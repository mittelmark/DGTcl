##-*- makefile -*-############################################################
#
#  Created By    : Detlef Groth
#  Created       : Fri Nov 26 17:28:19 2021
#  Last Modified : <211126.1930>
#
#  Description	 : Makefile for pandoc-tcl-filter examples
#
##############################################################################


default:
	pandoc -o header.html header.md
	pandoc -s -o temp.html -B header.html  --css ghpandoc.css \
		--filter pandoc-tcl-filter.tapp example-dot.md
	htmlark temp.html -o example-dot.html 		 
	pandoc -s -o temp.html -B header.html  --css ghpandoc.css \
		--filter pandoc-tcl-filter.tapp example-pic.md
	htmlark temp.html -o example-pic.html 		 
	pandoc -s -o temp.html -B header.html  --css ghpandoc.css \
		--filter pandoc-tcl-filter.tapp example-pik.md
	htmlark temp.html -o example-pik.html 		 
	pandoc -s -o temp.html -B header.html  --css ghpandoc.css \
		--filter pandoc-tcl-filter.tapp example-mtex.md
	htmlark temp.html -o example-mtex.html 		 
	pandoc -s -o temp.html -B header.html  --css ghpandoc.css \
		--filter pandoc-tcl-filter.tapp example-tsvg.md
	htmlark temp.html -o example-tsvg.html 		 
	pandoc -s -o temp.html -B header.html  --css ghpandoc.css \
		--filter pandoc-tcl-filter.tapp example-tcl.md
	htmlark temp.html -o example-tcl.html 		 
