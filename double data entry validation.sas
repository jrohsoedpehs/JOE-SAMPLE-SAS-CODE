/*RUN THE THREE FOLLOWING FIRST*/
libname raw '';
footnote "SAS program stored: "; 
options  fmtsearch=(raw);

/*QA ON YEAR*/
title;
proc freq data= raw.cuidalos_joe; /*REMOVE YEAR 2013*/
	tables year;
	title"joe";
run;
title;
proc freq data= raw.cuidalos_danielle; 
	tables year;
	title"danielle";
run;
/*CREATES RTF FOR YEARS TO BE REMOVED FROM DATASET*/
/*ods rtf file="U:\Antonia Villaruel\documents\output\discrepancy report2 &sysdate..rtf" style=journal;*/
/*proc print data= raw.cuidalosaaronn; */
/*	by staff_id year month day;*/
/*	where year = 5;*/
/*run;*/
/*proc print data= raw.cuidalos_joen; */
/*	by staff_id year month day;*/
/*	where year = 1;*/
/*run;*/
/*ods rtf close;*/

/*CHECK FOR VARIABLES IN DATASET*/
/*proc contents data= raw.cuidalos_joe;*/
/*run;*/
/*proc contents data= raw.cuidalos_danielle;*/
/*run;*/
/*CREATE TOTAL (HOURS) VARIABLE FOR JOE'S DATA*/
data raw.cuidalos_joen;
	set raw.cuidalos_joe (drop=record_id hourotherspecifyactivity cuidalos_program_complete);
	Total2 = sum(hourtraining,houroutreach,hourrecruitment,hourface,hourphonemail,hourother); 
	label Total2= 'Total2';
run;
/*QA CHECK THAT TOTAL2 WAS CREATED AND IS THE SUM OF */
/*hourtraining,houroutreach,hourrecruitment,hourface,hourphonemail,hourother*/
Proc print data= raw.cuidalos_joen;
run;

/*CREATE TOTAL (HOURS) VARIABLE FOR DANIELLE'S DATA*/;
data raw.cuidalos_daniellen;
	set raw.cuidalos_danielle(drop=record_id hourotherspecifyactivity cuidalos_program_complete);
	Total2 = sum(hourtraining,houroutreach,hourrecruitment,hourface,hourphonemail,hourother);
	label Total2= 'Total';
run;
/*QA CHECK THAT TOTAL2 WAS CREATED AND IS THE SUM OF */
/*hourtraining,houroutreach,hourrecruitment,hourface,hourphonemail,hourother*/
proc print data= raw.cuidalos_daniellen; 
run;
/*CHECK FOR DUPLICATES*/
/*DUPOUT SHOWS WHAT WAS DELETED*/
/*OUT SHOWS WHAT WAS KEPT*/
proc sort data=raw.cuidalos_joe dupout=temp4 nodupkey out=temp1; 
	by staff_id year month day;
run;

proc sort data= raw.cuidalos_danielle dupout=temp6 nodupkey out=temp5; 
	by staff_id year month day; 
run;
/*CREATE RTF OF DELETED DUPLICATES*/
ods rtf file="U:\Antonia Villaruel\documents\output\duplicates &sysdate..rtf" style=journal;
title;
proc print data=temp4 noobs;
	var record_id staff_id year month day;
	title 'duplicates joe';
run;
title;
proc print data=temp6 noobs; 
	var record_id staff_id year month day;
	title 'duplicates danielle';
run;
ods rtf close;
/*PREPARE DATASETS FOR COMPARE*/
proc sort data=raw.cuidalos_joen ; 
	by staff_id year month day;
run;

proc sort data= raw.cuidalos_daniellen; 
	by staff_id year month day; 
run;
/*COMPARE DATASETS CREATES RTF*/
/*NOSUMMARY WILL ONLY DISPLAY DISCREPANCIES. NEVER COMPARE OPEN TEXT FIELDS*/
ods rtf file="U:\Antonia Villaruel\documents\output\compare results &sysdate..rtf" style=journal;
title;
proc compare base=raw.cuidalos_joen compare=raw.cuidalos_daniellen nosummary outnoequal out=joe;  
	by staff_id year month day;
/*   with gr2;*/
	title 'Comparing joe and danielle data sets';
run;
ods rtf close;
/*DIFFERENCES I DON'T UNDERSTAND HOW TO READ THIS*/
title;
proc print data=joe;
	title"Differences";
run;
/*CREATE RTF OF COMPARE*/
/*ods rtf file="U:\Antonia Villaruel\documents\output\discrepancy report &sysdate..rtf" style=journal;*/
/*proc compare base=raw.cuidalos_joen compare=raw.cuidalosaaronn nosummary outnoequal out=joe; /*nosummary will only display discrepancies. Never compare open text fields*/*/
/*   by staff_id year month day;*/
/*run;*/
/*ods rtf close;*/
/* In line 77, where is the data set unique? It's not unique at the patient level. You want to make sure that the two data sets 
are coming together in a way that links Danielle's data 
In other words, we need to keep the rows distinct based on a combination of columns that is unique. If the columns
are not unique, then the info in your rows will get mixed with other rows (it will become unlinked)*/;
data injnotd indnotj;
	merge raw.cuidalos_daniellen(in=d) raw.cuidalos_joen(in=j); /*in makes d and j dummy variables. d = 1 if the data is in the indnotj (Danielle's) data set and vice versa*/
  	by staff_id year month day;
	if d = 1 and j ne 1 then output indnotj;/*DANIELLE ENTERED, BUT JOE DID NOT*/
	if j = 1 and d ne 1 then output injnotd; /*JOE ENTERED, BUT DANIELLE DID NOT*/
run;
/*ARCHIVE THE ABOVE MERGE*/

/*CREATES RTF OF DATA THAT IS IN ONE SET BUT MISSING IN THE OTHER*/
ods rtf file="U:\Antonia Villaruel\documents\output\did not enter &sysdate..rtf" style=journal;
proc print data=indnotj noobs;
  var staff_id year month day;
  title 'These are time sheets that Joe did not enter';
run;
proc print noobs data=injnotd;
  var staff_id year month day;
  title 'These are time sheets that Daneille did not enter';
run;
ods rtf close;


