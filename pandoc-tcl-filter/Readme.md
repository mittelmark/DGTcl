---
title: "Readme for the Pandoc Tcl filter"
shorttitle: "tcl-filter"
author: 
- Detlef Groth
date: 2021-08-25
abstract: >
    The pandoc-tcl-filter allows you the embed Tcl code in code blocks
    and short Tcl statements as wekk in the normal text of a Markdown 
    document. The code fragments will be executed dynamically and the output
    of the Tcl commands can be shown in an extra code block or can replace
    the code block as well.
---

## NAME

_pandoc-tcl-filter.tcl_ - filter to execute code within Markdown documents and use code results for documentation.

## Usage

```
pandoc input.md -s -o output.html --filter pandoc-tcl-filter.tcl
```

## Installation

The filter can be installed locally by placing it in a folder belonging to
your personal PATH and making the file executable or alternatively you can
just use it by specifying the correct path to the Tcl script in your pandoc
command line call. The direct link to the github repository folder is:
[https://downgit.github.io/#/home?url=https://github.com/mittelmark/DGTcl/tree/master/pandoc-tcl-filter](https://downgit.github.io/#/home?url=https://github.com/mittelmark/DGTcl/tree/master/pandoc-tcl-filter)
Just unpack the Tcl script from the download and make the file executable.

The filter requires the Tcl package *rl_json* which is available from Github: [https://github.com/RubyLane/rl_json](https://github.com/RubyLane/rl_json).
Unix users should be able to install the package via the standard configure/make pipeline.
Windows users should install the rl_json package via the Magicplats Tcl-Installer: [https://www.magicsplat.com/tcl-installer](https://www.magicsplat.com/tcl-installer/index.html)

## Example

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

In the code above a space was added to avoid confusiing the pandoc interpreter
by nesteding triple tickmarks, remove those spaces in your code.

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

Within the curly braces the following attributes are currently supported:

* _eval=false|true_ - evaluate the Tcl code
* _results=show|hide_ - show the output of the Tcl code execution
* _echo=true|false_ - show the Tcl code

Errors in the tcl code will be usually trapped and the error info is shown
instead of the regular output.

## Images

As Tcl has no standard library in the core to create graphics without the Tk
toolkit we will create a small object using a minimal object oriented system
which can create svg files easily.

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

We now need a method _unknow_ which catches all command on the object and
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

; # any unknown should forward to the tag method
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
svg write hello-world.svg
```

Let's now display the image:

```
 ![](hello-world.svg)
``` 

Here the image displayed:

![](hello-world.svg)

Let's now clean up the svg code:
```{.tcl}
svg set code ""
svg set code 
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
svg write chessboard.svg
```

![](chessboard.svg)

## Documentation

The HTML version of this document was generated using the following commandline:

```
pandoc Readme.md --metadata title="Readme pandoc-tcl-filter.tcl" \
    -M date="`date "+%B %e, %Y %H:%M"`" -s -o Readme.html \
     --filter pandoc-tcl-filter.tcl --css mini.css

```

Please look at the source Markdown file to see which Markdown code was the input.

## Links

* [Discussion page for pandoc-tcl-filter.tcl on the Tclers Wiki](https://wiki.tcl-lang.org/page/pandoc%2Dtcl%2Dfilter) 
* [https://pandoc.org/filters.html](https://pandoc.org/filters.html) - background on  pandoc filters
* [pandoc lua filters](https://github.com/pandoc/lua-filters)
* [https://github.com/mvhenderson/pandoc-filter-node](https://github.com/mvhenderson/pandoc-filter-node) - pandoc filters using JavaScript and TypeScript
* [https://pypi.org/project/panflute/](https://pypi.org/project/panflute/) - pandoc filters in Python
* 

## TODO

* code block labels (label=chunkname)
* code block figures (include=false fig=true)
* regular filter infrastructure for Tcl support for for instance other filters like .csv to include csv files .dot to include dot file graphics etc.
* Windows exe / starkit containing the rl_json library as well

## History

* 2021-08-22 - Release of Wiki cocde
* 2021-08-25 - Release of github code
* 2021-08-26 - Adding thingy svg creator, image file writing works


## Author

Detlef Groth, Caputh-Schwielowsee, Germany

## License

MIT, see the file LICENSE in the release folder.
