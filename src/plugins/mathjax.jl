export MathJax

mutable struct MathJax <: SpiderPlugin
  mjlist::Vector{String}
  MathJax() = new(Vector{String}(undef,0))
end

function processSource!(M::MathJax,
                        source::AbstractString,
                        fileinfo::FileInfo;
                        args...)
  mj_re = r"(\@\@.+?\@\@|\$.+?\$|\\begin{equation}.+?\\end{equation}|\\begin{equation\*}.+?\\end{equation\*})"s
  res = ""
  pos = 1
  match = false
  for m in eachmatch(mj_re,source)
    match = true
    res *= source[pos:m.offset-1]
    #res *= "\n\n<div>"*m.captures[1]*"</div>\n\n"
    push!(M.mjlist,m.captures[1])
    res *= "(MathJax$(length(M.mjlist)))"
    pos = m.offset+length(m.match)
  end
  if match 
    res *= source[pos:end]
  else
    res = source
  end
  return res
end

function processHTML(M::MathJax,
                     html::AbstractString,
                     fileinfo::FileInfo;
                     args...)
  res = html
  for (n,mj) in enumerate(M.mjlist)
    res = replace(res,"(MathJax$n)" => mj)
  end
  return res
end
