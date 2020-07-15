/*SIMPLE MISSING DATA REPORT*/


/*TEMPLATE*/
title "VAR";
proc print data = DSN  noobs label;
    where missing (VAR) and FORM_complete ne . and branchingLOGIC;
	var KEY VAR ;
run;
















/*MACRO - PROC PRINT ON MISSING DATA*/
%macro WORKSHEET(dsn, var, missing);

/*CREATE EXCEL SHEET*/
ods Excel OPTIONS(SHEET_INTERVAL="proc" SHEET_NAME="&var");
proc print data= &dsn label;
    var subject_id site_code redcap_event_name REDCAP_REPEAT_INSTRUMENT REDCAP_REPEAT_INSTANCE &var;
    where &var = &missing;
run;
%mend;

/*ABOVE MACRO BY SITE*/
%macro WORKBOOK(site_name, site_number);
ods Excel file="dir\ &site_name missing_data_adverse_events &sysdate..xlsx" ;
data site_data;
    set derived.adverse_events;
	where site_code = &site_number;
run;
%WORKSHEET(site_data, subject_id, "");
%WORKSHEET(site_data, description_1, "");
%WORKSHEET(site_data, ae_comments_1, "");
%WORKSHEET(site_data, relationship_to_study_1, .);
%WORKSHEET(site_data, grade_1, .);
%WORKSHEET(site_data, serious_1, .);
%WORKSHEET(site_data, serious_event_type_1, .);
%WORKSHEET(site_data, outcome_1, .);
ods Excel close;
%mend;

/*CREATE EXCEL OF MISSING ADVERSE EVENTS DATA*/
%WORKBOOK(UP, 11);
%WORKBOOK(UT, 12);
%WORKBOOK(UV, 14);
%WORKBOOK(WU, 15);
/*%WORKBOOK(JU, 16);*/
