## NAME 

_tdot_ - Thingy Graphviz dot file writer - package to create Graphviz dot files with a syntax close to Tcl and to the Dot language.

## SYNOPSIS

```{.tcl}
# demo: synopsis
package require tdot
tdot set type "strict digraph G"
tdot graph margin=0.2 
tdot node width=1 height=0.7 style=filled fillcolor=salmon shape=box
tdot block rank=same A B C
tdot addEdge A -> B
tdot node A label="Hello"
tdot node B label="World" fillcolor=skyblue
tdot edge dir=back
tdot addEdge B -> C
tdot node C label="Powered by\n tdot"
tdot write tdot-synopsis.png
```

![](tdot-synopsis.png)

## DESCRIPTION

The package provides one command _tdot_ which can hold currently just a dot 
file code. All commands will be evaluated within the tdot namespace. 
In comparison to the Graphviz [tcldot](https://graphviz.org/pdf/tcldot.3tcl.pdf) 
and the [gvtcl](https://graphviz.org/pdf/gv.3tcl.pdf)  packages this package
uses directly the Graphviz executables and has a syntax very close to the dot language. So there is no need to consult special API pages for the interfaces. It is therefore enough to consult the few methods below and the
standard [dot](https://graphviz.org/pdf/dotguide.pdf) or [neato](https://graphviz.org/pdf/neatoguide.pdf)  documentation.
There are a few restrictions because of this, for instance you can't delete nodes and edges, you can only use _shape=invis_ to hide them for instance.

## VARIABLES

The following public variables can be modified using the set command like so: _tdot set varname_ value:

> - _code_ - the variable collecting the dot code, usually you will only set this variable by hand to remove all existing dot code after creating a dot file by calling _tdot set code ""_.
  - _type_ - the dot type of graph, default: "strict digraph G"

## METHODS

The following methods are implemented:

__self__

> just an `interp alias` for `namespace current`

## TDOT METHODS

__tdot addEdge__ *args* 

> Adds code to the graph creating edges, if the last arguments are edge 
  attributes the will be appended as well to the edge.

> ```
tcldot addEdge A -> B color=red
# A -> B [color=red];
> ```

__tdot block__ *args* 

> Adds code to the graph within curly braces, arguments are separed by semikolons.

> ```
tcldot block rank=same A B C
# { rank=same; A; B ; C; }
> ```


__tdot demo__ 

> Writes a simple "Hello World!" demo to stdout. 

__tdot edge__ *args* 

> Adds code to the graph within regarding edge properties which will
  affect all subsequently created edges.

> ```
tcldot edge penwidth=2 dir=none color=red
# edge[penwidth=2,dir=none,color=red]
> ```

__tdot graph__ *args* 

> Changes global graph options.

> ```
tcldot graph margin=0.2
# creates: graph[margin=0.2];
> ```

__tdot node__ *args* 

> Adds code to the graph within regarding node properties, first argument can be a list 
  of node attributes where the attributes the belong to all nodes which will created
  thereafter. If the first argument dies not contain an `=` sign the first argument
  will be taken as a node with all subsequent properties attached.

> ```
tcldot node fillcolor=salmon style=filled
# node[fillcolor=salmon,style=filled];
tcldot node A fillcolor=salmon style=filled label="Hello World!"
# A[fillcolor=salmon,style=filled,label="Hello World!"];
> ```

__tdot render__  

> Returns the current graph code.

> ```
puts [tcldot render]
> ```

__tdot usage__ 

> Returns the application usage string, usually used on the terminal using help. 

> ```
tclsh tdot.tcl --help
> ```

> On a Unix system using X11 or GTK 
  you can very likely render the demo code on the terminal if Graphviz is installed either via:

> ```
$ tclsh tdot.tcl --demo | dot -Tgtk
# or using X11
$ tclsh tdot.tcl --demo | dot -Tx11
> ```

__tdot write__ _?device?_

> Writes the current tdot code to the given device. If the argument is empty the function
  just returns the tdot code. The following devices are support:

> - filenames which can be:
     - dot files
     - png files
     - pdf files
     - svg files
     - any other file type support by Graphviz

> Please note, that except for the dot file format the other file formats require
  an existing Graphviz installation.

> - Tk canvas widget

> ```{.tcl}
# demo: write
package require Tk
pack [canvas .can -background white] -side top -fill both -expand true
package require tdot
tdot set code ""
tdot graph margin=0.4
tdot node style=filled fillcolor=salmon shape=hexagon
tdot addEdge A -> B
tdot node A label="tdot"
tdot node B label="Hello World!"  
tdot write .can
.can create rect 10 10 290 250 -outline red
destroy . ;# just to allow automatic document processing
> ```

![](tdot-canvas.png)

> You can thereafter add additional items on the canvas widget using the standard 
  commands of the canvas.

## EXAMPLES

Obviously we start with the typical "Hello World!" example.

```{.tcl}
package require tdot
tdot set code ""
tdot node A label="Hello World!\ntdot" shape=box fillcolor=grey90 style=filled
tdot write tdot-hello-world.png
```

![](tdot-hello-world.png)

Here a more extensive example, the demo:

```{.tcl}
package require tdot
tdot set code ""
tdot graph margin=0.4
tdot node style=filled fillcolor=grey80 width=1.2 height=0.7
tdot block rank=same E D C F G 
tdot addEdge A -> B label=" connects"
tdot addEdge B -> C 
tdot addEdge B -> D
tdot addEdge D -> E
tdot node A label="Hello" style=filled fillcolor=salmon width=2 height=1
tdot node B label="World!" style=filled shape=box fillcolor=skyblue width=2 height=0.8
tdot addEdge C -> F -> G
tdot write tdot-demo.png
```

![](tdot-demo.png)

Now an exampe which uses _neato_ as the layout engine:

```{.tcl}
tdot set code ""
tdot set type "graph N" ;# switch to neato as layout engine
tdot addEdge n0 -- n1 -- n2 -- n3 -- n0;
tdot node n0 color=red style=filled fillcolor=salmon
tdot write dot-neato.png
```
![](dot-neato.png)

Alternatively you can as well overwrite the default layout engine using the graph layout option. Here the standard dot engine which is used for digraphs.

```{.tcl}
tdot set code ""
tdot set type "strict digraph G" ; # back to dot
tdot addEdge A -> B -> C -> D -> A
tdot write dot-circle1.png
```

![](dot-circle1.png)

Now let's switch to circo as the layout engine, still having a digraph:

```{.tcl}
tdot set code ""
tdot set type "strict digraph G" ; # back to dot
tdot graph layout=circo ;# switch to circo (circular layout engine)
tdot addEdge A -> B -> C -> D -> A
tdot write dot-circle2.png
```

![](dot-circle2.png)

Also undirected graphs can be converted:

```{.tcl}
tdot set code ""
tdot set type "graph N" ;# switch to neato as layout engine
tdot graph layout=circo
tdot addEdge n0 -- n1 -- n2 -- n3 -- n0;
tdot node n0 color=red style=filled fillcolor=salmon
tdot write dot-neato2.png
```
![](dot-neato2.png)

## INSTALLATION

The _tdot_ package requires to create images a running installation of the [Graphviz](https://graphviz.org/download/) command line tools. For only creating the textual dot files there is no installation of these tools reequired.
To use the package just download the library folder from [GitHub](https://downgit.github.io/#/home?url=https://github.com/mittelmark/DGTcl/tree/master/lib/tdot) and place it in your Tcl-library path.

## DOCUMENTATION

The documentation for this HTML file was created using the pandoc-tcl-filter and the filter for the tsg package as follows:

```
 perl -ne "s/^#' ?(.*)/\$$1/ and print " lib/tsvg/tdot.tcl > tdot.md
 pandoc tdot.md -s  \
    --metadata title="tdot package documentation"  \
    -o tdot.html  --filter pandoc-tcl-filter.tcl \
    --css mini.css --toc
 htmlark -o lib/tdot/tdot.html tdot.html
```

## CHANGELOG

* 2021-09-06 Version 0.1 released with docu uploaded to GitHub

## TODO

- subgraphs
- multi-line string problem
- OSX check
- method to get number of nodes or edges using -Tplain command flag
- options more close to Tcl arguments (layout=circo == -layout circo)
- input as json file, so json2dot to remove edges nodes etc at a later point
- pandoc filter _.tdot_
- converter for tdot files as command line option
    
## SEE ALSO

* [Graphviz documentation:](https://www.graphviz.org/documentation/)
    - [dotguide (pdf)](https://www.graphviz.org/pdf/dotguide.pdf).
    - [neatoguide (pdf)](https://www.graphviz.org/pdf/neatoguide.pdf).
    - [dot language (pdf)](https://www.graphviz.org/pdf/dot.1.pdf)
    - [tcdot documenation (pdf)](https://www.graphviz.org/pdf/tcldot.3tcl.pdf)
* [Readme.html](../../Readme.html) - Pandoc Tcl filters which were used to create this manual
* [Tclers Wiki page](https://wiki.tcl-lang.org/page/tdot) - place for discussion

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
