export runSpider

function runSpider(plugins::Vector{SpiderPlugin},
                   args::ArgDict)
  #
  # Get input options
  #
  idir = getArg(args,"source_dir")
  odir = getArg(args,"output_dir")
  clear_odir = getArg(args,"clear_output_dir",false)
  md_parser = getArg(args,"md_parser","python -m markdown ")

  header_prenav = open("header_prenav.html") do file read(file,String) end
  header_postnav = open("header_postnav.html") do file read(file,String) end
  footer = open("footer.html") do file read(file,String) end

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
      (base,ext) = split(f,".")
      ifname = curri*"/"*f
      if ext == "md"
        ofname = curro*"/"*base*".html"
        mdstring = read(ifname,String)

        for P in plugins
          mdstring = processSource(P,mdstring,base,ext,curri,args)
        end

        #
        # Plugin: TOC
        #
        mdstring = generateTOC(mdstring)

        #
        # Plugin: MathJax
        #
        (mdstring,mjlist) = processMathJax(mdstring)

        #
        # Plugin: WikiLinks
        #
        mdstring = processWikiLinks(mdstring,ifname)

        #
        # Plugin: ArxivLinks
        #
        mdstring = processArxivLinks(mdstring)

        open("_tmp_file.md","w") do tf
          print(tf,mdstring)
        end
        sp_md_command = split(md_parser)
        html = read(`$sp_md_command _tmp_file.md`,String)

        #
        # Restore HTML: MathJax
        #
        html = restoreMathJax(html,mjlist)

        open(ofname,"w") do of
          print(of,header_prenav)

          #
          # Put in backlinks
          # TODO: turn into plugin
          #
          if length(folders) > 0 || f!="index.md" #<-- don't show for main page
            print(of,"<tr><td></td><td class='backlinks'>")
            print(of,"<a href='/'>main</a>/")
            tfold = "/"
            for fold in folders[1:end-1]
              tfold *= fold * "/"
              print(of,"<a href=\"$tfold\">$fold</a>/")
            end
            if f!="index.md" 
              if length(folders) > 0 
                  fold = folders[end]
                  tfold *= fold * "/"
                  print(of,"<a href=\"$tfold\">$fold</a>/")
              end
              print(of,base)
            else
              (length(folders) > 0) && print(of,"$(folders[end])/")
            end
            print(of,"</td></tr>")
          end

          print(of,header_postnav)
          print(of,html)

          #
          # Plugin: Github Edit Footer Link
          #
          printEditFooter(of,ifname)

          print(of,footer)
        end
        run(`rm -f _tmp_file.md`)

      else
        run(`cp $ifname $(curro*"/"*f)`)
      end
    end
  end
end

function runSpider(args::ArgDict)
  runSpider(SpiderPlugin[],args)
end
