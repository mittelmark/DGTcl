#' ---
#' title: "filter-rplot.tcl documentation"
#' author: "Detlef Groth, Caputh-Schwielowsee, Germany"
#' date: 2021-11-29
#' dot:
#'     app: Rscript
#'     imagepath: figures
#'     ext: png
#' ---
#' 
#' ## Name
#' 
#' _filter-rplot.tcl_ - Filter which can be used to display R plots
#'  within a Pandoc processed document using the Tcl filter driver 
#' `pandoc-tcl-filter.tcl`. 
#' 
#' ## Usage
#' 
#' The conversion of the Markdown documents via Pandoc should be done as follows:
#' 
#' ```
#' pandoc input.md --filter pandoc-tcl-filter.tcl -s -o output.html
#' ```
#' 
#' The file `filter-rplot.tcl` is not used directly but sourced automatically by the `pandoc-tcl-filter.tcl` file.
#' If code blocks with the `.rplot` marker are found, the contents in the code block is 
#' processed via teh Rscript interpreter which must be on the path.
#' 
#' The following options can be given via code chunks or in the YAML header.
#' 
#' > - app - the application to be called, default: Rscript
#'   - ext - file file extension, can be png or pdf, default: png
#'   - imagepath - output imagepath, default: figures
#'   - include - should the created image be automatically included, default: true
#'   - results - should the output of the command line application been shown, should be show or hide, default: hide
#'   - eval - should the code in the code block be evaluated, default: true
#'   - fig - should a figure be created, default: true
#' 
#' The last three options should be normally not used, they are here just for 
#' compatibility reasons with the other filters.
#' 
#' To change the defaults the YAML header can be used. Here an example to change the 
#' default image output path to nfigures and the file extension to pdf (useful for Pdf output of the document)
#' 
#' ```
#'  ----
#'  title: "filter-rplot.tcl documentation"
#'  author: "Detlef Groth, Caputh-Schwielowsee, Germany"
#'  date: 2021-11-29
#'  dot:
#'      imagepath: nfigures
#'      ext: pdf
#'  ----
#' ```
#'
#' ## Examples
#' 
#' Here an example for a simple neat undirected graph:
#' 
#' ```{.rplot}
#' data(iris)
#' pairs(iris[,1:3],col=as.numeric(iris$species)+1)
#' ```
#' 
#' ## See also:
#' 
#' * [pandoc-tcl-filter Readme](../Readme.html)
#' 


proc filter-rplot {cont dict} {
    global n
    global rplotx
    if {[info exists rplotx]} {
        incr rplotx
    } else {
        set rplotx 0
    }
    incr n
    set def [dict create results show eval true fig true width 600 height 600 \
             include true imagepath images app Rscript label null ext png]
    set dict [dict merge $def $dict]
    set ret ""
    set owd [pwd] 
    if {[dict get $dict label] eq "null"} {
        set fname [file join $owd [dict get $dict imagepath] dot-$n]
    } else {
        set fname [file join $owd [dict get $dict imagepath] [dict get $dict label]]
    }
    if {![file exists [file join $owd [dict get $dict imagepath]]]} {
        file mkdir [file join $owd [dict get $dict imagepath]]
    }
    set out [open ${fname}.R w 0600]
    if {$rplotx == 0} {
        if {[file exists ".RData"]} {
            file delete .RData
        }
    }
    if {[file exists .RData]} {
        puts $out "load('.RData')"
    }
    if {[dict get $dict fig]} {
        set imgfile ${fname}.[dict get $dict ext]
        puts $out "[dict get $dict ext]('$imgfile' , width=[dict get $dict width] , height=[dict get $dict height]);"
        puts $out $cont
        puts $out "dev.off()"
    } else {
        puts $out $cont
    }
    puts $out "save.image(file='.RData')"
    close $out
    # TODO: error catching
    if {[dict get $dict eval]} {
        set res [exec [dict get $dict app] ${fname}.R]
    } else {
        set res ""
    }
    if {[dict get $dict results] eq "show"} {
        set res $res
    } else {
        set res ""
    }
    set img ""
    if {[dict get $dict fig]} {
        if {[dict get $dict include]} {
            set img $imgfile
        }
    }
    return [list $res $img]
}
