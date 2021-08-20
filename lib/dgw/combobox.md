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

# dgw::combobox 0.2
    
### Detlef Groth, Schwielowsee, Germany
    
### 2020-01-04


## NAME

**dgw::combobox** - snit widget derived from a ttk::combobox with added dropdown list and filtering

## <a name='toc'></a>TABLE OF CONTENTS

 - [SYNOPSIS](#synopsis)
 - [DESCRIPTION](#description)
 - [COMMAND](#command)
 - [WIDGET OPTIONS](#options)
 - [WIDGET COMMANDS](#commands)
 - [EXAMPLE](#example)
 - [INSTALLATION](#install)
 - [DEMO](#demo)
 - [DOCUMENTATION](#docu)
 - [SEE ALSO](#see)
 - [TODO](#todo)
 - [AUTHOR](#authors)
 - [COPYRIGHT](#copyright)
 - [LICENSE](#license)
 
## <a name='synopsis'>SYNOPSIS</a>


    package require dgw::combobox
    namespace import ::dgw::combobox
    combobox pathName options
    pathName configure -values list
    pathName configure -hidenohits boolean
    pathName configure -textvariable varname


## <a name='description'>DESCRIPTION</a>

**dgw::combobox** - is a snit widget derived from a ttk::combobox but with the added possibility to display
the list of values available in the combobox as dropdown list. This dropdown list can further be filtered using the given 
options. If the user supplies the option -hidenohits false. He just gets the standard ttk::combobox

## <a name='command'>COMMAND</a>

**dgw::combobox** *pathName ?options?*

> Creates and configures the **dgw::combobox**  widget using the Tk window id _pathName_ and the given *options*. 
 
## <a name='options'>WIDGET OPTIONS</a>

As the **dgw::combobox** widget is derived from the standard ttk::combobox it interhits all options and methods from ttk::combobox. 
  __-hidenohits__ _boolean_ 

 > If _hidenohits_ is set to true, non-matching list entries are not displayed in the dropdown listbox.
   Defaults to true.

## <a name='commands'>WIDGET COMMANDS</a>

As the dgw::combobox widget is dertived from the ttk::combobox, it has all methods available as a ttk::combobox, see the ttk::combobox 
manual from the description of the widget commands.


## <a name='example'>EXAMPLE</a>


       wm title . "DGApp"
       pack [label .l0 -text "standard combobox"]
       ttk::combobox .c0 -values [list  done1 done2 dtwo dthree four five six seven]
       pack .c0 -side top
       pack [label .l1 -text "combobox with filtering"]
       dgw::combobox .c1 -values [list done1 done2 dtwo dthree four five six seven] \
            -hidenohits true
       pack .c1 -side top     
       pack [label .l2 -text "combobox without filtering"]
       dgw::combobox .c2 -values [list done1 done2 dtwo dthree four five six seven] \
            -hidenohits false
       pack .c2 -side top 


## <a name='install'>INSTALLATION</a>

Installation is easy you can install and use the **dgw::combbox** package if you have a working install of:

- the snit package  which can be found in [tcllib - https://core.tcl-lang.org/tcllib](https://core.tcl-lang.org/tcllib)

For installation of dgw::combobox just put the folder _dgw_ in a folder belonging to your Tcl-library path 
or put combobox.tcl as combobox-0.2.tm to a folder dgw which belongs to your Tcl-Module path. 
The latter can be as well achieved using the _-install_ option such as `tclsh combobox.tcl --install` which will try to install dgw::combobox into your Tcl-module path.
## <a name='demo'>DEMO</a>

Example code for this package can  be executed by running this file using the following command line:


    $ wish combobox.tcl --demo

The example code used for this demo can be seen in the terminal by using the following command line:


    $ wish combobox.tcl --code


## <a name='docu'>DOCUMENTATION</a>

The script contains embedded the documentation in Markdown format. To extract the documentation you should use the following command line:


    $ tclsh combobox.tcl --markdown


This will extract the embedded manual pages in standard Markdown format. You can as well use this markdown output directly to create html pages for the documentation by using the *--html* flag.


    $ tclsh combobox.tcl --html


This will directly create a HTML page `combobox.html` which contains the formatted documentation. 
Github-Markdown can be extracted by using the *--man* switch:


    $ tclsh combobox.tcl --man


The output of this command can be used to feed a markdown processor for conversion into a 
man page, a html or a pdf document. If you have pandoc installed for instance, 
you could execute the following commands:


    # man page
    tclsh combobox.tcl --man | pandoc -s -f markdown -t man - > combobox.n
    # html page
    tclsh ../combobox.tcl --man > combobox.md
    pandoc -i combobox.md -s -o combobox.html
    # pdf
    pandoc -i combobox.md -s -o combobox.tex
    pdflatex combobox.tex


## <a name='see'>SEE ALSO</a>

- [dgw - package homepage: http://chiselapp.com/user/dgroth/repository/tclcode/index](http://chiselapp.com/user/dgroth/repository/tclcode/index)

## <a name='todo'>TODO</a>

* probably as usually more documentation
* more, real, tests
* github url for putting the code

## <a name='authors'>AUTHOR</a>

The **combobox** widget was written by Detlef Groth, Schwielowsee, Germany.

## <a name='copyright'>COPYRIGHT</a>

Copyright (c) 2019  Dr. Detlef Groth, E-mail: detlef(at)dgroth(dot)de

## <a name='license'>LICENSE</a>

Text search dialog widget dgw::combobox, version 0.2.

Copyright (c) 2019  Dr. Detlef Groth, E-mail: detlef(at)dgroth(dot)de

This library is free software; you can use, modify, and redistribute it
for any purpose, provided that existing copyright notices are retained
in all copies and that this notice is included verbatim in any
distributions.

This software is distributed WITHOUT ANY WARRANTY; without even the
implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.



