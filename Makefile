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
	echo "Tcl Version" >> $(LOGFILE)
	echo "set tcl_patchLevel" | tclsh >> $(LOGFILE)
	echo "tpack version" >> $(LOGFILE)
	tclsh bin/tpack.tcl --version >> $(LOGFILE)
	echo "this-is-test-end " >> $(LOGFILE)
