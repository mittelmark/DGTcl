#' ---
#' title: "filter-eqn.tcl documentation"
#' author: "Detlef Groth, Caputh-Schwielowsee, Germany"
#' date: 2021-11-20
#' pik:
#'     app: eqn2graph
#'     imagepath: images
#'     ext: png
#' ---
# a simple pandoc filter using Tcl
# the script pandoc-tcl-filter.tcl 
# must be in the in the parent directory of the filter directory
#' 
#' ## Name
#' 
#' _filter-eqn.tcl_ - Filter which can be used to render eqn data within a Pandoc processed
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
#' The file `filter-eqn.tcl` is not used directly but sourced automatically by the `pandoc-tcl-filter.tcl` file.
#' If code blocks with the `.eqn` marker are found, the contents in the code block is processed 
#' via the *eqn2graph* equation tool [https://man7.org/linux/man-pages/man1/eqn2graph.1.html](https://man7.org/linux/man-pages/man1/eqn2graph.1.html) which converts
#' convert an eqn equation into a cropped PGN image, see [https://en.wikipedia.org/wiki/Eqn_(software)](https://en.wikipedia.org/wiki/Eqn_(software)) into some graphics format like png or other file formats which can be converted by the the ImageMagick tool *convert*.
#' 
#' The following options can be given via code chunks or in the YAML header.
#' 
#'   - app - the application to process the eqn code, default: eqn2graph
#'   - ext - file file extension, can be png or pdf, default: png
#'   - imagepath - output imagepath, default: images
#'   - include - should the created image be automatically included, default: true
#'   - results - should the output of the command line application been shown, should be show or hide, default: hide
#'   - eval - should the code in the code block be evaluated, default: true
#'   - fig - should a figure be created, default: true
#' 
#' To change the defaults the YAML header can be used. Here an example to change the 
#' default the image output path to nfigures
#' 
#' ```
#'  ----
#'  title: "filter-eqn example"
#'  author: "Detlef Groth, Caputh-Schwielowsee, Germany"
#'  date: 2021-11-20
#'  eqn:
#'      imagepath: nfigures
#'  ----
#' ```
#'
#' ## Examples
#' 
#' Here an example for a simple neat undirected graph:
#' 
#' ```{.eqn}
#' x = {-b +- sqrt{b sup 2 - 4ac}} over 2a
#' ```
#' 
#' ## See also:
#' 
#' * [pandoc-tcl-filter Readme](../Readme.html)
#' * [PIC filter](filter-pic.html)
#' * [LaTeX Math filter](filter-mtex.html)
#' 


proc filter-eqn {cont dict} {
    global n
    incr n
    set def [dict create results show eval true fig true width 0 height 0 \
             include true imagepath images app eqn2graph label null ext png \
             border 15 density 300 background white]
    set dict [dict merge $def $dict]
    if {[auto_execok eqn2graph] eq ""} {
        return [list "Error: This filter requires the command line tool eqn2graph, please install it!" ""]
    }
    set ret ""
    set owd [pwd] 
    if {[dict get $dict label] eq "null"} {
        set fname [file join $owd [dict get $dict imagepath] eqn-$n]
    } else {
        set fname [file join $owd [dict get $dict imagepath] [dict get $dict label]]
    }
    if {![file exists [file join $owd [dict get $dict imagepath]]]} {
        file mkdir [file join $owd [dict get $dict imagepath]]
    }
    set out [open $fname.eqn w 0600]
    puts $out $cont
    close $out
    # TODO: error catching
    set res [exec cat $fname.eqn | [dict get $dict app] -density [dict get $dict density] \
             -format [dict get $dict ext] -background [dict get $dict background] \
             -bordercolor [dict get $dict background] -alpha off -colorspace RGB \
             -border [dict get $dict border] > $fname.[dict get $dict ext]]
    if {[dict get $dict results] eq "show"} {
        # should be usually empty
        set res $res
    } else {
        set res ""
    }
    if {[dict get $dict ext] ni [list "pdf" "png"]} {
        return [list "Error: unkown extension name '[dict get $dict ext]', valid values are pdf, png" ""]
    }
    set img ""
    if {[dict get $dict fig]} {
        if {[dict get $dict include]} {
            set img $fname.[dict get $dict ext]
        }
    }
    return [list $res $img]
}
