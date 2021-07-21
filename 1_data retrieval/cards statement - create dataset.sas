data dsn1;
input study_id $ trt;
cards;
1 1
2 0
3 0
4 1
;
run;


data dsn2;
input study_id $ trt;
cards;
2 .
4 .
;
run;

proc sort data= dsn1;by study_id;run;
proc sort data= dsn2;by study_id;run;

data even;
/*for dup vars the last data set overwites*/
merge  dsn2(in=a) dsn1;
by study_id;
if a ne 1 ;
run;

data even;
/*for dup vars the last data set overwites*/
set  dsn2(in=a) dsn1;
by study_id;
if a;
run;

proc print data=even;run;
