##-*- makefile -*-############################################################
#
#  Created By    : Dr. Detlef Groth
#  Created       : Tue Aug 24 08:52:58 2021
#  Last Modified : <210825.1118>
#
#  Description	 - Makefile for pandoc-tcl-filter
#
#  Copyright (c) 2021 Dr. Detlef Groth.
# 
##############################################################################

FILES=Makefile Readme.html Readme.md pandoc-tcl-filter.tcl mini.css LICENSE json-pretty.tcl


default:
	pandoc test.md -s --metadata title="test run with tcl filter" \
		-M date="`date "+%B %e, %Y %H:%M"`" \
		-o test.html --filter pandoc-tcl-filter.tcl --css mini.css

debug:
	pandoc -s -t json test.md > test.json 	
devel:	
	pandoc -s -t json test.md > test.json 	
	cat test.json | tclsh pandoc-tcl-filter.tcl | tclsh json-pretty.tcl
Readme.html : Readme.md mini.css
	pandoc Readme.md --metadata title="Readme pandoc-tcl-filter.tcl" \
		-M date="`date "+%B %e, %Y %H:%M"`" -s -o Readme.html \
		--filter pandoc-tcl-filter.tcl --css mini.css
github:
	for file in $(FILES) ; do cp -u $${file} ~/workspace/DGTcl/pandoc-tcl-filter/ ; done
