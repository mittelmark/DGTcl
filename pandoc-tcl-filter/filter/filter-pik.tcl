#' ---
#' title: "filter-pik.tcl documentation"
#' author: "Detlef Groth, Caputh-Schwielowsee, Germany"
#' date: 2021-11-18
#' pik:
#'     app: fossil
#'     imagepath: images
#'     ext: svg
#' ---
# a simple pandoc filter using Tcl
# the script pandoc-tcl-filter.tcl 
# must be in the in the parent directory of the filter directory
#' 
#' ## Name
#' 
#' _filter-pik.tcl_ - Filter which can be used to display Pikchr files within a Pandoc processed
#' document using the Tcl filter driver `pandoc-tcl-filter.tcl`. 
#' 
#' ## Usage
#' 
#' The conversion of the Markdown documents via Pandoc should be done as follows:
#' 
#' ```
#' pandoc input.md --filter pandoc-tcl-filter.tcl -s -o output.html
#' ```
#' 
#' The file `filter-pik.tcl` is not used directly but sourced automatically by the `pandoc-tcl-filter.tcl` file.
#' If code blocks with the `.pik` or '.pikchr' marker are found, the contents in the code block is 
#' processed via the fossil versioning system with support for Pikchr diagrams
#' since version 2.13 [https://fossil-scm.org](https://fossil-scm.org) or via the Pikchr diagram tool [https://pikchr.org/home/doc/trunk/](https://pikchr.org/home/doc/trunk/).
#' 
#' The following options can be given via code chunks or in the YAML header.
#' 
#'   - app - the application to process the pikchr code, should be fossil or pikchr default: fossil
#'   - ext - file file extension, can be svg, png, pdf, png and pdf needs the tool *cairosvg* [https://cairosvg.org/](https://cairosvg.org/), default: svg
#'   - imagepath - output imagepath, default: images
#'   - include - should the created image be automatically included, default: true
#'   - results - should the output of the command line application been shown, should be show or hide, default: hide
#'   - eval - should the code in the code block be evaluated, default: true
#'   - fig - should a figure be created, default: true
#'   - font - which alternative OTF font should be used, default: 'default'
#'   - fontsize - what should be the fontsize, 0 means that pikchr chooses the font size, default: 0  
#' 
#' To change the defaults the YAML header can be used. Here an example to change the 
#' default layout engine for _.pik_ code blocks with to _pikchr_ and the image output path to nfigures
#' 
#' ```
#'  ----
#'  title: "filter-pik example"
#'  author: "Detlef Groth, Caputh-Schwielowsee, Germany"
#'  date: 2021-11-120
#'  pik:
#'      app: pikchr
#'      imagepath: nfigures
#'      ext: png
#'  ## the .pikchr code blocks should be processed with fossil
#'  pikchr:
#'      app: fossil-2.17
#'      imagepath: nfigures
#'      ext: png
#'  ----
#' ```
#'
#' ## Examples
#' 
#' Here an example for a simple neat undirected graph:
#' 
#' ```{.pik}
#' arrow right 200% "Markdown" "Source"
#'    box rad 10px "Markdown" "Formatter" "(markdown.c)" fit
#'    arrow right 200% "HTML+SVG" "Output"
#'    arrow <-> down 70% from last box.s
#'    box same "Pikchr" "Formatter" "(pikchr.c)" fit
#' ```
#' 
#' ## See also:
#' 
#' * [pandoc-tcl-filter Readme](../Readme.html)
#' 

proc filter-pikchr {cont dict} {
    return [filter-pik $cont $dict]
}
proc filter-pik {cont dict} {
    global n
    incr n
    set def [dict create results show eval true fig true width 0 height 0 \
             include true imagepath images app pikchr label null ext svg font default fontsize 0]
    set dict [dict merge $def $dict]
    if {[auto_execok [dict get $dict app]] eq ""} {
        return [list "Error: This filter requires the command line tool pikchr https://pikchr.org/ - or fossil version 2.13 or newer - https://fossil-scm.org - please install it" ""]
    }
    set ret ""
    set owd [pwd] 
    if {[dict get $dict label] eq "null"} {
        set fname [file join $owd [dict get $dict imagepath] pik-$n]
    } else {
        set fname [file join $owd [dict get $dict imagepath] [dict get $dict label]]
    }
    if {![file exists [file join $owd [dict get $dict imagepath]]]} {
        file mkdir [file join $owd [dict get $dict imagepath]]
    }
    set out [open $fname.pik w 0600]
    puts $out $cont
    close $out
    # TODO: error catching
    if {[regexp {fossil} [dict get $dict app]]} {
        set res [exec [dict get $dict app] pikchr $fname.pik > $fname.svg]
    } else {
        set res [exec [dict get $dict app] --svg-only $fname.pik > $fname.svg]
    }
    if {[dict get $dict font] ne "default"} {
        if [catch {open $fname.svg r} infh] {
            return [list "Cannot open $fname.svg $infh" ""]
        } else {
            set out [open ${fname}-out.svg w 0600]
            set font [dict get $dict font]
            if {[dict get $dict fontsize]> 0} {
                set fontsize "font-size: [dict get $dict fontsize]px ;"
            } else {
                set fontsize ""
            }
            while {[gets $infh line] >= 0} {
                puts $out $line
                if {[regexp {<svg xmlns} $line]} {
                    puts $out "<defs>\n  <style type=\"text/css\">\n  text { font-family: $font ; $fontsize }\n  </style>\n</defs>\n"
                } 
                
            }
            close $infh
            close $out
            file rename -force ${fname}-out.svg $fname.svg
        }
    }
    if {[dict get $dict results] eq "show"} {
        # should be usually empty
        set res $res
    } else {
        set res ""
    }
    if {[dict get $dict ext] ni [list "pdf" "png" "svg"]} {
        return [list "Error: unkown extension name '[dict get $dict ext]', valid values are svg, pdf, png" ""]
    }
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
    set img ""
    if {[dict get $dict fig]} {
        if {[dict get $dict include]} {
            set img $fname.[dict get $dict ext]
        }
    }
    return [list $res $img]
}
