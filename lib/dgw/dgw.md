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

# dgw::dgw 0.6
    
### Dr. Detlef Groth, Schwielowsee, Germany
    
### 2021-08-21


## NAME

**dgw::dgw**  - Detlef Groth's Tk Widgets

## <a name='synopsis'>SYNOPSIS</a>


    package require Tk 8.6
    package require snit
    package require dgw::dgw
    dgw::basegui app
    dgw::combobox pathname
    dgw::sbuttonbar pathname
    dgw::seditor pathname
    dgw::statusbar pathname
    package require tablelist::tablelist
    dgw::sfilebrowser pathname
    dgw::tablelist pathname
    dgw::tlistbox pathname


## <a name='command'>COMMAND</a>

**package::require dgw::dgw**

> The *dgw::dgw* package is just a wrapper package to load all the dgw widgets with one package call.
The following packages are loaded via the *package require dgw::dgw* call.

> - [dgw::basegui](basegui.html) - framework to build up Tk application, contains as well a few standalone widgets which can be used inside existing Tk applications:
      - [autoscroll](basegui.html#autoscroll) - add scrollbars to Tk widgets which appear only when needed.
      - [balloon](basegui.html#balloon) - add tooltips to Tk widgets
      - [cballoon](basegui.html#cballoon) - add tooltips to canvas tags
      - [center](basegui.html#center) - center toplevel widgets
      - [console](basegui.html#console) - embedded Tcl console for debugging
      - [dlabel](basegui.html#dlabel) - label widget with dynamic fontsize fitting the widget size
      - [labentry](basegui.html#labentry) - composite widget of label and entry
      - [notebook](basegui.html#notebook) - ttk::notebook with interactive tab management faciltities
      - [rotext](basegui.html#rotext) - read only text widget
      - [splash](basegui.html#splash) - splash window with image and message faciltites
      - [timer](basegui.html#timer) - simple timer to measure execution times
      - [treeview](basegui.html#treeview) - ttk::treeview widget with sorting facilities
  - [dgw::combobox](combobox.html) - ttk::combobox with added dropdown list and filtering
  - [dgw::sbuttonbar](sbuttonbar.html) - buttonbar with round image buttons and text labels
  - [dgw::seditor](seditor.html) - extended text editor widget with toolbar and syntax hilighting 
  - [dgw::sfinddialog](sfinddialog.html) - find and search dialog for instance for text widgets
  - [dgw::statusbar](statusbar.html) - statusbar widget with label for text messages and ttk::progressbar
  - [dgw::tvmixins](tvmixins.html) - treeview widget adaptors usable as mixins for the ttk::treeview widget.
  - [dgw::txmixins](txmixins.html) - text widget adaptors usable as mixins for the tk::text widget.

> The following widgets must be loaded separately using `package dgw::widgetname` as they depend on other non-standard packages such as `tablelist::tablelist`, `tdbc::sqlite3` or `dgtools::shistory`

> - [dgw::hyperhelp](hyperhelp.html) - help system with hypertext facilitites and table of contents outline (requires dgtools package)
  - [dgw::sfilebrowser](sfilebrowser.html) - snit file browser widget (requires tablelist package)
  - [dgw::sqlview](sqlview.html) - SQLite database browser widget (requires tdbc::sqlite3 package)
  - [dgw::tablelist](tablelist.html) - tablelist widget with a few icons and implemention of icon changes if tree nodes are opened (requires tablelist package)
  - [dgw::tlistbox](tlistbox.html) - listbox widget based on tablelist with wrap facilities for multiline text and filtering (requires tablelist package)

## <a name='install'>INSTALLATION</a>

Installation is easy you can easily install and use this ** dgw** package if you have a working install of:

- the snit package  which can be found in [tcllib](https://core.tcl-lang.org/tcllib/doc/trunk/embedded/index.md)

For installation you copy the complete *dgw* folder into a path 
of your *auto_path* list of Tcl or you append the *auto_path* list with the parent dir of the *dgw* directory.

## <a name='docu'>DOCUMENTATION</a>

The script contains embedded the documentation in Markdown format. 
To extract the documentation you should use the following command line:


    $ tclsh dgw.tcl --markdown


This will extract the embedded manual pages in standard Markdown format. 
You can as well use this markdown output directly to create html pages for the documentation by using the *--html* flag.


    $ tclsh dgw.tcl --html


This will directly create a HTML page `dgw.html` which contains the formatted documentation. 
Github-Markdown can be extracted by using the *--man* switch:


    $ tclsh dgw.tcl --man


The output of this command can be used to feed a markdown processor for conversion into a 
html or pdf document. If you have pandoc installed for instance, you could execute the following commands:


    tclsh ../dgw.tcl --man > dgw.md
    pandoc -i dgw.md -s -o dgw.html
    pandoc -i dgw.md -s -o dgw.tex
    pdflatex dgw.tex


## <a name='see'>SEE ALSO</a>

- dgw - package homepage: [https://github.com/mittelmark/DGTcl](https://github.com/mittelmark/DGTcl)
- download via Downgit: https://downgit.github.io/#/home?url=https://github.com/mittelmark/DGTcl/tree/master/lib/dgw

## <a name='authors'>AUTHOR</a>

The **dgw** command was written by Detlef Groth, Schwielowsee, Germany.

## <a name='copyright'>COPYRIGHT</a>

Copyright (c) 2019-2020  Dr. Detlef Groth, E-mail: detlef(at)dgroth(dot)de

## <a name='license'>LICENSE</a>

dgw package, version 0.6.

Copyright (c) 2019-2021  Dr. Detlef Groth, E-mail: detlef(at)dgroth(dot)de

This library is free software; you can use, modify, and redistribute it
for any purpose, provided that existing copyright notices are retained
in all copies and that this notice is included verbatim in any
distributions.

This software is distributed WITHOUT ANY WARRANTY; without even the
implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.



