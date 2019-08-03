
function printEditFooter(of::IOStream,fname::String)
  template_edit_footer = open("template_edit_footer.html") do file read(file,String) end
  link = "https://github.com/TensorNetwork/tensornetwork.org/edit/master/"*fname
  out = replace(template_edit_footer,r"{github_link}" => link)
  print(of,out)
end
