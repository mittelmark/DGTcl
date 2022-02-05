#' ---
#' title: "filter-pic.tcl documentation"
#' author: "Detlef Groth, Caputh-Schwielowsee, Germany"
#' date: 2021-11-19
#' pik:
#'     app: pic2graph
#'     imagepath: images
#'     ext: pgn
#' ---
# a simple pandoc filter using Tcl
# the script pandoc-tcl-filter.tcl 
# must be in the in the parent directory of the filter directory
#' 
#' ## Name
#' 
#' _filter-pic.tcl_ - Filter which can be used to display pic files within a Pandoc processed
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
#' The file `filter-pic.tcl` is not used directly but sourced automatically by the `pandoc-tcl-filter.tcl` file.
#' If code blocks with the `.pic` marker are found, the contents in the code block is processed 
#' via the *pic2graph* diagram tool [https://man7.org/linux/man-pages/man1/pic2graph.1.html](https://man7.org/linux/man-pages/man1/pic2graph.1.html) which converts
#' PIC files, see [https://en.wikipedia.org/wiki/PIC_(markup_language)](https://en.wikipedia.org/wiki/PIC_(markup_language)) into some graphics format like png or other file formats which can be converted by the the ImageMagick tool *convert*.
#' 
#' The following options can be given via code chunks or in the YAML header.
#' 
#'   - app - the application to process the pic code, default: pic
#'   - ext - file file extension, can be png or pdf, default: png
#'   - imagepath - output imagepath, default: images
#'   - include - should the created image be automatically included, default: true
#'   - results - should the output of the command line application been shown, should be show or hide, default: hide
#'   - eval - should the code in the code block be evaluated, default: true
#'   - fig - should a figure be created, default: true
#' 
#' To change the defaults the YAML header can be used. Here an example to change the 
#' default the image output path to nfigures, teh default file format to png.
#' 
#' ```
#'  ----
#'  title: "filter-pic example"
#'  author: "Detlef Groth, Caputh-Schwielowsee, Germany"
#'  date: 2021-11-18
#'  pic:
#'      imagepath: nfigures
#'      ext: png
#'  ----
#' ```
#'
#' ## Examples
#' 
#' Here an example for a simple neat undirected graph:
#' 
#' ```{.pic}
#' circle "A"; line; box "B"
#' circle "A"; line; box "B 2"
#' move ; move ; move
#' {arrow down; move; "S" }
#' {arrow up; move; "N" }
#' {arrow left; move; "W" }
#' {arrow right; move; "E" }
#' ``` 
#' 
#' ## See also:
#' 
#' * [Unix Text Processing](https://www.oreilly.com/library/view/unix-text-processing/9780810462915/Chapter10.html)
#' * [pandoc-tcl-filter Readme](../Readme.html)
#' 


proc filter-pic {cont dict} {
    global n
    incr n
    set def [dict create results show eval true fig true width 0 height 0 \
             include true imagepath images app pic2graph label null ext png \
             border 15 density 150 background white]
    set dict [dict merge $def $dict]
    if {[auto_execok pic2graph] eq ""} {
        return [list "Error: This filter requires the command line tool pic2graph, please install it!" ""]
    }
    set ret ""
    set owd [pwd] 
    if {[dict get $dict label] eq "null"} {
        set fname [file join $owd [dict get $dict imagepath] pic-$n]
    } else {
        set fname [file join $owd [dict get $dict imagepath] [dict get $dict label]]
    }
    if {![file exists [file join $owd [dict get $dict imagepath]]]} {
        file mkdir [file join $owd [dict get $dict imagepath]]
    }
    set out [open $fname.pic w 0600]
    puts $out $cont
    close $out
    # TODO: error catching
    set res [exec cat $fname.pic | [dict get $dict app] -density [dict get $dict density] \
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
