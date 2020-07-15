libname raw "\\nursing.upenn.edu\Data\SonShare\Secured Folders\Research Statistics\Mark Fogel\R01 Nov2014\data\Raw\CBFII";
libname derived " ";
footnote "SAS Program Stored in: \\nursing.upenn.edu\Data\SonShare\Secured Folders\Research Statistics\Mark Fogel\R01 Nov2014\programs\Draft\CBFII_DDE";
options fmtsearch=(raw);

/***************************************
Prepare Nov2015 to May2016 Data
Check that the data is accurate
export labels from REDCap
Delete the name field

***************************************/


/*Proc Compare begins here*/

/*
datasets
joenov2015_may2016
demnov2015_may2016
*/



/*
PREPARE DATASETS FOR COMPARE

CHECK FOR DUPLICATES	
DUPOUT SHOWS WHAT WAS DELETED	
OUT SHOWS WHAT WAS KEPT
*/

proc sort data=raw.joenov2015_may2016 dupout=temp4 nodupkey out=temp1; 
	by staff_id year month day;
run;
proc sort data= raw.demnov2015_may2016 dupout=temp6 nodupkey out=temp5; 
	by staff_id year month day; 
run;

proc print data = temp4;
title "Joe's dups";
run;

proc print data = temp6;
title "Demola's dups";
run;

/*continue after there are no duplicates*/
proc sort data=raw.joenov2015_may2016; 
	by staff_id year month day;
run;
proc sort data= raw.demnov2015_may2016; 
	by staff_id year month day; 
run;



/*
Proc Compare

On the base dataset, Use (drop =  to exclude free text fields and other variables
from proc compare
*/

ods rtf file="U:\Antonia Villaruel\documents\output\Nov2015_May2016_Proc_Compare &sysdate..doc" style=journal;
options orientation = landscape;
title;
proc compare base=raw.joenov2015_may2016(drop = record_id studysite hourotherspecifyactivity) compare=raw.demnov2015_may2016(drop = record_id) nosummary outnoequal out=joe;  
	by staff_id year month day;
/*   with gr2;*/
	title 'Nov2015_May2016_Proc_Compare';
run;
ods rtf close;


/*Check for data that is in one set but not the other*/

data injnotd indnotj;
	merge raw.demnov2015_may2016(in=d) raw.joenov2015_may2016(in=j); /*in makes d and j dummy variables. d = 1 if the data is in the indnotj (Danielle's) data set and vice versa*/
  	by staff_id year month day;
	if d = 1 and j ne 1 then output indnotj;/*DANIELLE ENTERED, BUT JOE DID NOT*/
	if j = 1 and d ne 1 then output injnotd; /*JOE ENTERED, BUT DANIELLE DID NOT*/
run;
/*ARCHIVE THE ABOVE MERGE*/

/*CREATES RTF OF DATA THAT IS IN ONE SET BUT MISSING IN THE OTHER*/
ods rtf file="U:\Antonia Villaruel\documents\output\did not enter &sysdate..doc" style=journal;
proc print data=indnotj noobs;
  var staff_id year month day;
  title 'These are time sheets that Joe did not enter';
run;
proc print noobs data=injnotd;
  var staff_id year month day;
  title 'These are time sheets that Demola did not enter';
run;
ods rtf close;


