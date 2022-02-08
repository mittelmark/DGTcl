#' ---
#' title: "filter-tdot.tcl documentation"
#' author: "Detlef Groth, Caputh-Schwielowsee, Germany"
#' date: 2021-12-15
#' tdot:
#'     imagepath: images
#'     ext: svg
#'     results: hide
#' ---
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
#' _filter-tdot.tcl_ - Filter which can be used to display dot/neato diagrams
#'  within a Pandoc processed document using the Tcl library [tdot](https://github.com/mittelmark/DGTcl).
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
#' The file `filter-tdot.tcl` is not used directly but sourced automatically by the `pandoc-tcl-filter.tcl` file.
#' If code blocks with the `.tdot` marker are found, the contents in the code block is 
#' processed via the Tcl interpreter using the embedded tdot library. 
#' The filter requires the installation of the GraphViz command line tools dot and neato. See here: 
#' 
#' The following options can be given via code chunks options or as defaults in the YAML header.
#' 
#' > - eval - should the code in the code block be evaluated, default: true
#'   - ext - file file extension, can be svg, png or pdf, default: svg
#'   - fig - should a figure be created, default: true
#'   - imagepath - output imagepath, default: images
#'   - include - should the created image be automatically included, default: true
#'   - label - the code chunk label used as well for the image name, default: null
#'   - results - should the output of the command line application been shown, should be show or hide, default: hide
#' 
#' To change the defaults the YAML header can be used. Here an example to change the 
#' the image output path to nfigures and the file extension to pdf 
#' (useful for Pdf output of the document as in LaTeX mode of pandoc). You should usually always change the 
#' options results: to hide.
#' 
#' ```
#'  ----
#'  title: "filter-tdot.tcl documentation"
#'  author: "Detlef Groth, Caputh-Schwielowsee, Germany"
#'  date: 2021-12-15
#'  tdot:
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
#'     ```{.tdot}
#'     tdot set type "strict digraph G"
#'     tdot graph margin=0.2 
#'     tdot node width=1 height=0.7 style=filled fillcolor=salmon shape=box
#'     tdot block rank=same Hello World
#'     tdot addEdge Hello -> World
#'     ```
#' ```
#' 
#' And here is the output:
#' 
#' ```{.tdot}
#' tdot set type "strict digraph G"
#' tdot graph margin=0.2 
#' tdot node width=1 height=0.7 style=filled fillcolor=salmon shape=box
#' tdot block rank=same Hello World
#' tdot addEdge Hello -> World
#' ```
#' 
#' Creating a new image needs cleanup of the current image using `tdot set code ""`, 
#' below we include a font which is only available on our local machine 
#' so we set the filetype to png like this: `{.tdot ext=png}`
#' 
#' ```{.tdot}
#' tdot set code ""
#' tdot graph margin=0.2
#' tdot node width=1 height=0.7 
#' tdot addEdge A -> B
#' ```
#' 
#' ## See also:
#' 
#' * [pandoc-tcl-filter Readme](../Readme.html)
#' 

package require tdot
interp create tdoti
set apath [tdoti eval { set auto_path } ]
foreach d $auto_path {
    if {[lsearch $apath $d] == -1} {
        tdoti eval  "lappend auto_path $d"
    }
}
tdoti eval "package require tdot"
proc filter-tdot {cont dict} {
    global n
    incr n
    set def [dict create results hide eval true fig true width 100 height 100 \
             include true label null imagepath images ext svg]
    set dict [dict merge $def $dict]
    set ret ""
    set owd [pwd] 
    if {[dict get $dict label] eq "null"} {
        set fname [file join $owd [dict get $dict imagepath] tdot-$n]
    } else {
        set fname [file join $owd [dict get $dict imagepath] [dict get $dict label]]
    }
    if {![file exists [file join $owd [dict get $dict imagepath]]]} {
        file mkdir [file join $owd [dict get $dict imagepath]]
    }
    # protect semicolons in attributes for ending a command
    set code [regsub -all {([^ ]);} $cont "\\1\\\\;"]
    if {[catch {
         set res2 [tdoti eval $code]
     }]} {
         set res2 "Error: [regsub {\n +invoked.+} $::errorInfo {}]"
     }

    if {[dict get $dict results] eq "show" && $res2 ne ""} {
        set res2 $res2 
    }  else {
        set res2 ""
    }
    set img ""
    set imgfile ${fname}.[dict get $dict ext]
    if {[dict get $dict fig]} {
        tdoti eval "tdot write $imgfile"
        if {[dict get $dict include]} {
            set img $imgfile
        } else {
            set img ""
        }
    }
    return [list $res2 $img]
}



