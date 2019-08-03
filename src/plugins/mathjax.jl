#
# Process MathJax
# 
function processMathJax(html::String)
  mj_re = r"(\@\@.+?\@\@|\$.+?\$|\\begin{equation}.+?\\end{equation}|\\begin{equation\*}.+?\\end{equation\*})"s
  mjlist = String[]
  res = ""
  pos = 1
  match = false
  for m in eachmatch(mj_re,html)
    match = true
    res *= html[pos:m.offset-1]
    #res *= "\n\n<div>"*m.captures[1]*"</div>\n\n"
    push!(mjlist,m.captures[1])
    res *= "(MathJax$(length(mjlist)))"
    pos = m.offset+length(m.match)
  end
  if match 
    res *= html[pos:end]
  else
    res = html
  end
  return (res,mjlist)
end

function restoreMathJax(html::String,mjlist::Array{String,1})
  res = html
  for (n,mj) in enumerate(mjlist)
    res = replace(res,"(MathJax$n)" => mj)
  end
  return res
end
