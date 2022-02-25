---
title: "kroki4tcl - helpfile"
author: Detlef Groth
date: Tue Feb 22 16:35:52 2022
---

## Introduction

This is the helpfile for the package and application kroki4tcl.

The kroki webservice see [https://kroki.io/](https://kroki.io/) allows you to
create images on the kroki-server using textual description using various diagram tools without installing them.

kroki4tcl is a standalone command line application, provides as well a
graphical interface in a Tcl text editor and is as well a Tcl package.

If you read this file using the kroki-gui you can move your insert curser into
one of the code chunks and just press the "Save" button, on the right then the
image related to the diagram code should appear here an example. Move the
insertion cursor in the line after the first triple backticks and press Ctrl-s or press the save button.

```{.dot}
digraph G {
    node[shape=house,style=filled,fillcolor=skyblue];
    A -> B ;
}
```

You should see now on the right the image belonging to this code. Move the cursor to the next code chunk:

```{.ditaa}

+-------------------------------------------+      +-----------+ 
|   cPNK                                    |      |           |
|       Ditaa is here                       | ---> |   Good!   |
|                                           |      |    cEFE   |
+-------------------------------------------+      +-----------+
```

Just moving the cursor between the code chunks and then pressing Ctrl-s changed the image.
You can as well make changes to the images and after agin saving the file the image will be
updated.

Here an other example using PlantUML:

```{.puml}
@startmindmap
* item1
** item 1.1
** item 1.2
*** item 1.2.1
* item 2
** item 2.1
@endmindmap
```

You can that way switch very fast between the different images and update them.

## The GUI 

The application allows you to edit three types of text files

* Markdown files with extensions like .md, .Rmd, .Tmd, such as the file you are currently viewing where the code chunk properties indicate the diagram type  
* Text files with the txt extension where the comboox in the buttonbar indicates the diagram type
* diagram files where the extension indicates the diagram type

Most flexible is the Markdown format, you can have several code chunks in the same file

The buttonbar on top provides a combobox for selecting the diagram type if the current file you are editing is a text file. Right of it a standard buttons for file handling, such as New, Open, Savan and SaveAs. Next to it are two buttons which should

## Examples 

Below follow a few examples for every supported diagram type. 

ActDiag - see here: https://github.com/blockdiag/actdiag

```{.adia}
diagram {
  A -> B -> C;
  lane you {
    A; B;
  }
  lane me {
    C;
  }
}
```

BlockDiag - see here: https://github.com/blockdiag/blockdiag

```{.bdia}
diagram admin {
  top_page -> config -> config_edit -> config_confirm -> top_page;
  top_page[color = "#FF8888", textcolor="#FFFFFF"];
}
```

Ditaa - http://ditaa.sourceforge.net/

```{.ditaa}
    +--------+   +-------+    /-------\      sideway       
    | cEEF   | --+ ditaa +--> |       | ----------------+
    |  Text  |   +-------+    |diagram| -----\          |
    |Document|   |!magic!|    |       |      |          |
    |     {d}|   |  cGRE |    |   cPNK|      |          |
    +---+----+   +-------+    \-------/      V          |
        :                         ^       +-----+       |
        |       Lots of work      |       | ??? |  <----+
        \-------------------------/       +-----+
```

GraphViz - https://www.graphviz.org

```{.dot}
graph G {
   node[shape=box,style=filled,fillcolor=cornsilk];
   layout=neato;   
   a -- b -- c;
   d -- a; d -- b ;
}
```

ERD -  https://github.com/BurntSushi/erd

```{.erd}
[Person]
*name
height
weight
`birth date`
+birth_place_id

[`Birth Place`]
*id
`birth city`
'birth state'
"birth country"
Person *--1 `Birth Place`
```

Mermaid - https://github.com/mermaid-js/mermaid

```{.mmd}
graph TD;
	A{A} --> B(yes);
	A --> C;
	C --> D;
```

```{.ndia}
nwdiag {
  network dmz {
    address = "210.x.x.x/24"

    web01 [address = "210.x.x.1"];
    web02 [address = "210.x.x.2"];
  }
  network internal {
    address = "172.x.x.x/24";

    web01 [address = "172.x.x.1"];
    web02 [address = "172.x.x.2"];
    db01;
    db02;
  }
}
```

Nomnoml - [https://nomnoml.com/](https://nomnoml.com/):


```{.nml}
#stroke: black
#fill: #fee
[ Hello ]-[World!]
[Pirate|- eyeCount: Int|o raid();o pillage()|
  [beard]--[parrot]
  [beard]-:>[foul mouth]
]

```

Pikchr:

```{.pik}
box "Hello" fill skyblue ; arrow ;  box "World" fill salmon;
```

### PlantUML chunks

PlantUML - http://www.plantuml.com

```{.puml}
@startuml
Bob -> Alice : Hello
@enduml
```

Plantuml supports as well Ditaa:

```{.puml}
@startditaa
/-------\      /--------\ 
| cCEF  |      | cCEF   |
| Hello |----->| World! | 
|       |      |        | 
\-------/      \--------/
@enddita
```

and GraphViz:

```{.puml}
digraph G {
   rankdir=LR;
   node[shape=box,style=filled,fillcolor=skyblue];
   Hello -> "World!";
}
```

### SeqDia chunks

Here a SeqDia [http://blockdiag.com/en/seqdiag](http://blockdiag.com/en/seqdiag/index.html) example:

```{.sdia}
seqdiag {
  browser  -> webserver [label = "GET /index.html"];
  browser <-- webserver;
  browser  -> webserver [label = "POST /blog/comment"];
  webserver  -> database [label = "INSERT comment"];
  webserver <-- database;
  browser <-- webserver;
}
```

### Svgbob

And here the last diagram type Svgbob [https://ivanceras.github.io/svgbob/](https://ivanceras.github.io/svgbob/):

```{.sbob}
       .---.                      .-------.
      /-o-/--                      \       \       #
   .-/ / /->                   .----'       \     /
  ( *  \/                       \            '---'
   '-.  \                        \
      \ /                         \
       '                           V
.---------.                          .------------.
|  Hello  | *----> |-----> #------>  |  World {r1}| 
'---------'                          '------------'

      O     O 
   +--+--+--+
   |  |  #  |
   +--+--+--+
   #  |  |  |
   +--+--+--+
   |  |x |  |
   +--+--+--+
   |  |  |  |
   +--+--+--+


# Legend:
r1 = {
   fill: salmon;
}	

```


### Kroki Chunks

Another example which shows compatibility with the Kroki-filter of pandoc-tcl-filter where the generic chunk typer is kroki and the diagram type is indicated using the chunk option dia. Here an example:

```{.kroki dia="pik"}
box "Hello" ; arrow ; box "World";
```

## EOF

































