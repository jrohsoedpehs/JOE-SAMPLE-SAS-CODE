/*BASIC SUMMARY STATS TO CHECK DATA QUALITY*/

proc contents data= sashelp.cars out=contents;
run;

proc print data= contents;
var NAME TYPE FORMAT;
run;

proc means data= sashelp.cars maxdec=2 n nmiss min median max mean std;
var Horsepower;
run;

proc freq data= sashelp.cars;
tables Origin / nocum;
run;


/*SHORTCUTS*/
proc means data= sashelp.cars maxdec=2 n nmiss min median max mean std;
/*    var  ;*/
run;

proc freq data= sashelp.cars;
    tables _character_;
run;

/*Use this code for by statements*/
proc sort data= dsn;
   by variable;
run;
