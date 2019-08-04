
#
# Process wiki-style links
# 
function processWikiLinks(html::String,ifname::String)
  link_re = r"\[\[(.+?)\|(.*?)\]\]"
  sub_re = r"(.*?)(#.*)"
  missing_links = String[]
  res = ""
  pos = 1
  match = false
  for m in eachmatch(link_re,html)
    match = true
    res *= html[pos:m.offset-1]
    target = convert(String,m.captures[2])

    #If link has a "#" in it, split into target and sublink
    sublink = ""
    for sm in eachmatch(sub_re,target)
      target = convert(String,sm.captures[1])
      sublink = convert(String,sm.captures[2])
    end

    if isdir("src/"*target)
      res *= "["*m.captures[1]*"](/"*target*"/$sublink)"
    elseif isfile("src/"*target*".md")
      res *= "["*m.captures[1]*"](/"*target*".html$sublink)"
    else
      res *= "["*m.captures[1]*"](unknown_file)"
      push!(missing_links,target)
    end
    pos = m.offset+length(m.match)
  end
  if length(missing_links) > 0
    println("Missing/Incorrect Wiki Links in File $ifname:")
    for link in missing_links
      println("  $link")
    end
  end
  if !match 
    return html 
  else
    res *= html[pos:end]
  end
  return res
end