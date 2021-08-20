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

# dgw::seditor 0.3
    
### Detlef Groth, Schwielowsee, Germany
    
### 2021-08-20


## NAME

**dgw::seditor** - extended Tk text editor widget with toolbar buttons, configurable syntax highlighting, window splitting facilities 
and right click popupmenu for standard operations like cut, paste etc.

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
    package require dgw::seditor
    dgw::seditor pathName ?options?
    pathName configure option value
    pathName cget option
    pathName loadFile filename ?boolean?


## <a name='description'>DESCRIPTION</a>

The widget **dgw::seditor** inherits from the standard Tk text editor widget 
all methods and options but has further a standard toolbar, 
a right click context menu and allows easy configuration for syntax highlighting. 
Scrollbars are as well added by default, they are only shown however if necessary. 
Furthermore window splitting is added, the user can split the text editor window into two by pressing <Control-x> and thereafter either 2 or 3, splitting can be undone by pressing <Control-x> and thereafter the key 1.

## <a name='command'>COMMAND</a>

**dgw::seditor** *pathName ?-option value ...?*

> Creates and configures the **dgw::seditor**  widget using the Tk window id _pathName_ and the given *options*. 
 
## <a name='options'>WIDGET OPTIONS</a>

As the **dgw::seditor** is an extension of the standard Tk text editor widget 
it supports all method and options of the tk text editor widget. 
The following options are added by the *dgw::seditor* widget:

__-accelerator__ _keysequence_

> The key shortcut to execute a possibly given _-toolcommand_. 
Defaults to <Shift-Return> or <Control-x-Control-s>. Does nothing if no _-toolcommand_ is given.

__-filetypes__ _list of filetypes_

> The filetypes to be used for the file dialogs if the open or save buttons are pressed.
  Defaults to Text (\*.txt), SQL (\*.sql) and all files (\*.\*). 
See the [Example](#example) section on how to define other additional file extensions.

__-font__ _fontname_

> The font to be used for the text widget. 
  Defaults to Tk standards which are depending on the platform.

__-hilightcommand__ _command_

> The command to be used for highlighting. The user can with this supply their own commands to do syntax highlighting. 
   Please note, that the widget path of the text widget is appended to the argument list.

__-hilights__ _list_

> The list to be used for syntax highlighting the widget. 
  It is a nested list where the first element is the file extension without the dot, 
  the second element is the tagname and the third is the regular expression used for highlighting. Valid tagnames are:
  header, comment, highlight, keyword, string, package, class, method, proc. 
With the usual command `pathName tag configure tagname -forground color` etc., the developer can overwrite the default tag settings.


__-inifiles__ _list_

> The list of ini files to be used for hilights. 
  The ini files are loaded if this option is configured. Per default the file *seditor.ini* 
  in the same directory as seditor.tcl and a file seditor.ini in the folder `.config/dgw/seditor.ini` 
  in the users home directory are loaded autmoatically if they exist. See the following example for an editor widget which provides Python highlighting-

> ```
# file seditor.ini
[Python]
extension=*.py *.pyw
package=^(import|from).+
string=["'].+?["']
method=^\s*(def|class)\s+[A-Z0-9_a-z]+
keyword=(^| )(self|False|True|for|if|elif|else|try|and|as)
comment=#.+
> ```
__-lineaccelerator__ _keysequence_

> The key shortcut to execute a possibly given _-toolcommand_ with the current line as input.
Defaults to <Control-Return>. Does nothing if no _-toolcommand_ is given.

__-selectionaccelerator__ _keysequence_

> The key shortcut to execute a possibly given _-toolcommand_. with the current selection text as input.
Defaults to <Control-Shift-Return>. Does nothing if no _-toolcommand_ is given.

__-toolcommand__ _command_

> The text inside the text area can be executed with the give _-toolcommand_. 
For instance you can execute a SQL statement which was written into the text editor against a database.
There is also the possibility to execute just the current line, or the current selection. 
See the options for setting accelerators keys. Please note, that the text, either the current selection, the current line or the complete widget text is appended to the command as first argument.
  Defaults to empty string, so no toolcommand is executable on the current text.

__-toollabel__ _string_

> Label to be used as the Tool label in the popupmenu and if the tool Button on the top right is hovered with the mouse.
  Defaults to "tool"


## <a name='commands'>WIDGET COMMANDS</a>

Each **dgw::seditor** widget supports all usual methods of the Tk text widget and it adds the follwing method(s):

*pathName* **doHilights** *?mode?*

> Hilights the text within in the editor in the language given with the mode variable. 
  The following arguments are supported:

> *mode* - the programming or markup language used for hilighting, the following modes 
are already embedded into the widget: *tcl' (default), *sql', *text'. Other modes can be 
added to the widget by specifying the option *-hilights* or by using the inifile.

*pathName* **fileNew** 

> Loads a empty new file into the editor widget, if the previous file in the
  widget was changed and not saved, before opening a new file, a dialogbox will show up, 
  asking the user if he would like to save the file.

*pathName* **loadFile** *filename ?reload:boolean?*

> Loads the given filename into the text widget or reloads the currently 
  loaded file if reload is set to true. The default for reload is false.
## <a name='binding'>KEY BINDINGS</a>

In addition to the standard Bindings of a text editor widget the *dgw::editor* 
provides the following key and mouse bindings.

- `mouse right click` : editor popup with cut, paste etc.
- `Ctrl-x 2`: split the window vertically
- `Ctrl-x 3`: split the window horizontally
- `Ctrl-x 1` undo the splitting
- `Shift-Return`: Send the widget text to toolcommand 
- `Control-Return`: send the ehe current line to toolcommand
- `Control-Shift-Return`: send the current selection to toolcommand

Please note, that the toolcommand accelerator keys can be changed to other keys by using the options of this widget.

## <a name='example'>EXAMPLE</a>

In the example below we create a Markdown markup aware text editor.


    package require dgw::seditor
    dgw::seditor .top -borderwidth 5 -relief flat -font "Helvetica 20" \
                      -hilights {{md header ^#.+}    
                                 {md comment ^>.+} 
                                 {md keyword _{1,2}[^_]+_{1,2}}  
                                 {md string {"[^"]+"}}}
    pack .top -side top -fill both -expand true ;#"  
    .top configure -filetypes {{Markdown Files}  {.md}}
    
    # create a sample Markdown file and load it later
    set out [open test.md w 0600] 
    puts $out "# Header example\n"
    puts $out "_keyword_ example\n"
    puts $out "Some not hilighted text\n"
    puts $out "> some markdown quote text\n"
    puts $out "## Subheader\n"
    puts $out "Some more standard text with two \"strings\" which are \"inside!\"" 
    puts $out [lsort [.top cget -filetypes]]
    puts $out "\n\n## Tcl\n\nTcl be with you!\n\n## EOF\n\nThe End\n"
    close $out
    .top loadFile test.md
    .top lipsum end


## <a name='install'>INSTALLATION</a>

Installation is easy you can install and use the **dgw::seditor** package if you have a working install of:

- the snit package  which can be found in [tcllib - https://core.tcl-lang.org/tcllib](https://core.tcl-lang.org/tcllib)

For installation you copy the complete *dgw* folder into a path 
of your *auto_path* list of Tcl or you append the *auto_path* list with the parent dir of the *dgw* directory.
Alternatively you can install the package as a Tcl module by creating a file dgw/seditor-0.3.tm in your Tcl module path.
The latter in many cases can be achieved by using the _--install_ option of seditor.tcl. 
Try "tclsh seditor.tcl --install" for this purpose.

## <a name='demo'>DEMO</a>

Example code for this package can  be executed by running this file using the following command line:


    $ wish seditor.tcl --demo

The example code used for this demo can be seen in the terminal by using the following command line:


    $ tclsh seditor.tcl --code

## <a name='docu'>DOCUMENTATION</a>

The script contains embedded the documentation in Markdown format. To extract the documentation you should use the following command line:


    $ tclsh seditor.tcl --markdown


This will extract the embedded manual pages in standard Markdown format. You can as well use this markdown output directly to create html pages for the documentation by using the *--html* flag.


    $ tclsh seditor.tcl --html


If the tcllib Markdown package is installed, this will directly create a HTML page `seditor.html` 
which contains the formatted documentation. 

Github-Markdown can be extracted by using the *--man* switch:


    $ tclsh seditor.tcl --man


The output of this command can be used to feed a Markdown processor for conversion into a 
html, docx or pdf document. If you have pandoc installed for instance, you could execute the following commands:


    tclsh ../seditor.tcl --man > seditor.md
    pandoc -i seditor.md -s -o seditor.html
    pandoc -i seditor.md -s -o seditor.tex
    pdflatex seditor.tex


## <a name='see'>SEE ALSO</a>

- [dgw package homepage](https://chiselapp.com/user/dgroth/repository/tclcode/index) - various useful widgets
- [ctext widget in tklib](https://wiki.tcl-lang.org/page/Tklib+Contents) other syntax hilighting widget
- [text widget manual](https://www.tcl.tk/man/tcl8.6/TkCmd/text.htm) standard manual page for the underlying text widget

 
## <a name='changes'>CHANGES</a>

* 2020-02-04 - version 0.3 started
* adding splitting window keys and word wrap button to the toolbar
* fixing splitting issues, updating documentation
* automatic loading of infile from <home>/.config/dgw/seditor.ini added

## <a name='todo'>TODO</a>

* config file for syntax hilights in the same directory as the source code and in some config dir in the home directory
* example for a derived syntax editor with an added syntax hilight schema
* more, real, tests
* github url for putting the code

## <a name='authors'>AUTHORS</a>

The **dgw::seditor** widget was written by Detlef Groth, Schwielowsee, Germany.

## <a name='copyright'>Copyright</a>

Copyright (c) 2019-20  Dr. Detlef Groth, E-mail: detlef(at)dgroth(dot)de

## <a name='license'>LICENSE</a>

dgw::seditor package, version 0.3.

Copyright (c) 2019-2021  Dr. Detlef Groth, E-mail: detlef(at)dgroth(dot)de

This library is free software; you can use, modify, and redistribute it
for any purpose, provided that existing copyright notices are retained
in all copies and that this notice is included verbatim in any
distributions.

This software is distributed WITHOUT ANY WARRANTY; without even the
implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.



