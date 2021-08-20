## <a name='docu'>DOCUMENTATION</a>

The script contains embedded the documentation in Markdown format. To extract the documentation you should use the following command line:

```
$ tclsh __BASENAME__.tcl --markdown
```

This will extract the embedded manual pages in standard Markdown format. You can as well use this markdown output directly to create html pages for the documentation by using the *--html* flag.

```
$ tclsh __BASENAME__.tcl --html
```

If the tcllib Markdown package is installed, this will directly create a HTML page `__BASENAME__.html` 
which contains the formatted documentation. 

Github-Markdown can be extracted by using the *--man* switch:

```
$ tclsh __BASENAME__.tcl --man
```

The output of this command can be used to feed a Markdown processor for conversion into a 
html, docx or pdf document. If you have pandoc installed for instance, you could execute the following commands:

```
tclsh ../__BASENAME__.tcl --man > __BASENAME__.md
pandoc -i __BASENAME__.md -s -o __BASENAME__.html
pandoc -i __BASENAME__.md -s -o __BASENAME__.tex
pdflatex __BASENAME__.tex
```
