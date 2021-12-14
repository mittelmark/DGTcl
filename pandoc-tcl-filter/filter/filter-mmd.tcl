#' ---
#' title: "filter-mmd.tcl documentation"
#' author: "Detlef Groth, Caputh-Schwielowsee, Germany"
#' date: 2021-12-11
#' mmd:
#'     app: mmdc
#'     imagepath: images
#'     ext: png
#' ---
# a simple pandoc filter using Tcl
# the script pandoc-tcl-filter.tcl 
# must be in the in the parent directory of the filter directory
#' 
#' ## Name
#' 
#' _filter-mmd.tcl_ - Filter which can be used to display [Mermaid](https://mermaid-js.github.io) 
#' diagram files within a Pandoc processed document using the Tcl filter driver `pandoc-tcl-filter.tcl`. 
#' 
#' ## Usage
#' 
#' The conversion of the Markdown documents via Pandoc should be done as follows:
#' 
#' ```
#' pandoc input.md --filter pandoc-tcl-filter.tcl -s -o output.html
#' ```
#' 
#' The file `filter-mmd.tcl` is not used directly but sourced automatically by the `pandoc-tcl-filter.tcl` file.
#' If code blocks with the `.mmd` marker are found, the contents in the code block is processed via one of the Mermaid command line tool. To install this command line tool have 
#' a look at: [https://github.com/mermaid-js/mermaid-cli](https://github.com/mermaid-js/mermaid-cli)
#' 
#' The following options can be given via code chunks or in the YAML header.
#' 
#' > 
#'   - app - the application to be called, such as mmdc, default: mmdc
#'   - background - the background color such as transparent, salmon '#ccffff' (only used for png output), default: white
#'   - eval - should the code in the code block be evaluated, default: true
#'   - ext - file file extension, can be svg, png, pdf, default: svg
#'   - fig - should a figure be created, default: true
#'   - height - the image height, default: 600
#'   - imagepath - output imagepath, default: images
#'   - include - should the created image be automatically included, default: true
#'   - results - should the output of the command line application been shown, should be show or hide, default: hide
#'   - theme - the image them which can be used, should be either default, forest, dark, default: default
#'   - width - the image width, default: 800
#' 
#' The options fig, results, include should be normally not used, they are here just for 
#' compatibility reasons with the other filters.
#' 
#' To change the defaults the YAML header can be used. Here an example to change the 
#' default command line application to mmdc-8.10 and the image output path to nfigures
#' and the output image format to png.
#' 
#' ```
#'  ----
#'  title: "filter-mmd.tcl documentation"
#'  author: "Detlef Groth, Caputh-Schwielowsee, Germany"
#'  date: 2021-12-11
#'  mmd:
#'      app: mmdc-8.10
#'      imagepath: nfigures
#'      ext: png
#'  ----
#' ```
#'
#' ## Examples
#' 
#' Here an example for a simple flowchart:
#' 
#' ```{.mmd}
#' graph TD;
#'     A-->B;
#'     A-->C;
#'     B-->D;
#'     C-->D;
#' ```
#' 
#' Next an example for a sequence diagram with the forest theme and cornsilk background:
#'
#' ```{.mmd theme=forest background=cornsilk}
#' sequenceDiagram
#'     participant Alice
#'     participant Bob
#'     Alice->>John: Hello John, how are you?
#'     loop Healthcheck
#'         John->>John: Fight against hypochondria
#'     end
#'     Note right of John: Rational thoughts <br/>prevail!
#'     John-->>Alice: Great!
#'     John->>Bob: How about you?
#'     Bob-->>John: Jolly good!
#' ```
#' 
#' ## See also:
#' 
#' * [pandoc-tcl-filter Readme](../Readme.html)
#' * [GraphViz Filter](filter-dot.html)
#' * [Pikchr Filter](filter-pik.html)
#' * [PlantUML filter](filter-puml.html)
#' 


proc filter-mmd {cont dict} {
    global n
    incr n
    set def [dict create results show eval true fig true width 800 height 600 \
             include true imagepath images app mmdc label null ext svg theme default background white]
    set dict [dict merge $def $dict]
    set ret ""
    if {[auto_execok [dict get $dict app]] == ""} {
        return [list "Error: Command line tool [dict get $dict app] is not installed!" ""]
    }
    set owd [pwd] 
    if {[dict get $dict label] eq "null"} {
        set fname [file join $owd [dict get $dict imagepath] mmd-$n]
    } else {
        set fname [file join $owd [dict get $dict imagepath] [dict get $dict label]]
    }
    if {![file exists [file join $owd [dict get $dict imagepath]]]} {
        file mkdir [file join $owd [dict get $dict imagepath]]
    }
    set out [open $fname.mmd w 0600]
    puts $out $cont
    close $out
    # TODO: error catching
    set res [exec [dict get $dict app]  -i $fname.mmd -o $fname.[dict get $dict ext] \
             -w [dict get $dict width] -H [dict get $dict height] -t [dict get $dict theme] \
             -b [dict get $dict background]]
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
