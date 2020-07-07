export MathJax

mutable struct MathJax
  mjlist::Vector{String}
  MathJax() = new(Vector{String}(undef,0))
end

function process_source!(M::MathJax,
                         source::AbstractString,
                         fileinfo::FileInfo;
                         args...)
  resize!(M.mjlist,0) #reset replacement list for each file
  mj_re = r"(\@\@.+?\@\@|\$.+?\$|\\begin{equation}.+?\\end{equation}|\\begin{equation\*}.+?\\end{equation\*}|\\begin{align}.+?\\end{align})"s
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

function process_html(M::MathJax,
                      html::AbstractString,
                      fileinfo::FileInfo;
                      args...)
  res = html
  for (n,mj) in enumerate(M.mjlist)
    res = replace(res,"(MathJax$n)" => mj)
  end
  return res
end
