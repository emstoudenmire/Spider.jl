export TOC

struct TOC <: SpiderPlugin
  token::String
  TOC() = new("<!--TOC-->")
  TOC(tok::String) = new(tok)
end

function process_source!(toc::TOC,
                         source::AbstractString,
                         fileinfo::FileInfo;
                         args...)
  toc_re = Regex(toc.token,"is")
  if occursin(toc_re,source)
    output = ""
    toc_html = "\n\n\n<div class=\"toc\">\n"
    toc_html *= "<b>Table of Contents</b><br/><br/>\n"
    lev = 1
    sec_re = r"\n(#+)(.*)"
    count = 1
    pos = 1
    for m in eachmatch(sec_re,source)
      nlev = length(m.captures[1])
      output *= source[pos:m.offset-1]
      if nlev > 1
        output *= " <a name=\"toc_$count\"></a>\n"
        name = strip(convert(String,m.captures[2]))
        name = replace(name,r"\\cite{.*?}" => "")
        name = replace(name,r"\\onlinecite{.*?}" => "")
        for n in 1:nlev toc_html *= "  " end
        if nlev == lev+1
          toc_html *= "<ul>"
        elseif nlev == lev-1
          toc_html *= "</ul>"
        end
        toc_html *= "<li><a href=\"#toc_$count\">$name</a></li>\n"
        lev = nlev
        count += 1
      end
      output *= m.match
      pos = m.offset+length(m.match)
    end
    #if has_refs 
    #  toc_html *= "<li><a href=\"#toc_refs\">References</a></li>\n"
    #end
    toc_html *= "</ul></div>\n\n\n"
    output *= source[pos:end]
    #println(toc_html)
    return replace(output,toc_re => toc_html)
  end
  return source
end
