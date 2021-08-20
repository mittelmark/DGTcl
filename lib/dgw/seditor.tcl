#!/usr/bin/env tclsh
#  Created By    : Dr. Detlef Groth
#  Created       : Sun Oct 28 15:37:54 2018
#  Last Modified : <210812.0707>
#
#  Description	
#
#  Notes
#
#  History
#	
##############################################################################
#
#  Copyright (c) 2018-2020 Dr. Detlef Groth.
# 
##############################################################################
#' ---
#' documentclass: scrartcl
#' title: dgw::seditor __PKGVERSION__
#' author: Detlef Groth, Schwielowsee, Germany
#' geometry: "left=2.2cm,right=2.2cm,top=1cm,bottom=2.2cm"
#' output: pdf_document
#' ---
#' 
#' ## NAME
#'
#' **dgw::seditor** - extended Tk text editor widget with toolbar buttons, configurable syntax highlighting, window splitting facilities 
#' and right click popupmenu for standard operations like cut, paste etc.
#'
#' ## <a name='toc'></a>TABLE OF CONTENTS
#' 
#'  - [SYNOPSIS](#synopsis)
#'  - [DESCRIPTION](#description)
#'  - [COMMAND](#command)
#'  - [WIDGET OPTIONS](#options)
#'  - [WIDGET COMMANDS](#commands)
#'  - [KEY BINDINGS](#bindings)
#'  - [EXAMPLE](#example)
#'  - [INSTALLATION](#install)
#'  - [DEMO](#demo)
#'  - [DOCUMENTATION](#docu)
#'  - [SEE ALSO](#see)
#'  - [CHANGES](#changes)
#'  - [TODO](#todo)
#'  - [AUTHORS](#authors)
#'  - [COPYRIGHT](#copyright)
#'  - [LICENSE](#license)
#'  
#' ## <a name='synopsis'>SYNOPSIS</a>
#' 
#' ```
#' package require Tk
#' package require snit
#' package require dgw::seditor
#' dgw::seditor pathName ?options?
#' pathName configure option value
#' pathName cget option
#' pathName loadFile filename ?boolean?
#' ```
#'
#' ## <a name='description'>DESCRIPTION</a>
#' 
#' The widget **dgw::seditor** inherits from the standard Tk text editor widget 
#' all methods and options but has further a standard toolbar, 
#' a right click context menu and allows easy configuration for syntax highlighting. 
#' Scrollbars are as well added by default, they are only shown however if necessary. 
#' Furthermore window splitting is added, the user can split the text editor window into two by pressing <Control-x> and thereafter either 2 or 3, splitting can be undone by pressing <Control-x> and thereafter the key 1.
#'
#' ## <a name='command'>COMMAND</a>
#'
#' **dgw::seditor** *pathName ?-option value ...?*
#' 
#' > Creates and configures the **dgw::seditor**  widget using the Tk window id _pathName_ and the given *options*. 
#'  
#' ## <a name='options'>WIDGET OPTIONS</a>
#' 
#' As the **dgw::seditor** is an extension of the standard Tk text editor widget 
#' it supports all method and options of the tk text editor widget. 
#' The following options are added by the *dgw::seditor* widget:

package require Tk
package require snit
package require dgw::dgwutils
package provide dgw::seditor 0.3

#package require ctext
#package require wcb
#package require dgw::ttkwidgets
namespace eval ::dgw {
    variable seditordir
    set seditordir [file dirname [info script]]
} 

snit::widget ::dgw::seditor {
    variable text
    variable peer
    variable pframe
    variable pw
    variable Modified false
    variable file "*new*"
    variable lastfile ""
    variable lastmode ""
    variable bnlastfile "*new*"
    variable lastdir .
    variable textw
    variable ini
    typevariable ttk
    delegate option * to text 
    delegate method * to text except [list insert delete]
    #' 
    #' __-accelerator__ _keysequence_
    #'
    #' > The key shortcut to execute a possibly given _-toolcommand_. 
    #' Defaults to <Shift-Return> or <Control-x-Control-s>. Does nothing if no _-toolcommand_ is given.
    #' 
    option -accelerator "<Shift-Return> <Control-x><Control-s>"
    #' __-font__ _fontname_
    #'
    #' > The font to be used for the text widget. 
    #'   Defaults to Tk standards which are depending on the platform.
    #' 
    option -font -default "" -configuremethod UpdateFont -cgetmethod GetFont
    #' __-filetypes__ _list of filetypes_
    #'
    #' > The filetypes to be used for the file dialogs if the open or save buttons are pressed.
    #'   Defaults to Text (\*.txt), SQL (\*.sql) and all files (\*.\*). 
    #' See the [Example](#example) section on how to define other additional file extensions.
    #' 
    option -filetypes {
        {{Text Files}      {.txt} }
        {{SQL  Files}      {.sql} }
        {{All Files}       *      }
    }

    #' __-hilightcommand__ _command_
    #'
    #' > The command to be used for highlighting. The user can with this supply their own commands to do syntax highlighting. 
    #'    Please note, that the widget path of the text widget is appended to the argument list.
    #'
    option -hilightcommand ""
    
    #' __-inifiles__ _list_
    #'
    #' > The list of ini files to be used for hilights. 
    #'   The ini files are loaded if this option is configured. Per default the file *seditor.ini* 
    #'   in the same directory as seditor.tcl and a file seditor.ini in the folder `.config/dgw/seditor.ini` 
    #'   in the users home directory are loaded autmoatically if they exist. See the following example for an editor widget which provides Python highlighting-
    #'
    #' > ```
    #' #include "seditor.ini"
    #' > ```
    
    option -inifiles [list] 

    #' __-hilights__ _list_
    #'
    #' > The list to be used for syntax highlighting the widget. 
    #'   It is a nested list where the first element is the file extension without the dot, 
    #'   the second element is the tagname and the third is the regular expression used for highlighting. Valid tagnames are:
    #'   header, comment, highlight, keyword, string, package, class, method, proc. 
    #' With the usual command `pathName tag configure tagname -forground color` etc., the developer can overwrite the default tag settings.
    #' 
    #' 
    option -hilights [list]
    
    #' __-lineaccelerator__ _keysequence_
    #'
    #' > The key shortcut to execute a possibly given _-toolcommand_ with the current line as input.
    #' Defaults to <Control-Return>. Does nothing if no _-toolcommand_ is given.
    #' 
    option -lineaccelerator "<Control-Return>"    
    
    #' __-selectionaccelerator__ _keysequence_
    #'
    #' > The key shortcut to execute a possibly given _-toolcommand_. with the current selection text as input.
    #' Defaults to <Control-Shift-Return>. Does nothing if no _-toolcommand_ is given.
    #' 
    option -selectionaccelerator "<Control-Shift-Return>"    
    
    #' __-toolcommand__ _command_
    #'
    #' > The text inside the text area can be executed with the give _-toolcommand_. 
    #' For instance you can execute a SQL statement which was written into the text editor against a database.
    #' There is also the possibility to execute just the current line, or the current selection. 
    #' See the options for setting accelerators keys. Please note, that the text, either the current selection, the current line or the complete widget text is appended to the command as first argument.
    #'   Defaults to empty string, so no toolcommand is executable on the current text.
    #' 
    option -toolcommand ""

    #' __-toollabel__ _string_
    #'
    #' > Label to be used as the Tool label in the popupmenu and if the tool Button on the top right is hovered with the mouse.
    #'   Defaults to "tool"
    #' 
    option -toollabel "tool"
    
    constructor {args} {
        ${ttk}frame $win.ftop
        ${ttk}button $win.ftop.new -image filenew16 -command [mymethod FileNew]
        $self balloon $win.ftop.new "create new file ..."
        ${ttk}button $win.ftop.open -image fileopen16 -command [mymethod FileOpen]
        $self balloon $win.ftop.open "open file ..."
        ${ttk}button $win.ftop.save -image filesave16 -state disabled -command [mymethod FileSave] 
        $self balloon $win.ftop.save "save file ..."
        ${ttk}button $win.ftop.saveas -image filesaveas16 -state disabled -command [mymethod FileSaveAs]
        $self balloon $win.ftop.saveas "save file as ..."
        ${ttk}button $win.ftop.undo -image actundo16 -state disabled -command [mymethod TextUndo]
        $self balloon $win.ftop.undo "text undo"
        ${ttk}button $win.ftop.redo -image actredo16  -state disabled -command [mymethod TextRedo]
        $self balloon $win.ftop.redo "text redo"
        ${ttk}button $win.ftop.wrap -image wrap  -state active -command [mymethod ToggleWrap]
        $self balloon $win.ftop.wrap "text wrap on/off"
        ${ttk}label $win.ftop.fname -textvariable [myvar bnlastfile] -width 30 -anchor w
        foreach b {new open save saveas} {
            $win.ftop.$b configure -style ToolButton
            pack $win.ftop.$b -side left -padx 5 -pady 5 -ipadx 0 -ipady 0 
        }
        pack [${ttk}frame $win.ftop.f -width 5 -relief sunken] -side left
        foreach b {undo redo wrap} {
            $win.ftop.$b configure -style ToolButton
            pack $win.ftop.$b -side left -padx 5 -pady 5 -ipadx 0 -ipady 0
        }
        pack $win.ftop.fname  -side left -padx 5 -pady 5 -ipadx 1 -ipady 1
        ${ttk}panedwindow $win.fbot
        ${ttk}frame $win.fbot.frame
        panedwindow $win.fbot.pw
        set pw $win.fbot.pw
        set pw0 $win.fbot ;# not required

        set tframe [ttk::frame $pw.tframe]
        set pframe [ttk::frame $pw.pframe]
        set pframe2 [ttk::frame $pw0.pframe] ;# not required

        set text [text $tframe.text -undo true -maxundo 10 -wrap none]
        $self autoscroll $text
        set peer [$text peer create $pframe.text]
        $self autoscroll $peer
        set peer2 [$text peer create $pframe2.text]
        $self autoscroll $peer2
        $pw0 add $pw
        $pw add $tframe
        foreach w [list $text $peer] {
            bind $w <Control-x><Key-2> [mymethod bindControlXSplit vertical]
            bind $w <Control-x><Key-1> [mymethod bindControlXSplit zero]
            bind $w <Control-x><Key-3> [mymethod bindControlXSplit horizontal]
        
        }
        #foreach w [list $text $peer2] {
        #    bind $w <Control-x><Key-1> [mymethod bindControlXSplit zeroh]
        #}
        #pack $win.fbot.text -side left -fill both -expand true
        pack $win.ftop -side top -fill x -expand no
        pack $win.fbot -side top -fill both -expand yes
      
        $text tag configure header -underline 1 -foreground "dark blue"
        $text tag configure comment -underline 0 -foreground "#999999"
        $text tag configure highlight -foreground blue
        $text tag configure keyword -foreground blue
        $text tag configure string -foreground magenta
        $text tag configure package -foreground "#aa6633"        
        $text tag configure class -foreground "#33cc99"        
        $text tag configure method -foreground "#33aa88"        
        $text tag configure proc -foreground "#33aa88"        
        $text tag configure fold -background #ffbbaa
        $text tag configure folded -elide true 
        $text tag raise comment
        set textw $text
        # trial to remove wcb
        #wcb::callback $textw after insert [mymethod GuiTextChanged]
        #wcb::callback $textw after delete [mymethod GuiTextChanged]
        bind $textw <Button-3>   [mymethod Menu]
        bind $textw <Control-y>   [mymethod TextRedo]
        bind $textw <Control-plus> [mymethod changeFontSize +2]                
        bind $textw <Control-minus> [mymethod changeFontSize -2]
        bind $textw <Control-s> [mymethod FileSave]
        bind $textw <Control-n> [mymethod FileNew]
        bind $textw <Control-o> [mymethod FileOpen]
        bind $textw <F2> [mymethod FoldCurrent]
        bind $textw <F3> [mymethod FoldAll]        
         $self configurelist $args
        if {$options(-hilightcommand) ne ""} {
            $options(-hilightcommand) $text
        }
        if {$options(-toolcommand) ne ""} {
            #array set c $options(-toolcommand)
            
            ${ttk}button $win.ftop.tool -image apptools16 -command "$options(-toolcommand) all"  -style ToolButton
            $self balloon $win.ftop.tool "Execute $options(-toollabel)"
            pack $win.ftop.tool -side right -padx 5 -pady 5 -ipadx 0 -ipady 0
            if {$options(-accelerator) ne ""} {
                foreach acc $options(-accelerator) {
                    bind $textw $acc "$options(-toolcommand) all ; break "
                }
                foreach acc $options(-lineaccelerator) {
                    bind $textw $acc "$options(-toolcommand) line ; break "
                }
                foreach acc $options(-selectionaccelerator) {
                    bind $textw $acc "$options(-toolcommand) selection ; break "
                }
                #bind $textw <Control-x><Control-x> [mymethod TclEval]
            }
        }
        #bind $text <<Modified>> [mymethod doHilights sql]
        bind $text <KeyPress> [mymethod Keypress %K]
        #bind $textw <Control-c> [list tk_textCopy  $textw]
        #bind $textw <Control-v> [list tk_textPaste $textw]
        #bind $textw <Control-x> [list tk_textCut   $textw]
        set ifiles [list]
        #parray ::env
        if {[info exists ::env(HOME)]} {
            lappend ifiles [file join $::env(HOME) .config dgw seditor.ini]
        }
        lappend ifiles [file join $dgw::seditordir seditor.ini]
        foreach ifile $ifiles {
            if {[file exists $ifile]} {
                set ini [$self ini2dict $ifile]
                $self ininit
            }
                
        }
        #$self doHilights sql
    }   
    typeconstructor {
        set ttk ttk
        catch {
            package require tile
            set ttk ttk::
            ttk::style layout ToolButton [ttk::style layout TButton]
            ttk::style configure ToolButton [ttk::style configure TButton]
            ttk::style configure ToolButton -relief groove
            ttk::style configure ToolButton -borderwidth 2
            ttk::style configure ToolButton -padding {2 2 2 2} 
        }
        option add *Text.background    white
        image create photo filenew16 -data {
            R0lGODlhEAAQAIUAAPwCBFxaXNze3Ly2rJyanPz+/Ozq7GxqbPz6/GxubNTK
            xDQyNIyKhHRydERCROTi3PT29Pz29Pzy7PTq3My2pPzu5PTi1NS+rPTq5PTe
            zMyynPTm1Pz69OzWvMyqjPTu5PTm3OzOtOzGrMSehNTCtNS+tAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEAAAAALAAAAAAQABAAAAZ/
            QAAgQCwWhUhhQMBkDgKEQFIpKFgLhgMiOl1eC4iEYrtIer+MxsFRRgYe3wLk
            MWC0qXE5/T6sfiMSExR8Z1YRFRMWF4RwYIcYFhkahH6AGBuRk2YCCBwSFZgd
            HR6UgB8gkR0hpJsSGCAZoiEiI4QKtyQlFBQeHrVmC8HCw21+QQAh/mhDcmVh
            dGVkIGJ5IEJNUFRvR0lGIFBybyB2ZXJzaW9uIDIuNQ0KqSBEZXZlbENvciAx
            OTk3LDE5OTguIEFsbCByaWdodHMgcmVzZXJ2ZWQuDQpodHRwOi8vd3d3LmRl
            dmVsY29yLmNvbQA7
        }
        
        image create photo fileopen16 -data {
            R0lGODlhEAAQAIUAAPwCBAQCBOSmZPzSnPzChPzGhPyuZEwyHExOTFROTFxa
            VFRSTMSGTPT29Ozu7Nze3NTS1MzKzMTGxLy6vLS2tLSytDQyNOTm5OTi5Ly+
            vKyqrKSmpIyOjLR+RNTW1MzOzJyenGxqZBweHKSinJSWlExKTMTCxKyurGxu
            bBQSFAwKDJyanERCRERGRAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEAAAAALAAAAAAQABAAAAaR
            QIBwGCgGhkhkEWA8HpNPojFJFU6ryitTiw0IBgRBkxsYFAiGtDodDZwPCERC
            EV8sEk0CI9FoOB4BEBESExQVFgEEBw8PFxcYEBIZGhscCEwdCxAPGA8eHxkU
            GyAhIkwHEREQqxEZExUjJCVWCBAZJhEmGRUnoygpQioZGxsnxsQrHByzQiJx
            z3EsLSwWpkJ+QQAh/mhDcmVhdGVkIGJ5IEJNUFRvR0lGIFBybyB2ZXJzaW9u
            IDIuNQ0KqSBEZXZlbENvciAxOTk3LDE5OTguIEFsbCByaWdodHMgcmVzZXJ2
            ZWQuDQpodHRwOi8vd3d3LmRldmVsY29yLmNvbQA7
        }

        image create photo filesave16 -data {
            R0lGODlhEAAQAIUAAPwCBAQCBFRSVMTCxKyurPz+/JSWlFRWVJyenKSipJSS
            lOzu7ISChISGhIyOjHR2dJyanIyKjHx6fMzOzGRiZAQGBFxeXGRmZHRydGxq
            bAwODOTm5ExOTERGRExKTHx+fGxubNza3Dw+PDQ2NAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEAAAAALAAAAAAQABAAAAaA
            QIAQECgOj0jBgFAoBpBHpaFAbRqRh0F1a30ClAhuNZHwZhViqgFhJizSjIZX
            QCAoHOKHYw5xRBiAElQTFAoVQgINFBYXGBkZFxYHGRqIDBQbmRwdHgKeH2Yg
            HpmkIR0HAhFeTqSZIhwCFIdIrBsjAgcPXlBERZ4Gu7xCRZVDfkEAIf5oQ3Jl
            YXRlZCBieSBCTVBUb0dJRiBQcm8gdmVyc2lvbiAyLjUNCqkgRGV2ZWxDb3Ig
            MTk5NywxOTk4LiBBbGwgcmlnaHRzIHJlc2VydmVkLg0KaHR0cDovL3d3dy5k
            ZXZlbGNvci5jb20AOw==
        }
        image create photo filesaveas16 -data {
            R0lGODlhEAAQAIQAAAQCBPwCBPz+/PTizCQeHDQyNBweHAQGBAwKBDQ2NPzu
            5PTi3ERGRCQiJHR2dPTi1CwqLPz6/Mya/Mxm/GQCzFRWVGRmZAwODFxeXExO
            TExKTERCRBQWFMTCxKSipMzKzCH5BAEAAAEALAAAAAAQABAAAAV9ICCOQWkG
            IiqsQloCKCqy7UC8MC4URSsMhsDBNWOJEK4TYJfoGU8vmmJBGI5SyyYj0XDQ
            jMvVQwBxRCQTilowFGwrjG5kTo+0x4OdpcLvV0YXIhcGGH0ZFRobOSccfB2P
            HR4FiyYAGQwdAI8eEAdQKBsZmR+RBpSVVyMHfiEAIf5oQ3JlYXRlZCBieSBC
            TVBUb0dJRiBQcm8gdmVyc2lvbiAyLjUNCqkgRGV2ZWxDb3IgMTk5NywxOTk4
            LiBBbGwgcmlnaHRzIHJlc2VydmVkLg0KaHR0cDovL3d3dy5kZXZlbGNvci5j
            b20AOw==
        }

        image create photo actundo16 -data {
            R0lGODlhEAAQAIUAAPwCBBxSHBxOHMTSzNzu3KzCtBRGHCSKFIzCjLzSxBQ2
            FAxGHDzCLCyeHBQ+FHSmfAwuFBxKLDSCNMzizISyjJzOnDSyLAw+FAQSDAQe
            DBxWJAwmDAQOBKzWrDymNAQaDAQODAwaDDyKTFSyXFTGTEy6TAQCBAQKDAwi
            FBQyHAwSFAwmHAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEAAAAALAAAAAAQABAAAAZ1
            QIBwSCwaj0hiQCBICpcDQsFgGAaIguhhi0gohIsrQEDYMhiNrRfgeAQC5fMC
            AolIDhD2hFI5WC4YRBkaBxsOE2l/RxsHHA4dHmkfRyAbIQ4iIyQlB5NFGCAA
            CiakpSZEJyinTgAcKSesACorgU4mJ6uxR35BACH+aENyZWF0ZWQgYnkgQk1Q
            VG9HSUYgUHJvIHZlcnNpb24gMi41DQqpIERldmVsQ29yIDE5OTcsMTk5OC4g
            QWxsIHJpZ2h0cyByZXNlcnZlZC4NCmh0dHA6Ly93d3cuZGV2ZWxjb3IuY29t
            ADs=
        }

        image create photo actredo16 -data {
            R0lGODlhEAAQAIUAAPwCBBxOHBxSHBRGHKzCtNzu3MTSzBQ2FLzSxIzCjCSK
            FCyeHDzCLAxGHAwuFDSCNBxKLES+NHSmfBQ6FBxWJAQaDAQWFAw+HDSyLJzO
            nISyjMTexAQOBAwmDAw+FMzizAQODDymNKzWrAQKDAwaDEy6TFTGTFSyXDyK
            TAQCBAwiFBQyHAwSFAwmHAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEAAAAALAAAAAAQABAAAAZ2
            QIBwSCwaj0hAICBICgcDQsEgaB4PiIRiW0AEiE3sdsFgcK2CBsCheEAcjgYj
            oigwJRM2pUK0XDAKGRobDRwKHUcegAsfExUdIEcVCgshImojfEUkCiUmJygH
            ACkqHEQpqKkpogAgK5FOQywtprFDKRwptrZ+QQAh/mhDcmVhdGVkIGJ5IEJN
            UFRvR0lGIFBybyB2ZXJzaW9uIDIuNQ0KqSBEZXZlbENvciAxOTk3LDE5OTgu
            IEFsbCByaWdodHMgcmVzZXJ2ZWQuDQpodHRwOi8vd3d3LmRldmVsY29yLmNv
            bQA7
        }
        image create photo apptools16 -data {
            R0lGODlhEAAQAIUAAPwCBExKTERCRAQCBOzu7Nze3MzKzLy+vCxqZBQ2NJya
            nKyqrGRiZDRydKza3FRWVPT29LSytDw6PMTm5EySjCxaXGRaJFSanCRSVGxq
            bPTmvMSqVJTW1GSurHS6vOzq7KSipISChFRKHJSGNPz23GxKFBQ6PKyurCwq
            LMyufJx2RAQGBJSWlEwyDIRiLNy+lLSKVDwmDJRuNOTOrLyabGRCFDx2dKSC
            VOzWtHzCxOTGnNSyhAAAAAAAAAAAAAAAACH5BAEAAAAALAAAAAAQABAAAAah
            QIBwCAgIBAOiUiggFAyHASKxDAwUC8Zg0HAglA9IZPGQABoTSqJCFTIOEIsF
            gHBcEhhHUpKJFCwaGxYYHB0VEx4IEh8gIQwiIyQbJRMcHokmEicfDygAkCkq
            JQgIGG0rLElCLS4vMCWqQwMCQg0UMTIzNDVLQjaIGDE3ODQlS785CEkxKjow
            vEOHybG4O6JDCdNKuDUxRAmxRDHeveUAfkEAIf5oQ3JlYXRlZCBieSBCTVBU
            b0dJRiBQcm8gdmVyc2lvbiAyLjUNCqkgRGV2ZWxDb3IgMTk5NywxOTk4LiBB
            bGwgcmlnaHRzIHJlc2VydmVkLg0KaHR0cDovL3d3dy5kZXZlbGNvci5jb20A
            Ow==
        }
        image create photo wrap -data {
            R0lGODlhEAAQAIAAAPwCBAQCBCH5BAEAAAAALAAAAAAQABAAAAInhI+pqxH8
            kFsvsgtm1vvEaoBZSH6j5FSaRY4me4pyq1ochuf6fvgFACH+aENyZWF0ZWQg
            YnkgQk1QVG9HSUYgUHJvIHZlcnNpb24gMi41DQqpIERldmVsQ29yIDE5OTcs
            MTk5OC4gQWxsIHJpZ2h0cyByZXNlcnZlZC4NCmh0dHA6Ly93d3cuZGV2ZWxj
            b3IuY29tADs=
        }

    }
    
        
    onconfigure -filetypes value {
        lappend options(-filetypes) $value
        set options(-filetypes) [lsort $options(-filetypes)]
    }
    method autoscroll {w} {
        set frame [winfo parent $w]
        grid $w -in $frame -row 0 -column 0 -sticky nsew
        grid rowconfigure $frame $w -weight 1
        grid columnconfigure $frame $w -weight 1
        ttk::scrollbar $frame.vsb -command "$w yview"       
        grid $frame.vsb -row 0 -column 1 -sticky ns
        ttk::scrollbar $frame.hsb -orient horizontal -command "$w xview"       
        grid $frame.hsb -row 1 -column 0 -sticky ew 
        $w configure -yscrollcommand [mymethod scrollSet $frame.vsb] \
              -xscrollcommand [mymethod scrollSet $frame.hsb]
        grid propagate $w true
    }
    # private method
    method scrollSet {w lo hi} {
        if {$lo <= 0.0 && $hi >= 1.0} {
            grid remove $w
        } else {
            grid $w
        }
        $w set $lo $hi
    }
    method FoldAll {} {
        set rng [$text tag ranges fold]
        if {[llength $rng] ==0} {
            set store [$text index insert]            
            set current [$text index insert]
            set lastrng [list]
            set start 1.0
            tk::TextSetCursor $text $start

            while {true} {
                $self FoldCurrent
                set rng [$text tag ranges folded]
                if {[llength $lastrng] == [llength $rng]} {
                    break
                }
                set current [$text index [lindex $rng end]]
                set current [$text index "$current + 1 char"]
                tk::TextSetCursor $text $current
                set lastrng $rng
            }
            tk::TextSetCursor $text $store
        } else {
            $text tag remove fold 1.0 end
            $text tag remove folded 1.0 end
            $text see insert
        }
    }
    method FoldCurrent {} {
        set current [$text index insert]
        if {[lsearch [$text tag names $current] fold] > -1} {
            set idx1 [$text index "$current linestart"]
            set idx2 [$text index "$current lineend"]
            set end [$text search -regexp -forward {^#} "$current + 1 char"]                      
            $text tag remove fold $idx1 $idx2
            if {$end ne "1.0"} {
                $text tag remove folded "$idx2" "$end"
            } else {
                $text tag remove folded $idx2 end
            }
        } else {
            set lstart [$text index "$current linestart"]
            set cstart [$text index "insert linestart"]
            set lend [$text  index "$current lineend"]
            if {$lstart eq $current && $lend ne "$current"} {
                set current [$text index "$current + 1 char"]
            }
            set start [$text search -regexp -backward {^#} $current]
            set end [$text search -regexp -forward {^#} $current]                      
            if {$start ne ""} {
                set to [$text index "$start lineend"]
                $text tag add fold $start $to
                set start [$text index "$start lineend  + 1 char"]
                if {$end ne "1.0"} {
                    $text tag add folded $start "$end"
                } else {
                    $text tag add folded $start [$text index end]
                }
                if {[lsearch [$text tag names $current] folded] > -1} {
                    tk::TextSetCursor $text "$start - 1 char linestart"
                }
            }
        }


    }
    method lipsum {{index end}} {
        $text insert $index [regsub -all { +} " Lorem ipsum dolor sit amet, consectetur adipiscing elit,
        sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
        Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris 
        nisi ut aliquip ex ea commodo consequat. 
        Duis aute irure dolor in reprehenderit in voluptate velit esse cillum 
        dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, 
        sunt in culpa qui officia deserunt mollit anim id est laborum."   " "]
    }
    method bindControlXSplit {orient} {
        if {$orient eq "zero"} { 
            if {[llength [$pw panes]] == 2} {
                $pw forget $pframe
            }
        } else {
            $pw configure -orient $orient 
            if {[llength [$pw panes]] == 1} {
                $pw add $pframe
            }
        } 
        return -code break 
    }

    method ininit {} {
        foreach section [lsort [dict keys $ini]] {
            foreach {key value} [dict get $ini $section] {
                if {$key eq "extension"} {
                    lappend options(-filetypes) [list "$section files" $value]
                    set options(-filetypes) [lsort $options(-filetypes)]
                    set ext [regsub -all {\.} $value ""]
                    set ext [regsub -all " +" $ext " "]
                    set ext [regsub -all {[*]} $ext ""]
                } elseif  {[regexp {package|string|header|keyword|comment|method|class} $key]} {
                    foreach ex [split $ext " "] {
                        #puts $ex
                        lappend options(-hilights) [list $ex $key $value]
                    }
                }
                #puts  "$key=$value"
            }
            #lappend options(-hilights) $hilights
            #puts $options(-hilights)
        }
    }
    method ini2dict {filename} {
        set d [dict create] 
        if [catch {open $filename r} infh] {
            error "Cannot open $filename: $infh"
        } else {
            set section ""
            while {[gets $infh line] >= 0} {
                # Process line
                if {[regexp {^\s*#} $line]} {
                    continue
                } elseif {[regexp {^\[(.+)\]} $line -> section]} {
                    dict set d $section [list]
                } elseif {[regexp {^([-A-Z0-9a-z_]+)=(.+)} $line -> key value]} {
                    dict set d $section $key $value
                }
            }
            close $infh
        }
        return $d
    }
    method dict2ini {d outfile} {
        set out [open $outfile w 0600]
        foreach section [lsort [dict keys $d]] {
            puts $out "\[$section\]"
            foreach {key value} [dict get $d $section] {
                puts $out "$key=$value"
            }
        }
        close $out
    }
    method changeFontSize {i} {
        set size [font configure [$textw cget -font] -size]
        if {$size < 0} {
            # pixel
            incr size [expr {$i*-1}]
        } else {
            incr size $i
        }
        font configure [$textw cget -font] -size $size
    }

    method insert {args} {
        $textw insert {*}$args
        $self GuiTextChanged 
    }
    method delete {args} {
        $textw delete {*}$args
        $self GuiTextChanged
    }
    #-- A simple balloon, modified from Bag of Tk algorithms:  
    method balloon {w msg {display false}} {
        if {$display} {
            set top .balloon
            catch {destroy $top}
            toplevel $top -bd 1
            wm overrideredirect $top 1
            wm geometry $top +[expr {[winfo pointerx $w]+5}]+[expr {[winfo pointery $w]+5}]
            pack [message $top.txt -aspect 10000 -bg lightyellow \
                  -borderwidth 0 -text $msg -font {Helvetica 9}]
            bind  $top <1> [list destroy $top]
            raise $top
            after 3000 destroy $top
        } else {
            bind $w <Enter> [mymethod balloon $w $msg true]
            bind $w <Leave> { catch destroy .balloon }
        }
    }
    # public methods (are lowercase)
    # DESCRIPTION
    #     descr
    # ARGUMENTS
    #    arg1, arg2
    # RESULT
    #    what is returned
    # ***
    method UpdateFont {option value} {
        set options(-option) $value
        $text configure -font $value
        #$text configure -font $value
    }
    method GetFont {option} {
        return [$text cget $option]
    }
    method ForText {w args} {

        # initialize search command; we may add to it, depending on the
        # arguments passed in...
        set searchCommand [list $w search -count count]
        
        # Poor man's switch detection
        set i 0
        while {[string match {-*} [set arg [lindex $args $i]]]} {
            
            if {[string match $arg* -regexp]} {
                lappend searchCommand -regexp
                incr i
            } elseif {[string match $arg* -elide]} {
                lappend searchCommand  -elide
                incr i
            } elseif {[string match $arg* -nocase]} {
                lappend searchCommand  -nocase
                incr i
            } elseif {[string match $arg* -exact]} {
                lappend searchCommand  -exact
                incr i
            } elseif {[string compare $arg --] == 0} {
                incr i
                break
            } else {
                return -code error "bad switch \"$arg\": must be\
                --, -elide, -exact, -nocase or -regexp"
            }
        }
        
        # parse remaining arguments, and finish building search command
        foreach {pattern start end script} [lrange $args $i end] {break}
        lappend searchCommand $pattern matchEnd searchLimit
        
        # make sure these are of the canonical form
        set start [$w index $start]
        set end [$w index $end]
        
        # place marks in the text to keep track of where we've been
        # and where we're going
        $w mark set matchStart $start
        $w mark set matchEnd $start
        $w mark set searchLimit $end
        
        # default gravity is right, but we're setting it here just to
        # be pedantic. It's critical that matchStart and matchEnd have
        # left and right gravity, respectively, so that any text inserted
        # by the caller duing the search won't normally (*) cause an infinite
        # loop. 
        # (*) If the script inserts text after the matchEnd mark, and the
        # text that was added matches the pattern, madness will ensue.
        $w mark gravity searchLimit right
        $w mark gravity matchStart left
        $w mark gravity matchEnd right
        
        # finally, the part that does useful work. Keep running the search
        # command until we don't find anything else. Each time we find 
        # something, adjust the marks and execute the script
        while {1} {
            set cmd $searchCommand
            set index [eval $searchCommand]
            if {[string length $index] == 0} break
            
            $w mark set matchStart $index
            $w mark set matchEnd  [$w index "$index + $count c"]
            
            uplevel $script
        }
    }
    method Keypress {key} {
        if {$key eq "Return" || $key eq "space"} {
            if {$lastmode ne ""} {
                $self doHilights $lastmode
            } else {
                $self doHilights ""
            }
        }
        #puts $key
        # text edit modified does not work
        #[lsearch [list Up Down Left Right Alt_L Shift_L Control_R Prior ISO_Level3_Shift] $key] == -1
        if {[$textw edit modified]} {
            # instead of wcb
            $self GuiTextChanged
        }
    }
    #' 
    #' ## <a name='commands'>WIDGET COMMANDS</a>
    #' 
    #' Each **dgw::seditor** widget supports all usual methods of the Tk text widget and it adds the follwing method(s):
    #' 
    #' *pathName* **doHilights** *?mode?*
    #' 
    #' > Hilights the text within in the editor in the language given with the mode variable. 
    #'   The following arguments are supported:
    #' 
    #' > *mode* - the programming or markup language used for hilighting, the following modes 
    #' are already embedded into the widget: *tcl' (default), *sql', *text'. Other modes can be 
    #' added to the widget by specifying the option *-hilights* or by using the inifile.
    
    method doHilights {{mode tcl}} {
        if {$options(-hilightcommand) ne ""} {
            $options(-hilightcommand) $text
            return
        }
        if {$lastfile ne ""} {
            set mode [string tolower [string range [file extension $lastfile] 1 end]]
        } 
        set lastmode $mode
        set text $textw
        foreach tag [$text tag names] {
            if {$tag ne "fold" && $tag ne "folded"} {
                $text tag remove $tag 1.0 end
            }
        }
        if {$mode eq "tcl"} {
            $self ForText $text -regexp {^(itcl|oo|snit)::[a-zA-Z0-9 ]+} 1.0 end {
                $text tag add highlight matchStart matchEnd
            }
            $self ForText $text -regexp {^ *(method|constructor|typeconstructor|destructor|typedestructor|proc) *[a-zA-Z0-9 ]+} 1.0 end {
                $text tag add highlight matchStart matchEnd
            }
            $self ForText $text -regexp {^ *#.*} 1.0 end {
                $text tag add comment matchStart matchEnd
            }
            $self ForText $text -regexp { ;#.+} 1.0 end {
                $text tag add comment matchStart matchEnd
            }
            $self ForText $text -regexp {^ *(package|source).+} 1.0 end {
                $text tag add package matchStart matchEnd
            }
        } elseif {$mode eq "text"} {
            $self ForText $text -regexp {^!+.+} 1.0 end {
                $text tag add package matchStart matchEnd
            }
            $self ForText $text -regexp {^ *#.+} 1.0 end {
                $text tag add comment matchStart matchEnd
            }
            
        } elseif {$mode eq "sql"} {
            $self ForText $text -regexp {^ *--.+$} 1.0 end {
                $text tag add comment matchStart matchEnd
            }
            $self ForText $text -regexp -nocase {"[^"]+"} 1.0 end { ;#"
                $text tag add string matchStart matchEnd
            }

            $self ForText $text -regexp -nocase {(asc|all|attach|begin|between|by|commit|create|database|desc|detach|distinct|drop|except|exists|filter|from|full|glob|group|having|if|in|index|inner|insert|intersect|into|is|isnull|join|like|limit|match|natural|not|notnull|on|or|order|order|outer|pragma|primary|range|regexp|right|select|table|temp|transaction|trigger|union|unique|update|using|view|where|with|without)[\s\n]} 1.0 end {
                $text tag add highlight matchStart matchEnd
            }
            
        } else {
            foreach tps $options(-hilights) {
                foreach {tp tag regex} $tps {
                    if {$tp eq $mode} {
                        $self ForText $text -regexp -nocase $regex 1.0 end {
                            $text tag add $tag matchStart matchEnd
                        }
                    }
                }
            }
        }
    }
    method isModified {} {
        return [$text edit modified]
    }
    
    #' 
    #' *pathName* **loadFile** *filename ?reload:boolean?*
    #' 
    #' > Loads the given filename into the text widget or reloads the currently 
    #'   loaded file if reload is set to true. The default for reload is false.
    method loadFile {filename {reload false}} {
        if {$lastfile eq $filename && !$reload} {
            return
        }
        if {$Modified} {
            set answer [tk_messageBox -title "File modified!" -message "Do you want to save changes?" -type yesnocancel -icon question]
            switch -- $answer  {
                yes  { $self FileSave }
                cancel { return }
            }
        } 
        $text delete 1.0 end
        if [catch {open $filename r} infh] {
            tk_messageBox -title "Info!" -icon info -message "Cannot open $filename: $infh" -type ok
        } else {
            while {[gets $infh line] >= 0} {
                $text insert end "$line\n"
            }
            close $infh
            foreach b {save undo redo} {
                $win.ftop.$b configure -state disabled
            }
            set file $filename
            set Modified false
            set lastfile $filename
            $self doHilights [string tolower [string range [file extension $filename] 1 end]]
            $textw edit modified false
        }

    }
    method Menu {} {
        catch {destroy .editormenu}
        menu .editormenu -tearoff 0
        .editormenu add command -label "Undo" -underline 0 -command [list $self TextUndo] -accelerator Ctrl+z
        .editormenu add command -label "Redo" -underline 0 -command [list $self TextRedo] -accelerator Ctrl+y
        .editormenu add separator
        .editormenu add command -label "Cut" -underline 2 -command [list tk_textCut $textw] -accelerator Ctrl+x
        .editormenu add command -label "Copy" -underline 0 -command [list tk_textCopy $textw] -accelerator Ctrl+c
        .editormenu add command -label "Paste" -underline 0 -command [list tk_textPaste $textw] -accelerator Ctrl+v
        .editormenu add command -label "Delete" -underline 2 -command [list $self DeleteText $textw] -accelerator Del
        .editormenu add separator
        .editormenu add command -label "Select All" -underline 7 -command [list $textw tag add sel 1.0 end] -accelerator Ctrl+/
        if {$options(-toolcommand) ne ""} {
            .editormenu add separator
            $self addTool ;#[list -toolcommand $options(-toolcommand) -accelerator $options(-accelerator) -label $options(-toollabel)]
            

        }
        tk_popup .editormenu [winfo pointerx .] [winfo pointery .]
    }
    method addTool {} {
        .editormenu add command -label  $options(-toollabel) -command "$options(-toolcommand) all" \
              -accelerator [lindex $options(-accelerator) 0]
        .editormenu add command -label  "$options(-toollabel) (Selection)"  -command "$options(-toolcommand) selection" \
              -accelerator $options(-selectionaccelerator)
        .editormenu add command -label  "$options(-toollabel) (Line)"  -command "$options(-toolcommand) line" \
              -accelerator  $options(-lineaccelerator)
        return
        if {[info exists c(-lineaccelerator)]} {
            bind $textw  $c(-lineaccelerator) [list $options(-toolcommand) line]
        } else {
            .editormenu add command -label  "$c(-label) (Line)"  -command [list $options(-toolcommand) selection]
        }
        bind $textw  $c(-accelerator) [mymethod ToolCommand] 
    }
    method ToolCommandSelected {} {
        set cuttexts [selection own]
        if {$cuttexts != "" } {
            $options(-toolcommand) "[$win.fbot.text get sel.first sel.last]"
        }
    }
    method ToolCommandLine {} {
        set linetext [$win.fbot.text get "insert linestart" "insert lineend"]
        #array set c $options(-toolcommand)
        if {$linetext != "" } {
            $options(-toolcommand) "$linetext"
        }
    }

    method DeleteText {w} {
        set cuttexts [selection own]
        if {$cuttexts != "" } {
            catch {
                $cuttexts delete sel.first sel.last
                selection clear
            }
        }
    }

    # private methods (are uppercase)
    method GuiTextChanged {args} {
        foreach b {saveas save undo redo} {
            $win.ftop.$b configure -state normal
        }
        set Modified true
    }
    method TclEval {} {
        set text [$win.fbot.text get 1.0 end]
        
        set res [eval $text]
        $options(-toolcommand) "$res "
    }
    method ToolCommand {} {
        #array set c $options(-toolcommand)
        eval $options(-toolcommand) "[$win.fbot.text get 1.0 end]"
    }
    #' *pathName* **fileNew** 
    #' 
    #' > Loads a empty new file into the editor widget, if the previous file in the
    #'   widget was changed and not saved, before opening a new file, a dialogbox will show up, 
    #'   asking the user if he would like to save the file.
    method fileNew {} {
        $self FileNew
    }
    method FileNew {} {
        if {$Modified} {
            set answer [tk_messageBox -title "File modified!" -message "Do you want to save changes?" -type yesnocancel -icon question]
            switch -- $answer  {
                yes  {
                    $self FileSave
                }
                cancel { return }
            }
        } 
        $text delete 1.0 end       
        foreach b {saveas save undo redo} {
            $win.ftop.$b configure -state disabled
        }
        set bnlastfile "*new*"
        set file "*new*"
    }
    method FileSaveAs { } {
        unset -nocomplain savefile
        set filename [tk_getSaveFile -filetypes $options(-filetypes) -initialdir $lastdir]
        if {$filename != ""} {
            set out [open $filename w 0600]
            puts $out [$text get 1.0 end]
            close $out
            foreach b {save undo redo} {
                $win.ftop.$b configure -state disabled
            }
            set file $filename
            set bnlastfile [file tail $file]
            set lastdir [file dirname $file]
            set Modified false
            $textw edit modified false
        }
    }
    
    method FileSave { } {
        if {$file eq "*new*"} {
            unset -nocomplain savefile
            set file [tk_getSaveFile -filetypes $options(-filetypes) -initialdir $lastdir]
        }
        if {$file != ""} {
            set out [open $file w 0600]
            puts $out [$text get 1.0 end]
            close $out
            foreach b {save undo redo} {
                $win.ftop.$b configure -state disabled
            }
            set file $file
            set bnlastfile [file tail $file]
            set lastdir [file dirname $file]
            set Modified false
            $textw edit modified false
        }
    }
    method ToggleWrap {} {
        if {[$text cget -wrap] eq "word"} {
            $text configure -wrap none
            $peer configure -wrap none
        } else {
            $text configure -wrap word
            $peer configure -wrap word
        }
        
    }
    method TextRedo { } {
        catch {
            $text edit redo
        }
    }
    method TextUndo { } {
        catch {
            $text edit undo
        }
    }
    method FileOpen { } {
        set filename [tk_getOpenFile -filetypes $options(-filetypes) -initialdir $lastdir]
        if {$filename != ""} {
            $self loadFile $filename 
            set lastdir [file dirname $filename]
            set file $filename
            set bnlastfile [file tail $filename]
        }
    }

}


#' 
#' ## <a name='binding'>KEY BINDINGS</a>
#'
#' In addition to the standard Bindings of a text editor widget the *dgw::editor* 
#' provides the following key and mouse bindings.
#'
#' - `mouse right click` : editor popup with cut, paste etc.
#' - `Ctrl-x 2`: split the window vertically
#' - `Ctrl-x 3`: split the window horizontally
#' - `Ctrl-x 1` undo the splitting
#' - `Shift-Return`: Send the widget text to toolcommand 
#' - `Control-Return`: send the ehe current line to toolcommand
#' - `Control-Shift-Return`: send the current selection to toolcommand
#'
#' Please note, that the toolcommand accelerator keys can be changed to other keys by using the options of this widget.
#' 
#' ## <a name='example'>EXAMPLE</a>
#'
#' In the example below we create a Markdown markup aware text editor.
#' 
#' ```
#' package require dgw::seditor
#' dgw::seditor .top -borderwidth 5 -relief flat -font "Helvetica 20" \
#'                   -hilights {{md header ^#.+}    
#'                              {md comment ^>.+} 
#'                              {md keyword _{1,2}[^_]+_{1,2}}  
#'                              {md string {"[^"]+"}}}
#' pack .top -side top -fill both -expand true ;#"  
#' .top configure -filetypes {{Markdown Files}  {.md}}
#'
#' # create a sample Markdown file and load it later
#' set out [open test.md w 0600] 
#' puts $out "# Header example\n"
#' puts $out "_keyword_ example\n"
#' puts $out "Some not hilighted text\n"
#' puts $out "> some markdown quote text\n"
#' puts $out "## Subheader\n"
#' puts $out "Some more standard text with two \"strings\" which are \"inside!\"" 
#' puts $out [lsort [.top cget -filetypes]]
#' puts $out "\n\n## Tcl\n\nTcl be with you!\n\n## EOF\n\nThe End\n"
#' close $out
#' .top loadFile test.md
#' .top lipsum end
#' ```
#'
#' ## <a name='install'>INSTALLATION</a>
#'
#' Installation is easy you can install and use the **__PKGNAME__** package if you have a working install of:
#'
#' - the snit package  which can be found in [tcllib - https://core.tcl-lang.org/tcllib](https://core.tcl-lang.org/tcllib)
#' 
#' For installation you copy the complete *dgw* folder into a path 
#' of your *auto_path* list of Tcl or you append the *auto_path* list with the parent dir of the *dgw* directory.
#' Alternatively you can install the package as a Tcl module by creating a file dgw/__BASENAME__-__PKGVERSION__.tm in your Tcl module path.
#' The latter in many cases can be achieved by using the _--install_ option of __BASENAME__.tcl. 
#' Try "tclsh __BASENAME__.tcl --install" for this purpose.
#' 
#' ## <a name='demo'>DEMO</a>
#'
#' Example code for this package can  be executed by running this file using the following command line:
#'
#' ```
#' $ wish __BASENAME__.tcl --demo
#' ```

#' The example code used for this demo can be seen in the terminal by using the following command line:
#'
#' ```
#' $ tclsh __BASENAME__.tcl --code
#' ```
#' #include "documentation.md"
#' 
#' ## <a name='see'>SEE ALSO</a>
#'
#' - [dgw package homepage](https://chiselapp.com/user/dgroth/repository/tclcode/index) - various useful widgets
#' - [ctext widget in tklib](https://wiki.tcl-lang.org/page/Tklib+Contents) other syntax hilighting widget
#' - [text widget manual](https://www.tcl.tk/man/tcl8.6/TkCmd/text.htm) standard manual page for the underlying text widget
#'
#'  
#' ## <a name='changes'>CHANGES</a>
#'
#' * 2020-02-04 - version 0.3 started
#' * adding splitting window keys and word wrap button to the toolbar
#' * fixing splitting issues, updating documentation
#' * automatic loading of infile from <home>/.config/dgw/seditor.ini added
#'
#' ## <a name='todo'>TODO</a>
#' 
#' * config file for syntax hilights in the same directory as the source code and in some config dir in the home directory
#' * example for a derived syntax editor with an added syntax hilight schema
#' * more, real, tests
#' * github url for putting the code
#'
#' ## <a name='authors'>AUTHORS</a>
#'
#' The **__PKGNAME__** widget was written by Detlef Groth, Schwielowsee, Germany.
#'
#' ## <a name='copyright'>Copyright</a>
#'
#' Copyright (c) 2019-20  Dr. Detlef Groth, E-mail: detlef(at)dgroth(dot)de
#'
# LICENSE START
#
#' #include "license.md"
#
# LICENSE END

if {[info exists argv0] && [info script] eq $argv0 && [regexp seditor $argv0]} {
    set dpath dgw
    set pfile [file rootname [file tail [info script]]]
    if {[llength $argv] == 1 && [lindex $argv 0] eq "--version"} {    
        puts [dgw::getVersion [info script]]
        destroy .
    } elseif {[llength $argv] == 1 && [lindex $argv 0] eq "--demo"} {    
        dgw::runExample [info script]
    } elseif {[llength $argv] == 1 && [lindex $argv 0] eq "--code"} {
        puts [dgw::runExample [info script] false]
        destroy .
    } elseif {[llength $argv] == 1 && [lindex $argv 0] eq "--test"} {
        package require tcltest
        set argv [list] 
        tcltest::test dummy-1.1 {
            Calling my proc should always return a list of at least length 3
        } -body {
            set result 1
        } -result {1}
        tcltest::cleanupTests
        destroy .
    } elseif {[llength $argv] == 1 && ([lindex $argv 0] eq "--license" || [lindex $argv 0] eq "--man" || [lindex $argv 0] eq "--html" || [lindex $argv 0] eq "--markdown")} {
        dgw::manual [lindex $argv 0] [info script]
    } elseif {[llength $argv] == 1 && [lindex $argv 0] eq "--install"} {
        dgw::install [info script]
    } else {
        destroy .
        puts "\n    -------------------------------------"
        puts "     The ${dpath}::$pfile package for Tcl"
        puts "    -------------------------------------\n"
        puts "Copyright (c) 2019  Dr. Detlef Groth, E-mail: detlef(at)dgroth(dot)de\n"
        puts "License: MIT - License see manual page"
        puts "\nThe ${dpath}::$pfile package provides a text editor widget with syntax hilighting facilities and and toolbar"
        puts ""
        puts "Usage: [info nameofexe] [info script] option\n"
        puts "    Valid options are:\n"
        puts "        --help    : printing out this help page"
        puts "        --demo    : runs a small demo application."
        puts "        --code    : shows the demo code."
        puts "        --test    : running some test code"
        puts "        --license : printing the license to the terminal"
        puts "        --install : install ${dpath}::$pfile as Tcl module"        
        puts "        --man     : printing the man page in pandoc markdown to the terminal"
        puts "        --markdown: printing the man page in simple markdown to the terminal"
        puts "        --html    : printing the man page in html code to the terminal"
        puts "                    if the Markdown package from tcllib is available"
        puts ""
        puts "    The --man option can be used to generate the documentation pages as well with"
        puts "    a command like: "
        puts ""
        puts "    tclsh [file tail [info script]] --man | pandoc -t html -s > temp.html\n"
    }

}

