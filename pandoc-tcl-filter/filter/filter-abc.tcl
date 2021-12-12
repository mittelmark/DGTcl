#' ---
#' title: "filter-abc.tcl documentation"
#' author: "Detlef Groth, Caputh-Schwielowsee, Germany"
#' date: 2021-12-12
#' dot:
#'     app: abcm2ps
#'     imagepath: images
#'     ext: svg
#' ---
#' 
# a simple pandoc filter using Tclthe script pandoc-tcl-filter.tcl 
# must be in the in the parent directory of the filter directory
#' 
#' ## Name
#' 
#' _filter-abc.tcl_ - Filter which can be used to display ABC music notatiion 
#' within a Pandoc processed document using the Tcl filter driver `pandoc-tcl-filter.tcl`. 
#' The command line application abcm2ps is required which can be ususally installed using your package manager.
#' 
#' ## Usage
#' 
#' The conversion of the Markdown documents via Pandoc should be done as follows:
#' 
#' ```
#' pandoc input.md --filter pandoc-tcl-filter.tcl -s -o output.html
#' ```
#' 
#' The file `filter-abc.tcl` is not used directly but sourced automatically by the `pandoc-tcl-filter.tcl` file.
#' If code blocks with the `.abc` marker are found, the contents in the code block is processed via the abcm2ps command line tool.
#' Conversion to png or pdf requires teh Python command line application cairosvg which can be usually installed as well with your package manager or using the Python package manager like this:
#' 
#' ```
#' pip3 install cairosvg --user
#' ```
#' 
#' The following options can be given via code chunks or in the YAML header.
#' 
#' > - app - the application to be called, usually abcm2ps, default: abcm2p
#'   - eval - should the code in the code block be evaluated, default: true
#'   - ext - file file extension, can be svg, png, pdf, default: svg
#'   - fig - should a figure be created, default: true
#'   - imagepath - output imagepath, default: images
#'   - include - should the created image be automatically included, default: true
#'   - results - should the output of the command line application been shown, should be show or hide, default: hide
#' 
#' The options results, evalm fig, should be normally not used, they are here just for 
#' compatibility reasons with the other filters.
#' 
#' To change the defaults the YAML header can be used. Here an example to change the 
#' default application to an other abcm2ps executable and the output to png.
#' 
#' ```
#'  ----
#'  title: "filter-abc.tcl documentation"
#'  author: "Detlef Groth, Caputh-Schwielowsee, Germany"
#'  date: 2021-12-12
#'  dot:
#'      app: abcm2ps-new
#'      imagepath: nfigures
#'      ext: png
#'  ----
#' ```
#'
#' ## Examples
#' 
#' Here an example for a simple Jig score.
#' 
#' ```{.abc}
#' X:1
#' T:The Legacy Jig
#' M:6/8
#' L:1/8
#' R:jig
#' K:G
#' GFG BAB | gfg gab | GFG BAB | d2A AFD |
#' GFG BAB | gfg gab | age edB |1 dBA AFD :|2 dBA ABd |:
#' efe edB | dBA ABd | efe edB | gdB ABd |
#' efe edB | d2d def | gfe edB |1 dBA ABd :|2 dBA AFD |]
#' ```
#' 
#' Using the option `{.abc results="hide"}` the output of the command line tool can be hidden.
#' 
#' ```{.abc results="hide"}
#' X: 3
#' T: Amazing Grace
#' R: waltz
#' M: 3/4
#' L: 1/8
#' K: Dmaj
#' V:1
#' Ad|"D"d4 fe/d/|"D"f4 fe|"G"d4 B2|"D"A4 Ad|
#' V:2
#' d2|A4 dB/A/|d4 AB|B4 d2|f4 df|
#' V:1
#' "Bm"d4 fe/d/|"E7" f4 ef|"Asus" a6|"A/G"a4 fa||
#' V:2
#' f4 dB/A/|B4 Bd|d6|c4 df||
#' V:1
#' "D"a4 fe/d/|"D"f4 fe|"G"d4 B2|"D"A4 Ad|
#' V:2
#' f4 dB/A/|d4 AB|B4 d2|f4 df|
#' V:1
#' "Bm"d4 fe/d/|"E7"f4 "G/A"e2|"D" d6|"D"D4||
#' V:2
#' f4 dB/A/|B4 G2|F6|F4||
#' ```
#' 
#' ## See also:
#' 
#' * [pandoc-tcl-filter Readme](../Readme.html)
#' 


proc filter-abc {cont dict} {
    global n
    incr n
    set def [dict create results show eval true fig true width 400 height 400 \
             include true imagepath images app abcm2ps label null ext svg]
    set dict [dict merge $def $dict]
    if {[auto_execok [dict get $dict app]] eq ""} {
        return [list "Error: This filter requires the command line tool abcm2ps - please install it!" ""]
    }
    set ret ""
    set owd [pwd] 
    if {[dict get $dict label] eq "null"} {
        set fname [file join $owd [dict get $dict imagepath] abc-$n]
    } else {
        set fname [file join $owd [dict get $dict imagepath] [dict get $dict label]]
    }
    if {![file exists [file join $owd [dict get $dict imagepath]]]} {
        file mkdir [file join $owd [dict get $dict imagepath]]
    }
    set out [open $fname.abc w 0600]
    puts $out $cont
    close $out
    # TODO: error catching
    set res [exec [dict get $dict app] -g $fname.abc -O test.svg]
    file rename -force test001.svg $fname.svg
    if {[dict get $dict ext] in [list "pdf" "png"]} {
        if {[auto_execok cairosvg] eq ""} {
            return [list "Error: pdf and png conversion needs cairosvg, please install cairosvg https://www.cairosvg.org !" ""]
        }
    }
    if {[dict get $dict ext] eq "pdf"} {
        exec cairosvg $fname.svg -o $fname.pdf -W [dict get $dict width] -H [dict get $dict height]
    } elseif {[dict get $dict ext] eq "png"} {
        exec cairosvg $fname.svg -o $fname.png -W [dict get $dict width] -H [dict get $dict height]
    } elseif {[dict get $dict ext] ne "svg"} {
        set res "Error unkown extension name valid values are svg, pdf, png"
    }
    if {[dict get $dict results] eq "show"} {
        # should be usually empty
        set res $res
    } else {
        set res ""
    }
    set img ""
    if {[dict get $dict fig]} {
        if {[dict get $dict include]} {
            set img $fname.[dict get $dict ext]
        }
    }
    return [list $res $img]
}
