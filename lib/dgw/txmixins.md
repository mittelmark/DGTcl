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

# dgw::txmixins 0.1
    
### Detlef Groth, Schwielowsee, Germany
    
### 2021-08-20


## NAME

**dgw::txmixins** - implementations of extensions for the *text* 
        widget which can be added dynamically using chaining of commands 
        at widget creation or using the *dgw::mixin* command after widget 
        creation.

## <a name='toc'></a>TABLE OF CONTENTS

 - [SYNOPSIS](#synopsis)
 - [DESCRIPTION](#description)
 - [WIDGET COMMANDS](#commands)
    - [dgw::txmixin](#txmixin) - add one mixin to text widget after widget creation
    - [dgw::txautorep](#txautorep) - short abbreviations snippets invoked after closing parenthesis
    - [dgw::txfold](#txfold) - folding text editor
    - [dgw::txindent](#txindent) - keep indentation of previous line
    - [dgw::txrotext](#txrotext) - read only text widget
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
    package require dgw::txmixins
    ::dgw::txmixin pathName widgetAdaptor ?options?
    ::dgw::txfold [tk::text pathName ?options?] ?options?
    set txt [tk::text pathName ?options?]
    dgw::txmixin $txt dgw::txfold ?options?


## <a name='description'>DESCRIPTION</a>

The package **dgw::txmixins** implements several *snit::widgetadaptor*s which 
extend the standard *tk::text* widget with different functionalities.
Different adaptors can be chained together to add the required functionalities. 
Furthermore at any later time point using the *dgw::mixin* command other adaptors can be installed on the widget.

## <a name='commands'>WIDGET COMMANDS</a>


<a name="mixin">**dgw::mixin**</a> *pathName mixinWidget ?-option value ...?*

Adds the properties and methods of a snit::widgetadaptor specified with *mixinWidget* 
to the exising widget created before with the given *pathName* and configures the widget 
using the given *options*. 

Example:

> ```
# demo: mixin
# standard text widget
set text [tk::text .txt]
pack $text -side top -fill both -expand true
dgw::txmixin $text dgw::txfold
# fill the widget
for {set i 1} {$i < 4} {incr i} { 
    $text insert end "## Header $i\n\n"
    for {set j 0} {$j < 2} {incr j} {
      $text insert end "Lorem ipsum dolor sit amet, consetetur sadipscing elitr,\n"
      $text insert end "sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat,\n" 
      $text insert end "sed diam voluptua. \nAt vero eos et accusam et justo duo dolores et ea rebum.\n"
      $text insert end "Stet clita kasd gubergren, no sea takimata sanctus est.\n\n" 
    }
}
$text insert end "\n## Hint\n\nPress F2 or F3 and see what happend!"
> ```

<a name="txfold">**dgw::txfold**</a> *[tk::text pathName] ?-option value ...?*

Creates and configures the *dgw::txfold*  widget using the Tk window id _pathName_ and 
  the given *options*. The widgets supports text folding based on linestart regular expressions usually which allows fast navigation of larger
  documents by hiding and showing larger chunks of text within the folding marks.

The following options are available:

> - *-foldkey* *F2*  - the key to fold or unfold regions where the insert cursor is within
  - *-foldallkey* *F3* - the key to fold/unfold the complete text
  - *-foldstart* *^#* - the start folding marker, default is Markdown header folding
  - *-foldend* "^#* - the end fold marker, where the folding ends, if the end marker is the same as the start marker folding is ended in the line before the end line, otherwise on the end line

The following widget tags are created and can be modified at runtime:

> - *fold* - the folding line which remains visible, usually the background should be configured only, default is `#ffbbaa` a light salmon like color
  - *folded* - the hidden (-elide true) part which is invisible, usually not required to change it, as it is hidden

Example:

> ```
# demo: txfold
dgw::txfold [tk::text .txt]
foreach col [list A B C] { 
   .txt insert  end "# Header $col\n\nSome text\n\n"
}
.txt insert end "Place the cursor on the header lines and press F2\n"
.txt insert end "or press F3 to fold or unfold the complete text.\n"
.txt tag configure fold -background #cceeff
.txt configure -borderwidth 10 -relief flat
pack .txt -side top -fill both -expand yes
# next line would fold by double click (although I like F2 more ...)
# .txt configure -foldkey Double-1 
bind .txt <Enter> { focus -force .txt }
> ```

<a name="txrotext">**dgw::txrotext**</a> *[tk::text pathName] ?-option value ...?*

Creates and configures the *dgw::txrotext*  widget using the Tk window id _pathName_ and 
the given *options*. All options are delegated to the standard text widget. 
This creates a readonly text widget.
Based on code from the snitfaq by  William H. Duquette.

Example:

> ```
# demo: txrotext
dgw::txrotext [tk::text .txt]
foreach col [list A B C] { 
   .txt ins  end "# Header $col\n\nSome text\n\n"
}
pack .txt -side top -fill both -expand yes
> ```

<a name="txindent">**dgw::txindent**</a> *[tk::text pathName] ?-option value ...?*

Creates and configures the *dgw::txindent*  widget using the Tk window id _pathName_ and 
the given *options*. All options are delegated to the standard text widget. 
The widget indents every new line based on the initial indention of the previous line.
Based on code in the Wiki page https://wiki.tcl-lang.org/page/auto-indent started by Richard Suchenwirth.

Example:

> ```
# demo: txindent
dgw::txindent [tk::text .txt]
foreach col [list A B C] { 
   .txt insert  end "# Header $col\n\nSome text\n\n"
}
.txt insert end "  * item 1\n  * item 2 (press return here)"
pack .txt -side top -fill both -expand yes
> ```

<a name="txautorep">**dgw::txautorep**</a> *[tk::text pathName] ?-option value ...?*

Creates and configures the *dgw::txautorep*  widget using the Tk window id _pathName_ and 
the given *options*. All options are delegated to the standard text widget. 
Based on code in the Wiki page https://wiki.tcl-lang.org/page/autoreplace started by Richard Suchenwirth in 2008.

The following option is available:

> - *-automap* *list*  - list of abbreviations and their replacement, the abbreviations must end with a closing 
    parenthesis such as [list DG) {Detlef Groth}].

Example:

> ```
# demo: txautorep
dgw::txautorep [tk::text .txt] -automap [list (TM) \u2122 (C) \
     \u00A9 (R) \u00AE (K) \u2654 D) {D Groth} \
     (DG) {Detlef Groth, University of Potsdam}]
.txt insert end "type a vew abbreviations like (TM), (C), (R) or (K) ..."
pack .txt -side top -fill both -expand yes
> ```

TODO: Take abbreviations from file


## <a name='example'>EXAMPLE</a>

In the examples below we create a foldable text widget which can fold Markdown headers.
Just press the button F2 and F3 to fold or unfold regions or the complete text.
Thereafter a demonstration on how to use the *dgw::txmixin* command which simplifies the addition of 
new behaviors to our *tk::text* in a stepwise manner. 
The latter approach is as well nice to extend existing widgets in a more controlled manner 
avoiding restarts of applications during developing the widget.


    package require dgw::txmixins
    # standard text widget
    set f [ttk::frame .f]
    set text [tk::text .f.txt -borderwidth 5 -relief flat]
    pack $text -side left -fill both -expand true 
    dgw::txmixin $text dgw::txfold
    # fill the widget
    for {set i 0} {$i < 5} {incr i} { 
        $text insert end "## Header $i\n\n"
        for {set j 0} {$j < 2} {incr j} {
          $text insert end "Lorem ipsum dolor sit amet, consetetur sadipscing elitr,\n"
          $text insert end "sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat,\n" 
          $text insert end "sed diam voluptua. \nAt vero eos et accusam et justo duo dolores et ea rebum.\n"
          $text insert end "Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.\n\n" 
        }
    }
    set tcltxt [tk::text .f.tcl -borderwidth 5 -relief flat]
    dgw::txmixin $tcltxt dgw::txfold -foldstart "^\[A-Za-z\].+\{" -foldend "^\}"
    $tcltxt tag configure fold -background #aaccff
    $tcltxt insert end "package require Tk\nproc test {} {\n    puts Hi\n}\n\nsnit::widget wid {\n\n}\n"
    pack $tcltxt -side left -fill both -expand true
    pack $f -side top -fill both -expand yes
    set f2 [ttk::frame .f2]
    dgw::txrotext [tk::text $f2.rotxt]
    foreach col [list A B C] { 
       $f2.rotxt ins  end "# Header $col\n\nSome text\n\n"
    }
    pack $f2.rotxt -side left -fill both -expand yes
    dgw::txindent [tk::text $f2.intxt]
    dgw::txmixin $f2.intxt dgw::txfold
    $f2.intxt insert end "# Header 1\n\n* item\n    * subitem 1\n    * subitem2"
    $f2.intxt insert end "# Header 2\n\n* item\n    * subitem 1\n    * subitem2"
    $f2.intxt insert 5.0 "\n" ;  $f2.intxt tag add line 5.0 6.0 ; 
    $f2.intxt tag configure line -background black -font "Arial 1" 
    pack $f2.intxt -side left -fill both -expand yes
    pack $f2 -side top -fill both -expand yes


## <a name='install'>INSTALLATION</a>

Installation is easy you can install and use the **dgw::txmixins** package if you have a working install of:

- the snit package  which can be found in [tcllib - https://core.tcl-lang.org/tcllib](https://core.tcl-lang.org/tcllib)

For installation you copy the complete *dgw* folder into a path 
of your *auto_path* list of Tcl or you append the *auto_path* list with the parent dir of the *dgw* directory.
Alternatively you can install the package as a Tcl module by creating a file dgw/txmixins-0.1.tm in your Tcl module path. 

Only if you you like to extract the HTML documentation and run the examples, 
you need the complete dgw package and for the HTML generation the tcllib Markdown package.

## <a name='demo'>DEMO</a>

Example code for this package in the *EXAMPLE* section can  be executed by running this file using the following command line:


    $ wish txmixins.tcl --demo


Specific code examples outside of the EXAMPLE section can be executed using the string after the *demo:* prefix string in the code block for the individual code adaptors such as:



    $ wish txmixins.tcl --demo txfold


The example code used for the demo in the EXAMPLE section can be seen in the terminal by using the following command line:


    $ tclsh txmixins.tcl --code

## <a name='docu'>DOCUMENTATION</a>

The script contains embedded the documentation in Markdown format. To extract the documentation you should use the following command line:


    $ tclsh txmixins.tcl --markdown


This will extract the embedded manual pages in standard Markdown format. You can as well use this markdown output directly to create html pages for the documentation by using the *--html* flag.


    $ tclsh txmixins.tcl --html


If the tcllib Markdown package is installed, this will directly create a HTML page `txmixins.html` 
which contains the formatted documentation. 

Github-Markdown can be extracted by using the *--man* switch:


    $ tclsh txmixins.tcl --man


The output of this command can be used to feed a Markdown processor for conversion into a 
html, docx or pdf document. If you have pandoc installed for instance, you could execute the following commands:


    tclsh ../txmixins.tcl --man > txmixins.md
    pandoc -i txmixins.md -s -o txmixins.html
    pandoc -i txmixins.md -s -o txmixins.tex
    pdflatex txmixins.tex


## <a name='see'>SEE ALSO</a>

- [dgw package homepage](https://chiselapp.com/user/dgroth/repository/tclcode/index) - various useful widgets
- [tk::text widget manual](https://www.tcl.tk/man/tcl8.6/TkCmd/ttk_treeview.htm) standard manual page for the ttk::treeview widget

 
## <a name='changes'>CHANGES</a>

* 2021-08-12 - version 0.1 initial starting the widget.
* 2021-08-19 
    * completing docu
    * finalize txfold
    * adding txrotext, txindent, txautorep

## <a name='todo'>TODO</a>

* File watch: https://wiki.tcl-lang.org/page/File+watch
* Block selection: https://wiki.tcl-lang.org/page/Simple+Block+Selection+for+Text+Widget
* Text sorting: https://wiki.tcl-lang.org/page/Simple+Text+Widget+Sort
* Logic notation https://wiki.tcl-lang.org/page/A+little+logic+notation+editor
* Drag and drop of text: https://wiki.tcl-lang.org/page/Text+Drag+%2DDrag+and+Drop+for+Text+Widget+Selections
* text line coloring https://wiki.tcl-lang.org/page/text+line+coloring
* table display https://wiki.tcl-lang.org/page/Displaying+tables
* time stamp https://wiki.tcl-lang.org/page/Time%2Dstamp
* balloon help https://wiki.tcl-lang.org/page/Balloon+Help%2C+Generalised
* sub and superscripts https://wiki.tcl-lang.org/page/Super+and+Subscripts+in+a+text+widget

## <a name='authors'>AUTHORS</a>

The **dgw::txmixins** widget was written by Detlef Groth, Schwielowsee, Germany.

## <a name='copyright'>Copyright</a>

Copyright (c) 2021  Dr. Detlef Groth, E-mail: detlef(at)dgroth(dot)de

## <a name='license'>LICENSE</a>

dgw::txmixins package, version 0.1.

Copyright (c) 2019-2021  Dr. Detlef Groth, E-mail: detlef(at)dgroth(dot)de

This library is free software; you can use, modify, and redistribute it
for any purpose, provided that existing copyright notices are retained
in all copies and that this notice is included verbatim in any
distributions.

This software is distributed WITHOUT ANY WARRANTY; without even the
implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.



