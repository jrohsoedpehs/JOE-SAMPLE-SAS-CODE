/* Preparatory Work
If you walk into a project and there is no SOP (standard operating procedures ie. The standard subdirectory) 
then add yours (give it structure)

Create a header using PI’s instructions to get oriented
Run the library*/
libname name 'directory path';

/*ADD LIBNAME*/
libname raw 'U:\Scott Trerotola\Dan DePietro\SIR_STUDY\data\Raw';

/*ADD FOOTNOTES*/
footnote "SAS program stored: directory path\title.sas";

/*USE SAVED FORMATS*/
OPTIONS FMTSEARCH=(LIBRARYNAME);

/*CREATE AN RTF FILE*/

/*CALL IN ANOTHER PROGRAM*/
