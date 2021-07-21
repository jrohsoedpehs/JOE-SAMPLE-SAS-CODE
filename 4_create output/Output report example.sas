libname raw "Q:\George Demiris\PISCES\data\Raw";
libname derived "Q:\George Demiris\PISCES\data\Derived";

footnote "SAS Program Stored in: Q:\George Demiris\PISCES\programs\Draft\Demographic Table for Tracking Report.sas";


/*FORMATS*/
options fmtsearch=(raw.pisces_formats);
options nofmterr;

proc format;
    value complete 
        1 = 'Complete'
        2 = 'Pending' 
        3 = 'Withdrew';
    value race
        0 = 'American Indian or Alaska Native'
        1 = 'Black/African American'
        2 = 'White/Caucasian' 
        3 = 'Asian American'    
        4 = 'Native Hawaiian or Other Pacific Islander'
        5 = 'Multi-Racial'
        6 = 'Other'
		88='Other/Decline to Answer'
       99 = 'Decline to answer';
run;   





proc contents data=raw.pisces ;run;

proc freq data=raw.pisces ;
tables redcap_event_name*caregiver_id_complete/list missing;
run;

proc freq data=derived.pisces ;
tables redcap_event_name survey_complete/list missing;
where redcap_event_name ="Consent Visit";
run;

data pisces;
set raw.pisces;

/*Create Race*/
number_of_races = sum(demog_race___0, demog_race___1, demog_race___2, demog_race___3, demog_race___4, demog_race___5, demog_race___6, demog_race___99);
if number_of_races > 1 then race = 5;
if number_of_races = 1 then race = 0*demog_race___0 + 1*demog_race___1 + 2*demog_race___2 + 3*demog_race___3 + 4*demog_race___4 + 5*demog_race___5 + 6*demog_race___6 + 99*demog_race___99;

/*race2:  combines other and decline to answer*/
race2=race;
if race in (99 6) then race2=88;

format race race2 race.;
run;


/*qa race2*/
proc freq data=pisces;tables race*race2/list missing;run;



proc freq data=pisces;
tables race*redcap_event_name/list missing;run;

proc means data=pisces n mean ;
var caregiver_id_complete;
class race  demog_ethnic demog_gender;
where caregiver_id_complete ne .;
output out=demog
n=demog_n;
run;

proc print data=demog_n;run;

proc freq data=pisces;
tables race2*demog_ethnic*demog_gender/list missing out=demog_ nopct;
/*output out=demog_;*/
where race ne .;
run;



ods rtf file=  "Q:\George Demiris\PISCES\documents\output\Demographic Table for Tracking Report  &sysdate..doc" style=journal;
title "Participant Counts by Race, Ethnicity and Gender";
proc print data=demog_;
run;
ods rtf close;


/*CHECK FREE TEXT FOR 'OTHER' RACE*/

proc print data=pisces;
var race demog_patient_race_text;
where race=6;
run;



/* ‚               0‚               0‚Hispanic                                ‚  */
/* ‚               1‚               1‚Non-Hispanic                            ‚  */
/* ‚              99‚              99‚Decline to answer */

/*               0‚               0‚Male                                    ‚  */
/* ‚               1‚               1‚Female                                  ‚  */
/* ‚              99‚              99‚Decline to answer         */

data his_male his_female his_decline nonhis_male nonhis_female nonhis_decline decline_male decline_female decline_decline;
set demog_;
if demog_ethnic=0 & demog_gender=0 then output his_male;
if demog_ethnic=0 & demog_gender=1 then output his_female;
if demog_ethnic=0 & demog_gender=99 then output his_decline;


if demog_ethnic=1 & demog_gender=0 then output nonhis_male;
if demog_ethnic=1 & demog_gender=1 then output nonhis_female;
if demog_ethnic=1 & demog_gender=99 then output nonhis_decline;

if demog_ethnic=99 & demog_gender=0 then output decline_male;
if demog_ethnic=99 & demog_gender=1 then output decline_female;
if demog_ethnic=99 & demog_gender=99 then output decline_decline;
run;

proc contents data=his_male;run;

proc sort data=	his_male	; by race2;run;
proc sort data=	his_female	; by race2;run;
proc sort data=	his_decline	; by race2;run;
proc sort data=	nonhis_male	; by race2;run;
proc sort data=	nonhis_female	; by race2;run;
proc sort data=	nonhis_decline	; by race2;run;
proc sort data=	decline_male	; by race2;run;
proc sort data=	decline_female	; by race2;run;
proc sort data=	decline_decline	; by race2;run;


data tracking_table;
retain race2 nonhis_female nonhis_male nonhis_decline his_female his_male his_decline decline_female decline_male decline_decline;
merge 
his_male	(rename=( count=	his_male	) drop=demog_ethnic demog_gender percent)
his_female	(rename=( count=	his_female	) drop=demog_ethnic demog_gender percent)
his_decline	(rename=( count=	his_decline	) drop=demog_ethnic demog_gender percent)
nonhis_male	(rename=( count=	nonhis_male	) drop=demog_ethnic demog_gender percent)
nonhis_female	(rename=( count=	nonhis_female	) drop=demog_ethnic demog_gender percent)
nonhis_decline	(rename=( count=	nonhis_decline	) drop=demog_ethnic demog_gender percent)
decline_male	(rename=( count=	decline_male	) drop=demog_ethnic demog_gender percent)
decline_female	(rename=( count=	decline_female	) drop=demog_ethnic demog_gender percent)
decline_decline	(rename=( count=	decline_decline	) drop=demog_ethnic demog_gender percent)

;
by race2;

array vars (*) his_male his_female his_decline nonhis_male nonhis_female nonhis_decline decline_male decline_female decline_decline;
do i=1 to dim(vars);
if vars(i)=. then vars(i)=0;
end;

drop i;
run;





/*OUTPUT TO xlsx SIMPLE SYNTAX*/
ods Excel file="Q:\George Demiris\PISCES\documents\output\Progress Report &sysdate..xlsx" ;
ods Excel OPTIONS(SHEET_INTERVAL="proc" SHEET_NAME="Tab Name" EMBEDDED_TITLES="yes");

/*options orientation=landscape;*/
/*ods rtf file="Q:\George Demiris\PISCES\documents\output\Demographic Table for Tracking Report  &sysdate..doc" ;*/


title "Demographic Table for Tracking Report";
proc print data=tracking_table label;
label	his_male	=	"	Hispanic or Latino - Male	"	;
label	his_female	=	"	Hispanic or Latino - Female	"	;
label	his_decline	=	"	Hispanic or Latino -  Unknown Gender	"	;
label	nonhis_male	=	"	Not Hispanic or Latino - Male	"	;
label	nonhis_female	=	"	Not Hispanic or Latino - Female	"	;
label	nonhis_decline	=	"	Not Hispanic or Latino -  Unknown Gender	"	;
label	decline_male	=	"	Unknown Ethnicity - Male	"	;
label	decline_female	=	"	Unknown Ethnicity - Female	"	;
label	decline_decline	=	"	Unknown Ethnicity - Unknown Gender	"	;

run;


proc freq data=pisces;
tables race*demog_ethnic*demog_gender/list missing out=demog_ nopct;
/*output out=demog_;*/
where race ne .;
run;

title"Race Free Text for Participants who Responded 'Other Race'";
proc print data=pisces;
var race demog_patient_race_text;
where race=6;
run;

/*ods rtf close;*/
ods Excel close;

proc export data=tracking_table
outfile="Q:\George Demiris\PISCES\documents\output\Demographic Table for Tracking Report  &sysdate..xlsx" 
dbms=xlsx
 replace;
run;

