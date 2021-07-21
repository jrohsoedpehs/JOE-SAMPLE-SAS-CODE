/*RUN THE THREE FOLLOWING FIRST*/
libname raw 'U:\Antonia Villaruel\data\Raw\NewData20151123\SAS Dataset';
footnote "SAS program stored: U:\Antonia Villaruel\programs\Draft\proc compare2015.sas"; 
options  fmtsearch=(raw);

/*Proc Compare begins here*/
/*CHECK FOR DUPLICATES	
  DUPOUT SHOWS WHAT WAS DELETED	
  OUT SHOWS WHAT WAS KEPT*/
proc sort data=raw.cuidalosJoe dupout=temp4 nodupkey out=temp1; 
	by staff_id year month day;
run;
proc sort data= raw.cuidalosOlek dupout=temp6 nodupkey out=temp5; 
	by staff_id year month day; 
run;

proc print data = temp4;
title "Joe's dups";
run;

proc print data = temp6;
title "Olek's dups";
run;

/*PREPARE DATASETS FOR COMPARE*/
proc sort data=raw.cuidalosJoe ; 
	by staff_id year month day;
run;

proc sort data= raw.cuidalosOlek; 
	by staff_id year month day; 
run;


ods rtf file="U:\Antonia Villaruel\documents\output\compare results &sysdate..rtf" style=journal;
title;
proc compare base=raw.cuidalosJoe(drop = record_id) compare=raw.cuidalosOlek(drop = record_id) nosummary outnoequal out=joe;  
	by staff_id year month day;
/*   with gr2;*/
	title 'Comparing joe and danielle data sets';
run;
ods rtf close;

data injnotd indnotj;
	merge raw.cuidalosOlek(in=d) raw.cuidalosJoe(in=j); /*in makes d and j dummy variables. d = 1 if the data is in the indnotj (Danielle's) data set and vice versa*/
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
