
#
# Process arxiv preprint links
# 
function processArxivLinks(html::String)
  link_re = r"(arxiv|cond-mat|quant-ph|math|math-ph|physics)[/:]\W*?([\d\.]+)"i
  res = ""
  pos = 1
  match = false
  for m in eachmatch(link_re,html)
    match = true
    res *= html[pos:m.offset-1]
    prefix = m.captures[1]
    number = m.captures[2]
    if lowercase(prefix) == "arxiv"
      res *= "arxiv:[$number](https://arxiv.org/abs/$number)"
    else
      nbprefix = replace(prefix,"-" => "&#8209;") #non-breaking hypen
      res *= "<span>$nbprefix/[$number](https://arxiv.org/abs/$prefix/$number)</span>"
    end
    pos = m.offset+length(m.match)
  end
  if !match 
    return html 
  else
    res *= html[pos:end]
  end
  return res
end

function processCondMatLinks(html::String)
  link_re = r"arxiv:\W*?(\d+?\.\d+)"
  res = ""
  pos = 1
  match = false
  for m in eachmatch(link_re,html)
    match = true
    res *= html[pos:m.offset-1]
    res *= "arxiv:["*m.captures[1]*"](https://arxiv.org/abs/"*m.captures[1]*")"
    pos = m.offset+length(m.match)
  end
  if !match 
    return html 
  else
    res *= html[pos:end]
  end
  return res
end
