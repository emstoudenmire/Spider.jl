export SpiderPlugin,
       processSource!,
       processHTML

abstract type SpiderPlugin end

function processSource!(P::SpiderPlugin,
                        source::AbstractString,
                        fileinfo::FileInfo;
                        args...)
  return source
end

function processHTML(P::SpiderPlugin,
                     html::AbstractString,
                     fileinfo::FileInfo;
                     args...)
  return html
end
