##############################################################################
#
#  System        : 
#  Module        : 
#  Created By    : Dr. Detlef Groth
#  Created       : Wed Jan 18 11:17:19 2017
#  Last Modified : <210820.0901>
#
#  Description	Snit DGFileBrowser Widget 
#
#  Notes 
#
#  History: 
#     - 2017-01-18 project started
#     - 2017-01-20 first usable version
#     - 2018-10-04 remove recursive recursion in tree mode
#                  ViewCmd method for F4 key
#     - 2019-12-29 Release as version 0.1
#                  documentation, browse, getDirectory, 
#                  setDirectory command
#	
##############################################################################
#
#  Copyright (c) 2017 Dr. Detlef Groth.
# 
##############################################################################
#' ---
#' documentclass: scrartcl
#' title: dgw::sfilebrowser
#' author: Detlef Groth, Schwielowsee, Germany
#' ---
#' 
#' ## NAME
#'
#' > **dgw::sfilebrowser** - snit file browser widget
#'
#' ## <a name='toc'></a>TABLE OF CONTENTS
#' 
#'  - [SYNOPSIS](#synopsis)
#'  - [DESCRIPTION](#description)
#'  - [COMMAND](#command)
#'  - [WIDGET OPTIONS](#options)
#'  - [WIDGET COMMANDS](#commands)
#'  - [WIDGET BINDINGS](#bindings)
#'  - [EXAMPLE](#example)
#'  - [INSTALLATION](#install)
#'  - [DEMO](#demo)
#'  - [DOCUMENTATION](#docu)
#'  - [SEE ALSO](#see)
#'  - [TODO](#todo)
#'  - [AUTHOR](#authors)
#'  - [COPYRIGHT](#copyright)
#'  - [LICENSE](#license)
#'  
#' ## <a name='synopsis'>SYNOPSIS</a>
#' 
#' ```
#' package require dgw::sfilebrowser
#' namespace import ::dgw::sfilebrowser
#' sfilebrowser pathName options
#' pathName configure -treemode true
#' pathName configure -initialpath .
#' pathName configure -viewcmd procName
#' pathName configure -fileimage imgName
#' pathName browse dirName
#' ```
#'
#' ## <a name='description'>DESCRIPTION</a>
#'
#' **sfilebrowser** - tablelist based file browser widget to explore 
#' the file system and to execute certain actions on the currently selected file, 
#' such as opening it in an editor.
#'
#' ## <a name='command'>COMMAND</a>
#'
#' **sfilebrowser** *pathName ?options?*
#' 
#' > Creates and configures the *sfilebrowser* widget using the Tk window id _pathName_ and the given *options*. 
#'  
#' ## <a name='options'>WIDGET OPTIONS</a>
#'
#' The **sfilebrowser** widget inherits all options and methods of its parent widget, 
#' the tablelist widget. See the manual for tablelist for thowse options and methods. 
#' Further it adds the following options in additional to tablelists options:
#'
########

package require Tk
package require dgw::dgwutils
package require snit
package require tablelist
package provide dgw::sfilebrowser 0.2

namespace eval dgw {}


###
snit::widget dgw::sfilebrowser {
    delegate option * to Tbl
    delegate method * to Tbl
    #'
    #' __-treemode__ *boolean*
    #' 
    #' > Should the browser be opened in tree mode or in listbox mode? Default is *true*, which is tree mode.
    option -treemode -default true
    #'
    #' __-initialpath__ *dirName*
    #'
    #' > The directory from which the files and folders should be shown in the sfilebrowser widget. Defaults to the current working directory.
    option -initialpath -default .
    #'
    #' __-viewcmd__ *procName*
    #'
    #' > The command to be executed id the user double clicks the entry. Default to empty string, i.e. no action is performed.
    option -viewcmd ""
    #'
    #' __-fileimage__ *imgName*
    #'
    #' > The image to be displayed left of filenames. Defaults to the embedded image for files.
    option -fileimage fileImg 
    variable currentpath "."
    variable LastKeyTime 0
    variable LastKey " "
    typevariable winSys
    constructor {args} {
        $self configurelist $args
        set tf $win.tf
        frame $tf -class ScrollArea
        set tbl $tf.tbl
        set vsb $tf.vsb
        set hsb $tf.hsb
        install Tbl using tablelist::tablelist $tbl \
              -columns {0 "Name"  left
                        0 "Size"          right
                        0 "Date Modified" left} \
              -expandcommand [mymethod expandCmd] -collapsecommand [mymethod collapseCmd] \
              -xscrollcommand [list $hsb set] -yscrollcommand [list $vsb set] \
              -movablecolumns no -setgrid no -showseparators yes -height 20 ;# -stretch {1 true}
        if {[$tbl cget -selectborderwidth] == 0} {
            $tbl configure -spacing 1
        }
        $tbl columnconfigure 0 -formatcommand [mymethod formatString] -sortmode dictionary ;#
        $tbl columnconfigure 1 -formatcommand [mymethod formatSize] -sortmode integer
        $tbl columnconfigure 2 -formatcommand [mymethod formatString]
        ttk::scrollbar $vsb -orient vertical   -command [list $tbl yview]
        ttk::scrollbar $hsb -orient horizontal -command [list $tbl xview]
        #$tbl columnconfigure 0 -sortcommand [mymethod sortByFileName]
        grid $tbl -row 0 -rowspan 2 -column 0 -sticky news
        if {[string compare $winSys "aqua"] == 0} {
            grid [$tbl cornerpath] -row 0 -column 1 -sticky ew
            grid $vsb	       -row 1 -column 1 -sticky ns
        } else {
            grid $vsb -row 0 -rowspan 2 -column 1 -sticky ns
        }
        grid $hsb -row 2 -column 0 -sticky ew
        grid rowconfigure    $tf 1 -weight 1
        grid columnconfigure $tf 0 -weight 1
        pack $tf -side top -expand yes -fill both
        # Populate the tablelist with the contents of the given directory
        # ...
        $tbl sortbycolumn 0
        if {$options(-treemode)} {
            $self putContents . $tbl root
            bind $Tbl <<TablelistColumnSorted>> [mymethod sortingDone %d]
        } else {
            set bodyTag [$tbl bodytag]
            bind $bodyTag <Double-1>   [mymethod openFlatFolder $tbl]
            bind $bodyTag <Key-Return>   [mymethod openFlatFolder $tbl]
            bind $bodyTag <Key-Home>   [mymethod setSelection $tbl 0]
            bind $bodyTag <Key-End>   [mymethod setSelection $tbl end]
            bind $bodyTag <Key-BackSpace>   [mymethod openBackspace $tbl]
            bind $bodyTag <Any-Key> [mymethod ListMatch $tbl %W %A]
            bind $bodyTag <Key-F4> [mymethod ViewFile $tbl]
            bind $bodyTag <Triple-1> [mymethod ViewFile $tbl]
            bind $Tbl <<TablelistColumnSorted>> [mymethod sortingDone %d]
            set currentpath $options(-initialpath)
            $self putFlatContents $currentpath $tbl
        }
    }
    typeconstructor {
        # option.tcl
        if {[catch {tk windowingsystem} winSys] != 0} {
            switch $::tcl_platform(platform) {
                unix      { set winSys x11 }
                windows   { set winSys win32 }
                macintosh { set winSys classic }
            }
        }
        
        #
        # Add some entries to the Tk option database
        #
        if {[string compare $winSys "x11"] == 0} {
            #
            # Create the font TkDefaultFont if not yet present
            #
            catch {font create TkDefaultFont -family Helvetica -size -12}
            
            option add *Font			TkDefaultFont
            option add *selectBackground	#678db2
            option add *selectForeground	white
        } else {
            option add *ScrollArea.borderWidth			1
            option add *ScrollArea.relief			sunken
            option add *ScrollArea.Tablelist.borderWidth	0
            option add *ScrollArea.Tablelist.highlightThickness	0
            option add *ScrollArea.Text.borderWidth		0
            option add *ScrollArea.Text.highlightThickness	0
        }
        option add *Tablelist.background	white
        option add *Tablelist.stripeBackground	#e4e8ec
        option add *Tablelist.setGrid		yes
        option add *Tablelist.movableColumns	yes
        option add *Tablelist.labelCommand	tablelist::sortByColumn
        option add *Tablelist.labelCommand2	tablelist::addToSortColumns
        
        
        image create photo fileImg -data {
            R0lGODlhEAAOAPcAAAAAADVJYzZKZJOit5WkuZalupqpvpyrwJ6uw6OyyKSzyae2zKm5z6u70a6+
            1K+/1bLC2LrF1L3K4cTP5MnT5svV59HZ6tPb69Xd7Njf7drh7tzj79/l8OHn8ePp8ubr9Ont9evv
            9u7x9/Dz+PL1+fX3+vf4+/n6/Pv8/fz9/v7+/v///wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEAAP8ALAAAAAAQAA4A
            AAh7AP/9g0CwoAMGCgQqFAhhhcOHKw4IWCjwAcSHBCJMXNjgosMBAkIuXOBxBYoBIBcm8KiiBIgB
            ARYi8HhCRAeYCw1cTEHigwacCgtcNBGCwwWgAgdARDHCQ4YKSP8pddgSxAYLE6JOXVGzAwYKErSi
            HEs2aoCzaNOeFRgQADs=}
        image create photo textImg -data {
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

        image create photo appbook16 -data {
            R0lGODlhEAAQAIQAAPwCBAQCBDyKhDSChGSinFSWlEySjCx+fHSqrGSipESO
            jCR6dKTGxISytIy6vFSalBxydAQeHHyurAxubARmZCR+fBx2dDyKjPz+/MzK
            zLTS1IyOjAAAAAAAAAAAAAAAACH5BAEAAAAALAAAAAAQABAAAAVkICCOZGmK
            QXCWqTCoa0oUxnDAZIrsSaEMCxwgwGggHI3E47eA4AKRogQxcy0mFFhgEW3M
            CoOKBZsdUrhFxSUMyT7P3bAlhcnk4BoHvb4RBuABGHwpJn+BGX1CLAGJKzmK
            jpF+IQAh/mhDcmVhdGVkIGJ5IEJNUFRvR0lGIFBybyB2ZXJzaW9uIDIuNQ0K
            qSBEZXZlbENvciAxOTk3LDE5OTguIEFsbCByaWdodHMgcmVzZXJ2ZWQuDQpo
            dHRwOi8vd3d3LmRldmVsY29yLmNvbQA7}
        image create photo appbookopen16 -data {
            R0lGODlhEAAQAIUAAPwCBAQCBExCNGSenHRmVCwqJPTq1GxeTHRqXPz+/Dwy
            JPTq3Ny+lOzexPzy5HRuVFSWlNzClPTexIR2ZOzevPz29AxqbPz6/IR+ZDyK
            jPTy5IyCZPz27ESOjJySfDSGhPTm1PTizJSKdDSChNzWxMS2nIR6ZKyijNzO
            rOzWtIx+bLSifNTGrMy6lIx+ZCRWRAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEAAAAALAAAAAAQABAAAAae
            QEAAQCwWBYJiYEAoGAFIw0E5QCScAIVikUgQqNargtFwdB9KSDhxiEjMiUlg
            HlB3E48IpdKdLCxzEAQJFxUTblwJGH9zGQgVGhUbbhxdG4wBHQQaCwaTb10e
            mB8EBiAhInp8CSKYIw8kDRSfDiUmJ4xCIxMoKSoRJRMrJyy5uhMtLisTLCQk
            C8bHGBMj1daARgEjLyN03kPZc09FfkEAIf5oQ3JlYXRlZCBieSBCTVBUb0dJ
            RiBQcm8gdmVyc2lvbiAyLjUNCqkgRGV2ZWxDb3IgMTk5NywxOTk4LiBBbGwg
            cmlnaHRzIHJlc2VydmVkLg0KaHR0cDovL3d3dy5kZXZlbGNvci5jb20AOw==
        }
        image create photo clsdFolderImg -data {
            R0lGODlhEAAOAPcAAAAAAJycAM7OY//OnP//nP//zvf39wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEAAP8ALAAAAAAQAA4A
            AAhjAP8JHEiw4MAACBECMHjQQIECBAgEWGgwgICLGAUkTCgwwMOPIB8SELDQY8STKAkMIPnPZEqV
            MFm6fDlApUyIKGvqHFkSZ06YK3ue3KkzaMsCRIEOMGoxo1OMFAFInUqV6r+AADs=}
        image create photo openFolderImg -data {
            R0lGODlhEAAOAPcAAAAAAJycAM7OY//OnP//nP///wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEAAP8ALAAAAAAQAA4A
            AAhnAP8JHEiwIMEACBEaPFigYcMAC/8FKECgYsUCCRMKnGixo8MCAgBIpNixJIGQGVMmFHASAMeS
            AwgMCCkAJcmKMWW2rCnypcWYAwYEcNmTJFCZQVGKHHk0aNKhS1WqBLD0H9WrWLEGBAA7}
    }
    #'
    #' ## <a name='commands'>WIDGET COMMANDS</a>
    #' 
    #' Each **sfilebrowser** widget has all the standard widget commands ond options of a tablelist widget as well as the following commands:
    #'
    #' *pathName* **browse** *dirname*
    #' 
    #' > Opens the given directory name in the widget and displays its files and directories.
    #'
    method browse {dirname} {
        set currentpath $dirname
        if {$options(-treemode)} {
            $self putContents $dirname $Tbl root
        } else {
            $self putFlatContents $dirname $Tbl
        }
        #$self setSelection $Tbl 0
    }
    #' *pathName* **getDirectory** 
    #' 
    #' > Returns the path for the current opened directory.
    #'
    method getDirectory {} {
        return $currentpath
    }
    #' *pathName* **setDirectory** *dirname*
    #' 
    #' > Opens the given directory name in the widget and displays its files and directories. Alias for the *browse* command.
    #'
    method setDirectory {dirname} {
        $self browse $dirname
    }
    
    method setSelection {tbl index} {
        $tbl selection clear 0 end
        $tbl selection set $index $index
        $tbl activate $index
        $tbl see $index
    }
    method openBackspace {tbl} {
        $tbl selection clear 0 end
        $tbl selection set 0 0
        set dir [$tbl cellcget [$tbl curselection],0 -text] 
        set dir [regsub {D} $dir ""]
        set currentpath [file join $currentpath $dir] 
        $self putFlatContents $currentpath $tbl
    }
    method  ListMatch {tbl w key} {
        set ActualTime [clock seconds]
        if {[expr {$ActualTime-$LastKeyTime}] < 3} {
            set ActualKey "$LastKey$key"
        } else {
            set ActualKey $key
        }
        
        if [regexp {[-A-Za-z0-9]} $ActualKey] {
            set n 0
            foreach i [$tbl getkeys 0 end] {
                set name [regsub {^(D|F)} [$tbl cellcget $i,0 -text] ""]
                # pity I'm still on 8.0.5, else I'd say -nocase
                if [string match $ActualKey* $name] {
                    $tbl see $n
                    $tbl selection clear 0 end
                    $tbl selection set $n
                    $tbl activate $n
                    set LastKeyTime [clock seconds]
                    set LastKey $ActualKey
                    break
                } else {
                    incr n
                }
            }
        }
    }
    method openFlatFolder {tbl} {
        set dir [$tbl cellcget [$tbl curselection],0 -text] 
        set img [$tbl cellcget  [$tbl curselection],0 -image]
        if {$img eq "clsdFolderImg"} {
            set dir [regsub {D} $dir ""]
            set currentpath [file join $currentpath $dir] 
            $self putFlatContents $currentpath $tbl
        } elseif {$options(-viewcmd) ne ""} {
            set dir [regsub {F} $dir ""]
            eval $options(-viewcmd) [file join $currentpath $dir]
        }
    }
    method ViewFile {tbl} {
        set dir [$tbl cellcget [$tbl curselection],0 -text] 
        set img [$tbl cellcget  [$tbl curselection],0 -image]
        if {$img eq "clsdFolderImg"} {
            set dir [regsub {D} $dir ""]
            set currentpath [file join $currentpath $dir] 
            $self putFlatContents $currentpath $tbl
        } else {
            if {$options(-viewcmd) ne ""} {
                set dir [regsub {F} $dir ""]
                eval $options(-viewcmd) [file join $currentpath $dir]
            }
        }
    }
    method putFlatContents {dir tbl} {
        $tbl delete 0 end
        set row 0
        #lappend itemList [list D.. -1 D[clock format [file mtime "$dir"] -format "%Y-%m-%d %H:%M"] ".."]
        $tbl insert end [list "D.." -1  ""]
        $tbl cellconfigure $row,0 -image clsdFolderImg
        foreach entry [glob -nocomplain -types {d f} -directory $dir *] {
                if {[catch {file mtime $entry} modTime] != 0} {
                    continue
                }
                
                if {[file isdirectory $entry]} {
                    lappend itemList [list D[file tail $entry] -1 \
                                      D[clock format $modTime -format "%Y-%m-%d %H:%M"] $entry]
                } else {
                    lappend itemList [list F[file tail $entry] [file size $entry] \
                                      F[clock format $modTime -format "%Y-%m-%d %H:%M"] ""]
                }
         }
         
         #
         # Sort the above list and insert it into the tablelist widget
         # tbl as list of children of the row identified by nodeIdx
         #
         set itemList [$tbl applysorting $itemList]
         foreach item $itemList {
             set name [lindex $item end]
             incr row
             $tbl insert end [list [lindex $item 0] [lindex $item 1] [lindex $item 2]]

             if {[string compare $name ""] == 0} {			;# file
                 $tbl cellconfigure $row,0 -image $options(-fileimage)
             } else {						;# directory
                 $tbl cellconfigure $row,0 -image clsdFolderImg
                 $tbl rowattrib $row pathName $name
                 
             }
         }
         set ActualKey ""

        return
    }
    #------------------------------------------------------------------------------
    # putContents
    #
    # Outputs the contents of the directory dir into the tablelist widget tbl, as
    # child items of the one identified by nodeIdx.
    #------------------------------------------------------------------------------
    method putContents {dir tbl nodeIdx} {
                #
        # The following check is necessary because this procedure
        # is also invoked by the "Refresh" and "Parent" buttons
        #
        if {[string compare $dir ""] != 0 &&
            (![file isdirectory $dir] || ![file readable $dir])} {
            bell
            if {[string compare $nodeIdx "root"] == 0} {
                set choice [tk_messageBox -title "Error" -icon warning -message \
                            "Cannot read directory \"[file nativename $dir]\"\
                            -- replacing it with nearest existent ancestor" \
                            -type okcancel -default ok]
                if {[string compare $choice "ok"] == 0} {
		    while {![file isdirectory $dir] || ![file readable $dir]} {
                        set dir [file dirname $dir]
                    }
                } else {
                    return ""
                }
            } else {
                return ""
            }
        }
        
        if {[string compare $nodeIdx "root"] == 0} {
            if {[string compare $dir ""] == 0} {
                if {[llength [file volumes]] == 1} {
                    wm title . "Contents of the File System"
                } else {
                    wm title . "Contents of the File Systems"
                }
            } else {
                wm title . "Contents of the Directory \"[file nativename $dir]\""
            }
            
            $tbl delete 0 end
            set row 0
        } else {
            set row [expr {$nodeIdx + 1}]
        }
        
        #
        # Build a list from the data of the subdirectories and
        # files of the directory dir.  Prepend a "D" or "F" to
        # each entry's name and modification date & time, for
        # sorting purposes (it will be removed by formatString).
        #
        set itemList {}
        if {[string compare $dir ""] == 0} {
            foreach volume [file volumes] {
                lappend itemList [list D[file nativename $volume] -1 D $volume]
            }
        } else {
            if {[$tbl childcount root] == 0} {
                lappend itemList [list D.. -1 D[clock format [file mtime "$dir"] -format "%Y-%m-%d %H:%M"] ".."]
            }
            
            foreach entry [glob -nocomplain -types {d f} -directory $dir *] {
                if {[catch {file mtime $entry} modTime] != 0} {
                    continue
                }
                
                if {[file isdirectory $entry]} {
                    lappend itemList [list D[file tail $entry] -1 \
                                      D[clock format $modTime -format "%Y-%m-%d %H:%M"] $entry]
                } else {
                    lappend itemList [list F[file tail $entry] [file size $entry] \
                                      F[clock format $modTime -format "%Y-%m-%d %H:%M"] ""]
                }
                }
            }
            
            #
            # Sort the above list and insert it into the tablelist widget
            # tbl as list of children of the row identified by nodeIdx
            #
            set itemList [$tbl applysorting $itemList]
            $tbl insertchildlist $nodeIdx end $itemList
            
            #
            # Insert an image into the first cell of each newly inserted row
            #
            foreach item $itemList {
                set name [lindex $item end]
                if {[string compare $name ""] == 0} {			;# file
                    $tbl cellconfigure $row,0 -image $options(-fileimage)
                } else {						;# directory
                    $tbl cellconfigure $row,0 -image clsdFolderImg
                    $tbl rowattrib $row pathName $name
                    
                    #
                    # Mark the row as collapsed if the directory is non-empty
                    #
                    if {[file readable $name] && [llength \
                                                  [glob -nocomplain -types {d f} -directory $name *]] != 0} {
                        $tbl collapse $row
                    }
                }
                
                incr row
            }
            

    }
               
    #------------------------------------------------------------------------------
    # formatString
    #
    # Returns the substring obtained from the specified value by removing its first
    # character.
    #------------------------------------------------------------------------------
    method formatString val {
        return [string range $val 1 end]
    }
    
    #------------------------------------------------------------------------------
    # formatSize
    #
    # Returns an empty string if the specified value is negative and the value
    # itself in user-friendly format otherwise.
    #------------------------------------------------------------------------------
    method formatSize val {
        if {$val < 0} {
            return ""
        } elseif {$val < 1024} {
            return "$val bytes"
        } elseif {$val < 1048576} {
            return [format "%.1f KB" [expr {$val / 1024.0}]]
        } elseif {$val < 1073741824} {
            return [format "%.1f MB" [expr {$val / 1048576.0}]]
        } else {
            return [format "%.1f GB" [expr {$val / 1073741824.0}]]
        }
    }
    method sortingDone {data} {
        set items [$Tbl get 0 end]
        # move files last
        foreach item $items {
            if {[string range [lindex $item 0] 0 0] eq "F"} {
                #puts $item
                $Tbl move 0 end
            } else {
                break
            }
        }
        # move .. first
        set items [$Tbl get 0 end]
        set idx -1
        foreach item $items {
            incr idx
            if {[string range [lindex $item 0] 0 2] eq "D.."} {
                if {$idx != 0} {
                    $Tbl move $idx 0
                }
                break
            }
        }
        #puts "Done: $data"
    }
    #------------------------------------------------------------------------------
    # expandCmd
    #
    # Outputs the contents of the directory whose leaf name is displayed in the
    # first cell of the specified row of the tablelist widget tbl, as child items
    # of the one identified by row, and updates the image displayed in that cell.
    #------------------------------------------------------------------------------
    method expandCmd {tbl row} {
        if {[$tbl childcount $row] == 0} {
            set dir [$tbl rowattrib $row pathName]
            $self putContents $dir $tbl $row
        }
        
        if {[$tbl childcount $row] != 0} {
            $tbl cellconfigure $row,0 -image openFolderImg
        }
    }
    
    #------------------------------------------------------------------------------
    # collapseCmd
    #
    # Updates the image displayed in the first cell of the specified row of the
    # tablelist widget tbl.
    #------------------------------------------------------------------------------
    method collapseCmd {tbl row} {
        $tbl cellconfigure $row,0 -image clsdFolderImg
    }
    
    #------------------------------------------------------------------------------
    # putContentsOfSelFolder
    #
    # Outputs the contents of the selected folder into the tablelist widget tbl.
    #------------------------------------------------------------------------------
    method putContentsOfSelFolder tbl {
        set row [$tbl curselection]
        if {[$tbl hasrowattrib $row pathName]} {		;# directory item
            set dir [$tbl rowattrib $row pathName]
            if {[file isdirectory $dir] && [file readable $dir]} {
                if {[llength [glob -nocomplain -types {d f} -directory $dir *]]
                    == 0} {
                    bell
                } else {
                    $self putContents $dir $tbl root
                }
            } else {
                bell
                tk_messageBox -title "Error" -icon error -message \
                      "Cannot read directory \"[file nativename $dir]\""
                return ""
            }
        } else {
            bell
        }
    }
}
#' 
#' ## <a name='bindings'>WIDGET BINDINGS</a>
#'
#' The *dgw::sfilebrowser* widget provides a few useful key bindings to browse the current directory. Such as Up and Down keys to walk one entry up and down, 
#' Backspace, to switch to the parent directory, 
#' Ctrl-Start to go the the first and Ctrl-End to go to the last directory entry. 
#' Further if you type alphanumeric characters the selection moves to the entry starting with these characters.
#'
#' 
#' ## <a name='example'>EXAMPLE</a>
#'
#' ```
#'    wm title . DGApp
#'    option add *Tablelist.stripeBackground	#c4e8ff
#'    option add *Tablelist.setGrid		yes
#'    pack [dgw::sfilebrowser .fb] -side top -fill both -expand yes
#'    option add *Tablelist.stripeBackground	white
#'    option add *Tablelist.setGrid		no
#'    pack [text .text] -side top -fill both -expand yes
#'    pack [dgw::sfilebrowser .fb2 -treemode false] -side top -fill both -expand yes
#'    proc viewCmd {filename} {
#'        if {[regexp {(txt|tcl|html)$} $filename]} {
#'            if [catch {open $filename r} infh] {
#'                puts stderr "Cannot open $filename: $infh"
#'                exit
#'            } else {
#'                .text delete 1.0 end
#'                while {[gets $infh line] >= 0} {
#'                    .text insert end "$line\n"
#'                }
#'                close $infh
#'            }
#'        }
#'    }
#'    .fb2 configure -viewcmd viewCmd
#'    .fb2 browse /home/groth/workspace/detlef
#' ```
#'
#' ## <a name='install'>INSTALLATION</a>
#'
#' Installation is easy you can install and use the **dgw::sfilebrowser** package if you have a working install of:
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
#' $ wish __BASENAME__.tcl --code
#' ```
#'
#' ## <a name='docu'>DOCUMENTATION</a>
#'
#' The script contains embedded the documentation in Markdown format. To extract the documentation you should use the following command line:
#' 
#' ```
#' $ tclsh __BASENAME__.tcl --markdown
#' ```
#'
#' This will extract the embedded manual pages in standard Markdown format. You can as well use this markdown output directly to create html pages for the documentation by using the *--html* flag.
#' 
#' ```
#' $ tclsh __BASENAME__.tcl --html
#' ```
#' 
#' This will directly create a HTML page `__BASENAME__.html` which contains the formatted documentation. 
#' Github-Markdown can be extracted by using the *--man* switch:
#' 

#' ```
#' $ tclsh __BASENAME__.tcl --man
#' ```
#'
#' The output of this command can be used to feed a markdown processor for conversion into a 
#' man page, html or pdf document. If you have pandoc installed for instance, you could execute the following commands:
#'
#' ```
#' # man page
#' tclsh __BASENAME__.tcl --man | pandoc -s -f markdown -t man - > __BASENAME__.n
#' # html page
#' tclsh ../__BASENAME__.tcl --man > __BASENAME__.md
#' pandoc -i __BASENAME__.md -s -o __BASENAME__.html
#' # pdf
#' pandoc -i __BASENAME__.md -s -o __BASENAME__.tex
#' pdflatex __BASENAME__.tex
#' ```
#' 
#' ## <a name='see'>SEE ALSO</a>
#'
#' - [dgw - package homepage: http://chiselapp.com/user/dgroth/repository/tclcode/index](http://chiselapp.com/user/dgroth/repository/tclcode/index)
#' - [tablelist tutorial](https://www.nemethi.de/tablelist/tablelist.html) of Csaba Nemethi which formed the code basis for this widget
#'
#' ## <a name='todo'>TODO</a>
#'
#' * sorting folders first, then filenames
#' * more, real, tests
#' * github url for putting the code

#'
#' ## <a name='authors'>AUTHOR</a>
#'
#' The **__BASENAME__** widget was written by Detlef Groth, Schwielowsee, Germany. The code is mainly based on Csaba Nemethi's demo code for his tablelist widget.
#'
#' ## <a name='license'>LICENSE</a>
# LICENSE START
#' 
#' The widget __PKGNAME__, version __PKGVERSION__.
#'
#' Copyright (c) 
#' 
#'    * 2019  Dr. Detlef Groth, <detlef (at) dgroth(dot)de>
#' 
#' This library is free software; you can use, modify, and redistribute it
#' for any purpose, provided that existing copyright notices are retained
#' in all copies and that this notice is included verbatim in any
#' distributions.
#' 
#' This software is distributed WITHOUT ANY WARRANTY; without even the
#' implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#' 
# LICENSE END

if {[info exists argv0] && [info script] eq $argv0 && [regexp sfilebrowser $argv0]} {
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
        puts "\nThe ${dpath}::$pfile package provides a button toolbar with nice graphical buttons."
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
        puts "        --version : printing the package version to the terminal"
        puts ""
        puts "    The --man option can be used to generate the documentation pages as well with"
        puts "    a command like: "
        puts ""
        puts "    tclsh [file tail [info script]] --man | pandoc -t html -s > temp.html\n"
    }
}
