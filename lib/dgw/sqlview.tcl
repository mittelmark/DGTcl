#!/usr/bin/env tclsh
##############################################################################
#
#  Created By    : Dr. Detlef Groth
#  Created       : Sat Oct 27 11:43:24 2018
#  Last Modified : <200527.1656>
#
#  Description	 : Standalone SQLite datbase browser usable as well as widget.
#
#  History       : Version 0.0 Oct 27
#                  Version 0.1 Oct 30, Release to students
#                  Version 0.2 Nov 11
#                     - regex command
#                     - stats from R embedded
#                     - red background in case of error
#                     - busy widget to indicate statement execution
#                     - using opcodes for progress
#                     - support for sqlite3 functions in tcl
#                     - fix: sort for integer and double columns
#                  Version 0.3 ??
#                     - show log file, about button
#	
##############################################################################
#
#  Copyright (c) 2018-2020 Dr. Detlef Groth., Caputh-Schwielowsee, Germany
# 
#  Licsense: MIT
#
##############################################################################
#' ---
#' title:  __PKGNAME__ __PKGVERSION__
#' author: Dr. Detlef Groth, Schwielowsee, Germany
#' documentclass: scrartcl
#' geometry:
#' - top=20mm
#' - right=20mm
#' - left=20mm
#' - bottom=30mm
#' ---
#' 
#'
#' ## NAME
#'
#' **dgw::sqlview**  - database browser widget and standalone application
#' 
#' 
#' ## <a name='toc'></a>TABLE OF CONTENTS
#' 
#'  - [SYNOPSIS](#synopsis)
#'  - [DESCRIPTION](#description)
#'  - [COMMAND](#command)
#'  - [METHODS](#methods)
#'  - [EXAMPLE](#example)
#'  - [MARKUP LANGUAGE](#formatting)
#'  - [INSTALLATION](#install)
#'  - [SEE ALSO](#see)
#'  - [CHANGES](#changes)
#'  - [TODO](#todo)
#'  - [AUTHOR](#authors)
#'  - [LICENSE AND COPYRIGHT](#license)
#' 
#' 
#' ## <a name='synopsis'>SYNOPSIS</a>
#' 
#' Usage as package:
#' 
#' ```
#' package require Tk
#' package require snit
#' package require tdbc::sqlite3 
#' package require dgw::seditor 
#' package require dgw::hyperhelp
#' package require dgw::basegui
#' package require dgw::sqlview
#' dgw::sqlview pathName -database filename ?-funcfile sqlfunc.tcl?
#' dgw::sqlview tedit insert "sql statement"
#' dgw::sqlview tedit doHilights sql
#' ```
#' 
#' Usage as command line application:
#' 
#' ```
#' tclsh sqlview.tcl databasename
#' ```
#' 
#' ## <a name='description'>DESCRIPTION</a>
#' 
#' The **dgw::sqlview** package provides a SQL database browser widget as well 
#' as a standalone application. It main parts a treeview database structure viewer, 
#' a text editor with SQL syntax hilighting, and a tableview widget for viewing the
#' results of the entered SQL statements. The editor widget provides shortcuts to execute either the current selection, the current line or the complete
#' text entered in the text widget.


package require Tk
package require snit
package require tile
#package require tablelist
package require tdbc::sqlite3 
package require dgw::seditor 
package require dgw::dgwutils
package require dgw::hyperhelp
package require dgw::basegui
package provide dgw::sqlview 0.6

namespace eval ::dgw { }
namespace eval ::sqlfunc {} 
proc ::sqlfunc::rgx {args} {
    return [regexp [lindex $args 0] [lindex $args 1]]
}

set ::dgw::sqlviewmtime [clock format [file mtime [info script]] -format "%Y-%m-%d %H:%M"]
set ::dgw::sqlviewhelpfile [file normalize [file join [file dirname [info script]] sqlview.txt]]
set os [lindex $::tcl_platform(os) 0]
set machine $::tcl_platform(machine)
if {$::tcl_platform(wordSize) == 4 && $os eq "Linux"} {
    set machine x86
}
if {$machine eq "amd64"} {
    set machine x86_64
}
set ::dgw::extensionfile [file join [file dirname [info script]] c-extensions libsqlitefunctions-$os-$machine[info sharedlibextension]]
set ::dgw::reextensionfile [file join [file dirname [info script]] c-extensions pcre-$os-$machine[info sharedlibextension]]
set ::dgw::sqlfuncfile [file join [file dirname [info script]] sqlfunc.tcl]
#' 
#' ## <a name='command'>COMMAND</a>
#' 
#' **dgw::sqlview** *pathName -database fileName ?-option value ...?*
#' 
#' > creates a new *sqlview* widget using the given widget *pathName* and with the given *-database fileName*. 
#' Please note, that the filename must be currently a sqlite3 database. Support for other database types can be added on request.
#'
#' ## <a name='options'>OPTIONS</a>
#' 
#' The *dgw::sqlview* snit widget supports the following options:

snit::widget ::dgw::sqlview {
    option -dummy -default ""
    #' 
    #'   __-database__ _filename_
    #' 
    #'  > Configures the database used within the widget. Should be set already at
    #'    widget initialization.
    option -database -default ""
    
    #' 
    #'   __-type__ _sqlite3_
    #' 
    #'  > Configures the database type, currently only the type sqlite3 is supported. 
    #'    Other types can be added on request. Should be set only at
    #'    widget initialisation.
    option -type -default sqlite3
    
    #' 
    #'   __-logfile__ _filename_
    #' 
    #'  > The file where all executed statements of the sqlview editor widget are written into.
    #'    If not given, defaults to an the file sqlview.log in the users home directory.
    option -logfile -default ""
    
    #' 
    #'   __-log__ _boolean_
    #' 
    #'  > Should all executed statements written into the logfile. Default true.
    option -log true
    
    #' 
    #'   __-funcfile__ _filename(s)_
    #' 
    #'  > Load SQL functions from the file given with the *-funcfile* option. 
    #' Please note, that all SQL functions written in Tcl must be created 
    #' within the *sqlfunc* namespace.  If the *filenames* are a list, every file of this list  will be loaded.
    #' See the following example for the beginning of such a `funcfile.tcl`:
    #'
    #' > ```
    #' namespace eval ::sqlfunc {}
    #' # replace all A's with B's
    #' proc ::sqlfunc::mmap args {
    #'   return [string map {A B} [lindex $args 0]]
    #' }
    #' # support for regexp: rgx('^AB',colname)
    #' proc ::sqlfunc::rgx {args} {
    #'     return [regexp [lindex $args 0] [lindex $args 1]]
    #' }
    #' # support for replacements: rsub('^AB',colname,'')
    #' proc ::sqlfunc::rsub {args} {
    #'     return [regsub [lindex $args 0] [lindex $args 1] [lindex $args 2]]
    #' }
    #' > ```
    option -funcfile ""
    typevariable ndb 0
    variable db
    variable tview
    variable tdb
    variable tedit
    variable tedits
    variable tviews
    variable mtimer
    variable notebooks 
    variable helpfile sqlview.txt
    variable info 
    variable extension
    variable reextension
    variable Opcodes 0
    expose tedit
    variable hasExtension false
    variable hasReExtension false    
    variable specialFunctions [list]
    variable sapp
    variable status
    constructor {args} {
        $self configurelist $args
        set sapp [dgw::basegui %AUTO% -start false]
        if {$options(-logfile) eq ""} {
            set options(-logfile) [file join $::env(HOME) sqlview.log]
        }
        array set tedits [list]
        array set tviews [list]        
        array set notebooks [list]
        array set info [list tcl_version $::tcl_patchLevel]
        set extension $::dgw::extensionfile
        set reextension $::dgw::reextensionfile     
        set helpfile $::dgw::sqlviewhelpfile
        if {$options(-funcfile) ne ""} {
            foreach file $options(-funcfile) {
                if {[file exists $file]} {
                    puts stderr "loading $file"
                    source $options(-funcfile)
                } else {
                    error "file $file does not exists"
                }
            }
        }
        incr ndb
        set db db$ndb
        pack [panedwindow $win.pan -orient vertical] -side top -expand yes -fill both -pady 2 -padx 2
        panedwindow $win.pan.pan -orient horizontal
        set tdbframe [ttk::frame $win.pan.pan.tf]
        set toolbar [ttk::frame $win.pan.pan.tf.tf]
        ttk::button $toolbar.open -image fileopen16 -command [mymethod openDatabase]
        ttk::button $toolbar.refresh -image actreload16 -command [mymethod refreshDatabase]
        ttk::button $toolbar.history -image history-16 -command [mymethod showHistory]
        ttk::button $toolbar.exit -image fileclose16 -command [mymethod closeSQLview]
        ttk::button $toolbar.help -image acthelp16  -command [mymethod help $helpfile]
        ttk::button $toolbar.about -image hwinfo-16  -command [mymethod About]
        foreach btn [list open refresh history] {
            ${toolbar}.$btn configure -style ToolButton
            pack ${toolbar}.$btn -side left -padx 4 -pady 4
        }
        foreach btn [list exit help about] {
            ${toolbar}.$btn configure -style ToolButton
            pack ${toolbar}.$btn -side right -padx 4 -pady 4
        }
        set tdbf [ttk::frame $tdbframe.tf1]
        set tdb [ttk::treeview $tdbframe.tf1.db];#SortableTreeView $win.pan.pan.db -statusbar false
        pack $toolbar -side top -fill x -expand false
        $sapp autoscroll $tdb
        pack $tdbf -side top -fill both -expand true
        #$tdb configure -columns [list header] -displaycolumns [list]
        $tdb heading #0 -text "Database Structure"
        #$tdb heading header -text Table
        set nbedit [snotebook $win.pan.pan.nb -raisecmd [mymethod GuiChangedTEditTab] \
                    -createcmd [mymethod GuiAddTEditTab] -renamecmd [mymethod GuiRenamedTEditTab]]
        set notebooks(0) $nbedit
        ttk::notebook::enableTraversal $nbedit
        #bind  $nbedit <<NotebookTabChanged>>  [mymethod GuiChangedTEditTab %W]
        #install tedit using seditor $nbedit.text text -toolcommand [mymethod executeSQL] \
        #      -accelerator [list <Shift-Return> <Control-x><Control-s>]
        #$tdb tag configure std -font [$tedit cget -font]
        ttk::frame $nbedit.f
        set nbtview [snotebook $win.pan.nb -raisecmd [mymethod GuiChangedTViewTab] \
                     -createcmd [mymethod GuiAddTViewTab]]
        ttk::notebook::enableTraversal $nbtview 
        #ttk::frame $nbtview.f
        #$nbtview add $nbtview.f -text " Tab 1 "
        set notebooks(1) $nbtview
        $nbtview bind <Control-t> { break  }
        $nbtview bind <Control-w> { break  }
        $nbtview bind <Button-3>  { break  }
        $nbedit add $nbedit.f -text " Tab 1 "
        $win.pan.pan add $tdbframe $nbedit 
        
        #bind  $nbtview <<NotebookTabChanged>>  [mymethod GuiChangedTViewTab %W]
        $win.pan add $win.pan.pan $nbtview
        #bind $tedit <Control-x><Control-s> [mymethod executeSQL]
        set status [dgw::statusbar $win.stb]
        pack $status -side top -expand false -fill x
        bind $tdb <Double-1> [mymethod InsertStructure]
        bind all <Control-plus> [mymethod changeFontSize +2]
        bind all <Control-minus> [mymethod changeFontSize -2]
        if {[winfo parent $win] eq "."} {
            wm title . "sqlview 2020 [package provide dgw::sqlview]"
        }
        if {$options(-database) ne ""} {
            $self dbConnect 
            $self refreshDatabase
        
        }
    }
    typeconstructor {
        tk_focusFollowsMouse 
        image create photo history-16 -data {
            R0lGODlhEAAQAIUAAPwCBEQ2LEw6POTSrOzWtNS2lAQCBOzatPTm3PTq3Myy
            jEw+NOzm1Pz29Pz+/Pz6/Pz27FRGPFxKRPTu3Pzy7Pz69Pz67KSGbPzy3Pzu
            3PTizPzu1Pzq1PTmzOzaxPTixPTmxOzWvOTOtKyWdOTGpOTStNS+nIRmVLym
            hNzCnOzavLyefAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEAAAAALAAAAAAQABAAAAaH
            QIBwGCgOj0jBgFAwGJDJAyJBUDihwgWj4XhAqhEJNDKhVLwUSUDyPJIrlgYl
            LSG0hYELhgLJTBJOd1kaGxgYHB0egkQfHBwgHyEigkUBIwMkBwcEJSZ3ARYW
            JCcnKCYpJJ5HAQUqFhSjJysoKItOCgehJBISI4tCtyERa79HTrx2WEiBUH5B
            ACH+aENyZWF0ZWQgYnkgQk1QVG9HSUYgUHJvIHZlcnNpb24gMi41DQqpIERl
            dmVsQ29yIDE5OTcsMTk5OC4gQWxsIHJpZ2h0cyByZXNlcnZlZC4NCmh0dHA6
            Ly93d3cuZGV2ZWxjb3IuY29tADs=
        }

        image create photo contexthelp-16 -data {
            R0lGODlhEAAQAIEAAPwCBAQChAQCBAAAACH5BAEAAAAALAAAAAAQABAAAAIz
            hH+hIeiwVmtOUcjENaxqjVjhByaBSZZVl24Y1V6iEVMzkD4bqD700bshgh1f
            zwd0IfwFACH+aENyZWF0ZWQgYnkgQk1QVG9HSUYgUHJvIHZlcnNpb24gMi41
            DQqpIERldmVsQ29yIDE5OTcsMTk5OC4gQWxsIHJpZ2h0cyByZXNlcnZlZC4N
            Cmh0dHA6Ly93d3cuZGV2ZWxjb3IuY29tADs=
        }
        image create photo hwinfo-16 -data {
            R0lGODlhEAAQAIYAAPwCBBQ+XBRCZAw+XAw6XBRCXCRObCxihCxqjCRijBRS
            fAwyVCxehDx6nER+pPz+/BxKZAwmPFyWtGyevCRSbBxWfAxGbHSqxGSatCxu
            lBxahBRKbAQiNEyKrBRKdAw6ZAwiNESSLCyCDBxWBDRulBwyRHS6ZDSWHCyK
            FDQyNCxqlAQmRAwiPMzalPyCBMQCBCx+DAwuRBQqPITCdFxaXCyOFAQeNAwm
            RAxKdPz6/GyyVMTCxKSirAQCBGzKZAwqTAweNFyuRDyeJFzCTITOdAQiPAQa
            NHzCbES6NEy6PESyNDyqLDymJPz+xAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEAAAAA
            LAAAAAAQABAAAAfBgACCAAECAwSDiYMFBgcICQoLC4qCBQwNDg8PEJERlAYN
            EhOaFBUWnokBBw4SFxgOGRobCxyJBQkNHZoPpR4fICEiIiMBCSSYmgoKFgsl
            JicoKQQKCSoZmgW+KywtLi8pMDEbFRqaAcwyMyc0NSkiNjc4ObsrKyU6Ozw9
            7j4lNhGSfsgAEkQIDxr7YAwh0qKIDSM2jgRpgbDHPhFIMiZRsoTJkhMgobUD
            MKKkySYjUKockYJSypcrWypKQbOmTT+BAAAh/mhDcmVhdGVkIGJ5IEJNUFRv
            R0lGIFBybyB2ZXJzaW9uIDIuNQ0KqSBEZXZlbENvciAxOTk3LDE5OTguIEFs
            bCByaWdodHMgcmVzZXJ2ZWQuDQpodHRwOi8vd3d3LmRldmVsY29yLmNvbQA7
        }
        image create photo exec-16 -data {
            R0lGODlhEAAQAIYAAPwCBEQ+PBwaHLy+vMzOzGxqZHx+dKyqnKymnIR+dNTW
            1MTCxJyOfLySVMSaVMSeVMSebJyWhOSmTOSuVNyubPS+dKSWhHR2dDw+PIyK
            hNymTNSaTEw+JOy+fPzSnLSyrISChDQyNDw6NMzKzLy2rMyiXGxWLAQCBHRq
            TPzerNy+lMzGvCwuLAwKDDQyLJyWlNy6jPTGhGxaRGxiRPz2vOTStLy2tFRS
            TMS+tOzGlPzmtPTixGRiXCwqJLy6tOTWxPTq1MzKxMzOxISCfHRybLS2tHR2
            bCQmJExORMTCvMTGxAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEAAAAA
            LAAAAAAQABAAAAeogACCg4SFhoIBAYeDAogDA4oAjYQCBAEFBgcICQUBCpOD
            AQsMDQ4PEBGWhgUMDxITFBUUFheDGAYZCA0aGxwcHR4QHwwgISILIyQlGiYn
            JygpKisEIywALS4vMBoxMjM0KTU2LC2ENzg5wDo6Owo8hT0+Lx8/OztAQR9C
            1oInQz4FMBAp8sEIhgIEMpwYdASJCwAYkihR5OLGkUUAMmTACK8Hx4+C/AQC
            ACH+aENyZWF0ZWQgYnkgQk1QVG9HSUYgUHJvIHZlcnNpb24gMi41DQqpIERl
            dmVsQ29yIDE5OTcsMTk5OC4gQWxsIHJpZ2h0cyByZXNlcnZlZC4NCmh0dHA6
            Ly93d3cuZGV2ZWxjb3IuY29tADs=
        }
        image create photo kit-16 -data {
            R0lGODlhEAAQAIAAAPwCBAQCxCH5BAEAAAAALAAAAAAQABAAAAIghI+pFrHb
            XmpRMmoBxXB75IWcKIKk022ZunJtdlSw5BcAIf5oQ3JlYXRlZCBieSBCTVBU
            b0dJRiBQcm8gdmVyc2lvbiAyLjUNCqkgRGV2ZWxDb3IgMTk5NywxOTk4LiBB
            bGwgcmlnaHRzIHJlc2VydmVkLg0KaHR0cDovL3d3dy5kZXZlbGNvci5jb20A
            Ow==
        }
        image create photo acthelp16 -data {
            R0lGODlhEAAQAIMAAPwCBAQ6XAQCBCyCvARSjAQ+ZGSm1ARCbEyWzESOxIy6
            3ARalAAAAAAAAAAAAAAAACH5BAEAAAAALAAAAAAQABAAAAQ/EEgQqhUz00GE
            Jx2WFUY3BZw5HYh4cu6mSkEy06B72LHkiYFST0NRLIaa4I0oQyZhTKInSq2e
            AlaaMAuYEv0RACH+aENyZWF0ZWQgYnkgQk1QVG9HSUYgUHJvIHZlcnNpb24g
            Mi41DQqpIERldmVsQ29yIDE5OTcsMTk5OC4gQWxsIHJpZ2h0cyByZXNlcnZl
            ZC4NCmh0dHA6Ly93d3cuZGV2ZWxjb3IuY29tADs=
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
        image create photo actreload16 -data {
            R0lGODlhEAAQAIUAAPwCBCRaJBxWJBxOHBRGBCxeLLTatCSKFCymJBQ6BAwm
            BNzu3AQCBAQOBCRSJKzWrGy+ZDy+NBxSHFSmTBxWHLTWtCyaHCSSFCx6PETK
            NBQ+FBwaHCRKJMTixLy6vExOTKyqrFxaXDQyNDw+PBQSFHx6fCwuLJyenDQ2
            NISChLSytJSSlFxeXAwODCQmJBweHAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEAAAAALAAAAAAQABAAAAaB
            QIBQGBAMBALCcCksGA4IQkJBUDIDC6gVwGhshY5HlMn9DiCRL1MyYE8iiapa
            SKlALBdMRiPckDkdeXt9HgxkGhWDXB4fH4ZMGnxcICEiI45kQiQkDCUmJZsk
            mUIiJyiPQgyoQwwpH35LqqgMKiEjq5obqh8rLCMtowAkLqovuH5BACH+aENy
            ZWF0ZWQgYnkgQk1QVG9HSUYgUHJvIHZlcnNpb24gMi41DQqpIERldmVsQ29y
            IDE5OTcsMTk5OC4gQWxsIHJpZ2h0cyByZXNlcnZlZC4NCmh0dHA6Ly93d3cu
            ZGV2ZWxjb3IuY29tADs=
        }
        image create photo fileclose16 -data {
            R0lGODlhEAAQAIQAAPwCBCQiJBwaHAQCBDQyNDw6PFxaXFRSVERGRCwqLAwO
            DGRiZHx6fPz+/GxqbAwKDCQmJAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAACH5BAEAAAAALAAAAAAQABAAAAVaICCOZGme
            qBgEwjCkRGEcSKK4JrEcBrMgAdeLVDg0GguGsYEbBQyGYyN6FDoPDIf0+LCK
            BIgetQERDgGDBGIpNY8GioAU0m6KXFw883w3+/l9f4AkfimGIn4hACH+aENy
            ZWF0ZWQgYnkgQk1QVG9HSUYgUHJvIHZlcnNpb24gMi41DQqpIERldmVsQ29y
            IDE5OTcsMTk5OC4gQWxsIHJpZ2h0cyByZXNlcnZlZC4NCmh0dHA6Ly93d3cu
            ZGV2ZWxjb3IuY29tADs=
        }
        image create photo appsheet16 -data {
            R0lGODlhEAAQAIIAAPwCBAQCBAT+/Pz+/KSipPz+BAAAAAAAACH5BAEAAAAA
            LAAAAAAQABAAAANFCBDc7iqIKUW98WkWpx1DAIphR41ouWya+YVpoBAaCKtM
            oRfsyue8WGC3YxBii5+RtiEWmASFdDVs6GRTKfCa7UK6AH8CACH+aENyZWF0
            ZWQgYnkgQk1QVG9HSUYgUHJvIHZlcnNpb24gMi41DQqpIERldmVsQ29yIDE5
            OTcsMTk5OC4gQWxsIHJpZ2h0cyByZXNlcnZlZC4NCmh0dHA6Ly93d3cuZGV2
            ZWxjb3IuY29tADs=
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
        image create photo folder16 -data {
            R0lGODlhEAAQAIYAAPwCBAQCBExKTBwWHMzKzOzq7ERCRExGTCwqLARqnAQ+
            ZHR2dKyqrNTOzHx2fCQiJMTi9NTu9HzC3AxmnAQ+XPTm7Dy67DymzITC3IzG
            5AxypHRydKymrMzOzOzu7BweHByy9AyGtFyy1IzG3NTu/ARupFRSVByazBR6
            rAyGvFyuzJTK3MTm9BR+tAxWhHS61MTi7Pz+/IymvCxulBRelAx2rHS63Pz6
            /PTy9PTu9Nza3ISitBRupFSixNTS1CxqnDQyNMzGzOTi5MTCxMTGxGxubGxq
            bLy2vLSutGRiZLy6vLSytKyurDQuNFxaXKSipDw6PAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEAAAAA
            LAAAAAAQABAAAAfDgACCAAECg4eIAAMEBQYHCImDBgkKCwwNBQIBBw4Bhw8Q
            ERITFJYEFQUFnoIPFhcYoRkaFBscHR4Ggh8gIRciEiMQJBkltCa6JyUoKSkX
            KhIrLCQYuQAPLS4TEyUhKb0qLzDVAjEFMjMuNBMoNcw21QY3ODkFOjs82RM1
            PfDzFRU3fOggcM7Fj2pAgggRokOHDx9DhhAZUqQaISBGhjwMEvEIkiIHEgUA
            kgSJkiNLmFSMJChAEydPGBSBwvJQgAc0/QQCACH+aENyZWF0ZWQgYnkgQk1Q
            VG9HSUYgUHJvIHZlcnNpb24gMi41DQqpIERldmVsQ29yIDE5OTcsMTk5OC4g
            QWxsIHJpZ2h0cyByZXNlcnZlZC4NCmh0dHA6Ly93d3cuZGV2ZWxjb3IuY29t
            ADs=
        }
        image create photo file16 -data {
            R0lGODlhEAAQAIUAAPwCBFxaXNze3Ly2rJSWjPz+/Ozq7GxqbJyanPT29HRy
            dMzOzDQyNIyKjERCROTi3Pz69PTy7Pzy7PTu5Ozm3LyqlJyWlJSSjJSOhOzi
            1LyulPz27PTq3PTm1OzezLyqjIyKhJSKfOzaxPz29OzizLyidIyGdIyCdOTO
            pLymhOzavOTStMTCtMS+rMS6pMSynMSulLyedAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEAAAAALAAAAAAQABAAAAaQ
            QIAQECgajcNkQMBkDgKEQFK4LFgLhkMBIVUKroWEYlEgMLxbBKLQUBwc52Hg
            AQ4LBo049atWQyIPA3pEdFcQEhMUFYNVagQWFxgZGoxfYRsTHB0eH5UJCJAY
            ICEinUoPIxIcHCQkIiIllQYEGCEhJicoKYwPmiQeKisrKLFKLCwtLi8wHyUl
            MYwM0tPUDH5BACH+aENyZWF0ZWQgYnkgQk1QVG9HSUYgUHJvIHZlcnNpb24g
            Mi41DQqpIERldmVsQ29yIDE5OTcsMTk5OC4gQWxsIHJpZ2h0cyByZXNlcnZl
            ZC4NCmh0dHA6Ly93d3cuZGV2ZWxjb3IuY29tADs=
        }
    }
    method Centering {} {
        set top .history
        bind $top <Map> {}
        $sapp center $top 
        
    }
    #' 
    #' ## <a name='methods'>METHODS</a>
    #' 
    #' The *dgw::sqlview* widget provides the following methods:
    #' 
    
    #' *pathName* **tedit** *arguments*
    #'
    #' > Expose the interface of the *dgw::seditor* text widget, so you can use all of its methods 
    #'   and the methods of the standard text editor widget. For example: 
    #' 
    #' > `pathName tedit insert end "select * from students"`
    #' 

    
    #' *pathName* **showHistory** *toplevel*
    #'
    #' > Displays the SQL statement history in the given toplevel path. Default: `.history`

    method showHistory {{top .history}} {
        catch { destroy $top }
        
        toplevel $top
        wm title $top "Log Window"
        wm transient $top .
        bind $top <Map> [mymethod Centering]

        pack [ttk::frame .history.tf] -fill both -expand true -side top
        set txt [text .history.tf.text]
        $sapp autoscroll $txt
        grid [ttk::frame .history.tf.tf] -padx 5 -pady 5
        pack [ttk::checkbutton .history.tf.tf.cb -text "Logging" -variable [myvar options(-log)] -onvalue true -offvalue false] -side left -pady 1 -padx 10 -anchor n
        pack [ttk::button .history.tf.tf.btn -text "Dismiss" -command { destroy  .history }] -padx 10 -pady 1 -anchor n
        set filename $options(-logfile)
        if {[file exists $options(-logfile)]} {
            if [catch {open $filename r} infh] {
                $txt insert end "Cannot open $filename: $infh \n"
            } else {
                while {[gets $infh line] >= 0} {
                    $txt insert end "$line\n"
                }
                close $infh
                $txt see end
            }
        } else {
            $txt insert end "No statements yet inside your logfile: $options(-logfile) \n"
            $txt insert end "Have you enabled logging below??"
        }
    }
                           
    method About {} {
        tk_messageBox -title "About ..." -icon info  \
        -message "SQLView 2018-2020 [package present dgw::sqlview]\n@ Detlef Groth\nTcl/Tk:[set ::tcl_patchLevel]\nsqlite3: $info(dbversion)\n  stats: $hasExtension\n  regexp: $hasReExtension\n  Tcl-functions: [llength $specialFunctions]\n\nmtime: $::dgw::sqlviewmtime" -type ok
    }
    method help {fname {topic overview}} {
        catch { destroy .t2 }
        toplevel .t2
        wm title .t2 "SQLView - Help"
        set hhelp [dgw::hyperhelp .t2.win -helpfile $fname -commandsubst true]
        $hhelp Help $topic
        pack $hhelp -side top -fill both -expand yes
        #$hhelp CenterWindow .t2
        
        #puts "nameof exe:[info nameofexecutable]"
        #puts $selfns
        # only if not inside R
        #wm transient .t2 .

        #tk_messageBox -title "Info!" -icon info -message "SQLview by Detlef Groth\n\n       2018\n" -type ok
    }
    method GuiRenamedTEditTab {w page} {
        #set tedit $tedits($page)
        $notebooks(1) tab current -text [$w tab current -text]
    }
    method GuiChangedTEditTab {w page} {
        set tedit $tedits($page)
        $notebooks(1) select $page
    }
    method GuiChangedTViewTab {w page} {
        set tview $tviews($page)
        $notebooks(0) select $page
    }
    method GuiAddTEditTab {w page} {
        set i [llength [$w tabs]]
        set te [dgw::seditor $page.ed$i -toolcommand [mymethod executeSQL] \
                -toollabel "execute SQL"]
        $te doHilights sql 
        pack $te -side top -fill both -expand yes
        ttk::frame $notebooks(1).f$i
        incr i -1
        set tedits($i) $te
        set tedit $te
        incr i 1
        $notebooks(1) add $notebooks(1).f$i -text " Tab $i "

    }
    method GuiAddTViewTab {w page} {
        set i [llength [$w tabs]]
        set f [ttk::frame $page.f$i]
        set tv [$sapp treeview $f.t$i] ;#-padding [list 10 10 10 10]
        $sapp autoscroll $tv
        $tv tag configure std -font [$tedit cget -font]
        pack $f -side top -fill both -expand yes
        incr i -1
        set tviews($i) $tv
        set tview $tv
    }
    #'
    #' *pathName* **refreshDatabase**
    #'
    #' > Refresh the treeview widget which shows the database structure. Useful if the database was updated.

    method refreshDatabase {} {
        set tabs [$db tables]
        #puts $tabs
        $tdb delete [$tdb children {}]
        foreach tab [lsort [dict keys $tabs]] {
            #puts " table $tab type=[dict get $tabs $tab type]"
            set parent [$tdb insert {} end  -text " $tab ([dict get $tabs $tab type])" -image appsheet16]
            foreach col [dict keys [$db columns $tab]] {
                set idx [$tdb insert $parent end -text " $col" -image file16]
                #$tdb tag add std $idx 
                #puts "       col: $col"
            }
            $tdb tag add std [$tdb children $parent]
            $tdb tag add std $parent
        }
        set x 0
        set specialFunctions [list]
        foreach cmd [lsort [info commands ::sqlfunc::*]] {
            incr x
            if {$x == 1} {
                set parent [$tdb insert {} end -text " special functions" -image exec-16]
                $tdb tag add std $parent

            }
            regsub {.+::} $cmd "" func
            $tdb insert $parent end -text "$func" -image kit-16
            lappend specialFunctions $func
        }
        $tdb tag add std [$tdb children $parent]
        $self getDBVersion
        $status set "Loaded database [file tail $options(-database)] with $options(-type) $info(dbversion), Tcl/Tk $info(tcl_version)."
        $status progress 100
    }
    
    #'
    #' *pathName* **openDatabase** *?filename?*
    #'
    #' > Open the database using the given *filename* is given. 
    #'   If not *filename* is given opens the open file dialog.
    
    method openDatabase {{filename ""}} {
        set types {
            {{SQLite3 Files}       {.sqlite3} }
            {{All Files}        *             }
        }
        if {$filename eq ""} {
            set filename [tk_getOpenFile -filetypes $types]
        }
        if {$filename != ""} {
            # Open the file ...
            catch {
                $self dbDisconnect
            }
            $self configure -database $filename
            $self dbConnect
        }
    }
    #'
    #' *pathName* **closeSQLview** 
    #'
    #' > Destroys the sqlview widget. A message box will be shown to verify that the 
    #'   widget should be really destroyed. This as well disconnects the database cleanly.

    method closeSQLview {} {
        set answer [tk_messageBox -title "Question!" -message "Really close window / app ?" -type yesno -icon question]
        if { $answer } {
            $self dbDisconnect
            if {[winfo parent $win] eq "."} {
                exit 0
            } else {
                destroy $win
            }
        } 
    }
    method InsertStructure {} {
        set item [$tdb selection]
        set txt [$tdb item $item -text]
        set txt [regsub { *\(.+\)} $txt ""]
        $tedit insert insert $txt
        focus -force $tedit
        return
    }
    #'
    #' *pathName* **changeFontSize** *integer*
    #'
    #' > Increase (positive integer values) or decrease widget (negative integer values) font size of all text and ttk::treeview widgets.

    method changeFontSize {i} {
        set size [font configure [$tedit cget -font] -size]
        if {$size < 0} {
            # pixel
            incr size [expr {$i*-1}]
        } else {
            incr size $i
        }
        font configure [$tedit cget -font] -size $size
        set font [$tedit cget -font]
        $tdb tag configure std -font $font
        $tview tag configure std -font $font
    }
    #'
    #' *pathName* **getDBVersion**
    #'
    #' > Returns the SQLite 3 version of the current database implementation.

    method getDBVersion {} {
        if {$options(-type) eq "sqlite3"} {
            set statement [$db prepare "select sqlite_version();"]
            set res [list]
            $statement foreach -as lists -columnsvariable cvar row { 
                lappend res $row
            } 
            $statement close 
        }
        set info(dbversion) [lindex $res 0]
    }
    
    #'
    #' *pathName* **executeSQL** *mode*
    #'
    #' > Execute a SQL statement against the current database. 
    #' If mode is 'all' (default) the complete text entered in the text editor
    #' widget will be used as statement. The *mode* can be as well 'line' where only the current line is executed, 
    #' or 'selection' where only the currently selected text is send to the database.
    method executeSQL {{mode all}} {
        if {$mode eq "all"} {
            set stm [$tedit get 1.0 end]
        } elseif {$mode eq "line"} {
            set stm [$tedit get "insert linestart" "insert lineend"]
        } elseif {$mode eq "selection"} {
            set stm [$tedit get [$tedit index sel.first] [$tedit index sel.last]]
            if {$stm eq ""} {
                return
            }
        }
        $tview delete [$tview children {}]
        tk busy hold .
        tk busy configure . -cursor "watch"
        update
        catch {  $self dbSelect $stm } err
        if {$err ne ""} {
            puts "after bad proc call: ErrorCode: $::errorCode"
            puts "after syntax error: ErrorCode: $::errorInfo"        
            regsub { while executing.+} $::errorInfo "" error
            regsub -all {\n} $error " " error
            $status set "ERRORINFO: $error\n"
            $tedit configure -background salmon 
            update
            after 3000
            $tedit configure -background white
            set ::errorInfo ""
        } else {
            $self Log $stm
        }
        tk busy forget .
        # todo
        array unset ::mtopKK
        array set ::mtopKK [list]

    }
    method Log {stm} {
        if {$options(-logfile) ne "" && $options(-log)} {
            set out [open $options(-logfile) a 0600]
            puts $out "\n####### STATEMENT ############\n$stm"
            close $out
        }
    }
    method MonitorProgress {} {
        incr Opcodes 50000
        $status set " Processed [expr {$Opcodes/1000}]k opcodes in [$mtimer seconds] seconds ..."
        update
    }
    #'
    #' *pathName* **dbConnect**
    #'
    #' > Connect to the actual database. Currently only SQLite 3 is supported.
    method dbConnect {} {
        #$tdb configure -show headings
        if {[winfo parent $win] eq "."} {
            wm title . "sqlview 2020 - [file tail $options(-database)]"
        }

        if {$options(-type) eq "sqlite3"} {
            #  -timeout 10
            tdbc::sqlite3::connection create $db $options(-database)
            set Opcodes 0
            set handle [$db getDBhandle]
            $handle progress 50000 [mymethod MonitorProgress]
            $handle function mtop -argcount 1 mtop
            $handle function aamap -deterministic -argcount 2 aamap            
            foreach cmd [info commands ::sqlfunc::*] {
                regsub {.+::} $cmd "" func
                $handle function $func $cmd 
            }
            if {[file exists $extension]} {
                $handle enable_load_extension 1
                #set tempfile [file tempfile]
                #puts [pwd]
                set sharedlib libsqlite3stats[info sharedlibextension]
                file copy -force $extension $sharedlib
                if {[info sharedlibextension] eq ".so"} {
                    file attributes ./$sharedlib -permissions rwxr-xr-x 
                }
                #set sql [format "select load_extension('%s')" temp1.so]
                #set sql "select load_extension('temp1.so')"
                #puts "sql='$sql'"
                #exit 0
                $handle eval "select load_extension('./$sharedlib')"
                after 300
                file delete $sharedlib
                set hasExtension true
            }
            if {[file exists $reextension]} {
                #puts "file exists $reextension"
                $handle enable_load_extension 1
                #set tempfile [file tempfile]
                set sharedlib libsqlite3pcre[info sharedlibextension]
                catch {
                    file copy -force $reextension $sharedlib
                    if {[info sharedlibextension] eq ".so"} {
                        file attributes ./$sharedlib -permissions rwxr-xr-x
                    }
                    #set sql [format "select load_extension('%s')" temp2.so]
                    #set sql "select load_extension('temp2.so')"
                    #puts "sql='$sql'"
                    #exit 0
                    $handle eval "select load_extension('./$sharedlib')"
                    after 300
                    file delete $sharedlib
                    set hasReExtension true
                }
                #puts "re extensions loaded"
            }
        }
    }
    #'
    #' *pathName* **dbSelect** *statement*
    #'
    #' > Execute the given statement against the database and insert the result
    #'   into the tableview widget at the bottom.
    method dbSelect {stm} {
        set mtimer [Timer %AUTO%]
        set x 0
        set statement [$db prepare $stm]
        set res [list]
        $statement foreach -as lists -columnsvariable cvar row { 
            lappend res $row
            if {[incr x] == 10000} {
                break
            }
        } 
        $statement close 
        if {[llength $res] > 0} {
            $tview loadData $cvar $res
            $tview tag add std [$tview children ""]
        }
        if {$x == 10000} {
            $status set "Only 10000 rows shown in [$mtimer seconds] seconds, might be more!"
        } else {
            $status set " Processed $x rows in [$mtimer seconds] seconds"
        }
    }
    #'
    #' *pathName* **dbDisconnect**
    #'
    #' > Disconnect the actual database. Currently only SQLite 3 is supported.

    method dbDisconnect {} {
        $db close
    }

    method test {arg} {
        puts "Hi $arg"
        puts "dummy opt is $options(-dummy)"
    }
    destructor {
        catch { $db close }
    }
}



if {false} {
    array set mtopKK [list]
    proc ::sqlfunc::mtop {col} {
        if {[info exists ::mtopKK($col)]} {
            return [incr ::mtopKK($col)]
        } else {
            return [set ::mtopKK($col) 1]
        }
    }
}

if {[info exists argv0] && $argv0 eq [info script] && [regexp sqlview $argv0]} {
    set dpath dgw
    set pfile [file rootname [file tail [info script]]]
    proc usage { } {
        puts "Usage: $::argv0 ?--help? sqlite3file"
        destroy .
        exit 0
    }
    if {[llength $argv] == 0} {
        usage
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
    } else {
        if {[lsearch $argv --version] > -1} {
            puts [package provide dgw::sqlview]
            exit 0
        } elseif {[file exists [lindex $argv 0]]} {
            set sqlv [::dgw::sqlview .sql -database [lindex $argv 0] -funcfile $::dgw::sqlfuncfile]
            $sqlv tedit insert end " select * from ... limit 100"
            $sqlv tedit doHilights sql
            pack $sqlv -side top -fill both -expand yes

        } else {
            destroy .
            puts "\n    -------------------------------------"
            puts "     The ${dpath}::$pfile package for Tcl"
            puts "    -------------------------------------\n"
            puts "Copyright (c) 2020  Dr. Detlef Groth, E-mail: detlef(at)dgroth(dot)de\n"
            puts "License: MIT - License see manual page"
            puts "\nThe ${dpath}::$pfile package provides a sqlite3 database browser widget with:"
            puts "    - editor with syntax hilighting facilities and toolbar"
            puts "    - database structure viewer"
            puts "    - tableview for browsing data"
            puts "    - tabbed layout for running parallel editor sessions and data views"
            puts ""
            puts "Usage: [info nameofexe] [info script] option\n"
            puts "    Valid options are:\n"
            puts "        --help    : printing out this help page"
            puts "        --demo    : runs a small demo application."
            puts "        --code    : shows the demo code."
            puts "        --test    : running some test code"
            puts "        --license : printing the license to the terminal"
            puts "        --man     : printing the man page in pandoc markdown to the terminal"
            puts "        --markdown: printing the man page in simple markdown to the terminal"
            puts "        --html    : printing the man page in html code to the terminal"
            puts "                    if the Markdown package from tcllib is available"
            puts ""
            puts ""
        }
    }
}

#' 
#' ## <a name='binding'>KEY BINDINGS</a>
#' 
#' #### Editor widget
#'
#' In addition to the standard bindings of the Tk text editor widget, the SQL editor 
#' widget, *dgw::seditor*, in the upper right, provides the following key and mouse bindings:
#'
#' - `mouse right click` : editor popup with cut, paste etc.
#' - `Ctrl-x 2`: split the window vertically
#' - `Ctrl-x 3`: split the window horizontally
#' - `Ctrl-x 1` undo the splitting
#' - `Shift-Return`: Send the widget text to the configured *-toolcommand*
#' - `Control-Return`: send the current line to configured *-toolcommand*
#' - `Control-Shift-Return`: send the current selection to the tool command
#' 
#' Please note, that the tool command accelerator keys can be changed to other keys 
#' by using the options of the *dgw::seditor* widget using the `tedit` sub command of the *dgw::sqlview* widget.
#' 
#' #### Tableview widget
#' 
#' The tableview widget at the bottom can be sorted by column if the user clicks on 
#' the column headers. It otherwise provides the standard bindings of the ttk::treeview widget to the developer and user.
#' 
#' #### Notebook tabs
#' 
#' The following shortcuts are only available if the users click on the notebook tab:
#' 
#' - Ctrl-Tab: after click on the notebook will open a new tab, Ctrl-Tab outside of the notebook widget will change the visible tab
#' - Ctrl-Shift-Left: Move tab to the left.
#' - Ctrl-Shift-Right: move tab to the right
#' - Ctrl-w: closes the tab if the users confirms the dialog box message.
#' - Right mouse click: change the tab name.
#' 
#' If you the notebook tab has not the focus you have the following bindings available:
#' 
#' - Ctrl-Tab: cycle the tabs and bring the next in the forground, also called tab traversal.
#' 
#' ## <a name='example'>EXAMPLE</a>
#'
#' In the example below we create a sample database and load the database and 
#' their information into the three sub widgets.
#' 
#' ```
#' package require dgw::sqlview
#' set sqlv [::dgw::sqlview .sql -database test.sqlite3 -funcfile sqlfunc.tcl]
#' # create a test database
#' $sqlv dbSelect "drop table if exists students"
#' $sqlv dbSelect "create table students (id INTEGER, firstname TEXT, lastname TEXT, city TEXT)"
#' $sqlv dbSelect "insert into students (id,firstname, lastname, city) values (1234, 'Marc', 'Musterman', 'Mustercity')"
#' $sqlv dbSelect "insert into students (id,firstname, lastname, city) values (1235, 'Marcella', 'Musterwoman', 'Berlin')"
#' $sqlv refreshDatabase
#' $sqlv tedit doHilights sql
#' $sqlv tedit insert end " select * from students"
#' $sqlv executeSQL
#' pack $sqlv -side top -fill both -expand yes
#' ```
#'
#' ## <a name='install'>INSTALLATION</a>
#'
#' You can install and use the **__PKGNAME__** package if you have a working install of:
#'
#' - Tcl/Tk installed together with the database extensions *tdbc*
#' - the snit package, which is  part of [tcllib](https://core.tcl-lang.org/tcllib)
#' 
#' If you have this, then download the latest *dgw* and *dgtools* package releases from: [dgw package release page](https://chiselapp.com/user/dgroth/repository/tclcode/wiki?name=releases).
#' For installation unzip the latest *dgw* and *dgtools* zip files and copy the complete *dgw* and *dgtools* folders into a path 
#' of your *auto_path* list of Tcl. Alternatively you can append the *auto_path* list with the parent directory of the *dgw* directory.
#' 
#' ## <a name='demo'>DEMO</a>
#'
#' Example code for this package can  be executed by running this file using the following command line:
#'
#' ```
#' $ wish __BASENAME__.tcl --demo
#' ```
#'
#' The example code used for this demo can be seen in the terminal by using the following command line:
#'
#' ```
#' $ tclsh __BASENAME__.tcl --code
#' ```
#' #include "documentation.md"
#' 
#' ## <a name='see'>SEE ALSO</a>
#'
#' - [dgw package homepage](https://chiselapp.com/user/dgroth/repository/tclcode/index) - various other useful widgets and tools to build Tcl/Tk applications.
#'
#'  
#' ## <a name='changes'>CHANGES</a>
#'
#' * 2020-03-05 - version 0.6 started
#'
#' ## <a name='todo'>TODO</a>
#' 
#' * tests
#' * github url 
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
