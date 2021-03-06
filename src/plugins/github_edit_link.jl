export GithubEditLink

struct GithubEditLink
  template::String
  reponame::String
  function GithubEditLink(reponame::String)
    default_template = """
    <br/>
    <a href="{github_link}" target="_blank">Edit This Page</a>
    <br/>
    """
    return new(default_template,reponame)
  end
end

function process_html(G::GithubEditLink,
                      html::AbstractString,
                      fileinfo::FileInfo;
                      args...)
  link = "https://github.com/$(G.reponame)/edit/master/"*fileinfo["source_filename"]
  lhtml = replace(G.template,r"{github_link}" => link)
  return html*lhtml
end
