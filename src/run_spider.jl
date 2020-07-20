export run_spider,
       process_source!,
       process_html

process_source!(P,source::AbstractString,
                fileinfo::FileInfo;args...) = source

process_html(P,html::AbstractString,
             ::FileInfo; args...) = html

function run_spider(plugins...;
                    args...)
  sdir = get_arg(args,:source_dir)
  odir = get_arg(args,:output_dir)
  clear_output_dir = get_arg(args,:clear_output_dir,false)
  header_filename = get_arg(args,:header_file,"")
  footer_filename = get_arg(args,:footer_file,"")

  mdparser = CommonMark.Parser()

  if !isempty(header_filename)
    header_file = open(header_filename) do file read(file,String) end
  else
    header_file = Nothing
  end

  if !isempty(footer_filename)
    footer_file = open(footer_filename) do file read(file,String) end
  else
    footer_file = Nothing
  end

  run(`mkdir -p $odir`)
  if clear_output_dir
    run(`rm -fr $odir`)
  end

  for (root,dirs,files) in walkdir(sdir)
    offset = findfirst("/",root)
    folderstring = ""
    if !isnothing(offset)
      folderstring = root[offset[1]:end]
    end
    currs = sdir * folderstring
    curro = odir * folderstring

    for d in dirs
      run(`mkdir -p $curro/$d`)
    end

    for f in files
      (f[1]=='.') && continue
      if occursin(".",f)
        (basename,extension) = split(f,".")
      else
        basename = f
        extension = ""
      end
      sfname = currs*"/"*f
      if extension == "md"
        ofname = curro*"/"*basename*".html"
        mdstring = read(sfname,String)

        fileinfo = FileInfo()
        fileinfo["filename"] = f
        fileinfo["basename"] = basename
        fileinfo["extension"] = extension
        fileinfo["current_source_dir"] = currs
        fileinfo["current_output_dir"] = curro
        fileinfo["source_filename"] = sfname
        fileinfo["output_filename"] = ofname
        fileinfo["folderstring"] = folderstring
        fileinfo["source_dir"] = sdir
        fileinfo["output_dir"] = odir

        for P in plugins
          mdstring = process_source!(P,mdstring,fileinfo;args...)
        end

        #
        # Using custom parser
        #
        #open("_tmp_file.md","w") do tf
        #  print(tf,mdstring)
        #end
        #sp_md_command = split(md_parser)
        #html = read(`$sp_md_command _tmp_file.md`,String)

        #
        # Using CommonMark.jl
        #
        ast = mdparser(mdstring)
        htmlstr = CommonMark.html(ast)

        for P in plugins
          htmlstr = process_html(P,htmlstr,fileinfo;args...)
        end

        open(ofname,"w") do of
          if !isnothing(header_file)
            print(of,header_file)
          end

          print(of,htmlstr)

          if !isnothing(footer_file)
            print(of,footer_file)
          end
        end

        #
        # If using custom parser
        #
        #run(`rm -f _tmp_file.md`)

      else
        run(`cp $sfname $(curro*"/"*f)`)
      end
    end
  end
end
