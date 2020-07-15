/*QA - Show all duplicates in a cross-sectional dataset*/
proc sort data=followup_survey ;
by study_id;
run;

data duplicates;
	set followup_survey;
	by study_id;
	if first.study_id ne last.study_id  or first.study_id= 0 and last.study_id=0;
run;
/*All fields are duplicates - first.visit ne last.visit*/
/*Key fields are duplicates - first.visit= 0 and last.visit=0*/


/*QA - Show all duplicates in a longitudinal dataset*/
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
