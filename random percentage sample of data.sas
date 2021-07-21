**************************************************************************
**************************************************************************
From: Rhodes, Joseph M <josephrh@nursing.upenn.edu> 
Sent: Monday, June 1, 2020 6:43 PM
To: Chittams, Jesse L. <chittams@nursing.upenn.edu>
Subject: Steve Moelter

Hi Jesse,

The imported data with no missing on logical_memory_iia_file is saved as derived.np
and is available in "Q:\Nalaka Gooneratne\Memories2\programs\Draft\Moelter_logical_memory_iia_file.sas".
Steve wants a list of subject id that is a random sample of 25% of this data.
I’ll forward his email.

Thank you,
Joseph

Sent from Mail for Windows 10
**************************************************************************
**************************************************************************;

/*GET TOTAL # OF OBSERVATIONS*/
proc contents data=dsn; run;
/*161 OBS*/
/*25% OF 161 IS 40.25 ROUNDED DOWN TO 40*/


/*USE N=40*/
/*OUTPUT IDS FOR RANDOM SAMPLE*/
proc surveyselect data=dsn  SEED=1892370417
   method=srs n=40 out=rs_ids;
run;
*QA check on the random sample;


/*RANDOM SAMPLE CREATE FLAG FOR ABOVE IDS*/
data temp;
set rs_ids;
checkrs = 1;
run;


/*MERGE IN RANDOM SAMPLE FLAG*/
data rs;
	merge dsn temp;
	by subject_id;
run;

/*CHECK IF PERCENTAGE IS CORRECT*/
proc freq data=rs;
table checkrs;
run;


/*SHARE OUTPUT WHERE checkrs=1*/
ods Excel file="dir\filename &sysdate..xlsx" ;
ods Excel OPTIONS(SHEET_INTERVAL="proc" SHEET_NAME="Tab Name" EMBEDDED_TITLES="yes");

proc print data=rs;
where checkrs=1;
title '25% Simple Random Sampling';
run;

ods Excel close;
