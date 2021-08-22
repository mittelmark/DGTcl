##-*- makefile -*-############################################################
#  Created By    : Dr. Detlef Groth
#  Created       : Fri Aug 20 08:46:11 2021
#  Last Modified : <210822.0703>
#
#  Description	
#
#  Notes
#
#  History
#	
#  $Log$
#
##############################################################################
#
#  Copyright (c) 2021 Dr. Detlef Groth.
# 
##############################################################################

DGWPACKAGES=dgw basegui combobox dgwutils drawcanvas hyperhelp sbuttonbar seditor sfilebrowser sfinddialog sqlview statusbar tablelist tlistbox tvmixins txmixins
pkg=dgw
tclsh=~/tcl8.7/bin/tclsh8.7
# tclsh=tclsh
header:
	-rm header.md
	for file in $(DGWPACKAGES) ; do [[ "dgwutils" != "$${file}" ]] && echo -e "[$${file}]($${file}.html) - " >> header.md ; done
	perl -i -pe 's/(.+txmixins.+) -/$$1/' header.md
doc:  
	$(tclsh) ../dgtools/autoPather.tcl .. ../mkdoc/mkdoc.tcl $(pkg).tcl temp.md
	cat header.md temp.md > $(pkg).md
	$(tclsh) ../dgtools/autoPather.tcl .. ../mkdoc/mkdoc.tcl $(pkg).md $(pkg).html
	#$(tclsh) ../dgtools/autoPather.tcl .. $(pkg).tcl --man | pandoc -s -f markdown -t man  - > dgw_$(pkg).n
dgw: header
	for file in $(DGWPACKAGES) ; do make --no-print-directory $${file}.md $${file}.html ; done
	-rm temp.md
demos:
	for file in $(DGWPACKAGES) ; do $(tclsh) ../dgtools/autoPather.tcl .. $${file}.tcl --demo ; done 		
%.md: %.tcl
	$(tclsh) ../dgtools/autoPather.tcl .. ../mkdoc/mkdoc.tcl $<  temp.md
	cat header.md temp.md > `basename $< .tcl`.md
	-rm temp.md
%.html: %.md %.tcl
	$(tclsh) ../dgtools/autoPather.tcl .. ../mkdoc/mkdoc.tcl `basename $< .md`.md `basename $< .md`.html

