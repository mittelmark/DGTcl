---
title: pandoc-tcl-filter documentation - 0.7.0
author: Detlef Groth, Schwielowsee, Germany
date: 2022-01-22
tcl:
   echo: "true"
   results: show
---

## NAME

_pandoc-tcl-filter.tcl_ - filter application for the pandoc command line 
application to convert Markdown files into other formats. The filter allows you to embed Tcl code into your Markdown
documentation and offers a plugin architecture to add other command line filters easily using Tcl
and the `exec` command. As examples are given in the filter folder of the project:

* Tcl filter {.tcl}: `filter-tcl.tcl` [filter/filter-tcl.html](filter/filter-tcl.html)
* ABC music filter {.abc}: `filter-abc.tcl` [filter/filter-abc.html](filter/filter-abc.html)
* command line application filter {.cmd}: `filter-cmd.tcl` [filter/filter-abc.html](filter/filter-cmd.html)
* Graphviz dot filter {.dot}: `filter-dot.tcl` [filter/filter-dot.html](filter/filter-dot.html)
* EQN filter plugin for equations written in the EQN language {.eqn}: `filter-eqn` [filter/filter-eqn.html](filter/filter-eqn.html)
* Math TeX filter for single line equations {.mtex}: `filter-mtex.tcl` [filter/filter-mtex.html](filter/filter-mtex.html)
* Mermaid filter for diagrams {.mmd}: `filter-mmd.tcl` [filter/filter-mmd.html](filter/filter-mmd.html)
* Pikchr filter plugin for diagram creation {.pikchr}: `filter-pik.tcl` [filter/filter-pik.html](filter/filter-pik.html)
* PIC filter plugin for diagram creation (older version) {.pic}: `filter-pic.tcl` [filter/filter-pic.html](filter/filter-pic.html)
* pipe filter for R, Python and Octave {.pipe}: `filter-pipe.tcl` [filter/filter-pipe.html](filter/filter-pipe.html)
* PlantUMLfilter plugin for diagram creation {.puml}: `filter-puml.tcl` [filter/filter-puml.html](filter/filter-puml.html)
* R plot filter plugin for displaying plots in the R statistical language {.rplot}: `filter-rplot.tcl` [filter/filter-rplot.html](filter/filter-rplot.html)
* sqlite3 filter plugin to evaluate SQL code {.sqlite}: `filter-sqlite.tcl` [filter/filter-sqlite.html](filter/filter-sqlite.html)
* tcrd filter for music songs with chords {.tcrd}: `filter-tcrd.tcl` [filter/filter-tcrd.html](filter/filter-tcrd.html)
* tdot package filter {.tsvg}: `filter-tdot.tcl` [filter/filter-tdot.html](filter/filter-tdot.html)
* tsvg package filter {.tsvg}: `filter-tsvg.tcl` [filter/filter-tsvg.html](filter/filter-tsvg.html)

## SYNOPSIS 

```
# standalone application
pandoc-tcl-filter.tapp infile outfile ?options?
# as filter
pandoc infile --filter pandoc-tcl-filter.tapp ?options?
# as graphics user interface
pandoc-tcl-filter.tapp --gui
```

Where options for the filter and the standalone mode
are the usual pandoc options. For HTML conversion you should use for instance:

```
pandoc-tcl-filter.tapp infile.md outfile.html --css style.css -s --toc
```

## Code embedding
Embed code either inline or in form of code chunks like here (triple ticks):

``` 
    ```{.tcl}
    set x 4
    incr x
    set x
    ```
  
    Hello this is Tcl `tcl package provide Tcl`!
```

## Filter Overview 

The markers for the other filters are:

`{.abc}, `{.dot}`, `{.eqn}`, `{.mmd}`, `{.mtex}`, `{.pic}`,
`{.pikchr}, `{.puml}`, `{.rplot}`,`{.sqlite}` and `{.tsvg}`. 

For details on how to use them have a look at the manual page links on top.

You can combine all filters in one document  just by using the appropiate markers. 

Here an overview about the required tools to use a filter:

<center>

| filter | tool | svg | png | pdf | comment |
| ------ | ----- | ---- | ---- | ---- | ---- |
| .tcl   | tclsh   | tsvg | cairosvg | cairosvg | programming | 
| .abc   | abcm2ps | abcm2ps | cairosvg | cairosvg | music |
| .dot   | dot   | native | native | native | diagrams |
| .eqn   | eqn2graph | no | convert | no | math | 
| .mmd   | mermaid-cli (mmdc) | native | native | native | diagrams |
| .mtex  | latex  | dvisgm | dvipng | dvipdfm | math, diagrams, games |
| .pic   | pic2graph | no | convert | no | diagrams |
| .pik   | fossil    |  native | cairosvg | cairosvg | diagrams |
| .pipe  | R / python / octave |  native | native | native | Statistics, Programming |
| .puml  | plantuml  |  native | native | native | diagrams |
| .rplot | R         | native  | native | native | statistics, graphics |
| .tcrd  | tclsh       | no      | no    |  no | music, songs with chords |
| .tdot  | tclsh/dot   | native  | native |  native | diagrams |
| .tsvg  | tclsh       | native  | cairosvg | cairosvg | graphics |

</center>

The Markdown document within this file could be extracted and converted as follows:

```
 pandoc-tcl-filter.tapp pandoc-tcl-filter.tcl pandoc-tcl-filter.html \
   --css mini.css -s
```

## Example Tcl Filter

#### Tcl-filter

```
    ```{.tcl}
    set x 1
    puts $x
    ```
```

And here the output:

```{.tcl}
set x 1
puts $x
```

Does indented code blocks works as well?

> ```{.tcl}
  set x 2
  puts $x
>  ```

> Yes, since version 0.7.0!!

There is as well the possibility to inline Tcl code like here:

```
This document was processed using Tcl `tcl set tcl_patchLevel`!
```

will produce:

This document was processed using Tcl `tcl set tcl_patchLevel`!

This works as well in nested structures like lists or quotes.

> This document was processed using Tcl `tcl set tcl_patchLevel`!

> - This document was processed using Tcl `tcl set tcl_patchLevel`!

## Filter - Plugins

The pandoc-tcl-filter.tcl application allows to create custom filters for other 
command line application quite easily. The Tcl files has to be named `filter-NAME.tcl`
where NAME hast to match the code chunk marker. Below an example:

```
   ` ``{.dot label=dotgraph}
   digraph G {
     main -> parse -> execute;
     main -> init;
     main -> cleanup;
     execute -> make_string;
     execute -> printf
     init -> make_string;
     main -> printf;
     execute -> compare;
   }

   ![](dotgraph.svg)
   ` ``
```

The main script `pandoc-tcl-filter.tcl` evaluates if in the same folder as the script is,
if there any other files named `filter/filter-NAME.tcl` and sources them. In case of the dot
filter the file is named `filter-dot.tcl` and its filter function `filter-dot` is 
executed. Below is the simplified code: of this file `filter-dot.tcl`:

```{.tcl eval=false results="hide"}
# a simple pandoc filter using Tcl
# the script pandoc-tcl-filter.tcl 
# must be in the same filter directoy of the pandoc-tcl-filter.tcl file
proc filter-dot {cont dict} {
    global n
    incr n
    set def [dict create app dot results show eval true fig true 
             label null ext svg width 400 height 400 \
             include true imagepath images]
    # fuse code chunk options with defaults
    set dict [dict merge $def $dict]
    set ret ""
    if {[dict get $dict label] eq "null"} {
        set fname dot-$n
    } else {
        set fname [dict get $dict label]
    }
    # save dot file
    set out [open $fname.dot w 0600]
    puts $out $cont
    close $out
    # TODO: error catching
    set res [exec [dict get $dict app] -Tsvg $fname.dot -o $fname.svg]
    if {[dict get $dict results] eq "show"} {
        # should be usually empty
        set res $res
    } else {
        set res ""
    }
    set img ""
    if {[dict get $dict fig]} {
        if {[dict get $dict include]} {
            set img $fname.svg
        }
    }
    return [list $res $img]
}
```

Using the label and the option `include=false` we could create an image link manually using Markdown syntax. The 
The image filename should be then images/label.svg for instance.

## Dot Example

Here a longer dot-example where the code is include in 

```{.dot}
digraph G {
  margin=0.1;
  node[fontname="Linux Libertine";fontsize=18];
  node[shape=box,style=filled;fillcolor=skyblue,width=1.2,height=0.9];    
  { rank=same; Rst[group=g0,fillcolor=salmon] ; 
    Docx [group=g1,fillcolor=salmon]
  }
  { rank=same; Md[group=g0,fillcolor=salmon]  ; 
    pandoc ; AST1 ; filter[fillcolor=cornsilk] ; AST2 ; pandoc2;  
    Html[group=g1,fillcolor=salmon] 
  }
  { rank=same; Tex[group=g0,fillcolor=salmon] ; 
    Pdf[group=g1,fillcolor=salmon]; filters[fillcolor=cornsilk]; 
  }
  node[fillcolor=cornsilk]; 
  { rank=same; dot ; eqn; mtex; pic; pik; rplot; tsvg;}
  Rst -> pandoc -> AST1 -> filter -> AST2 -> pandoc2 -> Html ;
  Md -> pandoc;
  Tex -> pandoc;
  Rst -> Md -> Tex -> dot[style=invis] ;
  pandoc2 -> Docx;
  pandoc2 -> Pdf ;
  Docx -> Html -> Pdf -> tsvg[style=invis];
  pandoc2[label=pandoc];
  filter[label="pandoc-\ntcl-\nfilter"];
  filter->filters;
  filters -> dot ;
  filters -> eqn ;
  filters -> mtex;
  filters -> pic ;
  filters -> pik ; 
  filters -> rplot;
  filters -> tsvg; 
}
```

## Creating Markdown Code

Since version 0.5.0 it is as well possible to create Markup code within code blocks and to return it. 
To achieve this you to set use code chunk option results like this: `results="asis"` -
which should be usually used together with `echo=false`. Here an example:

``` 
     ```{.tcl echo=false results="asis"}
     return "**this is bold** and _this is italic_ text!"
     ```    
```

which gives this output:

```{.tcl echo=false results="asis"}
return "**this is bold** and _this is italic_ text!"

``` 

This can be as well used to include other Markup files. Here an example:

```
    ```{.tcl results="asis"}
    include tests/inc.md
    ```
```

And here is the result:

```{.tcl results="asis"}
include tests/inc.md
```

Please note, that currently no filters are applied on the included files. 
You should process them before using the pandoc filters and choose output format Markdown to include them later
in your master document.

To just show some file content as it is, remove the results="asis", 
this can be as well useful to display some source code, let's here simply show here the content of *tests/inc.md* without interpreting it as Markdown in a source code block:

```
    ```{.tcl results="show"}
    include tests/inc.md
    ```
```

And here is the result:

```{.tcl results="show"}
include tests/inc.md
```

## Documentation

To use this pipeline and to create pandoc-tcl-filter.html out of the code documentation 
in pandoc-tcl-filter.tapp your command in the terminal is still just:

```
pandoc-tcl-filter.tapp pandoc-tcl-filter.tcl pandoc-tcl-filter.html -s --css mini.css
```

The result should be the file which you are looking currently.

## ChangeLog

* 2021-08-22 Version 0.1
* 2021-08-28 Version 0.2
    * adding custom filters structure (dot, tsvg examples)
    * adding attributes label, width, height, results
* 2021-08-31 Version 0.3
    * moved filters into filter folder
    * plugin example mtex
    * default image path _images_
* 2021-11-03 Version 0.3.1
    * fix for parray and "puts stdout"
* 2021-11-15 Version 0.3.2
    * --help argument support
    * --version argument support
    * filters for Pikchr, PIC and EQN
* 2021-11-30 Version 0.3.3
    * filter for R plots: `.rplot`
* 2021-12-04 Version 0.4.0
    * pandoc-tcl-filter can be as well directly used for conversion 
      being then a frontend which calls pandoc internally with 
      itself as a filter ...
* 2021-12-12 Version 0.5.0
   * support for Markdown code creation in the Tcl filter with results="asis"
   * adding list2mdtab proc to the Tcl filter
   * adding include proc to the Tcl filter with results='asis' other Markdown files can be included.
   * support for `pandoc-tcl-filter.tcl infile --tangle .tcl`  to extract code chunks to the terminal
   * support for Mermaid diagrams
   * support for PlantUML diagrams 
   * support for ABC music notation
   * bug fix for Tcl filters for `eval=false`
   * documentation improvements for the filters and for the pandoc-tcl-filter
* 2022-01-09 - version 0.6.0
   * adding filter-cmd.tcl for shell scripts for all type of programming languages and tools
   * filter-mtex.tcl with more examples for different LaTeX packages like tikz, pgfplot, skak, sudoku, etc.
   * adding filter-tdot.tcl for tdot Tcl package
   * adding filter-tcrd.tcl for writing music chords above song lyrics
* 2022-02-05 - version 0.7.0
   * graphical user interface to the graphical filters (abc, dot, eqn, mmd, mtex, pic, pikchr, puml, rplot, tdot, tsvg) using the command line option *--gui*
   * can now as well work without pandoc standalone for conversion of Markdown with code chunks into 
     Markdown with evaluated code chunks and HTML code using the
     Markdown library of tcllib
   * that way it deprecates the use of tmdoc::tmdoc and mkdoc::mkdoc as it contains now the same functionality
   * support for inline code evaluations for Tcl, Python (pipe filter) and R (pipe filter) statements as well in nested paragraphs, lists and headers
   * support for indented code blocks with evaluation
   * new - filter-pipe:
       * initial support for R code block features and inline evaluation and error catching
       * initial support for Python with code block features and inline evaluation and error catching
       * initial support for Octave with code block features and error checking
   * more examples filter-mtex, filter-puml, filter-pikchr 
   * fix for filter-tcl making variables chunk and res namespace variables, avoiding variable collisions
    
## SEE ALSO

* [Readme.html](Readme.html) - more information and small tutorial
* [Examples](examples/example-eqn.html) - more examples for the filters 
* [Tclers Wiki page](https://wiki.tcl-lang.org/page/pandoc%2Dtcl%2Dfilter) - place for discussion
* [Pandoc filter documentation](https://pandoc.org/filters.html) - more background and information on how to implement filters in Haskell and Markdown
* [Lua filters on GitHub](https://github.com/pandoc/lua-filters)
* [Plotting filters on Github](https://github.com/LaurentRDC/pandoc-plot)
* [Github Pandoc filter list](https://github.com/topics/pandoc-filter)

## AUTHOR

Dr. Detlef Groth, Caputh-Schwielowsee, Germany, detlef(_at_)dgroth(_dot_).de
 
## LICENSE

*MIT License*

Copyright (c) 2021-2022 Dr. Detlef Groth, Caputh-Schwielowsee, Germany

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

