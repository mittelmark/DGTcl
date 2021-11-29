---
title: "Readme for the Pandoc Tcl filter"
shorttitle: "tcl-filter"
author: 
- Detlef Groth
date: 2021-08-25
standalone: true
toc: true
css: mini.css
mainfont: Georgia
monofont: Monaco

abstract: >
    The pandoc-tcl-filter allows you the embed Tcl code in code blocks
    and short Tcl statements as wekk in the normal text of a Markdown 
    document. The code fragments will be executed dynamically and the output
    of the Tcl commands can be shown in an extra code block or can replace
    the code block as well.
---

## NAME

_pandoc-tcl-filter_ - filter to execute code within Markdown documents and use code results for documentation.

## USAGE

```
 pandoc input.md -s --filter pandoc-tcl-filter.tcl -o output.html
 # or using the standalone application
 pandoc input.md -s  --filter pandoc-tcl-filter.tapp -o output.html
```

## Installation

The pandoc-tcl-filter can be installed locally by placing it in a folder belonging to
your personal PATH and making the file executable or alternatively you can
just use it by specifying the correct path to the Tcl script in your pandoc
command line call. The direct link to the github repository folder is:
[https://downgit.github.io/#/home?url=https://github.com/mittelmark/DGTcl/tree/master/pandoc-tcl-filter](https://downgit.github.io/#/home?url=https://github.com/mittelmark/DGTcl/tree/master/pandoc-tcl-filter)
Just unpack the Tcl script from the download and make the file executable.

The filter requires the Tcl package *rl_json* which is available from Github: [https://github.com/RubyLane/rl_json](https://github.com/RubyLane/rl_json).
Unix users should be able to install the package via the standard configure/make pipeline. A Linux binary, complied on a recent Fedora system is included in the download
link at the GitHub page as well to simplify the use of the Pandoc filter.
Windows users should install the *rl_json* package via the Magicplats Tcl-Installer: [https://www.magicsplat.com/tcl-installer](https://www.magicsplat.com/tcl-installer/index.html)

## Standalone application

Alternatively the application is released as packed application where all the
filters and the rl_json package are added, the file just requires and exiting
Tcl installation and can be downloaded from here: [https://github.com/mittelmark/DGTcl/releases/download/latest/pandoc-tcl-filter.tapp](https://github.com/mittelmark/DGTcl/releases/download/latest/pandoc-tcl-filter.tapp). Just download the file, make it executable and place it in a folder belonging to your PATH.



## Tcl filter

The HTML version of this file contains as well the output results and can be
seen on [GitHub](https://htmlpreview.github.io/?https://github.com/mittelmark/DGTcl/blob/master/pandoc-tcl-filter/Readme.html).

Tcl code can be embedded either within single backtick marks where the first
backtick is immediately followed by the string tcl and the the tcl code such
as in the following example:
 
```
The variable is now `tcl set x 5` or five times three is `tcl expr {3*5}`.

This document was processed using Tcl `tcl package provide Tcl`.

```

Here the output:

The variable is now `tcl set x 5` or five times three is `tcl expr {3*5}`.

This document was processed using Tcl `tcl package provide Tcl`.

The results from the code execution will be directly embedded in the text and
will replace the Tcl code. Such inline statements should be short and concise
and should not break over several lines. Currently single backtick statements
must be within non-list environments only.

Larger chunks of code can be placed within triple backticks such as in the
example below.

```
` ``{.tcl}
 # please remove the space after the first backtick above
 set x 3
 proc add {x y} {
       return [expr {$x+$y}]
 }
 add $x 7
 # please remove the space after the first backtick below
` ``
```

In the code above a space was added to avoid confusing the pandoc interpreter
by nested triple tickmarks, remove those spaces in your code.

And here the output:

```{.tcl}
set x 3
proc add {x y} {
    return [expr {$x+$y}]
}
add $x 7
```

Please note, that only the last statement is shown in code block after the Tcl
code. To show more output you can use the `puts` command.

### Code chunk attributes

Within the curly braces the following attributes are currently supported:

* _eval=false|true_ - evaluate the Tcl code
* _results=show|hide_ - show the output of the Tcl code execution
* _echo=true|false_ - show the Tcl code

Errors in the tcl code will be usually trapped and the error info is shown
instead of the regular output.

### Images

As Tcl has no standard library in the core to create graphics without the Tk
toolkit we will create a small object using a minimal object oriented system
which can be used to create svg files easily.

#### Thingy svg example

```{.tcl}
;# the onliner OO system thingy see here
;# https://wiki.tcl-lang.org/page/Thingy%3A+a+one%2Dliner+OO+system
proc thingy name {
    proc $name args "namespace eval $name \$args"
} 
;# our object
thingy svg

;# some variables
svg set code "" ;# the svg code
svg set header {<?xml version="1.0" encoding="utf-8" standalone="yes"?>
    <svg version="1.1" xmlns="http://www.w3.org/2000/svg" height="__HEIGHT__" width="__WIDTH__">}    
svg set footer {</svg>}
svg set width 100
svg set height 100

;# lets look what variables are there
info vars svg::* 
```

We now need a method _unknown_ which catches all command on the object and
forward this to the tag creation method.

```{.tcl}
;# the actual tag svg creation method
svg proc tag {args} {
    variable code
    set tag [lindex $args 0]
    set args [lrange $args 1 end]
    set ret "\n<$tag"
    foreach {key val} $args {
        if {$val eq ""} {
            append ret ">\n$key\n</$tag>\n"
            break
        } else {
            append ret " $key=\"$val\""
        }
    }
    if {$val ne ""} {
        append ret " />\n"
    }
    append code $ret
}

;# any unknown should forward to the tag method
namespace eval svg {
    namespace unknown svg::tag
}

; # write out the current svg code 
svg proc write {filename} {
    variable width
    variable height
    variable header
    variable footer
    variable code
    set out [open $filename w 0600]
    set head [regsub {__HEIGHT__} $header $height]
    set head [regsub {__WIDTH__} $head $width]
    puts $out $head
    puts $out $code
    puts $out $footer
    close $out
}

;# what methods we have
info commands svg::*
```

Ok we are now ready to go: Let's create the typical "Hello World!" example,
the first argument will be the tag every remaining pairs will be the attribute
and the value, remaining single arguments will be placed within the tag as
content:

```{.tcl}
svg circle cx 50 cy 50 r 45 stroke black stroke-width 2 fill salmon
svg text x 29 y 45 Hello
svg text x 27 y 65 World!
svg write images/hello-world.svg
```

Let's now display the image:

```
 ![](images/hello-world.svg)
``` 

Here the image displayed:

![](images/hello-world.svg)

Let's now clean up the svg code:
```{.tcl}
svg set code ""
```

We can now create an other image, let's create a chessboard:

```{.tcl}
svg set width 420
svg set height 420
for {set i 0} {$i < 8} {incr i} {
    if {[expr {$i % 2}] == 0} {
        set cols [join [lrepeat 4 [list cornsilk burlywood]]]
    } else {
        set cols [join [lrepeat 4 [list burlywood cornsilk ]]]
    }   
    for {set j 0} {$j < 8} {incr j} {
        set x [expr {10+$i*50}]
        set y [expr {10+$j*50}]
        svg rect x $x y $y width 50 height 50 fill [lindex $cols $j] stroke-width 3
    }
    svg rect x 6 y 6 width 408 height 408 stroke sienna stroke-width 7 fill transparent
}   
svg write images/chessboard.svg
```

![](images/chessboard.svg)


Great! Let's now illustrate a few more basic shapes. We will follow the
examples at
[https://developer.mozilla.org/en-US/docs/Web/SVG/Tutorial/Basic_Shapes](https://developer.mozilla.org/en-US/docs/Web/SVG/Tutorial/Basic_Shapes)

But first let's rewrite the `svg tag` function so that we can as well take a
list of attributes.

```{.tcl}
svg proc tag {args} {
    variable code
    set tag [lindex $args 0]
    set args [lrange $args 1 end]
    set ret "\n<$tag"
    # new check if attr="val" syntax  
    if {[regexp {=} [lindex $args 0]]} {
        set nargs [list]
        foreach kval $args {
            set idx [string first = $kval]
            set key [string range $kval 0 $idx-1]
            set val [string range $kval $idx+2 end-1]
            lappend nargs $key
            lappend nargs $val
        }
        set args $nargs
    } 
    # end of new check
    foreach {key val} $args {
       if {$val eq ""} {
           append ret ">\n$key\n</$tag>\n"
           break
       } else {
           append ret " $key=\"$val\""
       }
    }
    if {$val ne ""} {
        append ret " />\n"
    }
    append code $ret
}
```

With this redefinition of the tag method we can now very easily copy the svg
code from the website. We just have to remove the greater, smaller and slash
tag signs from the svg code. As arguments to functions in Tcl are separated by
spaces we have to protect attributes containing spaces with curly braces for
the last three shapes, the polyline, the polygon and the path.

```{.tcl}
svg set code "" ;# cleanup chessboard
svg set width 200 ;# new size as on the webpage
svg set height 250 
svg rect x="10" y="10" width="30" height="30" stroke="black" fill="transparent" stroke-width="5"
svg rect x="60" y="10" rx="10" ry="10" width="30" height="30" \
    stroke="black" fill="transparent" stroke-width="5"
svg circle cx="25" cy="75" r="20" stroke="red" fill="transparent" stroke-width="5"
svg ellipse cx="75" cy="75" rx="20" ry="5" stroke="red" fill="transparent" stroke-width="5"
svg line x1="10" x2="50" y1="110" y2="150" stroke="orange" stroke-width="5"
svg polyline {points="60 110 65 120 70 115 75 130 80 125 85 140 90 135 95 150 100 145"} \
     stroke="orange" fill="transparent" stroke-width="5"
svg polygon {points="50 160 55 180 70 180 60 190 65 205 50 195 35 205 40 190 30 180 45 180"} \
     stroke="green" fill="transparent" stroke-width="5"
svg path {d="M20,230 Q40,205 50,230 T90,230"} fill="none" stroke="blue" stroke-width="5"
svg write images/basic-shapes.svg
```

![](images/basic-shapes.svg)

Ok, great basic shapes can be directly copied from svg code and with a few
modifications we can create valid Tcl code out of the svg code. 
Please note, that from the code shown in this Readme the package _tsvg_ was derived which
does not need this protecting of the spaces within the attributes. See below the section
about the _tsvg_ plugin for more details.

#### Code chunk attributes for svg figures

Let's introduce now a few code chunk attributes for figures as they are known
for instance in R.

Below an example:
```
    ```{.tcl fig=true fig.width=400 fig.height=400}
    # some figure code
    ```
```

This code should call some procedure figure with the arguments of a basic
filename, _fig.width_, _fig.height_ and it should return a filename with an
extension like `.svg`

Here an outline of such a function:

```
proc figure {filename width height args} {
    # parse args, get width, get height
    # write file
    # return filename with extension
}
```

Ok, lets now implement our figure procedure for our svg:

```{.tcl} 
proc figure {filename width height args} {
    svg set width $width
    svg set height $height
    svg write images/$filename.svg
    return $filename.svg
}
```

Now in the next code chunk we create a new figure:

```
 ` ``{.tcl label=figsample fig=true width=80 height=80}
 svg set code ""
 svg rect x 0 y 0 width 80 height 80 fill cornsilk
 svg rect x 10 y 10 width 60 height 60 fill salmon
 ` ``
   
 ![](images/figsample.svg)
```   

Here the actual code (the space between the backticks was added to avoid
interpretation problems by pandoc):

```{.tcl label=figsample fig=true width=80 height=80}
svg set code ""
svg rect x 0 y 0 width 80 height 80 fill cornsilk
svg rect x 10 y 10 width 60 height 60 fill salmon
```

![](images/figsample.svg)

* TODO: autoembedding of figures by chunk number

## Other filters

The *pandoc-tcl-filter* supports as well generation of filters for other tools
and programming languages using the Tcl programming language. The standalone application *pandoc-tcl-filter.tapp* comes with the following filters:

|filter | Tool                 | URL                  |
---     | ---                  | ---                  | 
|.dot   | dot/neato (GraphViz) | [https://graphviz.org/](https://graphviz.org/) |
|.eqn   | eqn2graph  (groff)   | [https://www.gnu.org/software/groff/](https://www.gnu.org/software/groff/) |
|.mtex  | LaTex                | [https://www.latex-project.org/](https://www.latex-project.org/) |
|.pic   | pic2graph  (groff)   | [https://www.gnu.org/software/groff/](https://www.gnu.org/software/groff/) |
|.pik   | pikchr/fossil pikchr | [https://www.fossil-scm.org/home/doc/trunk/www/pikchr.md](https://www.fossil-scm.org/home/doc/trunk/www/pikchr.md) |
|.tsvg  | Tcl tsvg package     | [https://github.com/mittelmark/DGTcl](https://github.com/mittelmark/DGTcl) |

Let's finish our small tutorial with the implementation of a filter for a
command line application. Below you see the code for the GraphViz dot application.

Here the code example:

```
` ``{.dot label=digraph echo=true}
digraph G {
  main -> parse -> execute;
  main -> init [dir=none];
  main -> cleanup;
  execute -> make_string;
  execute -> printf
  init -> make_string;
  main -> printf;
  execute -> compare;
}
` ``
```

Which will produce the following output:

```{.dot label=digraph echo=true}
digraph G {
  main -> parse -> execute;
  main -> init [dir=none];
  main -> cleanup;
  execute -> make_string;
  execute -> printf
  init -> make_string;
  main -> printf;
  execute -> compare;
}
```

Using the chunk option _echo=false_, we can as well hide the source code. 
If you would like to see the code you now have to consult the Markdown file.


```{.dot label=digraph2 echo=false}
digraph G {
  main [shape=box,style=filled,fillcolor=".5 .8 1.0"] ;
  main -> parse -> execute;
  main -> init [style=dotted];
  main -> cleanup;
  execute -> make_string;
  execute -> printf
  edge [color="red",dir=none];
  init -> make_string;
  main -> printf;
  execute -> compare;
}
```

To avoid automatic placement of figures you can as well set the option include
to false _include=false_ and then create the usual Markdown code for the figure
where the basename is defined by a `images` subfolder the chunk label.

```
` ``{.dot label=digraph3 echo=false include=false}
digraph G {
  main [shape=box,style=filled,fillcolor=".5 .8 1.0"] ;
  main -> parse -> execute;
  main -> init [style=dotted];
  main -> cleanup;
  execute -> make_string;
  execute -> printf
  edge [color="red"];
  init -> make_string;
  edge [dir="none"]; // no arrows
  main -> printf;
  execute -> compare;
}
` ``
![](images/digraph3.svg)
```

This will produce the following:

```{.dot label=digraph3 echo=false include=false}
digraph G {
  main [shape=box,style=filled,fillcolor="0.95 0.90 .90"] ;
  main -> parse -> execute;
  main -> init [style=dotted];
  main -> cleanup;
  execute -> make_string;
  execute -> printf
  edge [color="red"];
  init -> make_string;
  edge [dir="none"];
  main -> printf;
  execute -> compare;
}
```

![](images/digraph3.svg)

Ok, now you know what was the code to create the graphic above.

The dot filter supports as well the other command line applications from the
GraphViz toolbox. To switch for instance from the `dot` command line
application to the `neato` application give the chunk argument `app=neato` and
you can enter neato code in your code chunk here an example:


```
` ``{.dot label=neato-sample app=neato}
graph G {
    node [shape=box,style=filled,fillcolor=skyblue,
        color=black,width=0.4,height=0.4];
    n0 -- n1 -- n2 -- n3 -- n0;
}
` ``
```

Which will produce this:


```{.dot label=neato-sample app=neato}
graph G {
    node [shape=box,style=filled,fillcolor=skyblue,
        color=black,width=0.4,height=0.4];
    n0 -- n1 -- n2 -- n3 -- n0;
}
```

You can try out as well the GraphViz layout engines yourself. Please have a
look at the GraphViz homepage at 
[https://www.graphviz.org/docs/layouts/](https://www.graphviz.org/docs/layouts/).

## tsvg plugin

The code shown above creating svg files using the thingy object was as well
saved as a plugin with some modifications and extensions. 
That way you can include code creating svg files using the described syntax above. 
Please not that the plugin object is named `tsvg`. Here an example.

```
` ``{.tsvg label=tsvg-hello-world results=hide echo=false}
tsvg circle cx 50 cy 50 r 45 stroke black stroke-width 2 fill salmon
tsvg text x 29 y 45 Hello
tsvg text x 26 y 65 World!
` ```
```

Which will produce this:

```{.tsvg fig=true label=tsvg-hello-world results=hide echo=true}
tsvg circle cx 50 cy 50 r 45 stroke black stroke-width 2 fill salmon
tsvg text x 29 y 45 Hello
tsvg text x 26 y 65 World!
```

In contrast to the svg code developed above the _tsvg_ plugin allows you to 
send the attributes containing as well spaces as they are, the _tag_ method will clean up 
the lists arguments by using the paired quotes. This greatly simplifies the
copy and paste procedure for existing svg examples, you in many cases just have to remove
the leading and trailing greater and lower signs.
Here is an example using different syntax types:

```{.tsvg label=tsvg-polyline results=hide echo=true}
tsvg set code ""
tsvg set width 180
tsvg set height 200
tsvg rect x 10 y 10 width 160 height 180 style "fill:#ddeeff;"
tsvg circle cx="130" cy="120" r="20" stroke="red" stroke-width="2" fill="salmon"
tsvg polyline points="0,40 40,40 40,80 80,80 80,120 120,120 120,160" \
   style="fill:white;stroke:red;stroke-width:4"
```  

For more information about the _tsvg_ package visit the [tsvg manual
page](lib/tsvg/tsvg.html).

## Filter for Math-Tex 

This filter requires a _LaTeX_ installation and the texlive-standalone package.
The plugin uses in the background conversion of a _LaTeX_ formula using the _latex_
command line application and thereafter a conversion to png using the _dvipgn_ application which is
part of the LaTeX installation. Please note that currently only single line equations are supported:

Here two examples:

```{.mtex fontsize=LARGE}
E = m \times c^2
```

And here the second example:

```{.mtex fontsize=LARGE}
 F(x) = \int^a_b \frac{1}{3}x^3
```

May be later version will support aligned sets of equations or matrices.

## PIC and EQN filters

The *groff* typesetting systems comes with the tools *eqn2graph* which
converts EQN equations into PNG graphics and and *pic2graph* which converts
diagram code written in the PIC programming language into PNG graphics. Below are two examples, one for each tool:

Here an example for the PIC language:
```
     ```{.pic ext=png}
     circle "circle" rad 0.5 fill 0.3; arrow ;
     ellipse "ellipse" wid 1.4 ht 1 fill 0.1 ; line;
     box wid 1 ht 1 fill 0.05 "A";
     spline;
     box wid 0.4 ht 0.4 fill 0.05 "B";
     arc;
     box wid 0.2 ht 0.2 fill 0.05 "C";
     ```
```

And here the output:

```{.pic ext=png}
circle "circle" rad 0.5 fill 0.3; arrow ;
ellipse "ellipse" wid 1.4 ht 1 fill 0.1 ; line;
box wid 1 ht 1 fill 0.05 "A";
spline;
box wid 0.4 ht 0.4 fill 0.05 "B";
arc;
box wid 0.2 ht 0.2 fill 0.05 "C";
```


The complete code was:

```
     ```{.pic ext=png}
     circle "circle" rad 0.5 fill 0.3; arrow ;
     ellipse "ellipse" wid 1.4 ht 1 fill 0.1 ; line;
     box wid 1 ht 1 fill 0.05 "A";
     spline;
     box wid 0.4 ht 0.4 fill 0.05 "B";
     arc;
     box wid 0.2 ht 0.2 fill 0.05 "C";
     ```
```      

And here an example for the EQN language:


```{.eqn echo=false}
x = {-b +- sqrt{b sup 2 - 4ac}} over 2a
```

The code here was (the indentation of five spaces is just to avoid interpretation):

```
     ```{.eqn echo=false}
     x = {-b +- sqrt{b sup 2 - 4ac}} over 2a
     ```
```

## Pikchr filter

The PIC diagram language has a modern successor, the Pikchr diagram language
used on the Sqlite webpage to display syntax diagrams. The homepage of the
pikchr tool is at: [https://pikchr.org/](https://pikchr.org). The tool can be
compiled easily, but even easier you can as well download the *fossil*
application which has a subcommand *pikchr* which allows you to create as well
diagrams. The downloads of *fossil* for various platforms can be found here
[https://www.fossil-scm.org/home/uv/download.html](https://www.fossil-scm.org/home/uv/download.html).

If the *fossil* application is in your PATH ou can create easily as well
*pikchr* diagrams. Here an example:

```{.pikchr app=fossil-2.17 ext=svg}
box "box"
circle "circle" fill cornsilk at 1 right of previous
ellipse "ellipse" at 1 right of previous
oval "oval" at .8 below first box
cylinder "cylinder" at 1 right of previous
file "file" at 1 right of previous
```

The code for this diagram follows below:

```
` ``{.pikchr app=fossil-2.17 ext=pdf}
box "box"
circle "circle" fill cornsilk at 1 right of previous
ellipse "ellipse" at 1 right of previous
oval "oval" at .8 below first box
cylinder "cylinder" at 1 right of previous
file "file" at 1 right of previous
` ``
```

The option `app=fossil-2.17` was used to use a newer version of the *fossil*
application than the default one. Please note, that at least *fossil* in
version 2.13 is required.
 
We can as well resize the image. In this case we have to create a *png*
extension. As conversion from svg to png is then required we need a tool
called cairosvg which can be installed as a Python packagte using pip:

```
pip3 install cairosvg --user
```

should do this. The advantage if using this tool is, that we beside resizing
we can as well create PDF's for inclusion into LaTeX documents. 
Here an example for a PNG image.

```{.pikchr label=fossil-sample app=fossil-2.17 ext=png width=500 height=300}
box "box"
circle "circle" fill cornsilk at 1 right of previous
ellipse "ellipse" at 1 right of previous
oval "oval" at .8 below first box
cylinder "cylinder" at 1 right of previous
file "file" at 1 right of previous
```


Here is the code:

```
` ``{.pikchr app=fossil-2.17 ext=png  width=500 height=300}
` ``
```

As you can see using the `ext=png` setting and the `width` and `height`
options, we can resize the image.


## Lua filters

Pandoc since version 2.0 has embedded support for Lua filters. To no reinvent
every filter again you should use Lua filters if they are available. Below an example for a Lua filter:

```
 **strong** should be converted to smallcaps using the Lua filter _smallcaps.lua_!
```

**strong** should be converted to smallcaps using the Lua filter _smallcaps.lua_!
To apply Lua filters use the pandoc option `--lua-filter=filter/smallcaps.lua`.

For more details see the Pandoc documentation at
[https://pandoc.org/lua-filters.html](https://pandoc.org/lua-filters.html) and
for examples of Lua filter look at GitHub
[https://github.com/pandoc/lua-filters](https://github.com/pandoc/lua-filters).


## Summary

In this Readme I explained on how to use the Tcl pandoc filter to embed and
process Tcl code during the creation of HTML or PDF documents. The Tcl filter
was generalized so that as well filters for other tools, especially command
line application can be easily programmed using the Tcl programming language.
Examples for a filter for the GraphViz tool dot to create flowcharts and
graphs, a package to create SVG images using Tcl, the new _tsvg_ package, a
little renderer for single TeX equations, filters for the PIC and EQN
langauges and as well for the Pikchr diagram tools are as well included in the
pandoc-tcl-filter. The provided infrastructure has the advantage that Tcl
programmers can stay within their favourite programming language but still can
use other nice tools easily for their documentation. In case of new may be
complex things look for existing Lua filters. As Lua is embedded into Pandoc
have a look for an existing Lua filter to not reinvent the (filter) wheel.


## Documentation

The HTML version of this document was generated using the following commandline:

```
pandoc Readme.md --metadata title="Readme pandoc-tcl-filter.tcl" \
    -M date="`date "+%B %e, %Y %H:%M"`" -s -o Readme.html \
     --filter pandoc-tcl-filter.tcl --css mini.css -B header.html \
     --toc --lua-filter=filter/smallcaps.lua

```

Please look at the source Markdown file to see which Markdown code was the input.

## Links

* [DGTcl homepage at GitHub](https://github.com/mittelmark/DGTcl)
* [Discussion page for pandoc-tcl-filter.tcl on the Tclers Wiki](https://wiki.tcl-lang.org/page/pandoc%2Dtcl%2Dfilter) 
* [Documentation to the tsvg package](http://htmlpreview.github.io/?https://github.com/mittelmark/DGTcl/blob/master/pandoc-tcl-filter/lib/tsvg/tsvg.html)
* [https://pandoc.org/filters.html](https://pandoc.org/filters.html) - background on  pandoc filters
* [pandoc lua filters](https://github.com/pandoc/lua-filters)
* [https://github.com/mvhenderson/pandoc-filter-node](https://github.com/mvhenderson/pandoc-filter-node) - pandoc filters using JavaScript and TypeScript
* [https://pypi.org/project/panflute/](https://pypi.org/project/panflute/) - pandoc filters in Python
* 

## Todo

* code block labels (label=chunkname)  - done
* code block figures (include=false fig=true) - done
* regular filter infrastructure for Tcl support for for instance other filters like .csv to include csv files .dot to include dot file graphics etc. - done (examples for dot code and tsvg plugin)
* Windows exe / starkit containing the rl_json library as well (adding linux library)


## History

* 2021-08-22 - Release of Wiki cocde
* 2021-08-25 - Release of github code
* 2021-08-26 - Adding thingy svg creator, image file writing works
* 2021-08-31 - adding mtex filter example, images now in images folder, Lua filter example
* 2021-11-23 - adding pikchr, pik, eqn filters, extending documentation

## Author

Detlef Groth, Caputh-Schwielowsee, Germany

## License

MIT, see the file LICENSE in the release folder.


