module Spider

include("util.jl")
include("plugins/plugin.jl")
include("generate.jl")

include("plugins/bibtex.jl")
include("plugins/toc.jl")
include("plugins/mathjax.jl")
include("plugins/wikilinks.jl")
include("plugins/arxivlinks.jl")
include("plugins/github_edit_link.jl")

end
