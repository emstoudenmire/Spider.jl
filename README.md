# Spider.jl

![Tests](https://github.com/emstoudenmire/Spider.jl/workflows/Tests/badge.svg)

Spider is a static website generator written in Julia that requires minimal setup,
essentially no fixed conventions (e.g. no required directory structure), and is highly
extensible.

By default, all Spider does is walk the directory tree of a specified source directory,
converting any Markdown (.md) files into html, and putting the resulting .html files
into the same directory tree but underneath a specified output directory. 
Any other files not having the .md extension are copied over unchanged.

## Plugins

Spider allows development of plugins which have a wide latitude in terms of how they
work. A plugin is any Julia type `P` which overloads one or both of the following functions:

    process_source!(P,
                    source::AbstractString,
                    fileinfo::FileInfo;
                    args...)::String
     
    process_html(P,
                 html::AbstractString,
                 fileinfo::FileInfo;
                 args...)::String

The `process_source!` function is run first for each plugin in the order provided to the 
`run_spider` function. It is passed the plugin object `P`, the contents of the source file
as a string `source`, and a `FileInfo = Dict{String,String}` dictionary with useful information
about the file currently being processed. 

After `process_source!` is called for each plugin, the`process_html` function is 
run for each plugin. It is passed the plugin object `P`, the contents of the html file
resulting from parsing the source file, and a `FileInfo = Dict{String,String}` dictionary 
with useful information about the file currently being processed. 

