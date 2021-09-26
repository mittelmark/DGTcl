---
author: Dr. Detlef Groth, Schwielowsee, Germany
title: tdot package documentation 0.3.0
date: 2021-09-14
---

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
tdot write tdot-synopsis.svg
```

![](tdot-synopsis.svg)

## DESCRIPTION

The package provides one command _tdot_ which can hold currently just a dot 
file code. All commands will be evaluated within the tdot namespace. 
In comparison to the Graphviz [tcldot](https://graphviz.org/pdf/tcldot.3tcl.pdf) 
and the [gvtcl](https://graphviz.org/pdf/gv.3tcl.pdf)  packages this package
uses directly the Graphviz executables and has a syntax very close to the dot language. So there is no need to consult special API pages for the interfaces. It is therefore enough to consult the few methods below and the
standard [dot](https://graphviz.org/pdf/dotguide.pdf) or [neato](https://graphviz.org/pdf/neatoguide.pdf)  documentation.
There are a few restrictions because of this, for instance you can't delete nodes and edges, you can only use _shape=invis_ to hide them for instance.

Please note that semikolon and brackets are special Tcl symbols to use them in labels you must escape them with backslashes, an example is given in the [history example](#tdot-history) below.

## VARIABLES

The following public variables can be modified using the set command like so: _tdot set varname_ value:

> - _code_ - the variable collecting the dot code, usually you will only set this variable by hand to remove all existing dot code after creating a dot file by calling _tdot set code ""_.
  - _type_ - the dot type of graph, default: "strict digraph G", other possible value should be "graph G" for undirected graphs.

## METHODS

The following methods are implemented:

__self__

> just a shorthand `interp alias` for the longer command `namespace current`

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

__tdot dotstring__ *dotstr* 

> Adds complete graph code to the graph starting a new graph from scratch. 
  First line and last line should contain opening and closing curly braces. As in the example
  below.

```{.tcl}
# demo: synopsis
package require tdot
tdot dotstring {
  digraph G {
    dir1 -> CVS;
    dir1 -> src -> doc;
    dir1 -> vfs-> bin;
    vfs -> config -> ps;
    config -> pw -> pure;
    vfs -> step1 -> substep;
    dir1 -> www -> cgi;
  }
}
# make all nodes blue by adding code at the beginning
tdot header node style=filled fillcolor=skyblue
tdot write tdot-dotstring.svg
```

> ![](tdot-dotstring.svg)

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

__tdot header__ *args* 

> Adds code to teh beginning of the graph which should affect all nodes and edges
  created before and afterwards. This is a workaround for changing global properties
  after the first initial nodes and edges were added to the graph code.

```{.tcl}
# demo: synopsis
package require tdot
tdot dotstring {
  graph G {
     run -- intr;
     intr -- runbl;
     runbl -- run;
     run -- kernel;
     kernel -- zombie;
     kernel -- sleep;
     kernel -- runmem;
     runmem[label="run\nmem"];
  }
}
tdot header node style=filled fillcolor=skyblue
tdot write tdot-dotstring-neato.svg
```

> ![](tdot-dotstring-neato.svg)

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

__tdot subgraph__ *name ?args?* 

> Starts a subgraph with the given name. Subsequent arguments are interpreted as
  standard dot commands to set global properties of the graph. 
  To end a subgraph the special name END has to be used. 
  Code is based on this [Graphviz gallery code](https://graphviz.org/Gallery/directed/cluster.html).

> Example:

```{.tcl}
package require tdot
tdot set code ""
tdot set type "digraph G"
tdot graph rankdir=LR
tdot subgraph cluster_0 style=filled \
                        color=lightgrey \
                        label="process #1"
tdot node	style=filled color=white
tdot addEdge	a0 -> a1 -> a2 -> a3
tdot subgraph	END
tdot subgraph cluster_1 label="process #2" color=blue
tdot node	style=filled
tdot addEdge	b0 -> b1 -> b2 -> b3;
tdot subgraph	END
tdot addEdge	start -> a0
tdot addEdge	start -> b0
tdot addEdge	a1 -> b3 -> end
tdot addEdge	b2 -> a3 -> end
tdot addEdge	a3 -> a0;
tdot node start shape=Mdiamond
tdot node end   shape=Msquare
tdot write subgraph-sample.svg
```

> ![](subgraph-sample.svg)

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

```{.tcl}
# demo: write
package require Tk
pack [canvas .can -background white] -side top -fill both -expand true
package require tdot
tdot set code ""
tdot set type "strict digraph G"
tdot graph margin=0.4
tdot node style=filled fillcolor=salmon shape=hexagon
tdot addEdge A -> B
tdot node A label="tdot"
tdot node B label="Hello World!"  
tdot write .can
.can create rect 10 10 290 250 -outline red
destroy . ;# just to allow automatic document processing
```

> ![](tdot-canvas.png)

> You can thereafter add additional items on the canvas widget using the standard 
  commands of the canvas.

## EXAMPLES

Obviously we start with the typical "Hello World!" example.

```{.tcl}
package require tdot
tdot set code ""
tdot node A label="Hello World!\ntdot" shape=box fillcolor=grey90 style=filled
tdot write tdot-hello-world.svg
```

> ![](tdot-hello-world.svg)

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
tdot write tdot-demo.svg
```

![](tdot-demo.svg)

Now an example which uses _neato_ as the layout engine:

```{.tcl}
tdot set code ""
tdot set type "graph N" ;# switch to neato as layout engine
tdot addEdge n0 -- n1 -- n2 -- n3 -- n0;
tdot node n0 color=red style=filled fillcolor=salmon
tdot write dot-neato.svg
```
> ![](dot-neato.svg)

Alternatively you can as well overwrite the default layout engine using the graph layout option. Here the standard dot engine which is used for digraphs.

```{.tcl}
tdot set code ""
tdot set type "strict digraph G" ; # back to dot
tdot graph rankdir=LR
tdot addEdge A -> B -> C -> D -> A
tdot write dot-circle1.svg
```

> ![](dot-circle1.svg)

Now let's switch to circo as the layout engine, still having a digraph:

```{.tcl}
tdot set code ""
tdot set type "strict digraph G" ; # back to dot
tdot graph layout=circo ;# switch to circo (circular layout engine)
tdot addEdge A -> B -> C -> D -> A
tdot write dot-circle2.svg
```

> ![](dot-circle2.svg)

Also undirected graphs can be converted:

```{.tcl}
tdot set code ""
tdot set type "graph N" ;# switch to neato as layout engine
tdot graph layout=circo
tdot addEdge n0 -- n1 -- n2 -- n3 -- n0;
tdot node n0 color=red style=filled fillcolor=salmon
tdot write dot-neato2.svg
```

> ![](dot-neato2.svg)

<a name="tdot-history" />
Now a very extended example based on the example _asde91_ 
in the [dotguide manual](https://www.graphviz.org/pdf/dotguide.pdf) showing the history of Tcl/Tk and tdot within ...

```{.tcl}
tdot set code ""
tdot set type "digraph Tk"
tdot graph margin=0.3 
tdot graph size="8\;7" ;# semikolon must be backslashed due to thingy
tdot node shape=box style=filled fillcolor=grey width=1
tdot addEdge 1988  -> 1993 -> 1995 -> 1997 -> 1999 \
      -> 2000 -> 2002 -> 2007 -> 2012 -> future
tdot node fillcolor="#ff9999"
tdot edge style=invis
tdot addEdge  Tk -> Bytecode -> Unicode -> TEA -> vfs -> \
      Tile -> TclOO -> zipvfs
tdot edge style=filled
tdot node fillcolor="salmon"
tdot addEdge "Tcl/Tk" -> 7.3 -> 7.4 -> 8.0  ->  8.1 ->  8.3 \
      -> 8.4  -> 8.5  ->  8.6 -> 8.7;
tdot node fillcolor=cornsilk
tdot addEdge  7.3 -> Itcl -> 8.6
tdot addEdge  Tk -> 7.4 -> Otcl -> XOTcl -> NX 
tdot addEdge  Otcl -> Thingy -> tdot
tdot addEdge  Bytecode -> 8.0 
tdot addEdge  8.0 -> Namespace dir=back
tdot addEdge  Unicode -> 8.1
tdot addEdge  8.1 -> Wiki
tdot addEdge  TEA -> 8.3 
tdot addEdge  8.3 -> Tcllib -> Tklib
tdot addEdge  8.4 -> Starkit -> Snit -> Dict -> 8.5 
tdot addEdge  vfs -> 8.4
tdot addEdge  Tile -> 8.5
tdot addEdge  TclOO -> 8.6  -> TDBC
tdot addEdge  zipvfs -> 8.7  ;# Null is just a placeholder for the history
tdot block    rank=same 1988 "Tcl/Tk"  group=g1
tdot block    rank=same 1993  7.3      group=g1  Itcl
tdot block    rank=same 1995  Tk       group=g0  7.4 group=g1 Otcl group=g2
tdot block    rank=same 1997  Bytecode group=g0  8.0 group=g1 Namespace
tdot block    rank=same 1999  Unicode  group=g0  8.1 group=g1 Wiki 
tdot block    rank=same 2000  TEA      group=g0  8.3 group=g1 Tcllib \
                              Tklib XOTcl group=g2 
tdot block    rank=same 2002  vfs      group=g0  8.4 group=g1 Starkit Dict Snit
tdot block    rank=same 2007  Tile     group=g0  8.5 group=g1 
tdot block    rank=same 2012  TclOO    group=g0  8.6 group=g1 TDBC NX group=g2
tdot block    rank=same future zipvfs  group=g0  8.7 group=g1 Null group=g2 tdot group=g3

# specific node settings 
tdot node     History label="History of Tcl/Tk\nand  tdot" shape=doubleoctagon color="salmon" penwidth=5 \
      fillcolor="white" fontsize=26 fontname="Monaco"
tdot node     Namespace fillcolor="#ff9999"
tdot node     future label=2021
tdot node     8.7    label="\[ 8.7a5 \]"
# arranging the History in the middle
tdot addEdge  8.7 -> Null style=invis
tdot addEdge  Null -> History style=invis
tdot node Null style=invis
tdot write tdot-history.png
```

![](tdot-history.svg)

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
* 2021-09-14 Version 0.2.0 
    * adding dotstring command similar to tcldot's command
    * docu fixes, switching from png to svg if possible for filesize
* 2021-09-26 Version 0.3.0
    * adding header method for code at the beginning
    * adding subgraph method with extended example from Graphviz gallery
    * adding quoted node names
    * fixing spacing issues in label spaces 
    * adding semikolon issue as note on top

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
    - [tcldot documenation (pdf)](https://www.graphviz.org/pdf/tcldot.3tcl.pdf)
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

