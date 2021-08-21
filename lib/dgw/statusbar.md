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

# dgw::statusbar 0.2
    
### Detlef Groth, Schwielowsee, Germany
    
### 2021-08-21


## NAME

**dgw::statusbar** - statusbar widget for Tk applications based on a ttk::label and a ttk::progressbar widget

## <a name='toc'></a>Table of Contents

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


    package require dgw::statusbar
    dgw::statusbar pathName options
    pathName configure -textvariable varname
    pathName configure -variable varname
    pathName clear 
    pathname progress value
    pathName set message ?value?


## <a name='description'>DESCRIPTION</a>

**dgw::statusbar** - is a composite widget consisiting of a ttk::label and a ttk::progressbar widget. 
It should be normally packaged at the bottom of an appöication.
The text and the numerical progress value can be displayed either directly 
using the widget commands or via the *-textvariable* and *-variable* options which  will be given at initialization time, 
but these options can be also redifined at a later point.

## <a name='command'>COMMAND</a>

**dgw::statusbar** *pathName ?options?*

> Creates and configures a new dgw::statusbar widget  using the Tk window id _pathName_ and the given *options*. 
 
## <a name='options'>WIDGET OPTIONS</a>

The **dgw::statusbar** widget is a composite widget where the options 
are delegated to the original widgets.

  __-maximum__ _value_ 

 > A floating point number specifying the maximum -value. Defaults to 100. 

  __-textvariable__ _varname_ 

 > Delegates the variable _varname_ to the ttk::label as such.

  __-variable__ _varname_ 

 > Delegates the variable _varname_ to the ttk::progressbar. Note that the maximum value is 100. 
   So you have to calculate the

## <a name='commands'>WIDGET COMMANDS</a>

Each **dgw::combobox** widgets supports its own as well via the *pathName label cmd* and *pathName progressbar cmd* syntax all the commands of its component widgets.

*pathName* **clear** *message ?value?*

> Removes the message from the label and sets to progressbar to zero.

*pathName* **label** *cmd ?option value ...?*

> Allows access to the commands of the embedded ttk::label widget. 
  Via configure and cget you can as well configure this internal widget. 
  For details on the available methods and options have a look at the 
  ttk::label manual page.

*pathName* **progress** *value*

> Sets the progressbar to the given value.

*pathName* **progressbar** *cmd ?option value ...?*

> Allows access to the commands of the embedded ttk::progessbar widget. 
  Via configure and cget you can as well configure this internal widget. 
  For details on the available methods and options have a look at the 
  ttk::progressbar manual page.

*pathName* **set** *message ?value?*

> Displays the given message and value. If the value is not given it is set to zero.

## <a name='example'>EXAMPLE</a>

    package require dgw::progressbar
    namespace import ::dgw::tlistbox
    wm title . DGApp
    pack [text .txt] -side top -fill both -expand yes
    set stb [dgw::statusbar .stb]
    pack $stb -side top -expand false -fill x
    $stb progress 50
    $stb set Connecting....
    after 1000
    $stb set "Connected, logging in..."
    $stb progress 50
    after 1000
    $stb set "Login accepted..." 
    $stb progress 75
    after 1000
    $stb set "Login done!" 90
    after 1000
    $stb set "Cleaning!" 95
    after 1000
    $stb set "" 100
    set msg Sompleted
    set val 90
    $stb configure -textvariable msg
    $stb configure -variable val


## <a name='install'>INSTALLATION</a>

Installation is easy you can easily install and use this ** dgw::statusbar** package if you have a working install of:

- the snit package  which can be found in [tcllib](https://core.tcl-lang.org/tcllib/doc/trunk/embedded/index.md)

For installation you copy the complete *dgw* folder into a path 
of your *auto_path* list of Tcl or you append the *auto_path* list with the parent dir of the *dgw* directory.
Alternatively you can install the package as a Tcl module by creating a file `dgw/statusbar-0.2.tm` in your Tcl module path.
The latter in many cases can be achieved by using the _--install_ option of statusbar.tcl. 
Try "tclsh statusbar.tcl --install" for this purpose.

## <a name='demo'>DEMO</a>

Example code for this package can  be executed by running this file using the following command line:


    $ wish statusbar.tcl --demo


The example code used for this demo can be seen in the terminal by using the following command line:


    $ wish statusbar.tcl --code


## <a name='docu'>DOCUMENTATION</a>

The script contains embedded the documentation in Markdown format. To extract the documentation you should use the following command line:


    $ tclsh statusbar.tcl --markdown


This will extract the embedded manual pages in standard Markdown format. You can as well use this markdown output directly to create html pages for the documentation by using the *--html* flag.


    $ tclsh statusbar.tcl --html


This will directly create a HTML page `statusbar.html` which contains the formatted documentation. 
Github-Markdown can be extracted by using the *--man* switch:


    $ tclsh statusbar.tcl --man


The output of this command can be used to feed a markdown processor for conversion into a 
man page, a html or a pdf document. If you have pandoc installed for instance, you could execute the following commands:


    # man page
    tclsh statusbar.tcl --man | pandoc -s -f markdown -t man - > statusbar.n
    # html page
    tclsh ../statusbar.tcl --man > statusbar.md
    pandoc -i statusbar.md -s -o statusbar.html
    # pdf
    pandoc -i statusbar.md -s -o statusbar.tex
    pdflatex statusbar.tex


## <a name='see'>SEE ALSO</a>

- [dgw - package homepage: http://chiselapp.com/user/dgroth/repository/tclcode/index](http://chiselapp.com/user/dgroth/repository/tclcode/index)

## <a name='todo'>TODO</a>

* probably as usually more documentation
* more, real, tests
* github url for putting the code

## <a name='authors'>AUTHOR</a>

The **statusbar** widget was written by Detlef Groth, Schwielowsee, Germany.

## <a name='copyright'>COPYRIGHT</a>

Copyright (c) 2019-2020  Dr. Detlef Groth, E-mail: detlef(at)dgroth(dot)de

## <a name='license'>LICENSE</a>

dgw::statusbar package, version 0.2.

Copyright (c) 2019-2021  Dr. Detlef Groth, E-mail: detlef(at)dgroth(dot)de

This library is free software; you can use, modify, and redistribute it
for any purpose, provided that existing copyright notices are retained
in all copies and that this notice is included verbatim in any
distributions.

This software is distributed WITHOUT ANY WARRANTY; without even the
implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.



