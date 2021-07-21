/*WORD DOCUMENT*/

/*Log will lose its color*/
/*USE notepad++ to view the rtf with sas colors*/
/*proc printto log = "dir\output\title_log &sysdate..doc";run;*/



/*Print log to an Excel Sheet*/

/*ADD immediately above creating the excel file*/
filename test "K:\SAS\logs\log.log";
/*new CLEARS THE LOG INSTEAD OF APPENDING*/
proc printto log=test new; run;


/*Excel output*/
/*ON ITS ON EXCEL SHEET, AFTER OPTIONS, ADD*/
/*Other excel sheets*/

proc printto;run;
proc document name=mydoc(write);
/*IMPORTS THE LOG FILE TEST INTO THE CURRENT EXCEL SHEET*/
	import textfile=test to logfile;run; 
/*	replay lets the log display in the results viewer - comment out for large logs*/
	replay;
    run;
quit;







/*Excel - sample*/
filename test "Q:\Jesse Chittams\admin\Joseph Rhodes\Notes\SAS\Experience\documents\output\log.log";
proc printto log=test new;
run;


ODS excel file="Q:\Jesse Chittams\admin\Joseph Rhodes\Notes\SAS\Experience\documents\log.xlsx";
ods Excel OPTIONS(SHEET_INTERVAL="proc" SHEET_NAME="Sheet1" EMBEDDED_TITLES="yes");

/*CODE*/

ods Excel OPTIONS(SHEET_INTERVAL="now" SHEET_NAME="log" EMBEDDED_TITLES="yes");
proc printto;run;
proc document name=mydoc(write);
	import textfile=test to logfile;run; 
	replay;run;
quit;
ODS excel close;




/*Excel - no borders on log output*/
filename test "%sysfunc(pathname(WORK))\log.log";
proc printto log=test new; run;
data T; run;
proc printto;run;

ODS excel file="%sysfunc(pathname(WORK))\test.xlsx" options(sheet_interval="none");
data  _null_;
  if _n_ = 1 then do;
    declare odsout ODS();
  end;   infile "%sysfunc(pathname(WORK))\log.log";  input;
  ODS.format_text(data: _infile_); 
run;
ODS excel close;




