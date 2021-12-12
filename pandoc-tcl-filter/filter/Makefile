
filter-docs: filter-abc.html \
	filter-dot.html \
	 filter-eqn.html \
	 filter-mmd.html \
 	 filter-mtex.html \
	 filter-pic.html \
	 filter-pik.html \
 	 filter-puml.html \
	 filter-rplot.html 

%.html: %.tcl mini.css
	pandoc header.md -o header.html
	pandoc-tcl-filter.tapp $< temp.html -s -B header.html  --css mini.css \
		-M date="`date +"%b %d, %Y"`" 
	htmlark temp.html -o `basename $< .tcl`.html
