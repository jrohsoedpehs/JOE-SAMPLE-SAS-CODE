/*Nancy Cresse*/

libname raw "U:\Jesse Chittams\Nancy Cresse\dissertation\data\Raw";
libname derived "U:\Jesse Chittams\Nancy Cresse\dissertation\data\Derived";

footnote "U:\Jesse Chittams\Nancy Cresse\dissertation\programs\Draft\read_data";


/* 7/24/15*/

/*Import CSV dataset*/
PROC IMPORT OUT= RAW.read_data 
            DATAFILE= "U:\Jesse Chittams\Nancy Cresse\dissertation\data\
Raw\DNP ausc educat data.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;

/*8/4/15 -Joe test*/
PROC IMPORT OUT= RAW.READ_DATA2 
            DATAFILE= "U:\Jesse Chittams\Nancy Cresse\dissertation\data\
Raw\DNP ausc educat data new.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;


/*Basic Summary Stats*/


ods rtf file= "U:\Jesse Chittams\Nancy Cresse\dissertation\documents\Reports\Summary_Stats_&sysdate..rtf" style=journal;

proc contents data= raw.read_data2;
run;

proc means data= raw.read_data2 maxdec=2;
run;

proc freq data= raw.read_data2 (drop= AGE06 POSTST PRETST subjectID);
run;

ods rtf close;


/*8/4/15*/

/*create a variable (st_diff)that equals the difference between the pre and post test variables*/

data raw.read_data3;
	set raw.read_data2;
	st_diff= postst-pretst;
run;

/*QA for difference variable*/

proc print data=raw.read_data3;
	var pretst postst st_diff;
run;

/*Do a proc univariate and create a histogram on the difference variable, st_diff*/


PROC UNIVARIATE DATA = raw.read_data3 normal;
var st_diff;
HISTOGRAM st_diff / CFILL = ltgray;
INSET N = '' MEDIAN (8.2) QRANGE (8.2) MEAN (8.2) STD (8.3) MIN (8.2) MAX (8.2)
/ POSITION = NE;
RUN;

/*Do a Npar1way on continuous outcome (st_diff) and all categorical variables*/

%macro getmeans(var);
      proc means data=raw.read_data3 n mean std median q1 q3 qrange maxdec=2;
	  class &var;
      var st_diff pretst;
      title4 font=Calibri j=left height=14pt "Proc means: &var. variable";
      quit;
%mend;

/*Call*/
%getmeans(GENDR07);
%getmeans(ACADEM02);/*do npar1way with st_diff and pretst in var statement, kruskall wallis with no by statement*/
%getmeans(CRITCA04);
%getmeans(LICENS01);
%getmeans(GRDASS05);

data temp;
	set raw.read_data3;
array name (5) $ GENDR07 ACADEM02 CRITCA04 LICENS01 GRDASS05 ;
do i= 1 to 5;
%getmeans(name(i));
end;
run;
