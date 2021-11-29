##-*- makefile -*-############################################################
#
#  Created By    : Detlef Groth
#  Created       : Fri Nov 26 17:28:19 2021
#  Last Modified : <211129.1945>
#
#  Description	 : Makefile for pandoc-tcl-filter examples
#
##############################################################################


default: example-dot.html \
	 example-mtex.html \
	 example-pik.html \
	 example-pic.html \
	 example-tcl.html \
	 example-tsvg.html \
	 example-rplot.html 

%.html: %.md ghpandoc.css
	pandoc header.md -o header.html
	pandoc -s -o temp.html -B header.html  --css ghpandoc.css \
		-M date="`date +"%b %d, %Y"`" \
		--filter pandoc-tcl-filter.tapp $<
	htmlark temp.html -o `basename $< .md`.html

