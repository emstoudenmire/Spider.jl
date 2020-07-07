export ArxivLinks

struct ArxivLinks
end

function process_source!(A::ArxivLinks,
                         source::AbstractString,
                         fileinfo::FileInfo;
                         args...)
  link_re = r"(arxiv|cond-mat|quant-ph|math|math-ph|physics)[/:]\W*?([\d\.]+)"i
  res = ""
  pos = 1
  match = false
  for m in eachmatch(link_re,source)
    match = true
    res *= source[pos:m.offset-1]
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
    return source 
  else
    res *= source[pos:end]
  end
  return res
end
