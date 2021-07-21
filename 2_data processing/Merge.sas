/*MERGE 2 DATASETS*/
/*DETERMINE 1-1, 1-MANY, MANY-MANY*/
/*0. Check for missing data in key fields and give common variable type and format (use numeric if possible)*/
/*1. CHECK FOR DUPLICATES ON KEY FIELDS*/
/*2. REMOVE DUPLICATES and CREATE KEY FIELDS*/
/*3. SORT CLEANED DATASETS*/
/*4. MERGE ON KEY FIELDS*/
/*5. QA - CHECK FOR ITEMS IN ONE DATASET BUT NOT THE OTHER*/

/*0. Check for missing data in key fields and give common variable type and format (use numeric if possible)*/


/*1. CHECK FOR DUPLICATES*/
proc sort data=followup_survey ;
by study_id visit;
run;

data duplicates;
	set followup_survey;
    by study_id visit;
	if first.visit ne last.visit or first.visit= 0 and last.visit=0;
run;
/*All fields are duplicates - first.visit ne last.visit*/
/*Key fields are duplicates - first.visit= 0 and last.visit=0*/

/*2. REMOVE DUPLICATES and CREATE KEY FIELDS*/
/*code*/


/*3. SORT CLEANED DATASETS*/
proc sort data=raw.form1 ;
   by KEYFIELDS;
run;


proc sort data=raw.form2 ;
   by KEYFIELDS;
run;

/*4. MERGE*/
data DSN;
   merge raw.form1  raw.form2;
/*This variable must exist in both data sets with same name and format (char or num) and makes an obs (row) unique*/
   by KEYFIELDS; 
run;


/*5. QA - CHECK FOR ITEMS IN ONE DATASET BUT NOT THE OTHER*/
data injnotd indnotj;
	merge raw.demnov2015_may2016(in=d) raw.joenov2015_may2016(in=j); /*in makes d and j dummy variables. d = 1 if the data is in the indnotj (Danielle's) data set and vice versa*/
  	by staff_id year month day KEYFIELDS;
	if d = 1 and j ne 1 then output indnotj;/*DANIELLE ENTERED, BUT JOE DID NOT*/
	if j = 1 and d ne 1 then output injnotd; /*JOE ENTERED, BUT DANIELLE DID NOT*/
run;
