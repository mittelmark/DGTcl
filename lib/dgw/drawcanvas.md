[dgw](dgw.html) - 
[basegui](basegui.html) - 
[combobox](combobox.html) - 
[drawcanvas](drawcanvas.html) - 
[hyperhelp](hyperhelp.html) - 
[sbuttonbar](sbuttonbar.html) - 
[seditor](seditor.html) - 
[sfilebrowser](sfilebrowser.html) - 
[sfinddialog](sfinddialog.html) - 
[sqlview](sqlview.html) - 
[statusbar](statusbar.html) - 
[tablelist](tablelist.html) - 
[tlistbox](tlistbox.html) - 
[tvmixins](tvmixins.html) - 
[txmixins](txmixins.html) 

# dgw::drawcanvas 0.1
    
### Detlef Groth, Schwielowsee, Germany
    
### 2021-08-20


## NAME

**dgw::drawcanvas** - simple drawing tool to sketch some text, lines, rectangles ovals on the fly.

## <a name='toc'></a>TABLE OF CONTENTS

 - [SYNOPSIS](#synopsis)
 - [DESCRIPTION](#description)
 - [COMMAND](#command)
 - [WIDGET OPTIONS](#options)
 - [WIDGET COMMANDS](#commands)
 - [KEY BINDINGS](#bindings)
 - [EXAMPLE](#example)
 - [INSTALLATION](#install)
 - [DEMO](#demo)
 - [DOCUMENTATION](#docu)
 - [SEE ALSO](#see)
 - [CHANGES](#changes)
 - [TODO](#todo)
 - [AUTHORS](#authors)
 - [COPYRIGHT](#copyright)
 - [LICENSE](#license)
 
## <a name='synopsis'>SYNOPSIS</a>


    package require Tk
    package require snit
    package require dgw::drawcanvas


## <a name='description'>DESCRIPTION</a>

The widget **dgw::drawcanvas** provides a simple drawing surface to place, lines, rextangles, ovales and text
in different in a fast manner on a canvas. It is based on code in the Tclers Wiki: 

## <a name='command'>COMMAND</a>

**dgw::drawcanvas** *pathName ?-option value ...?*

> Creates and configures the **dgw::drawcanvas**  widget using the Tk window id _pathName_ and the given *options*. 
 
## <a name='options'>WIDGET OPTIONS</a>

As the **dgw::drawcanvas** is an extension of the standard Tk canvas widget 
it supports all method and options of this widget. 
The following option(s) are added by the *dgw::drawcanvas* widget:

__-colors__ _colorList_

> List of colors which can be used to fill ovals and rectangles. Those colors are a set of pastel like colors.

## <a name='commands'>WIDGET COMMANDS</a>

Each **dgw::drawcanvas** widget supports all usual methods of the Tk canvas widget and it adds the follwing method(s):

*pathName* **eraseAll** *?ask?*

> Deletes all items in the widget, if ask is true (default), then the user will get a message box to agree on deleting all items.

*pathName* **saveCanvas** *?fileName?*

> Saves the content of the canvas either as ps or if the ghostscript 
interpreter is available as well as pdf file using the given filename. If the filename is not given
 the user will be asked for one.

## <a name='example'>EXAMPLE</a>

In the example below we create a Markdown markup aware text editor.


    package require dgw::drawcanvas
    dgw::drawcanvas .dc
    pack .dc -side top -fill both -expand true


## <a name='install'>INSTALLATION</a>

Installation is easy you can install and use the **dgw::drawcanvas** package if you have a working install of:

- the snit package  which can be found in [tcllib - https://core.tcl-lang.org/tcllib](https://core.tcl-lang.org/tcllib)

For installation you copy the complete *dgw* folder into a path 
of your *auto_path* list of Tcl or you append the *auto_path* list with the parent dir of the *dgw* directory.
Alternatively you can install the package as a Tcl module by creating a file dgw/drawcanvas-0.1.tm in your Tcl module path.
The latter in many cases can be achieved by using the _--install_ option of drawcanvas.tcl. 
Try "tclsh drawcanvas.tcl --install" for this purpose.

## <a name='demo'>DEMO</a>

Example code for this package can  be executed by running this file using the following command line:


    $ wish drawcanvas.tcl --demo

The example code used for this demo can be seen in the terminal by using the following command line:


    $ tclsh drawcanvas.tcl --code

## <a name='docu'>DOCUMENTATION</a>

The script contains embedded the documentation in Markdown format. To extract the documentation you should use the following command line:


    $ tclsh drawcanvas.tcl --markdown


This will extract the embedded manual pages in standard Markdown format. You can as well use this markdown output directly to create html pages for the documentation by using the *--html* flag.


    $ tclsh drawcanvas.tcl --html


If the tcllib Markdown package is installed, this will directly create a HTML page `drawcanvas.html` 
which contains the formatted documentation. 

Github-Markdown can be extracted by using the *--man* switch:


    $ tclsh drawcanvas.tcl --man


The output of this command can be used to feed a Markdown processor for conversion into a 
html, docx or pdf document. If you have pandoc installed for instance, you could execute the following commands:


    tclsh ../drawcanvas.tcl --man > drawcanvas.md
    pandoc -i drawcanvas.md -s -o drawcanvas.html
    pandoc -i drawcanvas.md -s -o drawcanvas.tex
    pdflatex drawcanvas.tex


## <a name='see'>SEE ALSO</a>

- [dgw package homepage](https://chiselapp.com/user/dgroth/repository/tclcode/index) - various useful widgets

 
## <a name='changes'>CHANGES</a>

* 2020-03-27 - version 0.1 started

## <a name='todo'>TODO</a>

* github url

## <a name='authors'>AUTHORS</a>

The dgw::**dgw::drawcanvas** widget was written by Detlef Groth, Schwielowsee, Germany.

## <a name='copyright'>Copyright</a>

Copyright (c) 2020  Dr. Detlef Groth, E-mail: detlef(at)dgroth(dot)de

## <a name='license'>LICENSE</a>

dgw::drawcanvas package, version 0.1.

Copyright (c) 2019-2021  Dr. Detlef Groth, E-mail: detlef(at)dgroth(dot)de

This library is free software; you can use, modify, and redistribute it
for any purpose, provided that existing copyright notices are retained
in all copies and that this notice is included verbatim in any
distributions.

This software is distributed WITHOUT ANY WARRANTY; without even the
implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.



