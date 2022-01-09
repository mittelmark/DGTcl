#' ---
#' title: "filter-tsvg.tcl documentation"
#' author: "Detlef Groth, Caputh-Schwielowsee, Germany"
#' date: 2021-12-12
#' tsvg:
#'     imagepath: images
#'     ext: svg
#'     results: hide
#' ---
#' 
#' ## Name
#' 
#' _filter-tsvg.tcl_ - Filter which can be used to display SVG graphics
#'  within a Pandoc processed document using the Tcl library [tsvg](https://github.com/mittelmark/DGTcl).
#' together with the pandoc-tcl-filter application.
#' 
#' ## Usage
#' 
#' The conversion of the Markdown documents via Pandoc should be done as follows:
#' 
#' ```
#' pandoc input.md --filter pandoc-tcl-filter.tcl -s -o output.html
#' ```
#' 
#' The file `filter-tsvg.tcl` is not used directly but sourced automatically by the `pandoc-tcl-filter.tcl` file.
#' If code blocks with the `.tsvg` marker are found, the contents in the code block is 
#' processed via the Tcl interpreter using the embedded tsvg library. 
#' 
#' The following options can be given via code chunks options or as defaults in the YAML header.
#' 
#' > - eval - should the code in the code block be evaluated, default: true
#'   - ext - file file extension, can be svg, png or pdf, teh latter two require the command application 
#'     cairsvg to be installed default: svg
#'   - fig - should a figure be created, default: true
#'   - imagepath - output imagepath, default: images
#'   - include - should the created image be automatically included, default: true
#'   - label - the code chunk label used as well for the image name, default: null
#'   - results - should the output of the command line application been shown, should be show or hide, default: show
#' 
#' To change the defaults the YAML header can be used. Here an example to change the 
#' the image output path to nfigures and the file extension to pdf 
#' (useful for Pdf output of the document as in LaTeX mode of pandoc). You should usually always change the 
#' options results: to hide.
#' 
#' ```
#'  ----
#'  title: "filter-tsvg.tcl documentation"
#'  author: "Detlef Groth, Caputh-Schwielowsee, Germany"
#'  date: 2021-12-12
#'  tsvg:
#'      imagepath: nfigures
#'      ext: pdf
#'      results: hide
#'  ----
#' ```
#'
#' ## Examples
#' 
#' Here an example for a simple hello world image:
#' 
#' ```
#'     ```{.tsvg}
#'     tsvg set code "" ;# clear 
#'     tsvg circle -cx 50 -cy 50 -r 45 -stroke black -stroke-width 2 -fill green
#'     tsvg text -x 29 -y 45 Hello
#'     tsvg text -x 27 -y 65 World!
#      ```
#' ```
#' 
#' And here is the output:
#' 
#' ```{.tsvg}
#' tsvg set code "" ;# clear 
#' tsvg circle -cx 50 -cy 50 -r 45 -stroke black -stroke-width 2 -fill green
#' tsvg text -x 29 -y 45 Hello
#' tsvg text -x 27 -y 65 World!
#' ```
#' 
#' Creating a new image needs cleanup of the current image using `tsvg set code ""`, 
#' below we include a font which is only available on our local machine 
#' so we set the filetype to png like this: `{.tsvg ext=png}`
#' 
#' ```{.tsvg ext=png}
#' tsvg set code ""
#' tsvg set width 100
#' tsvg set height 60
#' tsvg rect -x 0 -y 0 -width 100 -height 100 -fill #F64935
#' tsvg text -x 20 -y 40 -style "font-size:24px;fill:blue;font-family: Alegreya;" tSVG
#' ```
#' 
#' ## See also:
#' 
#' * [pandoc-tcl-filter Readme](../Readme.html)
#' 

package require tsvg
interp create tsvgi
set apath [tsvgi eval { set auto_path } ]
foreach d $auto_path {
    if {[lsearch $apath $d] == -1} {
        tsvgi eval  "lappend auto_path $d"
    }
}
tsvgi eval "package require tsvg"
proc filter-tsvg {cont dict} {
    global n
    incr n
    set def [dict create results hide eval true fig true width 100 height 100 \
             include true label null imagepath images ext svg]
    set dict [dict merge $def $dict]
    set ret ""
    set owd [pwd] 
    if {[dict get $dict label] eq "null"} {
        set fname [file join $owd [dict get $dict imagepath] tsvg-$n]
    } else {
        set fname [file join $owd [dict get $dict imagepath] [dict get $dict label]]
    }
    if {![file exists [file join $owd [dict get $dict imagepath]]]} {
        file mkdir [file join $owd [dict get $dict imagepath]]
    }
    # protect semicolons in attributes for ending a command
    set code [regsub -all {([^ ]);} $cont "\\1\\\\;"]
    if {[catch {
         set res2 [tsvgi eval $code]
     }]} {
         set res2 "Error: [regsub {\n +invoked.+} $::errorInfo {}]"
     }

    if {[dict get $dict results] eq "show" && $res2 ne ""} {
        set res2 $res2 
    }  else {
        set res2 ""
    }
    if {[dict get $dict ext] ni [list "pdf" "png" "svg"]} {
        return [list "Error: unkown extension name '[dict get $dict ext]', valid values are svg, pdf, png" ""]
    }
    if {[dict get $dict ext] in [list "pdf" "png"]} {
        if {[auto_execok cairosvg] eq ""} {
            return [list "Error: pdf and png conversion needs cairosvg, please install cairosvg https://www.cairosvg.org !" ""]
        }
    }
    set img ""
    set imgfile ${fname}.[dict get $dict ext]
    if {[dict get $dict fig]} {
        tsvgi eval "tsvg write $imgfile"
        if {[dict get $dict include]} {
            set img $imgfile
        } else {
            set img ""
        }
    }
    return [list $res2 $img]
}



