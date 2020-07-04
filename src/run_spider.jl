export runSpider

function runSpider(plugins::SpiderPlugin...;
                   args...)
  sdir = getArg(args,:source_dir)
  odir = getArg(args,:output_dir)
  clear_output_dir = getArg(args,:clear_output_dir,false)
  md_parser = getArg(args,:md_parser,"python -m markdown ")
  header_filename = getArg(args,:header_file,"")
  footer_filename = getArg(args,:footer_file,"")

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

        for P in plugins
          mdstring = processSource!(P,mdstring,fileinfo;args...)
        end

        open("_tmp_file.md","w") do tf
          print(tf,mdstring)
        end
        sp_md_command = split(md_parser)
        html = read(`$sp_md_command _tmp_file.md`,String)

        for P in plugins
          html = processHTML(P,html,fileinfo;args...)
        end

        open(ofname,"w") do of
          if !isnothing(header_file)
            print(of,header_file)
          end

          print(of,html)

          if !isnothing(footer_file)
            print(of,footer_file)
          end
        end
        run(`rm -f _tmp_file.md`)

      else
        run(`cp $sfname $(curro*"/"*f)`)
      end
    end
  end
end
