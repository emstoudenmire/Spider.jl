# Spider.jl

Spider is a static website generator written in Julia that is simple to use and extend.

By default, all Spider does is walk the directory tree of a specified source directory,
converting any Markdown (.md) files into html, and putting these files into the same
directory tree but underneath a specified output directory. Any other files besides
Markdown are just copied over unchanged.
