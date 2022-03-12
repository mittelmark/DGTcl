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
#' ------
#' 
#' ```{.tcl results="asis" echo=false}
#' include header.md
#' ```
#' 
#' ------
#'
#' ## Name
#' 
#' _filter-pic.tcl_ - Filter which can be used to display pic files within a Pandoc processed
#' document using the Tcl filter driver `pandoc-tcl-filter.tapp`. 
#' 
#' ## Usage
#' 
#' The conversion of the Markdown documents via Pandoc should be done as follows:
#' 
#' ```
#' pandoc input.md --filter pandoc-tcl-filter.tapp -s -o output.html
#' ```
#' 
#' The file `filter-pic.tcl` is not used directly but sourced automatically by the `pandoc-tcl-filter.tcl` file.
#' If code blocks with the `.pic` marker are found, the contents in the code block is processed 
#' via the *pic2graph* diagram tool [https://man7.org/linux/man-pages/man1/pic2graph.1.html](https://man7.org/linux/man-pages/man1/pic2graph.1.html) which converts
#' PIC files, see [https://en.wikipedia.org/wiki/PIC_(markup_language)](https://en.wikipedia.org/wiki/PIC_(markup_language)) into some graphics format like png or other file formats which can be converted by the the ImageMagick tool *convert*. 
#' 
#' Alternatively you can use as well the dpic command line application which supports native PDF, SVG and TikZ-LaTeX output. 
#' The sources for this application can be found here [https://gitlab.com/aplevich/dpic](https://gitlab.com/aplevich/dpic).
#' 
#' The following options can be given via code chunks or in the YAML header.
#' 
#'   - app - the application to process the pic code, usually pic2graph or dpic, default: pic2graph
#'   - ext - file file extension, can be png or pdf for pic2graph and pdf, svg and tikz for dpic, default: png
#'   - imagepath - output imagepath, default: images
#'   - include - should the created image be automatically included, default: true
#'   - results - should the output of the command line application been shown, should be show or hide, default: hide
#'   - eval - should the code in the code block be evaluated, default: true
#'   - fig - should a figure be created, default: true
#' 
#' To change the defaults the YAML header can be used. Here an example to change the 
#' default the image output path to nfigures, the default file format to svg and the application to dpic.
#' 
#' ```
#'  ----
#'  title: "filter-pic example"
#'  author: "Detlef Groth, Caputh-Schwielowsee, Germany"
#'  date: 2021-11-18
#'  pic:
#'      app: dpic
#'      imagepath: nfigures
#'      ext: svg
#'  ----
#' ```
#'
#' ## Examples
#' 
#' Let's start with the usual "Hello World!" script:
#'
#' ``` 
#'     ```{.pic}
#'     box wid 1.2 "Hello World!" fill 0.3;
#'     ```
#' ```
#'
#' and here the output:
#' 
#' ```{.pic}
#' box wid 1.2 "Hello World!" fill 0.3;
#' ```
#' 
#' Here some simple basic shapes:
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
#' Let's finish with an example for filled grey backgrounds:
#' 
#' ```{.pic}
#' circle "circle" rad 0.5 fill 0.3; arrow ;
#' ellipse "ellipse" wid 1.4 ht 1 fill 0.1 ; line;
#' box wid 1 ht 1 fill 0.05 "A";
#' spline;
#' box wid 0.4 ht 0.4 fill 0.05 "B";
#' arc;
#' box wid 0.2 ht 0.2 fill 0.05 "C";
#' ```
#' 
#' There is an other implementation of the PIC language, dpic which supports direct PDF, TeX and SVG output.
#' Here an example for the dpic application [https://gitlab.com/aplevich/dpic/](https://gitlab.com/aplevich/dpic/):
#' 
#' ```
#'      ```{.dpic ext=svg}
#'      [
#'      box dashed wid 1.2 "Hello World" ; move ;
#'      circle "circle" rad 0.5 fill 0.7; move ; arrow ; move ; 
#'      ellipse "ellipse" wid 1.4 ht 1 fill 0.8 ; 
#'      ] scaled 1.2
#'      ```
#' ```
#' 
#' Here is the output:
#'
#' ```{.dpic ext=svg}
#' [
#' box dashed wid 1.2 "Hello World" ; move ;
#' circle "circle" rad 0.5 fill 0.7; move ; arrow ; move ; 
#' ellipse "ellipse" wid 1.4 ht 1 fill 0.8 ; 
#' ] scaled 1.2
#' ```
#' 
#' Dpic understands PIC syntax but offers other output formats such as TikZ-LaTeX, PDF, SVG.
#' 
#' ## See also:
#' 
#' * [Unix Text Processing](https://www.oreilly.com/library/view/unix-text-processing/9780810462915/Chapter10.html)
#' * [Gnu PIC manual](https://pikchr.org/home/uv/gpic.pdf)
#' * [Dpic by Dwight Aplevich](https://gitlab.com/aplevich/dpic/)
#' * [Pikchr filter](filter-pik.html)
#' * [pandoc-tcl-filter Readme](../Readme.html)
#' * [pandoc-tcl-filter documentation](../pandoc-tcl-filter.html)
#' 

proc filter-dpic {cont dict} {
    global n
    incr n
    set owd [pwd]
    set def [dict create results show eval true fig true \
             include true imagepath images app dpic label null \
             ext svg border 15 density 150 background white]
    set dict [dict merge $def $dict]
    if {[auto_execok [dict get $dict app]] eq ""} {
        return [list "Error: This filter requires the command line tool dpic https://gitlab.com/aplevich/dpic - please install it!" ""]
    }
    if {[dict get $dict label] eq "null"} {
        set fname [file join $owd [dict get $dict imagepath] pic-$n]
    } else {
        set fname [file join $owd [dict get $dict imagepath] [dict get $dict label]]
    }
    if {![file exists [file join $owd [dict get $dict imagepath]]]} {
        file mkdir [file join $owd [dict get $dict imagepath]]
    }
    set out [open $fname.pic w 0600]
    puts $out ".PS"
    puts $out $cont
    puts $out ".PE"
    close $out
    set formats [dict create pdf -d tikz -f svg -v tex ""]
    if {[catch {
    set res [exec -ignorestderr cat $fname.pic | [dict get $dict app] \
             [dict get $formats [dict get $dict ext]] 2> /dev/null > $fname.[dict get $dict ext]]
    }]} {
       return [list $::errorInfo ""]    
    }
    if {[dict get $dict results] eq "show"} {
        # should be usually empty
        set res $res
    } else {
        set res ""
    }
    if {[dict get $dict ext] ni [list "pdf" "svg" "tikz" "tex"]} {
        return [list "Error: unkown extension name '[dict get $dict ext]', valid values are pdf, svg, tikz, tex" ""]
    }
    set img ""
    if {[dict get $dict fig]} {
        if {[dict get $dict include]} {
            set img $fname.[dict get $dict ext]
        }
    }
    return [list $res $img]
}
proc filter-pic {cont dict} {
    set def [dict create results show eval true fig true width 0 height 0 \
             include true imagepath images app pic2graph label null ext png \
             border 15 density 150 background white]
    set dict [dict merge $def $dict]
    if {[regexp {^dpic} [dict get $dict app]]} {
        return [filter-dpic $cont $dict]
    }
    global n
    incr n

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
    if {[catch {
    set res [exec -ignorestderr cat $fname.pic | [dict get $dict app] -density [dict get $dict density] \
             -format [dict get $dict ext] -background [dict get $dict background] \
             -bordercolor [dict get $dict background] -alpha off -colorspace RGB \
             -border [dict get $dict border] > $fname.[dict get $dict ext]]
    }]} {
        return [list $::errorInfo ""]
    }
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
