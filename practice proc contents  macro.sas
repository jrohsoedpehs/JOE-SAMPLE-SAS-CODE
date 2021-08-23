%LET NUMRX=2; 
* used to create dummy treatment groups *;

%MACRO LIBDATA; *change name to getcont*;
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

/* Create a macro variable for the total # of datasets */
IF LAST THEN CALL SYMPUT('TOTAL',LEFT(_N_));
RUN;

/* Replace this do loop with example code from later in article. */
%DO i=1 %TO &total;
DATA copyto.&&DS&I;
LENGTH ci prot ptid rxgrp 8. arxgrp $8.;
SET copyfrom.&&DS&I;
ci=9999;
prot=0001;
rxgrp=mod(ptid,&numrx)+1;
arxgrp=substr('AB',rxgrp,1);
RUN;
%END;
%MEND LIBDATA;

/* Call the macro */
%LIBDATA;
