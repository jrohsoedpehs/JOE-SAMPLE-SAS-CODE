/* SAS functionality for scheduling. */
/*Analysts have several options for scheduling their work to be run on a regular basis, */
/*whether it’s daily, weekly, monthly or otherwise.*/
/*"Q:\SAMPLE_SAS_PROGRAM\JOE-SAMPLE-SAS-CODE\documents\Four ways to schedule SAS tasks - SAS Users Groups.pdf"*/


/*Create RTF for each proc seperately*/
ods rtf file="Q:\SAMPLE_SAS_PROGRAM\JOE-SAMPLE-SAS-CODE\Schedule a SAS program\proc contents sashelp_cars &sysdate..doc" style=journal;
proc contents data=sashelp.cars;
title "sashelp.cars";
run;
ods rtf close;
