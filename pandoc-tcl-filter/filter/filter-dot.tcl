#' ---
#' title: "filter-dot.tcl documentation"
#' author: "Detlef Groth, Caputh-Schwielowsee, Germany"
#' date: 2021-12-12
#' dot:
#'     app: neato
#'     imagepath: images
#'     ext: png
#' ---
#' 
# a simple pandoc filter using Tcl the script pandoc-tcl-filter.tcl 
# must be in the in the parent directory of the filter directory
#' 
#' ## Name
#' 
#' _filter-dot.tcl_ - Filter which can be used to display GraphViz dot files within a Pandoc processed
#' document using the Tcl filter driver `pandoc-tcl-filter.tcl`. 
#' 
#' ## Usage
#' 
#' The conversion of the Markdown documents via Pandoc should be done as follows:
#' 
#' ```
#' pandoc input.md --filter pandoc-tcl-filter.tapp -s -o output.html
#' ```
#' 
#' The file `filter-dot.tcl` is not used directly but sourced automatically by the `pandoc-tcl-filter.tcl` file.
#' If code blocks with the `.dot` marker are found, the contents in the code block is processed via one of the Graphviz tools.
#' 
#' The following options can be given via code chunks or in the YAML header.
#' 
#' > - app - the application to be called, such as dot, neato, twopi etc default: dot
#'   - ext - file file extension, can be svg, png, pdf, default: svg
#'   - imagepath - output imagepath, default: images
#'   - include - should the created image be automatically included, default: true
#'   - results - should the output of the command line application been shown, should be show or hide, default: hide
#'   - eval - should the code in the code block be evaluated, default: true
#'   - fig - should a figure be created, default: true
#' 
#' The last three options should be normally not used, they are here just for 
#' compatibility reasons with the other filters.
#' 
#' To change the defaults the YAML header can be used. Here an example to change the 
#' default layout engine to neato and the image output path to nfigures
#' 
#' ```
#'  ----
#'  title: "filter-dot.tcl documentation"
#'  author: "Detlef Groth, Caputh-Schwielowsee, Germany"
#'  date: 2021-08-31
#'  dot:
#'      app: neato
#'      imagepath: nfigures
#'      ext: png
#'  ----
#' ```
#'
#' ## Examples
#' 
#' Below are a few samples for embedding code for the GraphViz tools dot and
#' neato into Markdown documents. The examples should work as well in other text
#' markup languages like LaTeX, Asciidoc etc. This filter requires a installation of the command line tools of the GraphViz tools.
#' 
#' Links: 
#' 
#' * GraphViz Homepage: [https://graphviz.org/](https://graphviz.org/)
#' * Dot guide: [https://graphviz.org/pdf/dotguide.pdf](https://graphviz.org/pdf/dotguide.pdf)
#' * Neato guide: [https://graphviz.org/pdf/neatoguide.pdf](https://graphviz.org/pdf/neatoguide.pdf)
#' 
#' ## Dot graph
#' 
#' ```
#'      ```{.dot label=digraph echo=true}
#'      digraph G {
#'        main -> parse -> execute;
#'        main -> init [dir=none];
#'        main -> cleanup;
#'        execute -> make_string;
#'        execute -> printf
#'        init -> make_string;
#'        main -> printf;
#'        execute -> compare;
#'      }
#'      ```
#' ```
#' 
#' Which will produce the following output:
#' 
#' ```{.dot label=digraph echo=true}
#' digraph G {
#'   main -> parse -> execute;
#'   main -> init [dir=none];
#'   main -> cleanup;
#'   execute -> make_string;
#'   execute -> printf
#'   init -> make_string;
#'   main -> printf;
#'   execute -> compare;
#' }
#' ```
#' 
#' ## Neato graphs
#' 
#' By using the argument `app=neato` in the code chunk header you can as well
#' create *neato* graphs. Here an example:
#' 
#' ```
#'       ```{.dot label=neato-sample app=neato}
#'       graph G {
#'           node [shape=box,style=filled,fillcolor=skyblue,
#'               color=black,width=0.4,height=0.4];
#'           n0 -- n1 -- n2 -- n3 -- n0;
#'       }
#'       ```
#' ```
#' 
#' Here the output.
#' 
#' ```{.dot label=neato-sample app=neato}
#' graph G {
#'     node [shape=box,style=filled,fillcolor=skyblue,
#'         color=black,width=0.4,height=0.4];
#'     n0 -- n1 -- n2 -- n3 -- n0;
#' }
#' ```
#' 
#' ## Document creation

#' Assuming that the file pandoc-tcl-filter.tapp is in your PATH, 
#' this document, a Tcl file with embedded Markdown and dot code
#' can be converted into a HTML file for instance using the command line:
#' 
#' ```
#' pandoc-tcl-filter.tapp filter-dot.tcl filter-dot.html -s --css mini.css
#' ```
#' 
#' Standard Markdown files with embedded dot code can be converted with the same command line:
#' 
#' ```
#' pandoc-tcl-filter.tapp sample.md sample.html -s 
#' ```
#' 
#' ## See also:
#' 
#' * [pandoc-tcl-filter Readme](../Readme.html)
#' * [pandoc-tcl-filter documentation](../pandoc-tcl-filter.html)
#' * [Mermaid filter](filter-mmd.html)
#' * [Pikchr filter](filter-pik.html)
#' * [PlantUML filter](filter-puml.html)
#' 


proc filter-dot {cont dict} {
    global n
    incr n
    set def [dict create results show eval true fig true width 400 height 400 \
             include true imagepath images app dot label null ext svg]
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
    set out [open $fname.dot w 0600]
    puts $out $cont
    close $out
    # TODO: error catching
    set res [exec [dict get $dict app] -T[dict get $dict ext] $fname.dot -o $fname.[dict get $dict ext]]
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
