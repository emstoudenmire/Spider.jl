export BibTexRefs

#
# Example of a BibTex entry:
#
# @article{name,
#   author = {Lastname1, Firstname1 and Lastname2, Firstname2},
#   title = {Title of the article},
#   journal = {Fancy journal},
#   year = {1982},
#   volume = {36},
#   pages = {1000-1010},
#   url = {http://arxiv.org/abs/1801.00315},
#   doi = {10.1103/PhysRevB.90.155136}
#   }
#

mutable struct BTEntry
  ref_num::Int
  btype::String
  name::String
  authors ::Array{String,1}
  journal ::String
  title ::String
  doi::String
  url::String
  eprint::String
  year::String
  pages::String
  volume::String
  school::String

  function BTEntry(btype_::String,name_::String)
    return new(0,
               btype_,
               name_,
               [], #authors
               "", #journal
               "", #title
               "", #doi
               "", #url
               "", #eprint
               "",  #year
               "", #pages
               "",  #volume
               "")  #school
  end
end

function convertToMD(bt::BTEntry)::String
  md = ""
  if bt.btype == "phdthesis"
    for a in bt.authors
      md *= "$a: "
    end
    if bt.url != ""
      md *= "[_$(bt.title)_]($(bt.url))"
    else
      md *= "_$(bt.title)_"
    end
    md *= " (Doctoral Thesis)"
    if bt.school != ""
      md *= ", $(bt.school)"
    end
    if bt.year != ""
      md *= ", $(bt.year)"
    end
  else
    if bt.url != ""
      md *= "[_$(bt.title)_]($(bt.url))"
    else
      md *= "_$(bt.title)_"
    end
    for a in bt.authors
      md *= ", $a"
    end
    if bt.journal != ""
      md *= ", <i>"*bt.journal*"</i>"
      if bt.volume != ""
        md *= " <b>$(bt.volume)</b>"
      end
      if bt.pages != ""
        md *= ", $(bt.pages)"
      end
    end
    if bt.year != ""
      md *= " ($(bt.year))"
    end
    if bt.eprint != ""
      md *= ", "*bt.eprint
    end
  end
  return md
end

function getEntry(contents::String,start::Int)::String
  lev = 1
  n = start
  while (lev > 0 && n < length(contents))
    if (contents[n] == '{') lev += 1 end
    if (contents[n] == '}') lev -= 1 end
    #@show n,contents[n],lev
    n += 1
  end
  return contents[start:n-1]
end

function parseBibTex(fname::String)
  contents = open(fname) do file read(file,String) end

  entries = Dict{String,BTEntry}()

  btre = r"@(.+?){(.+?),"s

  function getField(re,source::String)::String
    if occursin(re,source)
      return strip(match(re,source).captures[1])
    end
    return ""
  end

  for m in eachmatch(btre,contents)
    btype = convert(String,m.captures[1])
    name = convert(String,m.captures[2])
    bt = BTEntry(btype,name)
    start = m.offset+length(m.match)
    entry = getEntry(contents,start)

    bt.btype = btype
    bt.title = getField(r"title\W*=\W*{(.+?)}"is,entry)
    bt.journal = getField(r"journal\W*=\W*{(.+?)}"is,entry)
    bt.volume = getField(r"volume\W*=\W*{(.+?)}"is,entry)
    bt.pages = getField(r"pages\W*=\W*{(.+?)}"is,entry)
    bt.year = getField(r"year\W*=\W*{(.+?)}"is,entry)
    bt.doi = getField(r"doi\W*=\W*{(.+?)}"is,entry)
    bt.eprint = getField(r"eprint\W*=\W*{(.+?)}"is,entry)
    bt.url = getField(r"url\W*=\W*{(.+?)}"is,entry)
    bt.school = getField(r"school\W*=\W*{(.+?)}"is,entry)

    all_authors = getField(r"author[s]*\W*=\W*{(.+?)}"is,entry)
    if all_authors != ""
      authors = split(all_authors,"and")
      for a in authors
        a = strip(a)
        rev = r"(\w+?), (.+)"
        if occursin(rev,a)
          m = match(rev,a)
          push!(bt.authors,"$(m.captures[2]) $(m.captures[1])")
        else
          push!(bt.authors,a)
        end
      end
    end

    entries[name] = bt
  end
  return entries
end

#export parseBibTex
#end

#
# Process citations
# 
function processCitations(html::String)::Tuple{String,Dict{String,Int}}
  cite_re = r"\\(cite|onlinecite){(.+?)}"
  citenums = Dict{String,Int}()
  res = String("")
  pos = 1
  match = false
  counter = 1
  for m in eachmatch(cite_re,html)
    match = true
    res *= html[pos:m.offset-1]
    names = split(convert(String,m.captures[2]),",")
    namenums = Tuple{Int,String,String}[]
    for name in names
      if haskey(citenums,name)
        num = citenums[name]
      else
        citenums[name] = counter
        num = counter
        counter += 1
      end
      push!(namenums,(num,name,convert(String,m.captures[1])))
    end
    sort!(namenums, by = x -> x[1])
    for i in 1:length(namenums)
      (num,name,cmd) = namenums[i]
      if cmd == "cite"
        res *= "<a class=\"citation\" href=\"#$(name)_$(num)\">[$num]</a>"
      elseif cmd == "onlinecite"
        res *= "<a class=\"online_citation\" href=\"#$(name)_$(num)\">$num</a>"
        if i < length(namenums) res *= ", " end
      end
    end
    pos = m.offset+length(m.match)
  end
  if !match 
    return (html,citenums)
  else
    res *= html[pos:end]
  end
  return (res,citenums)
end

function generateRefs(citenums,btentries)
  keys = Array{String,1}(undef,length(citenums))
  for (k,v) in citenums
    keys[v] = k
  end
  rhtml = "<a name=\"toc_refs\"></a>\n"
  rhtml *= "## References\n"
  for (n,k) in enumerate(keys)
    if haskey(btentries,k)
      bt = btentries[k]
      rhtml *= "$n. <a name=\"$(bt.name)_$(n)\"></a>"*convertToMD(bt)
      rhtml *= "\n"
    end
  end
  return rhtml
end

struct BibTexRefs <: SpiderPlugin
end

function processSource!(B::BibTexRefs,
                        source::AbstractString,
                        fileinfo::FileInfo;
                        args...)
  
  idir = fileinfo["current_input_dir"]
  basename = fileinfo["basename"]

  nsource = source
  btfile = idir*"/"*basename*".bib"
  has_refs = isfile(btfile)
  (nsource,citenums) = processCitations(nsource)
  if has_refs
    bt = parseBibTex(btfile)
    refmd = generateRefs(citenums,bt)
    #
    # TODO: add option to have references
    #       appear anywhere in document
    #       by finding and replacing a
    #       special keyword e.g. ==References==
    #       that is customizable
    #
    nsource *= refmd
  end
  return nsource
end
