

/*OUTPUT TO xlsx SIMPLE SYNTAX*/
ods Excel file="dir\filename &sysdate..xlsx" ;
ods Excel OPTIONS(SHEET_INTERVAL="proc" SHEET_NAME="Tab Name" EMBEDDED_TITLES="yes");
/*code*/
ods Excel close;




/*OUTPUT MANY RESULTS ON THE SAME WORKSHEET*/
ods Excel file="&dir\output\ title &sysdate..xlsx" ;

/*CREATE WORKSHEET For a group of output on sheet 1*/
ods Excel OPTIONS(SHEET_INTERVAL="none" SHEET_NAME="Sheet1" EMBEDDED_TITLES="yes");
title "form1";
/*code*/

/*CREATE WORKSHEET For a group of output on sheet 2*/
ods Excel OPTIONS(SHEET_INTERVAL="now" SHEET_NAME="Sheet1" EMBEDDED_TITLES="yes");
title "form2";

/*...*/
ods Excel close;





/*OUTPUT TO xml SIMPLE SYNTAX*/
ods tagsets.ExcelXP file="dir\filename &sysdate..xml" ;
/*REPEAT THE FOLLOWING OPTION FOR EACH SHEET IN EXCEL*/
/*                          GROUP ON SAME SHEET  |NAME SHEET*/
ods tagsets.ExcelXP OPTIONS(SHEET_INTERVAL="proc" SHEET_NAME="Tab Name");
/*code*/
ods tagsets.ExcelXP close;


ods Excel file="dir\filename &sysdate..xlsx" ;
/*REPEAT THE FOLLOWING OPTION FOR EACH SHEET IN EXCEL*/
/*                          GROUP ON SAME SHEET  |NAME SHEET*/
ods Excel OPTIONS(SHEET_INTERVAL="none" SHEET_NAME="Tab Name");
/*code*/
ods Excel close;



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
ods Excel file="Q:\Nalaka Gooneratne\Memories2\DSMB\DSMB_2019_Spring\documents\output\ &site_name missing_data_adverse_events &sysdate..xlsx" ;
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
%WORKBOOK(JU, 16);

