---
title: "pandoc-tcl-filter example - tcl filter"
author: 
- Detlef Groth
date: Fri Nov 26 2021
---

## Introduction

Below are a few samples for embedding Tcl code 
into Markdown documents. The examples should work as well in other text
markup languages like LaTeX, Asciidoc etc. This filter requires no additional 
software installations, just a working Tcl installation.

Links: 

* Tcl/Tk Homepage: [https://www.tcl.tk/](https://www.tcl.tk/)
* Tcl filter documentation: [../filter/filter-tcl.html]  

## Tcl examples

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


The results from the code execution will be directly embedded in the text and will replace the Tcl code.
Such inline statements should be short and concise and should not break over
several lines.

Larger chunks of code can be placed within triple backticks such as in the example below.

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
by nesteding triple tickmarks, remove those spaces in your code.

And here the output:

```{.tcl}
set x 3
proc add {x y} {
    return [expr {$x+$y}]
}
add $x 7
```

## Table examples

Since version 0.5.0 the Tcl filter contains a prcedure *list2mdtab* which can
be used to display easily nested and unnested lists. The function get's two
arguments, first the column headers, second the values. Here two examples:
First a unnested list:

```{.tcl results="asis"}
list2mdtab [list Col1 Col2 Col3] [list 1 2 3 4 5 6 7 8 9]
```

Thereafter let's show a nested list example.

```{.tcl results="asis"}
list2mdtab [list Col1 Col2 Col3] [list [list 11 12 13] [list 14 15 16] [list 17 18 19]]
```


## Document creation

Assuming that the file pandoc-tcl-filter.tapp is in your PATH, 
this document can be converted into an HTML file using the command line:

```
 pandoc -s -o sample-tcl.html --filter pandoc-tcl-filter.tapp sample.md
 ## you can as well specify a style sheet to beautify the output
 pandoc -s -o sample-tcl.html --css ghpandoc.css \
    --filter pandoc-tcl-filter.tapp sample.md
```



## EOF



