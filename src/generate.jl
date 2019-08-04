export runSpider

function runSpider(plugins::SpiderPlugin...;
                   args...)
  #
  # Get input options
  #
  idir = getArg(args,:source_dir)
  odir = getArg(args,:output_dir)
  clear_odir = getArg(args,:clear_output_dir,false)
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
  if clear_odir
    run(`rm -f $odir/\*`)
  end

  for (root,dirs,files) in walkdir(idir)
    folderstring = root[4:end]
    curri = idir * folderstring
    curro = odir * folderstring

    folders = split(folderstring,"/")[2:end]

    for d in dirs
      run(`mkdir -p $curro/$d`)
    end

    for f in files
      (f[1]=='.') && continue
      (basename,extension) = split(f,".")
      ifname = curri*"/"*f
      if extension == "md"
        ofname = curro*"/"*basename*".html"
        mdstring = read(ifname,String)

        fileinfo = FileInfo()
        fileinfo["filename"] = f
        fileinfo["basename"] = basename
        fileinfo["extension"] = extension
        fileinfo["current_input_dir"] = curri
        fileinfo["current_output_dir"] = curro
        fileinfo["input_filename"] = ifname
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
        run(`cp $ifname $(curro*"/"*f)`)
      end
    end
  end
end
