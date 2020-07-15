libname raw "Q:\Salimah Meghani\RO1_2019\data\Raw";
libname derived "Q:\Salimah Meghani\RO1_2019\data\Derived";
footnote "SAS Program Stored in: Q:\Salimah Meghani\RO1_2019\programs\Draft\basic summary stats.sas";
options fmtsearch=(raw.main_formats raw.emr_formats);

/*Log with macro debugging options turned on  */
options mprint mlogic symbolgen; 

/***************************************
Description of task
6/30/2020 - Tresa
Basic summary stats for Meghani
***************************************/


/*Summary Stats on dataset raw.main*/
proc contents data= raw.main varnum;
run;

proc means data= raw.main maxdec=2 n nmiss min median max mean std;
	var demog_age;
run;

/*check missing ages*/
proc print data= raw.main (obs=10);
	var participant_id redcap_event_name demog_age;
run;


proc freq data= raw.main;
	tables redcap_event_name;
	format redcap_event_name;
run;

/*ad is not an expected visit - can we drop it*/
proc print data= raw.main ;
	where redcap_event_name='administrative_for_arm_1';
/*	var redcap_event_name;*/
run;




proc sort data = raw.main;
	by participant_id; 
run;

/*SAMPLE*/
/*no data on visit ad so drop it*/
/*manually repeat demog variables for each participant at all time points*/
/*data derived.main;*/
/*	set raw.main;*/
/**/
/*	retain demog_age1;*/
/*	if first.participant_id then demog_age1=demog_age; */
/*	else demog_age1 = demog_age1; */
/**/
/*	retain demog_gender1;*/
/*	if first.participant_id then demog_gender1=demog_gender; */
/*	else demog_gender1 = demog_gender1; */
/**/
/*	by participant_id; */
/**/
/*	where redcap_event_name ne 'administrative_for_arm_1';*/
/*run;*/

/*check demog variables repeat*/
/*proc print data= derived.main (obs=30);*/
*	where redcap_event_name='administrative_for_arm_1';
/*	var participant_id redcap_event_name demog_age demog_age1 demog_gender demog_gender1;*/
/*run;*/


/*no data on visit ad so drop it*/
/*manually repeat demog variables for each participant at all time points*/


/*USE ARRAY AND DO LOOP TO REPEAT THE FOLLOWING FOR EACH DEMOGRAPHIC VARIABLE*/
/*	if first.participant_id then demog_gender1=demog_gender; */
/*	else demog_gender1 = demog_gender1; */








/*use proc sql and loop to repeat demog variables for each participant at all time points*/
proc contents data=raw.main varnum out=cont_out noprint; run;

proc print data= cont_out /*(obs=10)*/;
run;

/*add suffix 1 to all variables with prefix demog*/
proc sql noprint;  
    select NAME into : suffix separated by '1 ' from cont_out  
/*    type=1 and format = 'BEST' is numeric, BEST IS THE DEFAULT NUM FORMAT*/ 
/*    where type = 1 and format in ('BEST'); */
	where type = 1 and lowcase(trim(NAME)) like "demog_%" ;
quit; 
%put &suffix.1;

proc sql noprint;  
    select NAME into : demog separated by ' ' from cont_out  
/*    type=1 and format = 'BEST' is numeric, BEST IS THE DEFAULT NUM FORMAT*/ 
/*    where type = 1 and format in ('BEST'); */
	where type = 1 and lowcase(trim(NAME)) like "demog_%" ;
quit; 
%put &demog;

/*repeat demog variables with loop*/
data derived.main;
	set raw.main;
	retain &suffix.1;
	array demog {*} &demog;
	array demog1 {*} &suffix.1;

/*	start loop*/
/*  dim(demog) is the number of variables in the array*/
	do i=1 to dim(demog); 
		if first.participant_id then demog1[i]=demog[i]; 
		else demog1[i] = demog1[i]; 
/*	stop loop*/
	end;

	by participant_id; /*same variable as line 5*/

	drop &demog;

	where redcap_event_name ne 'administrative_for_arm_1';
run;

/*check old demog variables were dropped*/
proc contents data= derived.main varnum;
run;

/*check all demog variables repeat*/
proc print data= derived.main (obs=30);
/*	where redcap_event_name='administrative_for_arm_1';*/
	var participant_id redcap_event_name &suffix.1;
run;

/*check visit ad was dropped*/
proc freq data= derived.main;
	tables redcap_event_name;
	format redcap_event_name;
run;


/*find proc means variables*/
/*proc contents data=derived.main varnum out=cont_out noprint; run;*/
/**/
/*proc print data= cont_out /*(obs=10)*/;*/
/*run;*/

/*proc sql noprint; */
/*    select NAME into : means separated by ' ' from cont_out */
/*/*  type=1 and format = 'BEST' is numeric, BEST IS THE DEFAULT NUM FORMAT*/ */
/*    where type = 1 and format in ('BEST'); */
/*quit; */
/*%put &means;*/

/*proc means data= derived.main maxdec=2 n nmiss min median max mean std;*/
/*	var &means;*/
/*run;*/;


ods rtf file="Q:\Salimah Meghani\RO1_2019\documents\output\Summary Stats for Continuous Variables &sysdate..doc" style=journal;
title "Summary Stats for Continuous Variables";
proc means data= derived.main maxdec=2 n nmiss min median max mean std;
	var daily_pain_survey_q3 daily_pain_survey_q4 npq_1 npq_2 npq_3 psqi_2 psqi_4 meddiscontinued_dose mednew_total_daily_dose
		hcu_nights_in_hospital nvs_score comm_total ort_oud_total comm_score ort_oud_score phq8_total_score dose demog_age1;
run;
ods rtf close;

ods rtf file="Q:\Salimah Meghani\RO1_2019\documents\output\Summary Stats for Categorical Variables &sysdate..doc" style=journal;
title "Summary Stats for Categorical Variables";
proc freq data= derived.main;
	tables participant_id_complete consent informed_consent_complete brief_pain_inventory_1 brief_pain_inventory_2
		brief_pain_inventory_3 brief_pain_inventory_4 brief_pain_inventory_5 brief_pain_inventory_7 brief_pain_inventory_8a
		brief_pain_inventory_8b brief_pain_inventory_8c brief_pain_inventory_8d brief_pain_inventory_8e brief_pain_inventory_8f
		brief_pain_inventory_8g psqi_1 psqi_3 psqi_5a psqi_5b psqi_5c psqi_5d psqi_5e psqi_5f psqi_5g psqi_5h psqi_5i psqi_5othera
		psqi_6 psqi_7 psqi_8 psqi_9 psqi_10 psqi_10a psqi_10b psqi_10c psqi_10d psqi_10e fact_g_gp1 fact_g_gp2 fact_g_gp3
		fact_g_gp4 fact_g_gp5 fact_g_gp6 fact_g_gp7 fact_g_gs1 fact_g_gs2 fact_g_gs3 fact_g_gs4 fact_g_gs5 fact_g_gs6 fact_g_gs7
		fact_g_ge1 fact_g_ge2 fact_g_ge3 fact_g_ge4 fact_g_ge5 fact_g_ge6 fact_g_gf1 fact_g_gf2 fact_g_gf3 fact_g_gf4 fact_g_gf5
		fact_g_gf6 fact_g_gf7 dose_extent_1 dose_extent_2 dose_extent_3 dose_reasons_1 dose_reasons_2 dose_reasons_3 dose_reasons_4
		dose_reasons_5 dose_reasons_6 dose_reasons_7 dose_reasons_8 dose_reasons_9 dose_reasons_10 dose_reasons_11 dose_reasons_12
		dose_reasons_13 dose_reasons_14 dose_reasons_15 dose_reasons_16 dose_reasons_17 dose_reasons_18 phase_change meddiscontinued_name
		meddiscontinued_date meddiscontinued_dose_units meddiscontinued_frequency mednew_name mednew_date mednew_dose_units
		mednew_frequency phase_change_validation hcu_seen_in_er hcu_er_date hcu_inpatient hcu_planned_admission hcu_admission_date
		hcu_discharge_date hcu_admitted_er hcu_urgent_care hcu_urgent_care_date hcu_admitted_urgent_care cam___1 cam___2 cam___3
		cam___4 cam___5 cam___6 cam___7 cam___8 cam___9 cam___10 cam___11 cam___12 cam___13 cam___14 cam___15 cam___16 cam___17
		cam___18 cam___19 cam___20 cam___21 cam___22 cam___23 cam___24 cam___25 cam___26 cam___29 cam___30 cam___27 cam___28
		msce_1 msce_2 msce_3 msce_4 msce_5 msce_6 msce_7 msce_8 msce_9 barriers_questionnaire_1 barriers_questionnaire_2
		barriers_questionnaire_3 barriers_questionnaire_4 barriers_questionnaire_5 barriers_questionnaire_6 barriers_questionnaire_7
		barriers_questionnaire_8 barriers_questionnaire_9 barriers_questionnaire_10 barriers_questionnaire_11 barriers_questionnaire_12
		barriers_questionnaire_13 pseq_1 pseq_2 pseq_3 pseq_4 pseq_5 pseq_6 pseq_7 pseq_8 pseq_9 pseq_10 ffsq_1 ffsq_2 ffsq_3
		ffsq_4 fssq_5 fssq_6 fssq_7 fssq_8 bhls_1 bhls_2 bhls_3 nvs_admin_1 nvs_admin_2 nvs_admin_3 nvs_admin_4 nvs_admin_5
		nvs_admin_6 appendix_a_1 appendix_a_2 appendix_a_3 appendix_a_4 appendix_a_5 cage_0 cage_1 cage_2 cage_3 cage_4
		main_survey_complete phq9_1 phq9_2 phq9_3 phq9_4 phq9_5 phq9_6 phq9_7 phq9_8 phq9_how_difficult phq8_complete comm_1 comm_2
		comm_3 comm_4 comm_5 comm_6 comm_7 comm_8 comm_9 comm_10 comm_11 comm_12 comm_13 comm_14 comm_15 comm_16 comm_17 ort_oud1
		ort_oud2 ort_oud3 ort_oud4 ort_oud5 ort_oud6 ort_oud7 ort_oud8 ort_oud9 comm_ort_complete index_oral_la_or_sa index_oral_la
		index_oral_sa med_frequency next_refill_date_bottle next_study_visit next_study_visit_time index_opioid_refill__v_1 

		demog_education1 demog_employment_status1 demog_employment_status_21 demog_ethnicity1 demog_gender1 demog_household_income1 
		demog_insurance___11 demog_insurance___21 demog_insurance___31 demog_insurance___41 demog_insurance____11
		demog_marital_status1 demog_mutiracial1 demog_race1  

		i;
run;
ods rtf close;

