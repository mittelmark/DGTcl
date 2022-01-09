#' ---
#' title: "filter-puml.tcl documentation"
#' author: "Detlef Groth, Caputh-Schwielowsee, Germany"
#' date: 2021-12-11
#' puml:
#'     app: plantuml
#'     imagepath: images
#'     ext: png
#' ---
#
# a simple pandoc filter using Tcl the script pandoc-tcl-filter.tcl 
# must be in the in the parent directory of the filter directory
#' 
#' ## Name
#' 
#' _filter-puml.tcl_ - Filter which can be used to display [PlantUML](https://plantuml.com/) 
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
#' The file `filter-puml.tcl` is not used directly but sourced automatically by the `pandoc-tcl-filter.tcl` file.
#' If code blocks with the `.puml` marker are found, the contents in the code block is processed via the PlantUML
#' command line tool. To install this command line tool you have to download the Java jar file from [https://plantuml.com/download](https://plantuml.com/download)
#' an create a shell script which runs the jar file using the Java runtime. Here an example of such a shell script:
#' 
#' ```
#' #!/bin/sh
#' # file plantuml - adapt the path to the jar file
#' java -jar /home/username/.local/bin/plantuml-1.2021.16.jar $@
#' ```
#' 
#' If this file is executable and in the PATH the filter should work.
#' 
#' > 
#'   - app - the application to be called, such as plantuml, so the name of your shell script which must be in the PATH, default: plantuml
#'   - eval - should the code in the code block be evaluated, default: true
#'   - ext - file file extension, can be svg, png, pdf, default: png
#'   - fig - should a figure be created, default: true
#'   - imagepath - output imagepath, default: images
#'   - include - should the created image be automatically included, default: true
#'   - results - should the output of the command line application been shown, should be show or hide, default: hide
#'   - theme - the image theme which can be used, should be one of the themes listed here: [https://the-lum.github.io/puml-themes-gallery/](https://the-lum.github.io/puml-themes-gallery/),  default: _none_
#' 
#' The options fig, results, include should be normally not used, they are here just for 
#' compatibility reasons with the other filters.
#' 
#' To change the defaults the YAML header can be used. Here an example to change the 
#' default command line application to plantuml-1.2020 and the image output path to nfigures
#' and the output image format to svg.
#' 
#' ```
#'  ----
#'  title: "filter-puml.tcl documentation"
#'  author: "Detlef Groth, Caputh-Schwielowsee, Germany"
#'  date: 2021-12-11
#'  mmd:
#'      app: plantuml-1.2020
#'      imagepath: nfigures
#'      ext: svg
#'  ----
#' ```
#'
#' ## Examples
#' 
#' Plantuml code must be include as follows:
#' 
#' ```
#'      ```{.puml option=value}
#'      plantuml code
#'      ```
#' ```
#' 
#' Here an example for a class diagram:
#' 
#' ```{.puml}
#' @startuml
#' abstract        abstract
#' abstract class  "abstract class"
#' annotation      annotation
#' circle          circle
#' ()              circle_short_form
#' class           class
#' diamond         diamond
#' <>              diamond_short_form
#' entity          entity
#' enum            enum
#' interface       interface
#' @enduml
#' ```
#' 
#' Next an example for a sequence diagram with the aws-orange theme ({.puml theme=aws-orange}):
#'
#' ```{.puml theme=aws-orange}
#' @startuml
#' left to right direction
#' actor Guest as g
#' package Professional {
#'   actor Chef as c
#'   actor "Food Critic" as fc
#' }
#' package Restaurant {
#'   usecase "Eat Food" as UC1
#'   usecase "Pay for Food" as UC2
#'   usecase "Drink" as UC3
#'   usecase "Review" as UC4
#' }
#' fc --> UC4
#' g --> UC1
#' g --> UC2
#' g --> UC3
#' @enduml
#' ```
#' 
#' Here an example for a mindmap:
#' 
#' ```{.puml}
#' @startmindmap
#' * root node
#' ** first child
#' *** grand child one
#' *** grand child two
#' ** second child
#' @endmindmap
#' ```
#' 
#' There is as style handwritten which might look useful at some situations. 
#' Here an example for a PlantUML mainframe.
#' 
#' ```{.puml}
#' @startsalt
#' skinparam handwritten true
#' mainframe This is a **mainframe**
#' {+
#'   Login    | | "MyName   "
#'   Passwod | | "****     "
#'   [Cancel] | | [  OK   ]
#' }
#' @endsalt
#' ```
#' The handwritten style can be applied as well to other diagram types, here a sequence diagram:
#' 
#' ```{.puml}
#' @startuml
#' skinparam handwritten true
#' skinparam monochrome  true
#' Alice->Bob: Hello Bob, how are you?
#' Note right of Bob: Bob thinks
#' Bob-->Alice: I am good thanks!
#' @enduml
#' ```
#' For more themes have a look here: [https://the-lum.github.io/puml-themes-gallery/](https://the-lum.github.io/puml-themes-gallery/) 
#' and for the complete documentation of the different diagram types have a look at the [PDF manual](http://plantuml.com/guide).
#' 
#' Finlly an even simpler example in case all you want is just a set of nice handwritten buttons:
#' 
#' ```{.puml}
#' @startuml
#' <style>
#' rectangle {
#'   FontSize 24
#'   FontStyle bold
#'   FontColor blue
#'   FontName Purisa
#' }
#' </style>
#' scale 400 width
#' skinparam handwritten true
#' rectangle "  Bob   " #ccddee 
#' rectangle " Alice  " #eeddcc 
#' rectangle " Benny  " #eeeecc
#' rectangle " <i>E=mc<sup>2</sup></i> " #eeeecc
#' @enduml
#' ```
#' 
#' And now a YAML visualization:
#'
#' ```{.puml}
#' @startyaml
#' <style>
#' yamlDiagram {
#'   FontSize 24
#'   FontName Purisa
#'   FontStyle bold
#'   node {
#'     Padding 20
#'   }
#' }
#' </style>
#' skinparam handwritten true
#' Key: G
#' Tempo: "96 BPM"
#' Capo: "3rd Fret"
#' @endyaml
#' ```

#' ## See also:
#' 
#' * [pandoc-tcl-filter Readme](../Readme.html)
#' * [filter-dot GraphViz Filter](filter-dot.html)
#' * [filter-pik Pikchr Filter](filter-pik.html)
#' * [filter-mmd Mermaid Filter](filter-mmd.html)


proc filter-puml {cont dict} {
    global n
    incr n
    set def [dict create results show eval true fig true  \
             include true imagepath images app plantuml label null ext png theme _none_]
    set dict [dict merge $def $dict]
    set ret ""
    if {[auto_execok [dict get $dict app]] == ""} {
        return [list "Error: Command line tool [dict get $dict app] is not installed!" ""]
    }
    set owd [pwd] 
    if {[dict get $dict label] eq "null"} {
        set fname [file join $owd [dict get $dict imagepath] puml-$n]
    } else {
        set fname [file join $owd [dict get $dict imagepath] [dict get $dict label]]
    }
    if {![file exists [file join $owd [dict get $dict imagepath]]]} {
        file mkdir [file join $owd [dict get $dict imagepath]]
    }
    set out [open $fname.puml w 0600]
    puts $out $cont
    close $out
    # TODO: error catching
    set res [exec [dict get $dict app]  -t[dict get $dict ext] -o [file dirname $fname] \
             -theme [dict get $dict theme] $fname.puml]
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
