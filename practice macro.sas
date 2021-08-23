%LET NUMRX=2; 
* used to create dummy treatment groups *;

%MACRO LIBDATA;
/* Use as many libname statements as you like */
LIBNAME copyfrom '/original/rawdata/study999';
LIBNAME copyto '/test/testdata/study999';

/* Get contents for data sets (from one of the libraries), save result
in an output data set */
PROC CONTENTS DATA=copyfrom._ALL_ MEMTYPE=data
OUT=OUT NOPRINT;
RUN;
/* Sort prior to selecting unique data set names */
PROC SORT DATA=OUT;
BY MEMNAME NAME;
RUN;
/* Select unique data set names, remove unneeded datasets */
DATA A;
SET OUT;
BY MEMNAME NAME;
IF MEMNAME IN ('NORMDATA','NORMLAB','NORMLAB2')
THEN delete; * delete the datasets
you do not need *;
/* Because each variable in a data set produces an observation in
the output data set, we need to remove the duplicate
MEMNAMEs. */
IF FIRST.MEMNAME;
RUN;
/* Create data set names as macro variables & get total number of
data sets */
DATA _NULL_;
SET A END=LAST;
BY MEMNAME NAME;
/* Create a macro variable like DS1 with the value of
MEMNAME */
CALL SYMPUT('DS'|| LEFT(_N_),TRIM(MEMNAME));
SUGI 27 Coders' Corner
