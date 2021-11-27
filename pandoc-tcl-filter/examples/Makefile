##-*- makefile -*-############################################################
#
#  Created By    : Detlef Groth
#  Created       : Fri Nov 26 17:28:19 2021
#  Last Modified : <211127.0737>
#
#  Description	 : Makefile for pandoc-tcl-filter examples
#
##############################################################################


default: example-dot.html \
	 example-mtex.html \
	 example-pik.html \
	 example-pic.html \
	 example-tcl.html \
	 example-tsvg.html

%.html: %.md ghpandoc.css
	pandoc -s -o temp.html -B header.html  --css ghpandoc.css \
		-M date="`date +"%b %d, %Y"`" \
		--filter pandoc-tcl-filter.tapp $<
	htmlark temp.html -o `basename $< .md`.html

