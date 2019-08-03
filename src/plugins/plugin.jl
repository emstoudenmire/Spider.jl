export SpiderPlugin,
       processSource,
       processHTML

abstract type SpiderPlugin end

function processSource(P::SpiderPlugin,
                       source::AbstractString,
                       basename::AbstractString,
                       ext::AbstractString,
                       idir::AbstractString,
                       args::ArgDict)
end

function processHTML(P::SpiderPlugin,
                     html::AbstractString,
                     basename::AbstractString,
                     ext::AbstractString,
                     idir::AbstractString,
                     args::ArgDict)
end
