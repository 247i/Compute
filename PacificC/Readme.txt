Getting Started:

The only program you have to run is PPD. This is the
integrated development environment.

Pacific C is invoked by the PPD command. Options to the
PPD command are:

	/screen:25
	/screen:28
	/screen:43
	/screen:50

These options set the DOS screen size to the specified number
of lines. A VGA or better display is needed for 50 lines, an
EGA or better for the others.

PPD will also take a file name, which may be a project file
name or a source file name. For example:

ppd /screen:43 testing

will start up PPD in 43 line mode, and look for a file TESTING.PRJ
or a file TESTING.C. A project file will be loaded, and a source
file will be loaded into the editor.

From within PPD you can load files into the editor with the File
menu. To create a project, that allows you to save source file names
and compile options in a project file, use the Make/New project command.

When you create a project, you will be prompted to fill in dialog boxes
with compiler options, then a source file list. Enter in the source file
list the names of all the source (.C) files you want to be compiled
and linked together. Assembler (.AS) files may also go here.

You can edit the options and the source file list from the Make,
Compile and Options menus.

To compile a single file from the editor window, use the Compile menu
or the F3 key. To "make" a project, which may involve compiling several
files and linking them, use the Make menu or the F5 key.

Explore the other menus (not forgetting the system menu that looks like
<<>> on the left hand side) to discover other features of
HI-TECH Software's Pacific C compiler.

HI-TECH Software also makes a range of C cross compilers for embedded
systems which are sold as full commercial products. Contact us for
more information.

HI-TECH Software
PO Box 103, Alderley
QLD 4051 Australia.

Phone +61 7 3552 7777
Fax   +61 7 3552 7778

Web:   http://www.htsoft.com
Email: hitech@htsoft.com
Ftp:   ftp.htsoft.com


Pacific C for MS-DOS, v7.51

                            Freeware Version

       1.  Pacific C for MS-DOS

            Welcome to Pacific C, HI-TECH Software's low cost, high
       performance  ANSI C compiler for MS-DOS.  Pacific C combines
       most of the features and power of the version  7  HI-TECH  C
       Cross  Compilers  into  a compact, easy to use package which
       will run on just about any MS-DOS based personal computer.

       This is the Freeware Version of Pacific C;  you may copy and
       redistribute this software, providing it remains in the same
       self-extracting .EXE file.

       2.  Quick Start

            To access the Pacific C compiler, you  need  only  know
       one  command;  PPD.  To help you get  started,  many  useful 
       Pacific C examples are available  in  a  subdirectory called 
       EXAMPLES.

            PPD is the integrated version of the compiler.  You can
       use  PPD  to  create  and  modify your source files, compile
       them, handle errors, and manage multiple file projects.  PPD
       also provides an on-line C library reference.


            EXAMPLES is a subdirectory within the compiler  instal-
       lation  which  contains  several example programs and utili-
       ties.  See the READ.ME file in EXAMPLES  for  more  details.
       If  you start PPD inside this directory, an extra menu entry
       "Pacific C Examples" will be available in the "Help" menu.

       3.  MS-DOS Environment Variables

            In order for Pacific C to work correctly, it is  neces-
       sary  for  the  compiler BIN subdirectory to be available in
       the PATH.  If required, you will need to modify or create  a
       suitable  PATH  statement  in AUTOEXEC.BAT.  For example, if
       the compiler were installed in the directory  C:\PACIFIC  it
       would  be  necessary to include C:\PACIFIC\BIN\ in the path.
       For installations under MS-DOS versions prior to  3.10,  the
       environment  variable  PCC_DOS should be set to point to the
       compiler installation directory.  For DOS versions 3.10  and
       higher,  no environment variables other than PATH are neces-
       sary.

            The compiler will automatically use a directory  speci-
       fied by the TEMP environment variable for scratch files.  If        
       TEMP is not set, the current directory will be used.

       CONTACT DETAILS:
       
        E-mail: hitech@htsoft.com
        Phone: +61 7 3552 7777
        Fax  : +61 7 3552 7778
       
       Postal:
        PO Box 103, Alderley
        QLD 4051 Australia

 http://www.htsoft.com or by ftp 
       from ftp.htsoft.com.
