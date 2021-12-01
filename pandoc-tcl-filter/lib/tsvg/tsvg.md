## NAME 

_tsvg_ - Thingy SVG writer - package to create svg image files with a syntax close to Tcl and to SVG.

## SYNOPSIS

```
package require tsvg
tsvg set width 100
tsvg set height 100
# Tcl like syntax without hyphens
tsvg circle cx 50 cy 50 r 45 stroke black stroke-width 2 fill salmon
tsvg text x 29 y 45 Hello
tsvg text x 27 y 65 World!
tsvg write hello-world.svg
tsvg write hello-world.pdf # needs cairosvg
tsvg write hello-world.png # needs cairosvg
tsvg set code ""
# Tcl like syntax with hyphens
tsvg circle -cx 50 -cy 50 -r 45 -stroke black -stroke-width 2 -fill salmon
tsvg text -x 29 -y 45 Hello
tsvg text -x 27 -y 65 World!
tsvg write hello-world.svg
# SVG like syntax
tsvg circle cx="50" cy="50" r="45" stroke="black" \
   stroke-width="2" fill="light blue"
tsvg text x="29" y="45" Hello
tsvg text x="27" y="65" World!
```

## DESCRIPTION

The package provides one command _tsvg_ which can hold currently just a single 
svg code. All commands will be evaluated within the tsvg namespace, all unknown 
methods will be forwarded to the standard `tsvg::tag` method and produce 
svg code out of them. So _tsvg dummy x="20" hello_ will produce:

```
<dummy x="20">hello</dummy>
```

## VARIABLES

The following public variables can be modified using the set command like so: _tsvg set varname_ value:

> - _code_ - the variable collecting the svg code, usually you will only set this variable by hand to remove all existing svg code after doing an image by calling _tsvg set code ""_.
  - _footer_ - the standard SVG-XML footer, should be usually not changed.
  - _header_ - the standard SVG-XML header, should be usually not changed.
  - _height_ - the image height used for writing out the svg file, default: 100
  - _width_ - the image width used for writing out the svg file, default: 100

## METHODS

The following methods are implemented:

__self__

> just an `interp alias` for `namespace current`

__tsvg demo__ 

> Writes the "Hello World!" string into a file hello-world.svg in the current directory.

__tsvg figure__ _filename_ _width_ _height_

> Writes the current svg code into the given filename with the 
  given width and height settings. 

__tsvg inline__ 

> Returns the SVG code as inline SVG with a viewBox code which can be directly embedded within HTML pages. So the xml header is here missing.

__tsvg write__ _filename_

> Writes the current svg code into the given filename with the current width and height settings. 
  Supported file extensions are *.svg* or if the tool *cairosvg* is installed as well *.png* and *.pdf*.

__tsvg tag__ tagname _args_

> Creates the given tagname and adds all remaining arguments as attibutes if they come 
  in pairs. If the numer of arguments is odd, the last argument will be placed within 
  the XML tags.

The following functions are just implemented for avoiding name clashes because some existing Tcl/Tk 
functions have the same name. They should be not used directly.

> - _tsvg text_

The following function(s) are private and should not be used directly by the user of
this package.

> - _tsvg TagFix_

## EXAMPLES

The typical Hello World example:

```{.tsvg label=hello-world}
tsvg circle cx 50 cy 50 r 45 stroke black stroke-width 2 fill salmon
tsvg text x 29 y 45 Hello
tsvg text x 27 y 65 World!
tsvg write hello-world.svg
```

The typical Hello World example but this time with hyphens to easier indicate the arguments:

```{.tsvg label=hello-world2}
tsvg set code "" ;# clear 
tsvg circle -cx 50 -cy 50 -r 45 -stroke black -stroke-width 2 -fill green
tsvg text -x 29 -y 45 Hello
tsvg text -x 27 -y 65 World!
tsvg write hello-world2.svg
```

Since version 0.3.0 writing of PNG and PDF files is as well possible if the command line tool *cairosvg* is installed. You can install this tool either using your package manager, or if yo do not have administrator rights as ordinary user using the Python package installer like this:

```
pip3 install cairosvg --user 
```  

If *cairosvg* is installed you can as well write PNG and PDF files. As this is an HTML document let's create a PNG file and display it thereafter:

```{.tsvg include=false}
tsvg circle -cx 50 -cy 50 -r 42 -stroke red -stroke-width 7 -fill none
tsvg write hello-world2.png
```

![](hello-world2.png)      
 
To continue with an other image you have first to clean up the previous image:

```{.tsvg label=basic-shapes}
tsvg set code "" ;# clear 
tsvg set width 200 ;# new size as on the webpage
tsvg set height 250 
tsvg rect x="10" y="10" width="30" height="30" stroke="black" fill="transparent" stroke-width="5"
tsvg rect x="60" y="10" rx="10" ry="10" width="30" height="30" stroke="black" fill="transparent" stroke-width="5"
tsvg circle cx="25" cy="75" r="20" stroke="red" fill="transparent" stroke-width="5"
tsvg ellipse cx="75" cy="75" rx="20" ry="5" stroke="red" fill="transparent" stroke-width="5"
tsvg line x1="10" x2="50" y1="110" y2="150" stroke="orange" stroke-width="5"
tsvg polyline points="60 110 65 120 70 115 75 130 80 125 85 140 90 135 95 150 100 145" \
    stroke="orange" fill="transparent" stroke-width="5"
tsvg polygon points="50 160 55 180 70 180 60 190 65 205 50 195 35 205 40 190 30 180 45 180" \
    stroke="green" fill="transparent" stroke-width="5"
tsvg path d="M20,230 Q40,205 50,230 T90,230" fill="none" stroke="blue" stroke-width="5"
tsvg write basic-shapes.svg
```

Nesting of elements can be achieved as well by adding *_start* and *_end* at the 
end of the tag, here an example for a group using the tag _g_.

```{.tsvg label=group-circles}
tsvg set code ""
tsvg set width 100
tsvg set height 100
tsvg g_start fill="white" stroke="green" stroke-width="5"
tsvg circle cx="40" cy="40" r="25"
tsvg circle cx="60" cy="60" r="25"
tsvg g_end
tsvg write group-circles.svg
```

## Embedding SVG code into HTML pages

The _tsvg_ object as well offers a _inline_ method which returns SVG code ready to be embed directly within HTML pages.

```{.tsvg results=show fig=false}
tsvg circle cx="70" cy="70" r="25" stroke="blue" fill="white" stroke-width="5"
tsvg write inline.svg
tsvg inline
```

![](inline.svg)


## Extending

If you need to extend the package or to fix nameclashes with other packages you can 
just write your own procedures. For instance if one package you are working with would
import an _rect_ command you would call this using the _tsvg rect_ command to fix this issue you just have to  implement your own _tsvg rect_ procedure like this:

```
tsvg proc rect {args} {
    set self [self]
    $self tag rect {*}$args
}
```

That way you can as well create your own function which perform more complex SVG element creations. Here an example:

```{.tsvg label=logo}
tsvg proc logo_tsvg {{filename ""}} {
    tsvg set code ""
    tsvg set width 100
    tsvg set height 60
    tsvg rect x 0 y 0 width 100 height 100 fill #F64935
    tsvg text x 20 y 40 style "font-size:24px;fill:blue;" tSVG
    if {$filename ne ""} {
       tsvg write $filename
    }
}
tsvg logo_tsvg logo.svg
```


## Documentation

The documentation for this HTML file was created using the pandoc-tcl-filter and the filter for the tsg package as follows:

```
 perl -ne "s/^#' ?(.*)/\$$1/ and print " lib/tsvg/tsvg.tcl > tsvg.md
 pandoc tsvg.md -s  \
    --metadata title="tsvg package documentation"  \
    -o tsvg.html  --filter pandoc-tcl-filter.tcl \
    --css mini.css --toc
 htmlark -o lib/tsvg/tsvg.html tsvg.html
```

## ChangeLog

* 2021-08-28 Version 0.1 with docu uploaded to GitHub
* 2021-08-31 Version 0.2 fix for the header line
* 2021-12-01 Version 0.3.0 adding write option for PNG and PDF files using cairosvg 
    
## SEE ALSO

* [Readme.html](../../Readme.html) - more information about pandoc Tcl filters
* [Tclers Wiki page](https://wiki.tcl-lang.org/page/tsvg) - place for discussion

## AUTHOR

Dr. Detlef Groth, Caputh-Schwielowsee, Germany, detlef(_at_)dgroth(_dot_).de

## License

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

