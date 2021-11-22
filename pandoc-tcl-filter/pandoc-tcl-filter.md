---
title: pandoc-tcl-filter documentaion - 0.3.2
author: Detlef Groth, Schwielowsee, Germany
date: 2021-11-23
---

## NAME

_pandoc-tcl-filter.tcl_ - filter application for the pandoc command line 
application to convert Markdown files into other formats. The filter allows you to embed Tcl code into your Markdown
documentation and offers a plugin architecture to add other command line filters easily using Tcl
and the `exec` command. As examples are given in the filter folder of the project:

* Graphviz dot filter plugin: `filter-dot.tcl`
* tsvg package plugin: `filter-tsvg.tcl`
* Math TeX filter plugin for single line equations: `filter-mtex.tcl`
* Pikchr filter plugin for diagram creation: `filter-pik.tcl`
* PIC filter plugin for diagram creation (older version): `filter-pic.tcl`
* EQN filter plugin for equations written in the EQN language: `filter-eqn.tcl`

## SYNOPSIS 

Embed code either inline or in form of code chunks like here (triple ticks without space):

``` 
  ` ``{.tcl}
  # a code block
  # remove the space between backticks
  # to avoid Pandoc confusion
  set x 4
  ` ```
  
  Hello this is Tcl `tcl package provide Tcl`!
```

The markers for the other filters are `{.dot}`, `{.tsvg}` and `{.mtex}`.

The Markdown document within this file could be processed as follows:

```
 perl -ne "s/^#' ?(.*)/\$1/ and print " > pandoc-tcl-filter.md
 pandoc pandoc-tcl-filter.md -s \
   --metadata title="pandoc-tcl-filter.tcl documentation" \
   -o pandoc-tcl-filter.html  --filter pandoc-tcl-filter.tcl  \
   --css mini.css
```


## Plugins

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

The main script pandoc-tcl-filter.tcl looks if in the same folders as the script is,
if there any other files named `filter-NAME.tcl` and source them. In case of the dot
filter the file is named `filter-dot.tcl` and its filter function filter-dot is 
executed. Below is the code: of this file `filter-dot.tcl`:

```
# a simple pandoc filter using Tcl
# the script pandoc-tcl-filter.tcl 
# must be in the same filter directoy of the pandoc-tcl-filter.tcl file
proc filter-dot {cont dict} {
    global n
    incr n
    set def [dict create results show eval true fig true width 400 height 400 \
             include true fontsize Large envir equation imagepath images]
    set dict [dict merge $def $dict]
    set ret ""
    if {[dict get $dict label] eq "null"} {
        set fname dot-$n
    } else {
        set fname [dict get $dict label]
    }
    set out [open $fname.dot w 0600]
    puts $out $cont
    close $out
    # TODO: error catching
    set res [exec dot -Tsvg $fname.dot -o $fname.svg]
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

Automatic inclusion of the image would require more effort and dealing with the cblock
which is a copy of the current json block containing the source code. Using the label
We could create an image link and append this block after the `$cblock` part of the `$ret var`.
As an exercise you could create a filter for the neato application which creates graphics for undirected graphs.

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
    
## SEE ALSO

* [Readme.html](Readme.html) - more information and small tutorial
* [Tclers Wiki page](https://wiki.tcl-lang.org/page/pandoc%2Dtcl%2Dfilter) - place for discussion
* [Pandoc filter documentation](https://pandoc.org/filters.html) - more background and information on how to implement filters in Haskell and Markdown
* [Lua filters on GitHub](https://github.com/pandoc/lua-filters)
* [Plotting filters on Github](https://github.com/LaurentRDC/pandoc-plot)
* [Github Pandoc filter list](https://github.com/topics/pandoc-filter)

## AUTHOR

Dr. Detlef Groth, Caputh-Schwielowsee, Germany, detlef(_at_)dgroth(_dot_).de
 
## LICENSE

```
MIT License

Copyright (c) 2021 Dr. Detlef Groth, Caputh-Schwielowsee, Germany

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
```

