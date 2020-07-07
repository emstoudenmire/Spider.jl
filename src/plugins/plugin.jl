export SpiderPlugin,
       process_source!,
       process_html

abstract type SpiderPlugin end

function process_source!(P::SpiderPlugin,
                         source::AbstractString,
                         fileinfo::FileInfo;
                         args...)
  return source
end

function process_html(P::SpiderPlugin,
                      html::AbstractString,
                      fileinfo::FileInfo;
                      args...)
  return html
end
