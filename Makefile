LOGFILE=log/test.txt
default:
	echo default
check:
	echo Ok
build:
	echo build
build-test:
	echo "#!/bin/bash" > $(LOGFILE)
	ls >> $(LOGFILE)
	echo "Operating System" >> $(LOGFILE)
	echo "parray tcl_platform" | tclsh >> $(LOGFILE)
	#echo "Tcl Version" >> $(LOGFILE)
	#echo "set tcl_patchLevel" | tclsh >> $(LOGFILE)
	#echo "tpack version" >> $(LOGFILE)
	#tclsh bin/tpack.tcl --version >> $(LOGFILE)
	#echo "this-is-test-end " >> $(LOGFILE)
pandoc-bin:	
	if [ -d pandoc-tapp ]; then rm -rf pandoc-tapp ; fi
	mkdir pandoc-tapp 
	cp pandoc-tcl-filter/pandoc-tcl-filter.tcl pandoc-tapp/
	if [ ! -d  pandoc-tapp/pandoc-tcl-filter.vfs ] ;  then mkdir  pandoc-tapp/pandoc-tcl-filter.vfs ; fi
	echo "lappend auto_path [file normalize [file join [file dirname [info script]] lib]]" > pandoc-tapp/pandoc-tcl-filter.vfs/main.tcl
	cp -r pandoc-tcl-filter/lib pandoc-tapp/pandoc-tcl-filter.vfs/
	rm -rf pandoc-tapp/pandoc-tcl-filter.vfs/lib/tclfilters
	if [ ! -d  pandoc-tapp/pandoc-tcl-filter.vfs/lib/tclfilters ] ;  then mkdir pandoc-tapp/pandoc-tcl-filter.vfs/lib/tclfilters ; fi	
	cp -r pandoc-tcl-filter/filter/*.tcl pandoc-tapp/pandoc-tcl-filter.vfs/lib/tclfilters/
	rm -f pandoc-tapp/pandoc-tcl-filter.vfs/lib/*/*~
	rm -f pandoc-tapp/pandoc-tcl-filter.vfs/lib/*/*.html
	rm -f pandoc-tapp/pandoc-tcl-filter.vfs/lib/*/*md
	rm -f pandoc-tapp/pandoc-tcl-filter.vfs/lib/*/*lua
	rm -f pandoc-tapp/pandoc-tcl-filter.vfs/lib/*/*.n	
	rm -f pandoc-tapp/pandoc-tcl-filter.vfs/lib/*/*.dot	
	cd pandoc-tapp && tclsh ../bin/tpack.tcl wrap pandoc-tcl-filter.tapp
	cp pandoc-tapp/pandoc-tcl-filter.tapp ../
	#rm -rf pandoc-tapp
