/*SIMPLE PROC COMPARE*/


/*SORT BOTH DATASETS*/
proc sort data= work.dsn1;
    by id visit;
run;

proc sort data= work.dsn2;
    by id visit;
run;

/*COMPARE BY SORTED VARIABLES*/
proc compare base=work.dsn1 compare=work.dsn2;
    id id visit;
run;
