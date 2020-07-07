export BackLinks

struct BackLinks <: SpiderPlugin
  postlinks::String

  function BackLinks()
    default_postlinks = """
              </table>
        </span> <!-- twelve columns -->

      </div> <!-- row -->
      <br/>
      <!--  </div> --> <!-- container -->

     <div class="row" style="margin-top: 2%">
    </div> <!-- class="row" -->
    """
    return new(default_postlinks)
  end

  BackLinks(default_pl::String) = new(default_pl)
end

function process_html(B::BackLinks,
                      html::AbstractString,
                      fileinfo::FileInfo;
                      args...)
  folders = split(fileinfo["folderstring"],"/")[2:end]
  filename = fileinfo["filename"]

  bhtml = ""
  if length(folders) > 0 || filename!="index.md" #<-- don't show for main page
    bhtml *= "<tr><td></td><td class='backlinks'>\n"
    bhtml *= "<a href='/'>main</a>/"
    tfold = "/"
    for fold in folders[1:end-1]
      tfold *= fold * "/"
      bhtml *= "<a href=\"$tfold\">$fold</a>/"
    end
    if filename!="index.md" 
      if length(folders) > 0 
          fold = folders[end]
          tfold *= fold * "/"
          bhtml *= "<a href=\"$tfold\">$fold</a>/"
      end
      bhtml *= fileinfo["basename"]
    else
      if length(folders) > 0
        bhtml*= "$(folders[end])/"
      end
    end
    bhtml *= "</td></tr>"
  end
  return bhtml*B.postlinks*html
end
