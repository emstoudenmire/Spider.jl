module Spider

using CommonMark

include("util.jl")
include("run_spider.jl")

include("plugins/bibtex.jl")
include("plugins/toc.jl")
include("plugins/mathjax.jl")
include("plugins/wikilinks.jl")
include("plugins/arxivlinks.jl")
include("plugins/backlinks.jl")
include("plugins/github_edit_link.jl")

end
