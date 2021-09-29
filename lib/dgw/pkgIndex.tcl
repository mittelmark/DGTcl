# pkgIndex.tcl
# mandatory packages
package ifneeded dgw::dgw 0.6 [list source [file join $dir dgw.tcl]]
package ifneeded dgw 0.6 [list source [file join $dir dgw.tcl]]
package ifneeded dgw::basegui 0.2 [list source [file join $dir basegui.tcl]]
package ifneeded dgw::combobox 0.2 [list source [file join $dir combobox.tcl]]
package ifneeded dgw::dgwutils 0.3 [list source [file join $dir dgwutils.tcl]]
package ifneeded dgw::drawcanvas 0.1 [list source [file join $dir drawcanvas.tcl]]
package ifneeded dgw::sbuttonbar 0.6 [list source [file join $dir sbuttonbar.tcl]]
package ifneeded dgw::seditor 0.3 [list source [file join $dir seditor.tcl]]
package ifneeded dgw::sfinddialog 0.4 [list source [file join $dir sfinddialog.tcl]]
package ifneeded dgw::statusbar 0.2 [list source [file join $dir statusbar.tcl]]
package ifneeded dgw::tvmixins 0.3 [list source [file join $dir tvmixins.tcl]]
package ifneeded dgw::txmixins 0.2.0 [list source [file join $dir txmixins.tcl]]

# require tdbc::sqlite3
package ifneeded dgw::sqlview 0.6 [list source [file join $dir sqlview.tcl]]

# require tablelist::tablelist
package ifneeded dgw::sfilebrowser 0.2 [list source [file join $dir sfilebrowser.tcl]]
package ifneeded dgw::tablelist 0.2 [list source [file join $dir tablelist.tcl]]
package ifneeded dgw::tlistbox 0.2 [list source [file join $dir tlistbox.tcl]]

# require dgtools::shistory
package ifneeded dgw::hyperhelp 0.8.2 [list source [file join $dir hyperhelp.tcl]]

