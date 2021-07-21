

proc contents data= sashelp.cars varnum;
run;


/*Make Model Type Origin DriveTrain MSRP */

/*OUTPUT MANY RESULTS ON THE SAME WORKSHEET*/
ods Excel file="C:\Users\josephrh\Downloads\demo &sysdate..xlsx" ;

/*CREATE WORKSHEET For a group of output on sheet 1*/
ods Excel OPTIONS(SHEET_INTERVAL="none" SHEET_NAME="Sheet1" EMBEDDED_TITLES="yes");
proc print data= sashelp.cars  (obs=5) noobs;
var Make;
run;

proc print data= sashelp.cars  (obs=5) noobs;
var Model;
run;



ods Excel OPTIONS(SHEET_INTERVAL="now" EMBEDDED_TITLES="yes");
title "";


/*CREATE WORKSHEET For a group of output on sheet 2*/
ods Excel OPTIONS(SHEET_INTERVAL="none" SHEET_NAME="Sheet3" EMBEDDED_TITLES="yes");
proc print data= sashelp.cars  (obs=5) noobs;
var Make;
run;

proc print data= sashelp.cars  (obs=5) noobs;
var Model;
run;

ods Excel OPTIONS(SHEET_INTERVAL="now" SHEET_NAME="Sheet4" EMBEDDED_TITLES="yes");

ods Excel close;

