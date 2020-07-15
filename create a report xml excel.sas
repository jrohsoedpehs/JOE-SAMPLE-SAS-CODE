
/* YOU SHOULD BE ABLE TO PULL UP THIS SAS PROGRAM AND PUSH SUBMIT AND A NEW REPORT WILL BE GENERATED FOR YOU
IN THE FOLLOWING SUBDIRECTORY: Q:\Kathy Richards\NARLS_2017\weekly_reports\documents\ 
CALLED: "TABLE REPORT" WITH THE DATE IT WAS GENERATED. 

THERE ARE ALSO COMMENTS THROUGHOUT THE CODE FOR SOMEONE WHO READS SAS AND WANTS TO
KNOW WHAT EACH COMAND IS DOING*/


/*TELL SAS THE DIRECTORY PATH THAT WE ARE WORKING IN */
libname raw "Q:\Kathy Richards\NARLS_2017\weekly_reports\data\Raw";
libname derived "Q:\Kathy Richards\NARLS_2017\weekly_reports\data\derived";
libname library "Q:\Kathy Richards\NARLS_2017\weekly_reports\data\Raw";

/*BRINGS IN PRE-DETERMINED FORMATS FOR THE DATA SETS*/
proc format library = library.baselineformats; run;
proc format library = library.cmaiformats; run;
proc format library = library.labcorp_metadataformats; run;
proc format library = library.rnkformats; run;
proc format library = library.rnraformats; run;
proc format library = library.screeningformats; run;
options fmtsearch = (library.baselineformats library.cmaiformats library.labcorp_metadataformats library.rnkformats library.rnraformats library.screeningformats work);
run;


/*PUTS A FOOTNOTE ON THE OUTPUT THAT ALLOWS US TO TRACE THE OUTPUT BACK TO THE PROGRAM THAT CREATED IT*/
footnote "Q:\Kathy Richards\NARLS_2017\weekly_reports\Generating_table_code";

/*FIXES ALL OF THE RESIDENT ID IN THE DATA SETS TO LOWERCASE FOR CONSISTENCY*/
data raw.screening;
	length redcap_event_name $500;
	set raw.screening;
	resident_id = lowcase(resident_id);
	label redcap_event_name = "Event Name";
run;
data raw.baseline;
	set raw.baseline;
	resident_id = lowcase(resident_id);
run;
data raw.cmai_direct_obs;
	set raw.cmai_direct_obs;
	resident_id = lowcase(resident_id);
run;
data raw.labcorp_metadata ;
	length redcap_event_name $500;
	set raw.labcorp_metadata ;
	resident_id = lowcase(resident_id);
	label redcap_event_name = "Event Name";
run;
data raw.rnrahc_actigraphy;
	set raw.rnrahc_actigraphy;
	resident_id = lowcase(resident_id);
run;
data raw.RNK_Physical (drop =exam_phase);
	length redcap_event_name $500;
	set raw.RNK_Physical;
	resident_id = lowcase(resident_id);

		 if exam_phase = 2 then redcap_event_name = "Physical Exam and AE Assessment";
	else if exam_phase = 1 then redcap_event_name = "Minus 8 week AE History";
	else if exam_phase = 3 then redcap_event_name = 'RN Daily Assessment';
	else if exam_phase = 4 then redcap_event_name ='+2 week AE Assessment'; 
	else if exam_phase = 5 then redcap_event_name ='+8 week AE Assessment';
	else if exam_phase = 6 then redcap_event_name ='+16 week AE Assessment';
	label redcap_event_name = "Event Name";
run;


/*******************************************************************************************

		TRANSPOSES ALL OF THE DATA SETS IN ORDER TO SET THEM ON TOP OF EACHOTHER

********************************************************************************************/
*SCREENING DATA SET;
proc sort data = raw.screening nodupkey out=temp; 
	by resident_ID ;
run;
Proc transpose data =raw.screening out=derived.screening name=name label=label;
	by resident_id ;
	var pass_1st_phase age_55_89 swallow_med ambulation night_agitation hemodialysis med_stable 
		med_change acute_illness acute_illness_symptoms___1 acute_illness_symptoms___2 acute_illness_symptoms___3 
		acute_illness_symptoms___4 acute_illness_symptoms___999 rescreen_later second_phaseyn diagnosis_alzheimer 
		date_diagnosis diagnosis_other_binary diagnosis_other diagnosis_other_other rls_treatment_binary diagnose_rls 
		opioids_binary opioids tremors_binary tremors notice_tremor receive_gen gabapentin_failure psychosis alcohol_binary 
		alcohol other_study_binary other_study_name date_other_study suicide_risk history_creatinine_passyn creatinine_value 
		pass_cdr cdr_calc ;
run;
*BASELINE DATA SET;
proc sort data = raw.baseline nodupkey out=temp;
	by resident_ID REDCAP_event_name;
run;
Proc transpose data =raw.baseline out=derived.baseline name=name label=label;
	by resident_id REDCAP_event_name;
	var cstotal bitrl_clinical_score cmai_total_alloptions night_sleep_length ;
run;
*CMAI DIRECT OBS DATA SET;
proc sort data = raw.cmai_direct_obs nodupkey out=temp;
	by resident_ID redcap_event_name;
run;
Proc transpose data =raw.cmai_direct_obs out=derived.cmai_direct_obs name=name label=label;
	by resident_id REDCAP_event_name;
	var cmai_total_bl cmai_total_bl_day1 cmai_total_w2_day2 ;
run;
*LABCORP METADATA;
proc sort data = raw.labcorp_metadata nodupkey out=temp;
	by resident_ID ;
run;
Proc transpose data =raw.labcorp_metadata out=derived.labcorp_metadata name=name label=label;
	by resident_id ;
	var baseline_creatinine_passyn creatinine_number1 ;
run;
*RNRA HC ACTIGRAPHY DATA SET;
proc sort data = raw.rnrahc_actigraphy nodupkey out=temp;
	by resident_ID redcap_event_name;
run;
Proc transpose data =raw.rnrahc_actigraphy out=derived.rnrahc_actigraphy name=name label=label;
	by resident_id REDCAP_event_name;
	var actigraph_passyn sleep_hours  ;
run;
*RNK PHYSICAL DATA SET;
proc sort data = raw.RNK_Physical nodupkey out=derived.RNK_Physical;
	by resident_ID redcap_event_name;
run;
proc transpose data = derived.RNK_Physical out = rnktemp name=name label=label;
	by resident_id redcap_event_name ;
	var approve_dementia affirm_med affirm_gen affirm_rls;
run;


/************************************************
SETS THE DATA ON TOP OF EACHOTHER FOR THE OUTPUT
*************************************************/

/*CHANGES THE COL VARIABLE FROM NUMERIC TO CHARACTER IN ORDER TO SET THE DATA SETS*/
data rnk (drop=col1);set rnktemp;col=put(col1,8.2);run;
data rnk2 (drop=col);set rnk;col1=col;run;

data pnk (drop=col1);set derived.baseline;col=put(col1,8.2);run;
data rnk3 (drop=col);set pnk;col1=col;run;

data pnk1 (drop=col1);set derived.cmai_direct_obs;col=put(col1,8.2);run;
data rnk4 (drop=col);set pnk1;col1=col;run;

data pnk2 (drop=col1);set derived.labcorp_metadata;col=put(col1,8.2);run;
data rnk5 (drop=col);set pnk2;col1=col;run;

data pnk3 (drop=col1);set derived.rnrahc_actigraphy ;col=put(col1,8.2);run;
data rnk6 (drop=col);set pnk3;col1=col;run;


/*SETS THE DATA SETS TOGETHER*/
data derived.final_table;
	set derived.screening rnk3 rnk4 rnk5 rnk6 rnk2;
	by resident_id ;

	if substr(resident_id,1,2) ne "nr"  then delete;
	format redcap_event_name redcap_event_name_.;
run;

data final_table2 (drop=temp);
SET derived.final_table;
	temp = col1*1;

	if name = "actigraph_passyn" and temp = 1 then col1="Yes";
	else if name = "actigraph_passyn" and temp= 0 then col1="No";

	if name = "baseline_creatinine_passyn" and temp = 1 then col1="Yes";
	else if name = "baseline_creatinine_passyn" and temp= 0 then col1="No";
	
RUN;

/*******************************************************************************************

			CREATING XML FILE FOR THE OUTPUT - DIFFERENT PATIENT ON EACH SHEET

********************************************************************************************/


data data_all_spreadsheet (drop=col1) ;
set final_table2 ;
response = col1;
run;

proc sort data=data_all_spreadsheet out=pat(keep=  resident_id) nodupkey;
by resident_id;
run;

proc sort data=data_all_spreadsheet  ;
by resident_id;
run;


%macro export( );
data _null_;
       set pat end = last;
       call symput(trim(left('resident_id'))||trim(left(_n_)),trim(left(resident_id))) ;
       if last then call symput ('last',_n_);
 run;

 filename myfile "Q:\Kathy Richards\NARLS_2017\weekly_reports\documents\Weekly Report &sysdate..XML";
 ods tagsets.excelxp body=myfile style=htmlblue options(Absolute_Column_Width='10.57,17.43,47.86,22.86,8.43');
%do a=1 %to &last;
 data t&a;
 set data_all_spreadsheet (keep=resident_id name label redcap_event_name response);
 where resident_id="&&resident_id&a";
 run;
	 proc report data=t&a;
	ods tagsets.excelxp OPTIONS(SHEET_NAME="&&resident_id&a");
	title "&&resident_id&a";
%end;
	proc report data=data_all_spreadsheet ;
	ods tagsets.excelxp OPTIONS(SHEET_NAME="null");
	title "null";
ODS tagsets.excelxp CLOSE; 
title;
%mend;
%export;












