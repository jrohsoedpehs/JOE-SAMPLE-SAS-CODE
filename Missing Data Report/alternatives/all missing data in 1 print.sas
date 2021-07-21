/*Log with macro debugging options turned on  */
/*options mprint mlogic symbolgen; */

libname raw "Q:\Julio Chirinos\Knock_out_Summer_2016\data\Raw";
libname derived "Q:\Julio Chirinos\Knock_out_Summer_2016\data\Derived";

/*RANDOMIZED PARTICIPANTS FROM FALL 2018 DSMB'S TRT DATASET*/
libname trt "Q:\Julio Chirinos\Knock_out_Summer_2016\DSMB\DSMB_Spring_2019\data\Derived";
/*trt*/

footnote "SAS Program Stored in: Q:\Julio Chirinos\Knock_out_Summer_2016\programs\Draft\missing_data_UP_Knockout.sas";

/*FORMATS*/
options fmtsearch=(raw.ko_up_formats );
options nofmterr;

/*QA THE DATA SETS*/

/*REDCAP DATASET*/
proc contents data=raw.ko_up varnum;run;
/*proc print data=raw.ko_up  (obs=5);run;*/

/*RANDOMIZED Participants*/
/*missing some participants*/
/*proc contents data=trt.treatment varnum;run;*/
/*proc print data=trt.treatment  (obs=5);*/
/*var subject_id rand_date;*/
/*run;*/


/*MERGE 2 DATASETS raw.ko_up AND trt.treatment */

/*DETERMINE 1-MANY*/
/*0. Check for missing data in key fields and give common variable type and format (use numeric if possible)*/
/*1. CHECK FOR DUPLICATES ON KEY FIELDS*/
/*2. REMOVE DUPLICATES and CREATE KEY FIELDS*/
/*3. SORT CLEANED DATASETS*/
/*4. MERGE ON KEY FIELDS*/
/*5. QA - CHECK FOR ITEMS IN ONE DATASET BUT NOT THE OTHER*/

/*0. Check for missing data in key fields and give common variable type and format (use numeric if possible)*/
/*NO MISSING DATA IN KEY FIELDS*/

/*SOURCE*/
/*"Q:\Julio Chirinos\Knock_out_Summer_2016\DSMB\DSMB_Spring_2019\documents\Reports\P1252_KNO3CKOUT_Assignments_as_AB_or_BA_as_of_4-15-19.xlsx"*/
data treatment_clean;
input study_id $;
cards;
KT-1-01
KT-1-02
KT-1-03
KT-1-04
KT-1-05
KT-1-06
KT-1-07
KT-1-08
KT-1-09
KT-1-11
KT-1-12
KT-1-13
KT-1-14
KT-1-15
KT-1-17
KT-1-18
KT-1-19
KT-1-20
KT-1-21
KT-1-22
KT-1-23
KT-1-24
KT-1-25
KT-1-26
KT-1-27
KT-1-28
;
run;
/*QA*/
proc print data= treatment_clean;run;
proc contents data=treatment_clean varnum;run;

/*data trt.treatment_clean;*/
/*set trt.treatment;*/
/*study_id = subject_id;*/
/*if study_id in(*/
/*"KT-2-01",*/
/*"KT-1-01",*/
/*"KT-2-03",*/
/*"KT-2-04",*/
/*"KT-2-05",*/
/*"KT-2-06",*/
/*"KT-2-07",*/
/*"KT-2-08",*/
/*"KT-2-09",*/
/*"KT-2-10",*/
/*"KT-2-11",*/
/*"KT-2-12",*/
/*"KT-2-13",*/
/*"KT-2-14",*/
/*"KT-2-15",*/
/*"KT-2-17",*/
/*"KT-2-18",*/
/*"KT-2-19",*/
/*"KT-2-20",*/
/*"KT-3-01"*/
/*) then delete;*/
/*run;*/

/*QA study_id*/
proc print data = treatment_clean  ;
var study_id;
run;


/*1. CHECK FOR DUPLICATES*/
proc sort data=treatment_clean  ;
    by study_id;
run;
data duplicates;
	set treatment_clean ;
    by study_id;
	if first.study_id ne last.study_id or first.study_id= 0 and last.study_id=0;
run;

proc sort data=raw.ko_up ;
    by study_id REDCAP_EVENT_NAME;
run;
data duplicates;
	set raw.ko_up ;
    by study_id REDCAP_EVENT_NAME;
	if first.REDCAP_EVENT_NAME ne last.REDCAP_EVENT_NAME or first.REDCAP_EVENT_NAME= 0 and last.REDCAP_EVENT_NAME=0;
run;

/*2. REMOVE DUPLICATES and CREATE KEY FIELDS*/
/*THERE ARE NO DUPLICATES*/


/*3. SORT CLEANED DATASETS*/
proc sort data=treatment_clean ;
    by study_id;
run;
proc sort data=raw.ko_up ;
    by study_id;
run;

/*4. MERGE*/
data derived.ko_up_randomized;
merge raw.ko_up (in=a)  treatment_clean (in=b);
by study_id;
if b;

/*PATH AND FILES*/
/*if path_and_files_complete = 2 and REDCAP_EVENT_NAME = "week_6_phase_1_arm_1" then delete;*/
/*if path_and_files_complete = 2 and REDCAP_EVENT_NAME = "week_6_phase_2_arm_1" then delete;*/

/*FORM EL*/
/*if form_el_complete = 2 and REDCAP_EVENT_NAME = "baseline_visit_arm_1" then delete;*/



/*baseline_visit_arm_1*/
/*week_1_phase_1_arm_1*/
/*week_6_phase_1_arm_1*/
/*week_1_phase_2_arm_1*/
/*week_6_phase_2_arm_1*/

run;


/*5. QA - CHECK FOR ITEMS IN ONE DATASET BUT NOT THE OTHER*/
data injnotd indnotj;
	merge raw.ko_up (in=d) treatment_clean (in=j);
    by study_id;
	if d = 1 and j ne 1 then output indnotj;
	if j = 1 and d ne 1 then output injnotd; /*In treatment_clean  but missing from raw.ko_up*/
run;
/*proc print data = injnotd;run;*/



/*********************************************************************
Purpose:
CREATE A MISSING DATA REPORT BY ID FOR UP KNOCKOUT

Modified 8/14/2020 Joseph
*********************************************************************/


/*Log with macro debugging options turned on */
/*options mprint mlogic symbolgen; */

/*Preview Data*/
proc contents data= derived.ko_up_randomized varnum;
run;



/*GENERATES A LIST OF ALL study_ids*/
proc sql /*noprint*/;
select distinct study_id
into :name_list separated by " " from derived.ko_up_randomized;
quit;
/*VIEW THE LIST IN THE LOG*/
%put &name_list;

/*lIST ALL IDS EXCLUDING THE 1ST ONE*/
%let name_list =  KT-1-02 KT-1-03 KT-1-04 KT-1-05 KT-1-06 KT-1-07 KT-1-08 KT-1-09 KT-1-11 KT-1-12 KT-1-13 KT-1-14 KT-1-15 KT-1-17
                  KT-1-18 KT-1-19 KT-1-20 KT-1-21 KT-1-22 KT-1-23 KT-1-24 KT-1-25 KT-1-26 KT-1-27 KT-1-28
;

%put &name_list;




/*GOAL REPEAT THE FOLLOWING PROC PRINT FOR ALL VARIABLES IN THE MAIN SURVEY*/
proc print data= derived.ko_up_randomized label noobs;
where study_id = "KT-1-01" and missing(tonometry_file1) and path_and_files_complete not in (.,0) and na_path_and_files  ne  1;
var study_id redcap_event_name tonometry_file1;
title1 "KT-1-01";
title2 "Path And Files";
title3 "tonometry_file1";
run;



data macro_variables;
    length variable$100 logic$300 title$100;
    infile datalines delimiter='|';
    input variable$ logic$ title$;
    datalines;  
tonometry_file1|%str( and path_and_files_complete not in (.,0) and na_path_and_files  ne  1)|Path And Files 
tonometry_file2|%str( and path_and_files_complete not in (.,0) and na_path_and_files  ne  1)|Path And Files 
tonometry_file3|%str( and path_and_files_complete not in (.,0) and na_path_and_files  ne  1)|Path And Files 
tonometry_file4|%str( and path_and_files_complete not in (.,0) and na_path_and_files  ne  1)|Path And Files 
cardiopulmonary_file_1|%str( and path_and_files_complete not in (.,0) and na_path_and_files  ne  1)|Path And Files 
epd_date|%str( and end_phase_dosing_complete not in (.,0) and na_end_phase_dosing  ne  1)|End Phase Dosing
epd_time|%str( and end_phase_dosing_complete not in (.,0) and na_end_phase_dosing  ne  1)|End Phase Dosing
activity_dressing|%str( and kccq_complete not in (.,0) and na_kccq  ne  1)|KCCQ
activity_showering|%str( and kccq_complete not in (.,0) and na_kccq  ne  1)|KCCQ
activity_walking|%str( and kccq_complete not in (.,0) and na_kccq  ne  1)|KCCQ
activity_work|%str( and kccq_complete not in (.,0) and na_kccq  ne  1)|KCCQ
activity_climbing|%str( and kccq_complete not in (.,0) and na_kccq  ne  1)|KCCQ
activity_run|%str( and kccq_complete not in (.,0) and na_kccq  ne  1)|KCCQ
heart_failure_chage|%str( and kccq_complete not in (.,0) and na_kccq  ne  1)|KCCQ
frequency_swelling|%str( and kccq_complete not in (.,0) and na_kccq  ne  1)|KCCQ
swelling_bother|%str( and kccq_complete not in (.,0) and na_kccq  ne  1)|KCCQ
fatigue_limit|%str( and kccq_complete not in (.,0) and na_kccq  ne  1)|KCCQ
fatigue_bother|%str( and kccq_complete not in (.,0) and na_kccq  ne  1)|KCCQ
breath_limited|%str( and kccq_complete not in (.,0) and na_kccq  ne  1)|KCCQ
shortness_bother|%str( and kccq_complete not in (.,0) and na_kccq  ne  1)|KCCQ
sleep_sittingup|%str( and kccq_complete not in (.,0) and na_kccq  ne  1)|KCCQ
heartfail_contact|%str( and kccq_complete not in (.,0) and na_kccq  ne  1)|KCCQ
heart_fail_worse|%str( and kccq_complete not in (.,0) and na_kccq  ne  1)|KCCQ
enjoyment_limit|%str( and kccq_complete not in (.,0) and na_kccq  ne  1)|KCCQ
heartfail_life|%str( and kccq_complete not in (.,0) and na_kccq  ne  1)|KCCQ
discouraged_heartfail|%str( and kccq_complete not in (.,0) and na_kccq  ne  1)|KCCQ
hobbies|%str( and kccq_complete not in (.,0) and na_kccq  ne  1)|KCCQ
working|%str( and kccq_complete not in (.,0) and na_kccq  ne  1)|KCCQ
family_visit|%str( and kccq_complete not in (.,0) and na_kccq  ne  1)|KCCQ
intimate_relationships|%str( and kccq_complete not in (.,0) and na_kccq  ne  1)|KCCQ
data_obtained_yn|%str( and form_el_complete not in (.,0) and na_form_el  ne  1)|FORM BL_EL Baseline Eligibility
heart_failure|%str( and form_el_complete not in (.,0) and na_form_el  ne  1)|FORM BL_EL Baseline Eligibility
lv_ejection|%str( and form_el_complete not in (.,0) and na_form_el  ne  1)|FORM BL_EL Baseline Eligibility
date1|%str( and form_el_complete not in (.,0) and na_form_el  ne  1)|FORM BL_EL Baseline Eligibility
medical_therapy|%str( and form_el_complete not in (.,0) and na_form_el  ne  1)|FORM BL_EL Baseline Eligibility
filling_pressures|%str( and form_el_complete not in (.,0) and na_form_el  ne  1)|FORM BL_EL Baseline Eligibility
mitral_ratio|%str( and form_el_complete not in (.,0) and na_form_el  ne  1)|FORM BL_EL Baseline Eligibility
left_atrium|%str( and form_el_complete not in (.,0) and mitral_ratio=1)|FORM BL_EL Baseline Eligibility
date2|%str( and form_el_complete not in (.,0) and left_atrium=1)|FORM BL_EL Baseline Eligibility
chronic_loop|%str( and form_el_complete not in (.,0) and mitral_ratio=1)|FORM BL_EL Baseline Eligibility
natriuretic_peptides|%str( and form_el_complete not in (.,0) and mitral_ratio=1)|FORM BL_EL Baseline Eligibility
date3|%str( and form_el_complete not in (.,0) and natriuretic_peptides=1)|FORM BL_EL Baseline Eligibility
either_lateral|%str( and form_el_complete not in (.,0) and na_form_el  ne  1)|FORM BL_EL Baseline Eligibility
capillary_wedge|%str( and form_el_complete not in (.,0) and na_form_el  ne  1)|FORM BL_EL Baseline Eligibility
value|%str( and form_el_complete not in (.,0) and na_form_el  ne  1)|FORM BL_EL Baseline Eligibility
date4|%str( and form_el_complete not in (.,0) and na_form_el  ne  1)|FORM BL_EL Baseline Eligibility
iv_diuretics|%str( and form_el_complete not in (.,0) and na_form_el  ne  1)|FORM BL_EL Baseline Eligibility
date5|%str( and form_el_complete not in (.,0) and na_form_el  ne  1)|FORM BL_EL Baseline Eligibility
date6|%str( and form_el_complete not in (.,0) and na_form_el  ne  1)|FORM BL_EL Baseline Eligibility
supine_systolic|%str( and form_el_complete not in (.,0) and na_form_el  ne  1)|FORM BL_EL Baseline Eligibility
pregnancy|%str( and form_el_complete not in (.,0) and na_form_el  ne  1)|FORM BL_EL Baseline Eligibility
orthostatic_hypotension|%str( and form_el_complete not in (.,0) and na_form_el  ne  1)|FORM BL_EL Baseline Eligibility
native_conduction|%str( and form_el_complete not in (.,0) and na_form_el  ne  1)|FORM BL_EL Baseline Eligibility
hemoglobin|%str( and form_el_complete not in (.,0) and na_form_el  ne  1)|FORM BL_EL Baseline Eligibility
inability_exercise|%str( and form_el_complete not in (.,0) and na_form_el  ne  1)|FORM BL_EL Baseline Eligibility
valvular_disease|%str( and form_el_complete not in (.,0) and na_form_el  ne  1)|FORM BL_EL Baseline Eligibility
hypertrophic|%str( and form_el_complete not in (.,0) and na_form_el  ne  1)|FORM BL_EL Baseline Eligibility
pericardial_disease|%str( and form_el_complete not in (.,0) and na_form_el  ne  1)|FORM BL_EL Baseline Eligibility
current_angina|%str( and form_el_complete not in (.,0) and na_form_el  ne  1)|FORM BL_EL Baseline Eligibility
coronary_syndrome|%str( and form_el_complete not in (.,0) and na_form_el  ne  1)|FORM BL_EL Baseline Eligibility
primary_pulmonary|%str( and form_el_complete not in (.,0) and na_form_el  ne  1)|FORM BL_EL Baseline Eligibility
chronic_obstructive|%str( and form_el_complete not in (.,0) and na_form_el  ne  1)|FORM BL_EL Baseline Eligibility
stress_testing|%str( and form_el_complete not in (.,0) and na_form_el  ne  1)|FORM BL_EL Baseline Eligibility
ventricular_ejection|%str( and form_el_complete not in (.,0) and na_form_el  ne  1)|FORM BL_EL Baseline Eligibility
phosphodiesterase|%str( and form_el_complete not in (.,0) and na_form_el  ne  1)|FORM BL_EL Baseline Eligibility
organic_nitrates|%str( and form_el_complete not in (.,0) and na_form_el  ne  1)|FORM BL_EL Baseline Eligibility
liver_disease|%str( and form_el_complete not in (.,0) and na_form_el  ne  1)|FORM BL_EL Baseline Eligibility
egfr|%str( and form_el_complete not in (.,0) and na_form_el  ne  1)|FORM BL_EL Baseline Eligibility
g6pd_deficiency|%str( and form_el_complete not in (.,0) and na_form_el  ne  1)|FORM BL_EL Baseline Eligibility
methemoglobinemia|%str( and form_el_complete not in (.,0) and na_form_el  ne  1)|FORM BL_EL Baseline Eligibility
methemoglobin|%str( and form_el_complete not in (.,0) and na_form_el  ne  1)|FORM BL_EL Baseline Eligibility
hyperkalemia_serum|%str( and form_el_complete not in (.,0) and na_form_el  ne  1)|FORM BL_EL Baseline Eligibility
ventricular_dysfunction|%str( and form_el_complete not in (.,0) and na_form_el  ne  1)|FORM BL_EL Baseline Eligibility
medical_condition|%str( and form_el_complete not in (.,0) and na_form_el  ne  1)|FORM BL_EL Baseline Eligibility
contraindications_to_mri|%str( and form_el_complete not in (.,0) and na_form_el  ne  1)|FORM BL_EL Baseline Eligibility
intra_luminal_implant|%str( and form_el_complete not in (.,0) and na_form_el  ne  1)|FORM BL_EL Baseline Eligibility
life_assist_device|%str( and form_el_complete not in (.,0) and na_form_el  ne  1)|FORM BL_EL Baseline Eligibility
vascular_clip|%str( and form_el_complete not in (.,0) and na_form_el  ne  1)|FORM BL_EL Baseline Eligibility
visceral_organs|%str( and form_el_complete not in (.,0) and na_form_el  ne  1)|FORM BL_EL Baseline Eligibility
intracranial_implants|%str( and form_el_complete not in (.,0) and na_form_el  ne  1)|FORM BL_EL Baseline Eligibility
non_removable_piercings|%str( and form_el_complete not in (.,0) and na_form_el  ne  1)|FORM BL_EL Baseline Eligibility
personal_history|%str( and form_el_complete not in (.,0) and na_form_el  ne  1)|FORM BL_EL Baseline Eligibility
radiologic_evaluation|%str( and form_el_complete not in (.,0) and na_form_el  ne  1)|FORM BL_EL Baseline Eligibility
date7|%str( and form_el_complete not in (.,0) and na_form_el  ne  1)|FORM BL_EL Baseline Eligibility
consent_yn|%str( and form_bl_cl_complete not in (.,0) and na_form_bl_cl  ne  1)|FORM BL_CL Baseline Checklist
urine_yn|%str( and form_bl_cl_complete not in (.,0) and na_form_bl_cl  ne  1)|FORM_BL_CL Baseline Checklist
urine_radio|%str( and form_bl_cl_complete not in (.,0) and urine_yn=1)|FORM_BL_CL Baseline Checklist
diet_yn|%str( and form_bl_cl_complete not in (.,0) and na_form_bl_cl  ne  1)|FORM_BL_CL Baseline Checklist
vital_yn|%str( and form_bl_cl_complete not in (.,0) and na_form_bl_cl  ne  1)|FORM_BL_CL Baseline Checklist
mw6_yn|%str( and form_bl_cl_complete not in (.,0) and na_form_bl_cl  ne  1)|FORM_BL_CL Baseline Checklist
quality_yn|%str( and form_bl_cl_complete not in (.,0) and na_form_bl_cl  ne  1)|FORM_BL_CL Baseline Checklist
cognitive_test_yn|%str( and form_bl_cl_complete not in (.,0) and na_form_bl_cl  ne  1)|FORM_BL_CL Baseline Checklist
blood_yn|%str( and form_bl_cl_complete not in (.,0) and na_form_bl_cl  ne  1)|FORM_BL_CL Baseline Checklist
g6pd_yn|%str( and form_bl_cl_complete not in (.,0) and na_form_bl_cl  ne  1)|FORM_BL_CL Baseline Checklist
art_tono_yn|%str( and form_bl_cl_complete not in (.,0) and na_form_bl_cl  ne  1)|FORM_BL_CL Baseline Checklist
echo_yn|%str( and form_bl_cl_complete not in (.,0) and na_form_bl_cl  ne  1)|FORM_BL_CL Baseline Checklist
ekg_bl|%str( and form_bl_cl_complete not in (.,0) and na_form_bl_cl  ne  1)|FORM_BL_CL Baseline Checklist
labs_yn|%str( and form_bl_cl_complete not in (.,0) and na_form_bl_cl  ne  1)|FORM_BL_CL Baseline Checklist
hemo_yn|%str( and form_bl_cl_complete not in (.,0) and na_form_bl_cl  ne  1)|FORM_BL_CL Baseline Checklist
hemo_value|%str( and form_bl_cl_complete not in (.,0) and na_form_bl_cl  ne  1)|FORM_BL_CL Baseline Checklist
creati_yn|%str( and form_bl_cl_complete not in (.,0) and na_form_bl_cl  ne  1)|FORM_BL_CL Baseline Checklist
creati_value|%str( and form_bl_cl_complete not in (.,0) and na_form_bl_cl  ne  1)|FORM_BL_CL Baseline Checklist
egfr_yn|%str( and form_bl_cl_complete not in (.,0) and na_form_bl_cl  ne  1)|FORM_BL_CL Baseline Checklist
egfr_value|%str( and form_bl_cl_complete not in (.,0) and na_form_bl_cl  ne  1)|FORM_BL_CL Baseline Checklist
meth_yn|%str( and form_bl_cl_complete not in (.,0) and na_form_bl_cl  ne  1)|FORM_BL_CL Baseline Checklist
meth_value|%str( and form_bl_cl_complete not in (.,0) and na_form_bl_cl  ne  1)|FORM_BL_CL Baseline Checklist
potas_yn|%str( and form_bl_cl_complete not in (.,0) and na_form_bl_cl  ne  1)|FORM_BL_CL Baseline Checklist
potas_value|%str( and form_bl_cl_complete not in (.,0) and na_form_bl_cl  ne  1)|FORM_BL_CL Baseline Checklist
ntpro_yn|%str( and form_bl_cl_complete not in (.,0) and na_form_bl_cl  ne  1)|FORM_BL_CL Baseline Checklist
ntpro_value|%str( and form_bl_cl_complete not in (.,0) and na_form_bl_cl  ne  1)|FORM_BL_CL Baseline Checklist
med_dis_yn|%str( and form_bl_cl_complete not in (.,0) and na_form_bl_cl  ne  1)|FORM_BL_CL Baseline Checklist
bl_ch_date|%str( and form_bl_cl_complete not in (.,0) and na_form_bl_cl  ne  1)|FORM_BL_CL Baseline Checklist
urine_pregnancy_test|%str( and form_6wk_cl_complete not in (.,0) and na_form_6wk_cl  ne  1 and redcap_event_name = 'week_6_phase_1_arm_1')|FORM_6WK_CL_P1
urine_pregnancy_results|%str( and form_6wk_cl_complete not in (.,0) and na_form_6wk_cl  ne  1 and redcap_event_name = 'week_6_phase_1_arm_1')|FORM_6WK_CL_P1
dietary_questionnaire|%str( and form_6wk_cl_complete not in (.,0) and na_form_6wk_cl  ne  1 and redcap_event_name = 'week_6_phase_1_arm_1')|FORM_6WK_CL_P1
physical_exam|%str( and form_6wk_cl_complete not in (.,0) and na_form_6wk_cl  ne  1 and redcap_event_name = 'week_6_phase_1_arm_1')|FORM_6WK_CL_P1
orthostatics|%str( and form_6wk_cl_complete not in (.,0) and na_form_6wk_cl  ne  1 and redcap_event_name = 'week_6_phase_1_arm_1')|FORM_6WK_CL_P1
vital_signs|%str( and form_6wk_cl_complete not in (.,0) and na_form_6wk_cl  ne  1 and redcap_event_name = 'week_6_phase_1_arm_1')|FORM_6WK_CL_P1
questionnaires_kccq|%str( and form_6wk_cl_complete not in (.,0) and na_form_6wk_cl  ne  1 and redcap_event_name = 'week_6_phase_1_arm_1')|FORM_6WK_CL_P1
potential_side_effects|%str( and form_6wk_cl_complete not in (.,0) and na_form_6wk_cl  ne  1 and redcap_event_name = 'week_6_phase_1_arm_1')|FORM_6WK_CL_P1
cognitive_test2_yn|%str( and form_6wk_cl_complete not in (.,0) and na_form_6wk_cl  ne  1 and redcap_event_name = 'week_6_phase_1_arm_1')|FORM_6WK_CL_P1
blood_draws_before|%str( and form_6wk_cl_complete not in (.,0) and na_form_6wk_cl  ne  1 and redcap_event_name = 'week_6_phase_1_arm_1')|FORM_6WK_CL_P1
light_breakfast|%str( and form_6wk_cl_complete not in (.,0) and na_form_6wk_cl  ne  1 and redcap_event_name = 'week_6_phase_1_arm_1')|FORM_6WK_CL_P1
blood_draws_after|%str( and form_6wk_cl_complete not in (.,0) and na_form_6wk_cl  ne  1 and redcap_event_name = 'week_6_phase_1_arm_1')|FORM_6WK_CL_P1
arterial_tonometry|%str( and form_6wk_cl_complete not in (.,0) and na_form_6wk_cl  ne  1 and redcap_event_name = 'week_6_phase_1_arm_1')|FORM_6WK_CL_P1
doppler_echocardiogram|%str( and form_6wk_cl_complete not in (.,0) and na_form_6wk_cl  ne  1 and redcap_event_name = 'week_6_phase_1_arm_1')|FORM_6WK_CL_P1
ekg_p1|%str( and form_6wk_cl_complete not in (.,0) and na_form_6wk_cl  ne  1 and redcap_event_name = 'week_6_phase_1_arm_1')|FORM_6WK_CL_P1
bicycle_exercise_test|%str( and form_6wk_cl_complete not in (.,0) and na_form_6wk_cl  ne  1 and redcap_event_name = 'week_6_phase_1_arm_1')|FORM_6WK_CL_P1
muscle_mri|%str( and form_6wk_cl_complete not in (.,0) and na_form_6wk_cl  ne  1 and redcap_event_name = 'week_6_phase_1_arm_1')|FORM_6WK_CL_P1
medication_dispensed|%str( and form_6wk_cl_complete not in (.,0) and na_form_6wk_cl  ne  1 and redcap_event_name = 'week_6_phase_1_arm_1')|FORM_6WK_CL_P1
stage_2_meds|%str( and form_6wk_cl_complete not in (.,0) and na_form_6wk_cl  ne  1 and redcap_event_name = 'week_6_phase_1_arm_1')|FORM_6WK_CL_P1
stage_1_meds|%str( and form_6wk_cl_complete not in (.,0) and na_form_6wk_cl  ne  1 and redcap_event_name = 'week_6_phase_1_arm_1')|FORM_6WK_CL_P1
pill_count_yn|%str( and form_6wk_cl_complete not in (.,0) and na_form_6wk_cl  ne  1 and redcap_event_name = 'week_6_phase_1_arm_1')|FORM_6WK_CL_P1
cardiac_mri_performed_p1|%str( and form_6wk_cl_complete not in (.,0) and na_form_6wk_cl  ne  1 and redcap_event_name = 'week_6_phase_1_arm_1')|FORM_6WK_CL_P1
date_6wk_cl_p1|%str( and form_6wk_cl_complete not in (.,0) and na_form_6wk_cl  ne  1 and redcap_event_name = 'week_6_phase_1_arm_1')|FORM_6WK_CL_P1
urine_pregnancy_test_p2|%str( and form_6wk_cl_p2_complete not in (.,0) and na_form_6wk_cl_p2  ne  1)|FORM_6WK_CL_P2
urine_pregnancy_results_p2|%str( and form_6wk_cl_p2_complete not in (.,0) and na_form_6wk_cl_p2  ne  1)|FORM_6WK_CL_P2
dietary_questionnaire_p2|%str( and form_6wk_cl_p2_complete not in (.,0) and na_form_6wk_cl_p2  ne  1)|FORM_6WK_CL_P2
physical_exam_p2|%str( and form_6wk_cl_p2_complete not in (.,0) and na_form_6wk_cl_p2  ne  1)|FORM_6WK_CL_P2
orthostatics_p2|%str( and form_6wk_cl_p2_complete not in (.,0) and na_form_6wk_cl_p2  ne  1)|FORM_6WK_CL_P2
vital_signs_p2|%str( and form_6wk_cl_p2_complete not in (.,0) and na_form_6wk_cl_p2  ne  1)|FORM_6WK_CL_P2
questionnaires_kccq_p2|%str( and form_6wk_cl_p2_complete not in (.,0) and na_form_6wk_cl_p2  ne  1)|FORM_6WK_CL_P2
potential_side_effects_p2|%str( and form_6wk_cl_p2_complete not in (.,0) and na_form_6wk_cl_p2  ne  1)|FORM_6WK_CL_P2
cognitive_test3_yn|%str( and form_6wk_cl_p2_complete not in (.,0) and na_form_6wk_cl_p2  ne  1)|FORM_6WK_CL_P2
blood_draws_before_p2|%str( and form_6wk_cl_p2_complete not in (.,0) and na_form_6wk_cl_p2  ne  1)|FORM_6WK_CL_P2
light_breakfast_p2|%str( and form_6wk_cl_p2_complete not in (.,0) and na_form_6wk_cl_p2  ne  1)|FORM_6WK_CL_P2
blood_draws_after_p2|%str( and form_6wk_cl_p2_complete not in (.,0) and na_form_6wk_cl_p2  ne  1)|FORM_6WK_CL_P2
arterial_tonometry_p2|%str( and form_6wk_cl_p2_complete not in (.,0) and na_form_6wk_cl_p2  ne  1)|FORM_6WK_CL_P2
doppler_echocardiogram_p2|%str( and form_6wk_cl_p2_complete not in (.,0) and na_form_6wk_cl_p2  ne  1)|FORM_6WK_CL_P2
ekg_p2|%str( and form_6wk_cl_p2_complete not in (.,0) and na_form_6wk_cl_p2  ne  1)|FORM_6WK_CL_P2
bicycle_exercise_test_p2|%str( and form_6wk_cl_p2_complete not in (.,0) and na_form_6wk_cl_p2  ne  1)|FORM_6WK_CL_P2
muscle_mri_p2|%str( and form_6wk_cl_p2_complete not in (.,0) and na_form_6wk_cl_p2  ne  1)|FORM_6WK_CL_P2
medication_dispensed_p2|%str( and form_6wk_cl_p2_complete not in (.,0) and na_form_6wk_cl_p2  ne  1)|FORM_6WK_CL_P2
stage_1_meds_p2|%str( and form_6wk_cl_p2_complete not in (.,0) and na_form_6wk_cl_p2  ne  1)|FORM_6WK_CL_P2
pill_count_yn_p2|%str( and form_6wk_cl_p2_complete not in (.,0) and na_form_6wk_cl_p2  ne  1)|FORM_6WK_CL_P2
cardiac_mri_performed_p2|%str( and form_6wk_cl_p2_complete not in (.,0) and na_form_6wk_cl_p2  ne  1)|FORM_6WK_CL_P2
date_6wk_cl_p2|%str( and form_6wk_cl_p2_complete not in (.,0) and na_form_6wk_cl_p2  ne  1)|FORM_6WK_CL_P2
penn_chart|%str( and form_mh_complete not in (.,0) and na_form_mh  ne  1)|FORM_BL_MH
age|%str( and form_mh_complete not in (.,0) and penn_chart=1 and penn_chart_6p ne 0)|FORM_BL_MH
gender|%str( and form_mh_complete not in (.,0) and penn_chart=1 and penn_chart_6p ne 0)|FORM_BL_MH
type_decent|%str( and form_mh_complete not in (.,0) and penn_chart=1 and penn_chart_6p ne 0)|FORM_BL_MH
acutecoronary|%str( and form_mh_complete not in (.,0) and penn_chart=1 and penn_chart_6p ne 0)|FORM_BL_MH
prior_angina|%str( and form_mh_complete not in (.,0) and penn_chart=1 and penn_chart_6p ne 0)|FORM_BL_MH
any_arrhythmia|%str( and form_mh_complete not in (.,0) and penn_chart=1 and penn_chart_6p ne 0)|FORM_BL_MH
valv_disease_surgery|%str( and form_mh_complete not in (.,0) and penn_chart=1 and penn_chart_6p ne 0)|FORM_BL_MH
htn|%str( and form_mh_complete not in (.,0) and penn_chart=1 and penn_chart_6p ne 0)|FORM_BL_MH
high_cholesterol|%str( and form_mh_complete not in (.,0) and penn_chart=1 and penn_chart_6p ne 0)|FORM_BL_MH
peripheral_vascular|%str( and form_mh_complete not in (.,0) and penn_chart=1 and penn_chart_6p ne 0)|FORM_BL_MH
diabetes|%str( and form_mh_complete not in (.,0) and penn_chart=1 and penn_chart_6p ne 0)|FORM_BL_MH
insulin|%str( and form_mh_complete not in (.,0) and penn_chart=1 and penn_chart_6p ne 0)|FORM_BL_MH
cva_tia|%str( and form_mh_complete not in (.,0) and penn_chart=1 and penn_chart_6p ne 0)|FORM_BL_MH
pulmonary_embolism_dvt|%str( and form_mh_complete not in (.,0) and penn_chart=1 and penn_chart_6p ne 0)|FORM_BL_MH
osa|%str( and form_mh_complete not in (.,0) and penn_chart=1 and penn_chart_6p ne 0)|FORM_BL_MH
cpap|%str( and form_mh_complete not in (.,0) and penn_chart=1 and penn_chart_6p ne 0)|FORM_BL_MH
copd_asthma|%str( and form_mh_complete not in (.,0) and penn_chart=1 and penn_chart_6p ne 0)|FORM_BL_MH
osteoarthritis|%str( and form_mh_complete not in (.,0) and penn_chart=1 and penn_chart_6p ne 0)|FORM_BL_MH
cabg|%str( and form_mh_complete not in (.,0) and penn_chart=1 and penn_chart_6p ne 0)|FORM_BL_MH
peripheral|%str( and form_mh_complete not in (.,0) and penn_chart=1 and penn_chart_6p ne 0)|FORM_BL_MH
valvular_surgery|%str( and form_mh_complete not in (.,0) and penn_chart=1 and penn_chart_6p ne 0)|FORM_BL_MH
congenital_surgery|%str( and form_mh_complete not in (.,0) and penn_chart=1 and penn_chart_6p ne 0)|FORM_BL_MH
trauma_requiring_surgery|%str( and form_mh_complete not in (.,0) and penn_chart=1 and penn_chart_6p ne 0)|FORM_BL_MH
current_smoker|%str( and form_mh_complete not in (.,0) and penn_chart=1 and penn_chart_6p ne 0)|FORM_BL_MH
pack_years|%str( and form_mh_complete not in (.,0) and penn_chart=1 and current_smoker=1 and penn_chart_6p ne 0)|FORM_BL_MH
prior_smoker|%str( and form_mh_complete not in (.,0) and penn_chart=1 and penn_chart_6p ne 0)|FORM_BL_MH
current_alcohol|%str( and form_mh_complete not in (.,0) and penn_chart=1 and penn_chart_6p ne 0)|FORM_BL_MH
drinks_day|%str( and form_mh_complete not in (.,0) and current_alcohol=1 and current_alcohol=1 and penn_chart_6p ne 0)|FORM_BL_MH
prior_alcohol|%str( and form_mh_complete not in (.,0) and penn_chart=1 and penn_chart_6p ne 0)|FORM_BL_MH
recreational_drug_use|%str( and form_mh_complete not in (.,0) and penn_chart=1 and penn_chart_6p ne 0)|FORM_BL_MH
occupation_yn|%str( and form_mh_complete not in (.,0) and penn_chart=1 and penn_chart_6p ne 0)|FORM_BL_MH
date9|%str( and form_mh_complete not in (.,0) and penn_chart=1 and penn_chart_6p ne 0)|FORM_BL_MH
nyhaclass|%str( and form_mh_complete not in (.,0) and penn_chart=1 and penn_chart_6p ne 0)|FORM_BL_MH
orthopnea|%str( and form_mh_complete not in (.,0) and penn_chart=1 and penn_chart_6p ne 0)|FORM_BL_MH
paroxysmal_nocturnal|%str( and form_mh_complete not in (.,0) and penn_chart=1 and penn_chart_6p ne 0)|FORM_BL_MH
lower_extremity_edema|%str( and form_mh_complete not in (.,0) and penn_chart=1 and penn_chart_6p ne 0)|FORM_BL_MH
num_of_stairs|%str( and form_mh_complete not in (.,0) and penn_chart=1 and penn_chart_6p ne 0)|FORM_BL_MH
distance|%str( and form_mh_complete not in (.,0) and penn_chart=1 and penn_chart_6p ne 0)|FORM_BL_MH
block_miles|%str( and form_mh_complete not in (.,0) and penn_chart=1 and penn_chart_6p ne 0)|FORM_BL_MH
crvalue|%str( and form_mh_complete not in (.,0) and penn_chart=1 and penn_chart_6p ne 0)|FORM_BL_MH
crdate|%str( and form_mh_complete not in (.,0) and penn_chart=1 and penn_chart_6p ne 0)|FORM_BL_MH
egfr_value2|%str( and form_mh_complete not in (.,0) and penn_chart=1 and penn_chart_6p ne 0)|FORM_BL_MH
egfr_date|%str( and form_mh_complete not in (.,0) and penn_chart=1 and penn_chart_6p ne 0)|FORM_BL_MH
nt_pro_bnp_value|%str( and form_mh_complete not in (.,0) and penn_chart=1 and penn_chart_6p ne 0)|FORM_BL_MH
nt_pro_bnp_date|%str( and form_mh_complete not in (.,0) and penn_chart=1 and penn_chart_6p ne 0)|FORM_BL_MH
hemoglobin_value|%str( and form_mh_complete not in (.,0) and penn_chart=1 and penn_chart_6p ne 0)|FORM_BL_MH
hemoglobin_date|%str( and form_mh_complete not in (.,0) and penn_chart=1 and penn_chart_6p ne 0)|FORM_BL_MH
hematocrit_value|%str( and form_mh_complete not in (.,0) and penn_chart=1 and penn_chart_6p ne 0)|FORM_BL_MH
hematocrit_date|%str( and form_mh_complete not in (.,0) and penn_chart=1 and penn_chart_6p ne 0)|FORM_BL_MH
hemoglobin_a1c_value|%str( and form_mh_complete not in (.,0) and penn_chart=1 and penn_chart_6p ne 0)|FORM_BL_MH
hemoglobin_a1c_date|%str( and form_mh_complete not in (.,0) and penn_chart=1 and penn_chart_6p ne 0)|FORM_BL_MH
cholesterol_total|%str( and form_mh_complete not in (.,0) and penn_chart=1 and penn_chart_6p ne 0)|FORM_BL_MH
cholesterol_total_date|%str( and form_mh_complete not in (.,0) and penn_chart=1 and penn_chart_6p ne 0)|FORM_BL_MH
triglycerides_value|%str( and form_mh_complete not in (.,0) and penn_chart=1 and penn_chart_6p ne 0)|FORM_BL_MH
triglycerides_date|%str( and form_mh_complete not in (.,0) and penn_chart=1 and penn_chart_6p ne 0)|FORM_BL_MH
hdl_cholesterol|%str( and form_mh_complete not in (.,0) and penn_chart=1 and penn_chart_6p ne 0)|FORM_BL_MH
hdl_cholesterol_date|%str( and form_mh_complete not in (.,0) and penn_chart=1 and penn_chart_6p ne 0)|FORM_BL_MH
vldl_date|%str( and form_mh_complete not in (.,0) and penn_chart=1 and penn_chart_6p ne 0)|FORM_BL_MH
ldl|%str( and form_mh_complete not in (.,0) and penn_chart=1 and penn_chart_6p ne 0)|FORM_BL_MH
ldl_date|%str( and form_mh_complete not in (.,0) and penn_chart=1 and penn_chart_6p ne 0)|FORM_BL_MH
non_hdl|%str( and form_mh_complete not in (.,0) and penn_chart=1 and penn_chart_6p ne 0)|FORM_BL_MH
non_hdl_date|%str( and form_mh_complete not in (.,0) and penn_chart=1 and penn_chart_6p ne 0)|FORM_BL_MH
prev_hrt_catheter|%str( and form_mh_complete not in (.,0) and penn_chart=1 and penn_chart_6p ne 0)|FORM_BL_MH
pcwp_12|%str( and form_mh_complete not in (.,0) and prev_hrt_catheter=1 and penn_chart_6p ne 0)|FORM_BL_MH
lvedp_16|%str( and form_mh_complete not in (.,0) and prev_hrt_catheter=1 and penn_chart_6p ne 0)|FORM_BL_MH
hrt_catheter_date|%str( and form_mh_complete not in (.,0) and prev_hrt_catheter=1 and penn_chart_6p ne 0)|FORM_BL_MH
pcwp_value|%str( and form_mh_complete not in (.,0) and pcwp_12=1 and penn_chart_6p ne 0)|FORM_BL_MH
lvedp_value|%str( and form_mh_complete not in (.,0) and lvedp_16=1 and penn_chart_6p ne 0)|FORM_BL_MH
prior_stress_test|%str( and form_mh_complete not in (.,0) and penn_chart=1 and penn_chart_6p ne 0)|FORM_BL_MH
stress_test_date|%str( and form_mh_complete not in (.,0) and prior_stress_test=1 and penn_chart_6p ne 0)|FORM_BL_MH
performed_by_date|%str( and form_mh_complete not in (.,0) and penn_chart=1 and penn_chart_6p ne 0)|FORM_BL_MH
penn_chart_6p|%str( and form_mh_8174_complete not in (.,0) and na_form_mh_p1_p2  ne  1 and penn_chart_6p ne 0)|FORM_BL_MH
age_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1 and penn_chart_6p ne 0)|FORM_BL_MH
gender_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1 and penn_chart_6p ne 0)|FORM_BL_MH
type_decent_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1 and penn_chart_6p ne 0)|FORM_BL_MH
acutecoronary_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1 and penn_chart_6p ne 0)|FORM_BL_MH
prior_angina_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1 and penn_chart_6p ne 0)|FORM_BL_MH
any_arrhythmia_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1 and penn_chart_6p ne 0)|FORM_BL_MH
valv_disease_surgery_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1 and penn_chart_6p ne 0)|FORM_BL_MH
htn_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1 and penn_chart_6p ne 0)|FORM_BL_MH
high_cholesterol_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1 and penn_chart_6p ne 0)|FORM_BL_MH
peripheral_vascular_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1 and penn_chart_6p ne 0)|FORM_BL_MH
diabetes_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1 and penn_chart_6p ne 0)|FORM_BL_MH
insulin_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1 and penn_chart_6p ne 0)|FORM_BL_MH
cva_tia_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1 and penn_chart_6p ne 0)|FORM_BL_MH
pulmonary_embolism_dvt_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1 and penn_chart_6p ne 0)|FORM_BL_MH
osa_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1 and penn_chart_6p ne 0)|FORM_BL_MH
cpap_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1 and penn_chart_6p ne 0)|FORM_BL_MH
copd_asthma_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1 and penn_chart_6p ne 0)|FORM_BL_MH
osteoarthritis_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1 and penn_chart_6p ne 0)|FORM_BL_MH
cabg_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1 and penn_chart_6p ne 0)|FORM_BL_MH
peripheral_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1 and penn_chart_6p ne 0)|FORM_BL_MH
valvular_surgery_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1 and penn_chart_6p ne 0)|FORM_BL_MH
congenital_surgery_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1 and penn_chart_6p ne 0)|FORM_BL_MH
trauma_requiring_surgery_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1 and penn_chart_6p ne 0)|FORM_BL_MH
current_smoker_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1 and penn_chart_6p ne 0)|FORM_BL_MH
pack_years_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1 and penn_chart_6p ne 0)|FORM_BL_MH
prior_smoker_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1 and penn_chart_6p ne 0)|FORM_BL_MH
current_alcohol_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1 and penn_chart_6p ne 0)|FORM_BL_MH
drinks_day_6p|%str( and form_mh_8174_complete not in (.,0) and current_alcohol_6p=1 and penn_chart_6p ne 0)|FORM_BL_MH
prior_alcohol_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1 and penn_chart_6p ne 0)|FORM_BL_MH
recreational_drug_use_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1 and penn_chart_6p ne 0)|FORM_BL_MH
date9_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1 and penn_chart_6p ne 0)|FORM_BL_MH
nyhaclass_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1 and penn_chart_6p ne 0)|FORM_BL_MH
orthopnea_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1 and penn_chart_6p ne 0)|FORM_BL_MH
paroxysmal_nocturnal_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1 and penn_chart_6p ne 0)|FORM_BL_MH
lower_extremity_edema_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1 and penn_chart_6p ne 0)|FORM_BL_MH
num_of_stairs_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1 and penn_chart_6p ne 0)|FORM_BL_MH
distance_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1 and penn_chart_6p ne 0)|FORM_BL_MH
block_miles_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1 and penn_chart_6p ne 0)|FORM_BL_MH
crvalue_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1 and penn_chart_6p ne 0)|FORM_BL_MH
crdate_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1 and penn_chart_6p ne 0)|FORM_BL_MH
egfr_value2_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1 and penn_chart_6p ne 0)|FORM_BL_MH
egfr_date_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1 and penn_chart_6p ne 0)|FORM_BL_MH
nt_pro_bnp_value_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1 and penn_chart_6p ne 0)|FORM_BL_MH
nt_pro_bnp_date_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1 and penn_chart_6p ne 0)|FORM_BL_MH
hemoglobin_value_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1 and penn_chart_6p ne 0)|FORM_BL_MH
hemoglobin_date_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1 and penn_chart_6p ne 0)|FORM_BL_MH
hematocrit_value_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1 and penn_chart_6p ne 0)|FORM_BL_MH
hematocrit_date_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1 and penn_chart_6p ne 0)|FORM_BL_MH
hemoglobin_a1c_value_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1 and penn_chart_6p ne 0)|FORM_BL_MH
hemoglobin_a1c_date_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1 and penn_chart_6p ne 0)|FORM_BL_MH
prev_hrt_catheter_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1 and penn_chart_6p ne 0)|FORM_BL_MH
hrt_catheter_date_6p|%str( and form_mh_8174_complete not in (.,0) and prev_hrt_catheter_6p=1 and penn_chart_6p ne 0)|FORM_BL_MH
pcwp_12_6p|%str( and form_mh_8174_complete not in (.,0) and prev_hrt_catheter_6p=1 and penn_chart_6p ne 0)|FORM_BL_MH
pcwp_value_6p|%str( and form_mh_8174_complete not in (.,0) and pcwp_12_6p=1 and penn_chart_6p ne 0)|FORM_BL_MH
lvedp_16_6p|%str( and form_mh_8174_complete not in (.,0) and prev_hrt_catheter_6p=1 and penn_chart_6p ne 0)|FORM_BL_MH
lvedp_value_6p|%str( and form_mh_8174_complete not in (.,0) and lvedp_16_6p=1 and penn_chart_6p ne 0)|FORM_BL_MH
prior_stress_test_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1 and penn_chart_6p ne 0)|FORM_BL_MH
stress_test_date_6p|%str( and form_mh_8174_complete not in (.,0) and prior_stress_test_6p=1 and penn_chart_6p ne 0)|FORM_BL_MH
performed_by_date_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1 and penn_chart_6p ne 0)|FORM_BL_MH
penn_chart_6p|%str( and form_mh_8174_complete not in (.,0) and na_form_mh_p1_p2  ne  1)|FORM_MH_P1_P2
age_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1)|FORM_MH_P1_P2
gender_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1)|FORM_MH_P1_P2
type_decent_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1)|FORM_MH_P1_P2
acutecoronary_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1)|FORM_MH_P1_P2
prior_angina_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1)|FORM_MH_P1_P2
any_arrhythmia_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1)|FORM_MH_P1_P2
valv_disease_surgery_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1)|FORM_MH_P1_P2
htn_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1)|FORM_MH_P1_P2
high_cholesterol_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1)|FORM_MH_P1_P2
peripheral_vascular_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1)|FORM_MH_P1_P2
diabetes_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1)|FORM_MH_P1_P2
insulin_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1)|FORM_MH_P1_P2
cva_tia_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1)|FORM_MH_P1_P2
pulmonary_embolism_dvt_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1)|FORM_MH_P1_P2
osa_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1)|FORM_MH_P1_P2
cpap_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1)|FORM_MH_P1_P2
copd_asthma_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1)|FORM_MH_P1_P2
osteoarthritis_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1)|FORM_MH_P1_P2
cabg_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1)|FORM_MH_P1_P2
peripheral_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1)|FORM_MH_P1_P2
valvular_surgery_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1)|FORM_MH_P1_P2
congenital_surgery_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1)|FORM_MH_P1_P2
trauma_requiring_surgery_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1)|FORM_MH_P1_P2
current_smoker_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1)|FORM_MH_P1_P2
pack_years_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1)|FORM_MH_P1_P2
prior_smoker_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1)|FORM_MH_P1_P2
current_alcohol_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1)|FORM_MH_P1_P2
drinks_day_6p|%str( and form_mh_8174_complete not in (.,0) and current_alcohol_6p=1)|FORM_MH_P1_P2
prior_alcohol_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1)|FORM_MH_P1_P2
recreational_drug_use_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1)|FORM_MH_P1_P2
date9_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1)|FORM_MH_P1_P2
nyhaclass_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1)|FORM_MH_P1_P2
orthopnea_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1)|FORM_MH_P1_P2
paroxysmal_nocturnal_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1)|FORM_MH_P1_P2
lower_extremity_edema_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1)|FORM_MH_P1_P2
num_of_stairs_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1)|FORM_MH_P1_P2
distance_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1)|FORM_MH_P1_P2
crvalue_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1)|FORM_MH_P1_P2
crdate_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1)|FORM_MH_P1_P2
egfr_value2_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1)|FORM_MH_P1_P2
egfr_date_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1)|FORM_MH_P1_P2
nt_pro_bnp_value_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1)|FORM_MH_P1_P2
nt_pro_bnp_date_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1)|FORM_MH_P1_P2
hemoglobin_value_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1)|FORM_MH_P1_P2
hemoglobin_date_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1)|FORM_MH_P1_P2
hematocrit_value_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1)|FORM_MH_P1_P2
hematocrit_date_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1)|FORM_MH_P1_P2
hemoglobin_a1c_value_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1)|FORM_MH_P1_P2
hemoglobin_a1c_date_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1)|FORM_MH_P1_P2
prev_hrt_catheter_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1)|FORM_MH_P1_P2
hrt_catheter_date_6p|%str( and form_mh_8174_complete not in (.,0) and prev_hrt_catheter_6p=1)|FORM_MH_P1_P2
pcwp_12_6p|%str( and form_mh_8174_complete not in (.,0) and prev_hrt_catheter_6p=1)|FORM_MH_P1_P2
pcwp_value_6p|%str( and form_mh_8174_complete not in (.,0) and pcwp_12_6p=1)|FORM_MH_P1_P2
lvedp_16_6p|%str( and form_mh_8174_complete not in (.,0) and prev_hrt_catheter_6p=1)|FORM_MH_P1_P2
lvedp_value_6p|%str( and form_mh_8174_complete not in (.,0) and lvedp_16_6p=1)|FORM_MH_P1_P2
prior_stress_test_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1)|FORM_MH_P1_P2
stress_test_date_6p|%str( and form_mh_8174_complete not in (.,0) and prior_stress_test_6p=1)|FORM_MH_P1_P2
performed_by_date_6p|%str( and form_mh_8174_complete not in (.,0) and penn_chart_6p=1)|FORM_MH_P1_P2
form_pe_obtained|%str( and form_pe_complete not in (.,0) and na_physical_exam  ne  1)|FORM_PE
height_2|%str( and form_pe_complete not in (.,0) and na_physical_exam  ne  1)|FORM_PE
height_2_units|%str( and form_pe_complete not in (.,0) and na_physical_exam  ne  1)|FORM_PE
weight_2|%str( and form_pe_complete not in (.,0) and na_physical_exam  ne  1)|FORM_PE
weight_2_units|%str( and form_pe_complete not in (.,0) and na_physical_exam  ne  1)|FORM_PE
systolic_2|%str( and form_pe_complete not in (.,0) and na_physical_exam  ne  1)|FORM_PE
diastolic_2|%str( and form_pe_complete not in (.,0) and na_physical_exam  ne  1)|FORM_PE
blood_pressure_arm_2|%str( and form_pe_complete not in (.,0) and na_physical_exam  ne  1)|FORM_PE
heart_rate_2|%str( and form_pe_complete not in (.,0) and na_physical_exam  ne  1)|FORM_PE
o2_saturation_2|%str( and form_pe_complete not in (.,0) and na_physical_exam  ne  1)|FORM_PE
rr_2|%str( and form_pe_complete not in (.,0) and na_physical_exam  ne  1)|FORM_PE
jvp_2|%str( and form_pe_complete not in (.,0) and na_physical_exam  ne  1)|FORM_PE
ekg|%str( and form_pe_complete not in (.,0) and na_physical_exam  ne  1)|FORM_PE
extremities_date|%str( and form_pe_complete not in (.,0) and na_physical_exam  ne  1)|FORM_PE
sup_systolic_2|%str( and form_pe_complete not in (.,0) and na_physical_exam  ne  1)|FORM_PE
sup_diastolic_2|%str( and form_pe_complete not in (.,0) and na_physical_exam  ne  1)|FORM_PE
stan_systolic_2|%str( and form_pe_complete not in (.,0) and na_physical_exam  ne  1)|FORM_PE
stan_diastolic_2|%str( and form_pe_complete not in (.,0) and na_physical_exam  ne  1)|FORM_PE
orthostatic_symptoms_yn|%str( and form_pe_complete not in (.,0) and na_physical_exam  ne  1)|FORM_PE
phys_date|%str( and form_pe_complete not in (.,0) and na_physical_exam  ne  1)|FORM_PE
iv_time_1|%str( and form_lab_6412_complete not in (.,0) and na_form_lab_pre_medication ne 1)|Form Lab Pre Medication
preg_test|%str( and form_lab_6412_complete not in (.,0) and na_form_lab_pre_medication ne 1)|Form Lab Pre Medication
cmp_gold|%str( and form_lab_6412_complete not in (.,0) and na_form_lab_pre_medication ne 1)|Form Lab Pre Medication
pax_gene|%str( and form_lab_6412_complete not in(.,0) and na_form_lab_pre_medication ne 1 and redcap_event_name in('week_6_phase_1_arm_1','week_6_phase_2_arm_1'))|Form Lab Pre Medication
form_lab_methemoglobin|%str( and form_lab_6412_complete not in (.,0) and na_form_lab_pre_medication ne 1)|Form Lab Pre Medication
form_lab_cbc|%str( and form_lab_6412_complete not in (.,0) and na_form_lab_pre_medication ne 1)|Form Lab Pre Medication
g6pd_test|%str( and form_lab_6412_complete not in (.,0) and na_form_lab_pre_medication ne 1)|Form Lab Pre Medication
urine_cc|%str( and form_lab_6412_complete not in (.,0) and na_form_lab_pre_medication ne 1)|Form Lab Pre Medication
plasma_purp|%str( and form_lab_6412_complete not in (.,0) and na_form_lab_pre_medication ne 1)|Form Lab Pre Medication
serum_red|%str( and form_lab_6412_complete not in (.,0) and na_form_lab_pre_medication ne 1)|Form Lab Pre Medication
saliva_tube|%str( and form_lab_6412_complete not in (.,0) and na_form_lab_pre_medication ne 1)|Form Lab Pre Medication
date_lab|%str( and form_lab_6412_complete not in (.,0) and na_form_lab_pre_medication ne 1)|Form Lab Pre Medication
mouthwash_se_ep|%str( and end_phase_side_effec_v_0 not in (.,0) and na_end_phase_se_review ne 1)|End Phase Side Effect Review
compliant_with_mouthwash_se_ep|%str( and end_phase_side_effec_v_0 not in (.,0) and na_end_phase_se_review ne 1)|End Phase Side Effect Review
reviewed_no_viagra_se_ep|%str( and end_phase_side_effec_v_0 not in (.,0) and na_end_phase_se_review ne 1)|End Phase Side Effect Review
dietary_restrictions_se_ep|%str( and end_phase_side_effec_v_0 not in (.,0) and na_end_phase_se_review ne 1)|End Phase Side Effect Review
headache_se_ep|%str( and end_phase_side_effec_v_0 not in (.,0) and na_end_phase_se_review ne 1)|End Phase Side Effect Review
dizziness_se_ep|%str( and end_phase_side_effec_v_0 not in (.,0) and na_end_phase_se_review ne 1)|End Phase Side Effect Review
lightheadedness_se_ep|%str( and end_phase_side_effec_v_0 not in (.,0) and na_end_phase_se_review ne 1)|End Phase Side Effect Review
low_blood_pressure_90_se_ep|%str( and end_phase_side_effec_v_0 not in (.,0) and na_end_phase_se_review ne 1)|End Phase Side Effect Review
stomach_ache_diarrhea_se_ep|%str( and end_phase_side_effec_v_0 not in (.,0) and na_end_phase_se_review ne 1)|End Phase Side Effect Review
increased_shortness_se_ep|%str( and end_phase_side_effec_v_0 not in (.,0) and na_end_phase_se_review ne 1)|End Phase Side Effect Review
flushing_se_ep|%str( and end_phase_side_effec_v_0 not in (.,0) and na_end_phase_se_review ne 1)|End Phase Side Effect Review
rash_se_ep|%str( and end_phase_side_effec_v_0 not in (.,0) and na_end_phase_se_review ne 1)|End Phase Side Effect Review
ch_in_blood_pressure_se_ep|%str( and end_phase_side_effec_v_0 not in (.,0) and na_end_phase_se_review ne 1)|End Phase Side Effect Review
swelling_se_ep|%str( and end_phase_side_effec_v_0 not in (.,0) and na_end_phase_se_review ne 1)|End Phase Side Effect Review
fatigue_se_assess|%str( and end_phase_side_effec_v_0 not in (.,0) and na_end_phase_se_review ne 1)|End Phase Side Effect Review
other_symps_se|%str( and end_phase_side_effec_v_0 not in (.,0) and na_end_phase_se_review ne 1)|End Phase Side Effect Review
orthostat_se_ep|%str( and end_phase_side_effec_v_0 not in (.,0) and na_end_phase_se_review ne 1)|End Phase Side Effect Review
phys_date_se_ep|%str( and end_phase_side_effec_v_0 not in (.,0) and na_end_phase_se_review ne 1)|End Phase Side Effect Review
form_p1_se_ep|%str( and end_phase_side_effec_v_0 not in (.,0) and na_end_phase_se_review ne 1)|End Phase Side Effect Review
date_med|%str( and medications_complete not in (.,0)  and na_medications ne 1)|Medications
num_med|%str( and medications_complete not in (.,0)  and na_medications ne 1)|Medications
meds_1|%str( and medications_complete not in (.,0)  and num_med>=1)|Medications
dose_1|%str( and medications_complete not in (.,0)  and num_med>=1)|Medications
units_1|%str( and medications_complete not in (.,0)  and num_med>=1)|Medications
freq_1|%str( and medications_complete not in (.,0)  and num_med>=1)|Medications
route_1|%str( and medications_complete not in (.,0)  and num_med>=1)|Medications
recent_start_date_1|%str( and medications_complete not in (.,0)  and num_med>=1)|Medications
start_date_1|%str( and medications_complete not in (.,0)  and recent_start_date_1=1)|Medications
recent_end_date_1|%str( and medications_complete not in (.,0)  and num_med>=1)|Medications
end_date_1|%str( and medications_complete not in (.,0)  and recent_end_date_1=1)|Medications
meds_2|%str( and medications_complete not in (.,0)  and num_med>=2)|Medications
dose_2|%str( and medications_complete not in (.,0)  and num_med>=2)|Medications
units_2|%str( and medications_complete not in (.,0)  and num_med>=2)|Medications
freq_2|%str( and medications_complete not in (.,0)  and num_med>=2)|Medications
route_2|%str( and medications_complete not in (.,0)  and num_med>=2)|Medications
recent_start_date_2|%str( and medications_complete not in (.,0)  and num_med>=2)|Medications
start_date_2|%str( and medications_complete not in (.,0)  and recent_start_date_2=1)|Medications
recent_end_date_2|%str( and medications_complete not in (.,0)  and num_med>=2)|Medications
end_date_2|%str( and medications_complete not in (.,0)  and recent_end_date_2=1)|Medications
meds_3|%str( and medications_complete not in (.,0)  and num_med>=3 )|Medications
dose_3|%str( and medications_complete not in (.,0)  and num_med>=3 )|Medications
units_3|%str( and medications_complete not in (.,0)  and num_med>=3 )|Medications
freq_3|%str( and medications_complete not in (.,0)  and num_med>=3 )|Medications
route_3|%str( and medications_complete not in (.,0)  and num_med>=3 )|Medications
recent_start_date_3|%str( and medications_complete not in (.,0)  and num_med>=3 )|Medications
start_date_3|%str( and medications_complete not in (.,0)  and recent_start_date_3=1)|Medications
recent_end_date_3|%str( and medications_complete not in (.,0)  and num_med>=3 )|Medications
end_date_3|%str( and medications_complete not in (.,0)  and recent_end_date_3=1)|Medications
meds_4|%str( and medications_complete not in (.,0)  and num_med>=4)|Medications
dose_4|%str( and medications_complete not in (.,0)  and num_med>=4)|Medications
units_4|%str( and medications_complete not in (.,0)  and num_med>=4)|Medications
freq_4|%str( and medications_complete not in (.,0)  and num_med>=4)|Medications
route_4|%str( and medications_complete not in (.,0)  and num_med>=4)|Medications
recent_start_date_4|%str( and medications_complete not in (.,0)  and num_med>=4)|Medications
start_date_4|%str( and medications_complete not in (.,0)  and recent_start_date_4=1)|Medications
recent_end_date_4|%str( and medications_complete not in (.,0)  and num_med>=4)|Medications
end_date_4|%str( and medications_complete not in (.,0)  and recent_end_date_4=1)|Medications
meds_5|%str( and medications_complete not in (.,0)  and num_med>=5)|Medications
dose_5|%str( and medications_complete not in (.,0)  and num_med>=5)|Medications
units_5|%str( and medications_complete not in (.,0)  and num_med>=5)|Medications
freq_5|%str( and medications_complete not in (.,0)  and num_med>=5)|Medications
route_5|%str( and medications_complete not in (.,0)  and num_med>=5)|Medications
recent_start_date_5|%str( and medications_complete not in (.,0)  and num_med>=5)|Medications
start_date_5|%str( and medications_complete not in (.,0)  and recent_start_date_5=1)|Medications
recent_end_date_5|%str( and medications_complete not in (.,0)  and num_med>=5)|Medications
end_date_5|%str( and medications_complete not in (.,0)  and recent_end_date_5=1)|Medications
meds_6|%str( and medications_complete not in (.,0)  and num_med>=6)|Medications
dose_6|%str( and medications_complete not in (.,0)  and num_med>=6)|Medications
units_6|%str( and medications_complete not in (.,0)  and num_med>=6)|Medications
freq_6|%str( and medications_complete not in (.,0)  and num_med>=6)|Medications
route_6|%str( and medications_complete not in (.,0)  and num_med>=6)|Medications
recent_start_date_6|%str( and medications_complete not in (.,0)  and num_med>=6)|Medications
start_date_6|%str( and medications_complete not in (.,0)  and recent_start_date_6=1)|Medications
recent_end_date_6|%str( and medications_complete not in (.,0)  and num_med>=6)|Medications
end_date_6|%str( and medications_complete not in (.,0)  and recent_end_date_6=1)|Medications
meds_7|%str( and medications_complete not in (.,0)  and num_med>=7)|Medications
dose_7|%str( and medications_complete not in (.,0)  and num_med>=7)|Medications
units_7|%str( and medications_complete not in (.,0)  and num_med>=7)|Medications
freq_7|%str( and medications_complete not in (.,0)  and num_med>=7)|Medications
route_7|%str( and medications_complete not in (.,0)  and num_med>=7)|Medications
recent_start_date_7|%str( and medications_complete not in (.,0)  and num_med>=7)|Medications
start_date_7|%str( and medications_complete not in (.,0)  and recent_start_date_7=1)|Medications
recent_end_date_7|%str( and medications_complete not in (.,0)  and num_med>=7)|Medications
end_date_7|%str( and medications_complete not in (.,0)  and recent_end_date_7=1)|Medications
meds_8|%str( and medications_complete not in (.,0)  and num_med>=8)|Medications
dose_8|%str( and medications_complete not in (.,0)  and num_med>=8)|Medications
units_8|%str( and medications_complete not in (.,0)  and num_med>=8)|Medications
freq_8|%str( and medications_complete not in (.,0)  and num_med>=8)|Medications
route_8|%str( and medications_complete not in (.,0)  and num_med>=8)|Medications
recent_start_date_8|%str( and medications_complete not in (.,0)  and num_med>=8)|Medications
start_date_8|%str( and medications_complete not in (.,0)  and recent_start_date_8=1)|Medications
recent_end_date_8|%str( and medications_complete not in (.,0)  and num_med>=8)|Medications
end_date_8|%str( and medications_complete not in (.,0)  and recent_end_date_8=1)|Medications
meds_9|%str( and medications_complete not in (.,0)  and num_med>=9)|Medications
dose_9|%str( and medications_complete not in (.,0)  and num_med>=9)|Medications
units_9|%str( and medications_complete not in (.,0)  and num_med>=9)|Medications
freq_9|%str( and medications_complete not in (.,0)  and num_med>=9)|Medications
route_9|%str( and medications_complete not in (.,0)  and num_med>=9)|Medications
recent_start_date_9|%str( and medications_complete not in (.,0)  and num_med>=9)|Medications
start_date_9|%str( and medications_complete not in (.,0)  and recent_start_date_9=1)|Medications
recent_end_date_9|%str( and medications_complete not in (.,0)  and num_med>=9)|Medications
end_date_9|%str( and medications_complete not in (.,0)  and recent_end_date_9=1)|Medications
meds_10|%str( and medications_complete not in (.,0)  and num_med>=10)|Medications
dose_10|%str( and medications_complete not in (.,0)  and num_med>=10)|Medications
units_10|%str( and medications_complete not in (.,0)  and num_med>=10)|Medications
freq_10|%str( and medications_complete not in (.,0)  and num_med>=10)|Medications
route_10|%str( and medications_complete not in (.,0)  and num_med>=10)|Medications
recent_start_date_10|%str( and medications_complete not in (.,0)  and num_med>=10)|Medications
start_date_10|%str( and medications_complete not in (.,0)  and recent_start_date_10=1)|Medications
recent_end_date_10|%str( and medications_complete not in (.,0)  and num_med>=10)|Medications
end_date_10|%str( and medications_complete not in (.,0)  and recent_end_date_10=1)|Medications
meds_11|%str( and medications_complete not in (.,0)  and num_med>=11)|Medications
dose_11|%str( and medications_complete not in (.,0)  and num_med>=11)|Medications
units_11|%str( and medications_complete not in (.,0)  and num_med>=11)|Medications
freq_11|%str( and medications_complete not in (.,0)  and num_med>=11)|Medications
route_11|%str( and medications_complete not in (.,0)  and num_med>=11)|Medications
recent_start_date_11|%str( and medications_complete not in (.,0)  and num_med>=11)|Medications
start_date_11|%str( and medications_complete not in (.,0)  and recent_start_date_11=1)|Medications
recent_end_date_11|%str( and medications_complete not in (.,0)  and num_med>=11)|Medications
end_date_11|%str( and medications_complete not in (.,0)  and recent_end_date_11=1)|Medications
meds_12|%str( and medications_complete not in (.,0)  and num_med>=12)|Medications
dose_12|%str( and medications_complete not in (.,0)  and num_med>=12)|Medications
units_12|%str( and medications_complete not in (.,0)  and num_med>=12)|Medications
freq_12|%str( and medications_complete not in (.,0)  and num_med>=12)|Medications
route_12|%str( and medications_complete not in (.,0)  and num_med>=12)|Medications
recent_start_date_12|%str( and medications_complete not in (.,0)  and num_med>=12)|Medications
start_date_12|%str( and medications_complete not in (.,0)  and recent_start_date_12=1)|Medications
recent_end_date_12|%str( and medications_complete not in (.,0)  and num_med>=12)|Medications
end_date_12|%str( and medications_complete not in (.,0)  and recent_end_date_12=1)|Medications
meds_13|%str( and medications_complete not in (.,0)  and num_med>=13)|Medications
dose_13|%str( and medications_complete not in (.,0)  and num_med>=13)|Medications
units_13|%str( and medications_complete not in (.,0)  and num_med>=13)|Medications
freq_13|%str( and medications_complete not in (.,0)  and num_med>=13)|Medications
route_13|%str( and medications_complete not in (.,0)  and num_med>=13)|Medications
recent_start_date_13|%str( and medications_complete not in (.,0)  and num_med>=13)|Medications
start_date_13|%str( and medications_complete not in (.,0)  and recent_start_date_13=1)|Medications
recent_end_date_13|%str( and medications_complete not in (.,0)  and num_med>=13)|Medications
end_date_13|%str( and medications_complete not in (.,0)  and recent_end_date_13=1)|Medications
meds_14|%str( and medications_complete not in (.,0)  and num_med>=14)|Medications
dose_14|%str( and medications_complete not in (.,0)  and num_med>=14)|Medications
units_14|%str( and medications_complete not in (.,0)  and num_med>=14)|Medications
freq_14|%str( and medications_complete not in (.,0)  and num_med>=14)|Medications
route_14|%str( and medications_complete not in (.,0)  and num_med>=14)|Medications
recent_start_date_14|%str( and medications_complete not in (.,0)  and num_med>=14)|Medications
start_date_14|%str( and medications_complete not in (.,0)  and recent_start_date_14=1)|Medications
recent_end_date_14|%str( and medications_complete not in (.,0)  and num_med>=14)|Medications
end_date_14|%str( and medications_complete not in (.,0)  and recent_end_date_14=1)|Medications
meds_15|%str( and medications_complete not in (.,0)  and num_med>=15)|Medications
dose_15|%str( and medications_complete not in (.,0)  and num_med>=15)|Medications
units_15|%str( and medications_complete not in (.,0)  and num_med>=15)|Medications
freq_15|%str( and medications_complete not in (.,0)  and num_med>=15)|Medications
route_15|%str( and medications_complete not in (.,0)  and num_med>=15)|Medications
recent_start_date_15|%str( and medications_complete not in (.,0)  and num_med>=15)|Medications
start_date_15|%str( and medications_complete not in (.,0)  and recent_start_date_15=1)|Medications
recent_end_date_15|%str( and medications_complete not in (.,0)  and num_med>=15)|Medications
end_date_15|%str( and medications_complete not in (.,0)  and recent_end_date_15=1)|Medications
meds_16|%str( and medications_complete not in (.,0)  and num_med>=16)|Medications
dose_16|%str( and medications_complete not in (.,0)  and num_med>=16)|Medications
units_16|%str( and medications_complete not in (.,0)  and num_med>=16)|Medications
freq_16|%str( and medications_complete not in (.,0)  and num_med>=16)|Medications
route_16|%str( and medications_complete not in (.,0)  and num_med>=16)|Medications
recent_start_date_16|%str( and medications_complete not in (.,0)  and num_med>=16)|Medications
start_date_16|%str( and medications_complete not in (.,0)  and recent_start_date_16=1)|Medications
recent_end_date_16|%str( and medications_complete not in (.,0)  and num_med>=16)|Medications
end_date_16|%str( and medications_complete not in (.,0)  and recent_end_date_16=1)|Medications
meds_17|%str( and medications_complete not in (.,0)  and num_med>=17)|Medications
dose_17|%str( and medications_complete not in (.,0)  and num_med>=17)|Medications
units_17|%str( and medications_complete not in (.,0)  and num_med>=17)|Medications
freq_17|%str( and medications_complete not in (.,0)  and num_med>=17)|Medications
route_17|%str( and medications_complete not in (.,0)  and num_med>=17)|Medications
recent_start_date_17|%str( and medications_complete not in (.,0)  and num_med>=17)|Medications
start_date_17|%str( and medications_complete not in (.,0)  and recent_start_date_17=1)|Medications
recent_end_date_17|%str( and medications_complete not in (.,0)  and num_med>=17)|Medications
end_date_17|%str( and medications_complete not in (.,0)  and recent_end_date_17=1)|Medications
meds_18|%str( and medications_complete not in (.,0)  and num_med>=18)|Medications
dose_18|%str( and medications_complete not in (.,0)  and num_med>=18)|Medications
units_18|%str( and medications_complete not in (.,0)  and num_med>=18)|Medications
freq_18|%str( and medications_complete not in (.,0)  and num_med>=18)|Medications
route_18|%str( and medications_complete not in (.,0)  and num_med>=18)|Medications
recent_start_date_18|%str( and medications_complete not in (.,0)  and num_med>=18)|Medications
start_date_18|%str( and medications_complete not in (.,0)  and recent_start_date_18=1)|Medications
recent_end_date_18|%str( and medications_complete not in (.,0)  and num_med>=18)|Medications
end_date_18|%str( and medications_complete not in (.,0)  and recent_end_date_18=1)|Medications
meds_19|%str( and medications_complete not in (.,0)  and num_med>=19)|Medications
dose_19|%str( and medications_complete not in (.,0)  and num_med>=19)|Medications
units_19|%str( and medications_complete not in (.,0)  and num_med>=19)|Medications
freq_19|%str( and medications_complete not in (.,0)  and num_med>=19)|Medications
route_19|%str( and medications_complete not in (.,0)  and num_med>=19)|Medications
recent_start_date_19|%str( and medications_complete not in (.,0)  and num_med>=19)|Medications
start_date_19|%str( and medications_complete not in (.,0)  and recent_start_date_19=1)|Medications
recent_end_date_19|%str( and medications_complete not in (.,0)  and num_med>=19)|Medications
end_date_19|%str( and medications_complete not in (.,0)  and recent_end_date_19=1)|Medications
meds_20|%str( and medications_complete not in (.,0)  and num_med>=20)|Medications
dose_20|%str( and medications_complete not in (.,0)  and num_med>=20)|Medications
units_20|%str( and medications_complete not in (.,0)  and num_med>=20)|Medications
freq_20|%str( and medications_complete not in (.,0)  and num_med>=20)|Medications
route_20|%str( and medications_complete not in (.,0)  and num_med>=20)|Medications
recent_start_date_20|%str( and medications_complete not in (.,0)  and num_med>=20)|Medications
start_date_20|%str( and medications_complete not in (.,0)  and recent_start_date_20=1)|Medications
recent_end_date_20|%str( and medications_complete not in (.,0)  and num_med>=20)|Medications
end_date_20|%str( and medications_complete not in (.,0)  and recent_end_date_20=1)|Medications
meds_21|%str( and medications_complete not in (.,0)  and num_med>=21)|Medications
dose_21|%str( and medications_complete not in (.,0)  and num_med>=21)|Medications
units_21|%str( and medications_complete not in (.,0)  and num_med>=21)|Medications
freq_21|%str( and medications_complete not in (.,0)  and num_med>=21)|Medications
route_21|%str( and medications_complete not in (.,0)  and num_med>=21)|Medications
recent_start_date_21|%str( and medications_complete not in (.,0)  and num_med>=21)|Medications
start_date_21|%str( and medications_complete not in (.,0)  and recent_start_date_21=1)|Medications
recent_end_date_21|%str( and medications_complete not in (.,0)  and num_med>=21)|Medications
end_date_21|%str( and medications_complete not in (.,0)  and recent_end_date_21=1)|Medications
meds_22|%str( and medications_complete not in (.,0)  and num_med>=22)|Medications
dose_22|%str( and medications_complete not in (.,0)  and num_med>=22)|Medications
units_22|%str( and medications_complete not in (.,0)  and num_med>=22)|Medications
freq_22|%str( and medications_complete not in (.,0)  and num_med>=22)|Medications
route_22|%str( and medications_complete not in (.,0)  and num_med>=22)|Medications
recent_start_date_22|%str( and medications_complete not in (.,0)  and num_med>=22)|Medications
start_date_22|%str( and medications_complete not in (.,0)  and recent_start_date_22=1)|Medications
recent_end_date_22|%str( and medications_complete not in (.,0)  and num_med>=22)|Medications
end_date_22|%str( and medications_complete not in (.,0)  and recent_end_date_22=1)|Medications
meds_23|%str( and medications_complete not in (.,0)  and num_med>=23)|Medications
dose_23|%str( and medications_complete not in (.,0)  and num_med>=23)|Medications
units_23|%str( and medications_complete not in (.,0)  and num_med>=23)|Medications
freq_23|%str( and medications_complete not in (.,0)  and num_med>=23)|Medications
route_23|%str( and medications_complete not in (.,0)  and num_med>=23)|Medications
recent_start_date_23|%str( and medications_complete not in (.,0)  and num_med>=23)|Medications
start_date_23|%str( and medications_complete not in (.,0)  and recent_start_date_23=1)|Medications
recent_end_date_23|%str( and medications_complete not in (.,0)  and num_med>=23)|Medications
end_date_23|%str( and medications_complete not in (.,0)  and recent_end_date_23=1)|Medications
meds_24|%str( and medications_complete not in (.,0)  and num_med>=24)|Medications
dose_24|%str( and medications_complete not in (.,0)  and num_med>=24)|Medications
units_24|%str( and medications_complete not in (.,0)  and num_med>=24)|Medications
freq_24|%str( and medications_complete not in (.,0)  and num_med>=24)|Medications
route_24|%str( and medications_complete not in (.,0)  and num_med>=24)|Medications
recent_start_date_24|%str( and medications_complete not in (.,0)  and num_med>=24)|Medications
start_date_24|%str( and medications_complete not in (.,0)  and recent_start_date_24=1)|Medications
recent_end_date_24|%str( and medications_complete not in (.,0)  and num_med>=24)|Medications
end_date_24|%str( and medications_complete not in (.,0)  and recent_end_date_24=1)|Medications
meds_25|%str( and medications_complete not in (.,0)  and num_med>=25)|Medications
dose_25|%str( and medications_complete not in (.,0)  and num_med>=25)|Medications
units_25|%str( and medications_complete not in (.,0)  and num_med>=25)|Medications
freq_25|%str( and medications_complete not in (.,0)  and num_med>=25)|Medications
route_25|%str( and medications_complete not in (.,0)  and num_med>=25)|Medications
recent_start_date_25|%str( and medications_complete not in (.,0)  and num_med>=25)|Medications
start_date_25|%str( and medications_complete not in (.,0)  and recent_start_date_25=1)|Medications
recent_end_date_25|%str( and medications_complete not in (.,0)  and num_med>=25)|Medications
end_date_25|%str( and medications_complete not in (.,0)  and recent_end_date_25=1)|Medications
meds_26|%str( and medications_complete not in (.,0)  and num_med>=26)|Medications
dose_26|%str( and medications_complete not in (.,0)  and num_med>=26)|Medications
units_26|%str( and medications_complete not in (.,0)  and num_med>=26)|Medications
freq_26|%str( and medications_complete not in (.,0)  and num_med>=26)|Medications
route_26|%str( and medications_complete not in (.,0)  and num_med>=26)|Medications
recent_start_date_26|%str( and medications_complete not in (.,0)  and num_med>=26)|Medications
start_date_26|%str( and medications_complete not in (.,0)  and recent_start_date_26=1)|Medications
recent_end_date_26|%str( and medications_complete not in (.,0)  and num_med>=26)|Medications
end_date_26|%str( and medications_complete not in (.,0)  and recent_end_date_26=1)|Medications
meds_27|%str( and medications_complete not in (.,0)  and num_med>=27)|Medications
dose_27|%str( and medications_complete not in (.,0)  and num_med>=27)|Medications
units_27|%str( and medications_complete not in (.,0)  and num_med>=27)|Medications
freq_27|%str( and medications_complete not in (.,0)  and num_med>=27)|Medications
route_27|%str( and medications_complete not in (.,0)  and num_med>=27)|Medications
recent_start_date_27|%str( and medications_complete not in (.,0)  and num_med>=27)|Medications
start_date_27|%str( and medications_complete not in (.,0)  and recent_start_date_27=1)|Medications
recent_end_date_27|%str( and medications_complete not in (.,0)  and num_med>=27)|Medications
end_date_27|%str( and medications_complete not in (.,0)  and recent_end_date_27=1)|Medications
meds_28|%str( and medications_complete not in (.,0)  and num_med>=28)|Medications
dose_28|%str( and medications_complete not in (.,0)  and num_med>=28)|Medications
units_28|%str( and medications_complete not in (.,0)  and num_med>=28)|Medications
freq_28|%str( and medications_complete not in (.,0)  and num_med>=28)|Medications
route_28|%str( and medications_complete not in (.,0)  and num_med>=28)|Medications
recent_start_date_28|%str( and medications_complete not in (.,0)  and num_med>=28)|Medications
start_date_28|%str( and medications_complete not in (.,0)  and recent_start_date_28=1)|Medications
recent_end_date_28|%str( and medications_complete not in (.,0)  and num_med>=28)|Medications
end_date_28|%str( and medications_complete not in (.,0)  and recent_end_date_28=1)|Medications
meds_29|%str( and medications_complete not in (.,0)  and num_med>=29)|Medications
dose_29|%str( and medications_complete not in (.,0)  and num_med>=29)|Medications
units_29|%str( and medications_complete not in (.,0)  and num_med>=29)|Medications
freq_29|%str( and medications_complete not in (.,0)  and num_med>=29)|Medications
route_29|%str( and medications_complete not in (.,0)  and num_med>=29)|Medications
recent_start_date_29|%str( and medications_complete not in (.,0)  and num_med>=29)|Medications
start_date_29|%str( and medications_complete not in (.,0)  and recent_start_date_29=1)|Medications
recent_end_date_29|%str( and medications_complete not in (.,0)  and num_med>=29)|Medications
end_date_29|%str( and medications_complete not in (.,0)  and recent_end_date_29=1)|Medications
meds_30|%str( and medications_complete not in (.,0)  and num_med>=30)|Medications
dose_30|%str( and medications_complete not in (.,0)  and num_med>=30)|Medications
units_30|%str( and medications_complete not in (.,0)  and num_med>=30)|Medications
freq_30|%str( and medications_complete not in (.,0)  and num_med>=30)|Medications
route_30|%str( and medications_complete not in (.,0)  and num_med>=30)|Medications
recent_start_date_30|%str( and medications_complete not in (.,0)  and num_med>=30)|Medications
start_date_30|%str( and medications_complete not in (.,0)  and recent_start_date_30=1)|Medications
recent_end_date_30|%str( and medications_complete not in (.,0)  and num_med>=30)|Medications
end_date_30|%str( and medications_complete not in (.,0)  and recent_end_date_30=1)|Medications
diet_complete|%str( and form_cns_complete not in (.,0) and na_counseling ne 1)|FORM CNS Counseling
date_diet|%str( and form_cns_complete not in (.,0) and na_counseling ne 1)|FORM CNS Counseling
shopping_test_yn|%str( and cognitive_testing_complete not in (.,0) and na_cognitive_testing ne 1)|FORM CT Cognitive Testing
gorton_test_yn|%str( and cognitive_testing_complete not in (.,0) and na_cognitive_testing ne 1)|FORM CT Cognitive Testing
detection_test_yn|%str( and cognitive_testing_complete not in (.,0) and na_cognitive_testing ne 1)|FORM CT Cognitive Testing
identification_test_yn|%str( and cognitive_testing_complete not in (.,0) and na_cognitive_testing ne 1)|FORM CT Cognitive Testing
card_test_yn|%str( and cognitive_testing_complete not in (.,0) and na_cognitive_testing ne 1)|FORM CT Cognitive Testing
one_back_test_yn|%str( and cognitive_testing_complete not in (.,0) and na_cognitive_testing ne 1)|FORM CT Cognitive Testing
delayed_recall_test_yn|%str( and cognitive_testing_complete not in (.,0) and na_cognitive_testing ne 1)|FORM CT Cognitive Testing
data_backed_up_yn|%str( and cognitive_testing_complete not in (.,0) and na_cognitive_testing ne 1)|FORM CT Cognitive Testing
form_ct_date|%str( and cognitive_testing_complete not in (.,0) and na_cognitive_testing ne 1)|FORM CT Cognitive Testing
iv_time_1_v2|%str( and form_lab_pre_medicat_v_1 not in (.,0) and na_form_lab_post_med ne 1)|Form Lab Post Medication
urine_post|%str( and form_lab_pre_medicat_v_1 not in (.,0) and na_form_lab_post_med ne 1)|Form Lab Post Medication
plasma_post|%str( and form_lab_pre_medicat_v_1 not in (.,0) and na_form_lab_post_med ne 1)|Form Lab Post Medication
serum_post|%str( and form_lab_pre_medicat_v_1 not in (.,0) and na_form_lab_post_med ne 1)|Form Lab Post Medication
saliva_post|%str( and form_lab_pre_medicat_v_1 not in (.,0) and na_form_lab_post_med ne 1)|Form Lab Post Medication
iv_time_1_v3|%str( and form_lab_pre_medicat_v_2 not in (.,0) and na_form_lab_peak_bike ne 1)|Form Lab Post Medication
plasma_bike|%str( and form_lab_pre_medicat_v_2 not in (.,0) and na_form_lab_peak_bike ne 1)|Form Lab Post Medication
serum_bike|%str( and form_lab_pre_medicat_v_2 not in (.,0) and na_form_lab_peak_bike ne 1)|Form Lab Post Medication
sternal_angle_to_carotid_1|%str( and form_vp_complete not in (.,0) and na_form_vp ne 1)|FORM VP Vascular Procedures
ster_carotid_1|%str( and form_vp_complete not in (.,0) and na_form_vp ne 1)|FORM VP Vascular Procedures
sternal_angle_to_femoral_1|%str( and form_vp_complete not in (.,0) and na_form_vp ne 1)|FORM VP Vascular Procedures
ster_femoral_1|%str( and form_vp_complete not in (.,0) and na_form_vp ne 1)|FORM VP Vascular Procedures
sternal_angle_to_radial_1|%str( and form_vp_complete not in (.,0) and na_form_vp ne 1)|FORM VP Vascular Procedures
ster_radial_1|%str( and form_vp_complete not in (.,0) and na_form_vp ne 1)|FORM VP Vascular Procedures
sternal_length|%str( and form_vp_complete not in (.,0) and na_form_vp ne 1)|FORM VP Vascular Procedures
bp_collected_yn|%str( and form_vp_complete not in (.,0) and na_form_vp ne 1)|FORM VP Vascular Procedures
bp_subject_id|%str( and form_vp_complete not in (.,0) and bp_collected_yn=1)|FORM VP Vascular Procedures
bp_plus_systolic|%str( and form_vp_complete not in (.,0) and bp_collected_yn=1)|FORM VP Vascular Procedures
bp_plus_diastolic|%str( and form_vp_complete not in (.,0) and bp_collected_yn=1)|FORM VP Vascular Procedures
pre_bike_systolic_1|%str( and form_vp_complete not in (.,0) and na_form_vp ne 1)|FORM VP Vascular Procedures
pre_bike_diastolic_1|%str( and form_vp_complete not in (.,0) and na_form_vp ne 1)|FORM VP Vascular Procedures
time_1|%str( and form_vp_complete not in (.,0) and na_form_vp ne 1)|FORM VP Vascular Procedures
hr_1|%str( and form_vp_complete not in (.,0) and na_form_vp ne 1)|FORM VP Vascular Procedures
carotid_1|%str( and form_vp_complete not in (.,0) and na_form_vp ne 1)|FORM VP Vascular Procedures
carotid_vasc|%str( and form_vp_complete not in (.,0) and na_form_vp ne 1)|FORM VP Vascular Procedures
femora_1|%str( and form_vp_complete not in (.,0) and na_form_vp ne 1)|FORM VP Vascular Procedures
femora_vasc|%str( and form_vp_complete not in (.,0) and na_form_vp ne 1)|FORM VP Vascular Procedures
radial_1|%str( and form_vp_complete not in (.,0) and na_form_vp ne 1)|FORM VP Vascular Procedures
radial_vasc|%str( and form_vp_complete not in (.,0) and na_form_vp ne 1)|FORM VP Vascular Procedures
lvot_flow|%str( and form_vp_complete not in (.,0) and na_form_vp ne 1)|FORM VP Vascular Procedures
form_vp_date|%str( and form_vp_complete not in (.,0) and na_form_vp ne 1)|FORM VP Vascular Procedures
na_form_6mwt | %str( and form_6mwt_complete not in (., 0)) | FORM 6MWT
dyspnea_borg_score | %str( and na_form_6mwt ne 1 and form_6mwt_complete not in (., 0)) | FORM 6MWT
fatigue_borg_score | %str( and na_form_6mwt ne 1 and form_6mwt_complete not in (., 0)) | FORM 6MWT
heart_rate | %str( and na_form_6mwt ne 1 and form_6mwt_complete not in (., 0)) | FORM 6MWT
pulse_oximetry | %str( and na_form_6mwt ne 1 and form_6mwt_complete not in (., 0)) | FORM 6MWT
systolic_bf | %str( and na_form_6mwt ne 1 and form_6mwt_complete not in (., 0)) | FORM 6MWT
diastolic_bf | %str( and na_form_6mwt ne 1 and form_6mwt_complete not in (., 0)) | FORM 6MWT
post_dyspnea_borg | %str( and na_form_6mwt ne 1 and form_6mwt_complete not in (., 0)) | FORM 6MWT
post_fatigue_borg | %str( and na_form_6mwt ne 1 and form_6mwt_complete not in (., 0)) | FORM 6MWT
post_bpm | %str( and na_form_6mwt ne 1 and form_6mwt_complete not in (., 0)) | FORM 6MWT
post_pulse_oximetry | %str( and na_form_6mwt ne 1 and form_6mwt_complete not in (., 0)) | FORM 6MWT
systolic_af | %str( and na_form_6mwt ne 1 and form_6mwt_complete not in (., 0)) | FORM 6MWT
diastolic_af | %str( and na_form_6mwt ne 1 and form_6mwt_complete not in (., 0)) | FORM 6MWT
test_start_time | %str( and na_form_6mwt ne 1 and form_6mwt_complete not in (., 0)) | FORM 6MWT
total_meters_walked | %str( and na_form_6mwt ne 1 and form_6mwt_complete not in (., 0)) | FORM 6MWT
perform_date | %str( and na_form_6mwt ne 1 and form_6mwt_complete not in (., 0)) | FORM 6MWT
na_form_6wk_ex | %str( and form_6wk_ex_complete not in (., 0)) | Form 6wk Ex
bicyc_1 | %str( and na_form_6wk_ex ne 1 and form_6wk_ex_complete not in (., 0)) | Form 6wk Ex
stage_1_yn | %str( and na_form_6wk_ex ne 1 and form_6wk_ex_complete not in (., 0)) | Form 6wk Ex
stage_1_systolic_1 | %str( and stage_1_yn = 1 and form_6wk_ex_complete not in (., 0)) | Form 6wk Ex
stage_1_diastolic_1 | %str( and stage_1_yn = 1 and form_6wk_ex_complete not in (., 0)) | Form 6wk Ex
stage_1_hr_1 | %str( and stage_1_yn = 1 and form_6wk_ex_complete not in (., 0)) | Form 6wk Ex
stage_1_o2_1 | %str( and stage_1_yn = 1 and form_6wk_ex_complete not in (., 0)) | Form 6wk Ex
stage_1_ultras_1 | %str( and stage_1_yn = 1 and form_6wk_ex_complete not in (., 0)) | Form 6wk Ex
stage_2_yn | %str( and stage_1_yn = 1 and form_6wk_ex_complete not in (., 0)) | Form 6wk Ex
stage_2_systolic_1 | %str( and stage_2_yn = 1 and form_6wk_ex_complete not in (., 0)) | Form 6wk Ex
stage_2_diastolic_1 | %str( and stage_2_yn = 1 and form_6wk_ex_complete not in (., 0)) | Form 6wk Ex
stage_2_hr_1 | %str( and stage_2_yn = 1 and form_6wk_ex_complete not in (., 0)) | Form 6wk Ex
stage_2_o2_1 | %str( and stage_2_yn = 1 and form_6wk_ex_complete not in (., 0)) | Form 6wk Ex
stage_2_ultras_1 | %str( and stage_2_yn = 1 and form_6wk_ex_complete not in (., 0)) | Form 6wk Ex
stage_3_yn | %str( and stage_2_yn = 1 and form_6wk_ex_complete not in (., 0)) | Form 6wk Ex
stage_3_systolic_1 | %str( and stage_3_yn = 1 and form_6wk_ex_complete not in (., 0)) | Form 6wk Ex
stage_3_diastolic_1 | %str( and stage_3_yn = 1 and form_6wk_ex_complete not in (., 0)) | Form 6wk Ex
stage_3_hr_1 | %str( and stage_3_yn = 1 and form_6wk_ex_complete not in (., 0)) | Form 6wk Ex
stage_3_o2_1 | %str( and stage_3_yn = 1 and form_6wk_ex_complete not in (., 0)) | Form 6wk Ex
stage_3_ultras_1 | %str( and stage_3_yn = 1 and form_6wk_ex_complete not in (., 0)) | Form 6wk Ex
stage_4_yn | %str( and stage_3_yn = 1 and form_6wk_ex_complete not in (., 0)) | Form 6wk Ex
stage_4_systolic_1 | %str( and stage_4_yn = 1 and form_6wk_ex_complete not in (., 0)) | Form 6wk Ex
stage_4_diastolic_1 | %str( and stage_4_yn = 1 and form_6wk_ex_complete not in (., 0)) | Form 6wk Ex
stage_4_hr_1 | %str( and stage_4_yn = 1 and form_6wk_ex_complete not in (., 0)) | Form 6wk Ex
stage_4_o2_1 | %str( and stage_4_yn = 1 and form_6wk_ex_complete not in (., 0)) | Form 6wk Ex
stage_4_ultras_1 | %str( and stage_4_yn = 1 and form_6wk_ex_complete not in (., 0)) | Form 6wk Ex
stage_5_yn | %str( and stage_4_yn = 1 and form_6wk_ex_complete not in (., 0)) | Form 6wk Ex
stage_5_systolic_1 | %str( and stage_5_yn = 1 and form_6wk_ex_complete not in (., 0)) | Form 6wk Ex
stage_5_diastolic_1 | %str( and stage_5_yn = 1 and form_6wk_ex_complete not in (., 0)) | Form 6wk Ex
stage_5_hr_1 | %str( and stage_5_yn = 1 and form_6wk_ex_complete not in (., 0)) | Form 6wk Ex
stage_5_o2_1 | %str( and stage_5_yn = 1 and form_6wk_ex_complete not in (., 0)) | Form 6wk Ex
stage_5_ultras_1 | %str( and stage_5_yn = 1 and form_6wk_ex_complete not in (., 0)) | Form 6wk Ex
stage_6_yn | %str( and stage_5_yn = 1 and form_6wk_ex_complete not in (., 0)) | Form 6wk Ex
stage_6_systolic_1 | %str( and stage_6_yn = 1 and form_6wk_ex_complete not in (., 0)) | Form 6wk Ex
stage_6_diastolic_1 | %str( and stage_6_yn = 1 and form_6wk_ex_complete not in (., 0)) | Form 6wk Ex
stage_6_hr_1 | %str( and stage_6_yn = 1 and form_6wk_ex_complete not in (., 0)) | Form 6wk Ex
stage_6_o2_1 | %str( and stage_6_yn = 1 and form_6wk_ex_complete not in (., 0)) | Form 6wk Ex
stage_6_ults_1 | %str( and stage_6_yn = 1 and form_6wk_ex_complete not in (., 0)) | Form 6wk Ex
stage_7_yn | %str( and stage_6_yn = 1 and form_6wk_ex_complete not in (., 0)) | Form 6wk Ex
stage_7_systolic_1 | %str( and stage_7_yn = 1 and form_6wk_ex_complete not in (., 0)) | Form 6wk Ex
stage_7_diastolic_1 | %str( and stage_7_yn = 1 and form_6wk_ex_complete not in (., 0)) | Form 6wk Ex
stage_7_hr_1 | %str( and stage_7_yn = 1 and form_6wk_ex_complete not in (., 0)) | Form 6wk Ex
stage_7_o2_1 | %str( and stage_7_yn = 1 and form_6wk_ex_complete not in (., 0)) | Form 6wk Ex
stage_7_ultras_1 | %str( and stage_7_yn = 1 and form_6wk_ex_complete not in (., 0)) | Form 6wk Ex
stage_8_yn | %str( and stage_7_yn = 1 and form_6wk_ex_complete not in (., 0)) | Form 6wk Ex
stage_8_systolic_1 | %str( and stage_8_yn = 1 and form_6wk_ex_complete not in (., 0)) | Form 6wk Ex
stage_8_diastolic_1 | %str( and stage_8_yn = 1 and form_6wk_ex_complete not in (., 0)) | Form 6wk Ex
stage_8_hr_1 | %str( and stage_8_yn = 1 and form_6wk_ex_complete not in (., 0)) | Form 6wk Ex
stage_8_o2_1 | %str( and stage_8_yn = 1 and form_6wk_ex_complete not in (., 0)) | Form 6wk Ex
stage_8_ultras_1 | %str( and stage_8_yn = 1 and form_6wk_ex_complete not in (., 0)) | Form 6wk Ex
stage_9_yn | %str( and stage_8_yn = 1 and form_6wk_ex_complete not in (., 0)) | Form 6wk Ex
stage_9_systolic_1 | %str( and stage_9_yn = 1 and form_6wk_ex_complete not in (., 0)) | Form 6wk Ex
stage_9_diastolic_1 | %str( and stage_9_yn = 1 and form_6wk_ex_complete not in (., 0)) | Form 6wk Ex
stage_9_hr_1 | %str( and stage_9_yn = 1 and form_6wk_ex_complete not in (., 0)) | Form 6wk Ex
stage_9_o2_1 | %str( and stage_9_yn = 1 and form_6wk_ex_complete not in (., 0)) | Form 6wk Ex
stage_9_ultras_1 | %str( and stage_9_yn = 1 and form_6wk_ex_complete not in (., 0)) | Form 6wk Ex
stage_10_yn | %str( and stage_9_yn = 1 and form_6wk_ex_complete not in (., 0)) | Form 6wk Ex
stage_10_systolic_1 | %str( and stage_10_yn = 1 and form_6wk_ex_complete not in (., 0)) | Form 6wk Ex
stage_10_diastolic_1 | %str( and stage_10_yn = 1 and form_6wk_ex_complete not in (., 0)) | Form 6wk Ex
stage_10_hr_1 | %str( and stage_10_yn = 1 and form_6wk_ex_complete not in (., 0)) | Form 6wk Ex
stage_10_o2_1 | %str( and stage_10_yn = 1 and form_6wk_ex_complete not in (., 0)) | Form 6wk Ex
stage_10_ultras_1 | %str( and stage_10_yn = 1 and form_6wk_ex_complete not in (., 0)) | Form 6wk Ex
peak_bld_systolic_1 | %str( and na_form_6wk_ex ne 1 and form_6wk_ex_complete not in (., 0)) | Form 6wk Ex
peak_bld_diastolic_1 | %str( and na_form_6wk_ex ne 1 and form_6wk_ex_complete not in (., 0)) | Form 6wk Ex
peak_hr_1 | %str( and na_form_6wk_ex ne 1 and form_6wk_ex_complete not in (., 0)) | Form 6wk Ex
peak_o2_sat_1 | %str( and na_form_6wk_ex ne 1 and form_6wk_ex_complete not in (., 0)) | Form 6wk Ex
peak_ultras_1 | %str( and na_form_6wk_ex ne 1 and form_6wk_ex_complete not in (., 0)) | Form 6wk Ex
recov_bld_systolic_1 | %str( and na_form_6wk_ex ne 1 and form_6wk_ex_complete not in (., 0)) | Form 6wk Ex
recov_bld_diastolic_1 | %str( and na_form_6wk_ex ne 1 and form_6wk_ex_complete not in (., 0)) | Form 6wk Ex
recov_hr_1 | %str( and na_form_6wk_ex ne 1 and form_6wk_ex_complete not in (., 0)) | Form 6wk Ex
recov_o2_1 | %str( and na_form_6wk_ex ne 1 and form_6wk_ex_complete not in (., 0)) | Form 6wk Ex
recov_ultras_1 | %str( and na_form_6wk_ex ne 1 and form_6wk_ex_complete not in (., 0)) | Form 6wk Ex
exerc_time_1 | %str( and na_form_6wk_ex ne 1 and form_6wk_ex_complete not in (., 0)) | Form 6wk Ex
peak_exerc_1 | %str( and na_form_6wk_ex ne 1 and form_6wk_ex_complete not in (., 0)) | Form 6wk Ex
peak_borg_1 | %str( and na_form_6wk_ex ne 1 and form_6wk_ex_complete not in (., 0)) | Form 6wk Ex
nirs_completed_yn | %str( and na_form_6wk_ex ne 1 and form_6wk_ex_complete not in (., 0)) | Form 6wk Ex
date_ex | %str( and na_form_6wk_ex ne 1 and form_6wk_ex_complete not in (., 0)) | Form 6wk Ex
complet_ex | %str( and na_form_6wk_ex ne 1 and form_6wk_ex_complete not in (., 0)) | Form 6wk Ex
na_form_lab_peak_bike | %str( and form_lab_pre_medicat_v_2 not in (., 0)) | Form Lab (Peak Bike)
iv_time_1_v3 | %str( and na_form_lab_peak_bike ne 1 and form_lab_pre_medicat_v_2 not in (., 0)) | Form Lab (Peak Bike)
plasma_bike | %str( and na_form_lab_peak_bike ne 1 and form_lab_pre_medicat_v_2 not in (., 0)) | Form Lab (Peak Bike)
serum_bike | %str( and na_form_lab_peak_bike ne 1 and form_lab_pre_medicat_v_2 not in (., 0)) | Form Lab (Peak Bike)
na_form_files | %str( and form_files_complete not in (., 0)) | FORM FILES
file1 | %str( and na_form_files ne 1 and form_files_complete not in (., 0)) | FORM FILES
file1_na | %str( and na_form_files ne 1 and form_files_complete not in (., 0)) | FORM FILES
file2 | %str( and na_form_files ne 1 and form_files_complete not in (., 0)) | FORM FILES
file2_na | %str( and na_form_files ne 1 and form_files_complete not in (., 0)) | FORM FILES
file3 | %str( and na_form_files ne 1 and form_files_complete not in (., 0)) | FORM FILES
file3_na | %str( and na_form_files ne 1 and form_files_complete not in (., 0)) | FORM FILES
file4 | %str( and na_form_files ne 1 and form_files_complete not in (., 0)) | FORM FILES
file4_na | %str( and na_form_files ne 1 and form_files_complete not in (., 0)) | FORM FILES
file5 | %str( and na_form_files ne 1 and form_files_complete not in (., 0)) | FORM FILES
file5_na | %str( and na_form_files ne 1 and form_files_complete not in (., 0)) | FORM FILES
file6 | %str( and na_form_files ne 1 and form_files_complete not in (., 0)) | FORM FILES
file6_na | %str( and na_form_files ne 1 and form_files_complete not in (., 0)) | FORM FILES
file7 | %str( and na_form_files ne 1 and form_files_complete not in (., 0)) | FORM FILES
file7_na | %str( and na_form_files ne 1 and form_files_complete not in (., 0)) | FORM FILES
file8 | %str( and na_form_files ne 1 and form_files_complete not in (., 0)) | FORM FILES
file8_na | %str( and na_form_files ne 1 and form_files_complete not in (., 0)) | FORM FILES
bike_ex_yn | %str( and na_form_files ne 1 and form_files_complete not in (., 0)) | FORM FILES
file9 | %str( and bike_ex_yn = 1 and form_files_complete not in (., 0)) | FORM FILES
file9_na | %str( and na_form_files ne 1 and form_files_complete not in (., 0)) | FORM FILES
aurora_export | %str( and na_form_files ne 1 and form_files_complete not in (., 0)) | FORM FILES
placed_in_jlab | %str( and na_form_files ne 1 and form_files_complete not in (., 0)) | FORM FILES
uploaded_to_redcap | %str( and na_form_files ne 1 and form_files_complete not in (., 0)) | FORM FILES
transmittal_sheet | %str( and na_form_files ne 1 and form_files_complete not in (., 0)) | FORM FILES
aurora_watch_transaction | %str( and na_form_files ne 1 and form_files_complete not in (., 0)) | FORM FILES
actigraph_transaction | %str( and na_form_files ne 1 and form_files_complete not in (., 0)) | FORM FILES
placed_calendar_reminder | %str( and na_form_files ne 1 and form_files_complete not in (., 0)) | FORM FILES
labs_signed | %str( and na_form_files ne 1 and form_files_complete not in (., 0)) | FORM FILES
g6pd | %str( and na_form_files ne 1 and form_files_complete not in (., 0)) | FORM FILES
completion | %str( and na_form_files ne 1 and form_files_complete not in (., 0)) | FORM FILES
date99 | %str( and na_form_files ne 1 and form_files_complete not in (., 0)) | FORM FILES
na_visit_lab_results | %str( and visit_lab_results_complete not in (., 0)) | Visit Lab Results
hemoglobin_vlr | %str( and na_visit_lab_results ne 1 and visit_lab_results_complete not in (., 0)) | Visit Lab Results
oxyhemoglobin_ | %str( and na_visit_lab_results ne 1 and visit_lab_results_complete not in (., 0)) | Visit Lab Results
o2_ct_ | %str( and na_visit_lab_results ne 1 and visit_lab_results_complete not in (., 0)) | Visit Lab Results
carboxyhemoglobin | %str( and na_visit_lab_results ne 1 and visit_lab_results_complete not in (., 0)) | Visit Lab Results
methemoglobin_ | %str( and na_visit_lab_results ne 1 and visit_lab_results_complete not in (., 0)) | Visit Lab Results
nt_pro_bnp_vlr | %str( and na_visit_lab_results ne 1 and visit_lab_results_complete not in (., 0)) | Visit Lab Results
white_blood_cells | %str( and na_visit_lab_results ne 1 and visit_lab_results_complete not in (., 0)) | Visit Lab Results
red_blood_cells | %str( and na_visit_lab_results ne 1 and visit_lab_results_complete not in (., 0)) | Visit Lab Results
hemoglobin_vlr2 | %str( and na_visit_lab_results ne 1 and visit_lab_results_complete not in (., 0)) | Visit Lab Results
hematocrit | %str( and na_visit_lab_results ne 1 and visit_lab_results_complete not in (., 0)) | Visit Lab Results
rdw | %str( and na_visit_lab_results ne 1 and visit_lab_results_complete not in (., 0)) | Visit Lab Results
mch | %str( and na_visit_lab_results ne 1 and visit_lab_results_complete not in (., 0)) | Visit Lab Results
mchc | %str( and na_visit_lab_results ne 1 and visit_lab_results_complete not in (., 0)) | Visit Lab Results
mcv | %str( and na_visit_lab_results ne 1 and visit_lab_results_complete not in (., 0)) | Visit Lab Results
platelets | %str( and na_visit_lab_results ne 1 and visit_lab_results_complete not in (., 0)) | Visit Lab Results
glucose | %str( and na_visit_lab_results ne 1 and visit_lab_results_complete not in (., 0)) | Visit Lab Results
urea_nitrogen | %str( and na_visit_lab_results ne 1 and visit_lab_results_complete not in (., 0)) | Visit Lab Results
creatinine | %str( and na_visit_lab_results ne 1 and visit_lab_results_complete not in (., 0)) | Visit Lab Results
sodium | %str( and na_visit_lab_results ne 1 and visit_lab_results_complete not in (., 0)) | Visit Lab Results
potassium | %str( and na_visit_lab_results ne 1 and visit_lab_results_complete not in (., 0)) | Visit Lab Results
chloride | %str( and na_visit_lab_results ne 1 and visit_lab_results_complete not in (., 0)) | Visit Lab Results
carbon_dioxide | %str( and na_visit_lab_results ne 1 and visit_lab_results_complete not in (., 0)) | Visit Lab Results
anion_gap | %str( and na_visit_lab_results ne 1 and visit_lab_results_complete not in (., 0)) | Visit Lab Results
calcium | %str( and na_visit_lab_results ne 1 and visit_lab_results_complete not in (., 0)) | Visit Lab Results
protein_total | %str( and na_visit_lab_results ne 1 and visit_lab_results_complete not in (., 0)) | Visit Lab Results
albumin | %str( and na_visit_lab_results ne 1 and visit_lab_results_complete not in (., 0)) | Visit Lab Results
biblirubin_total | %str( and na_visit_lab_results ne 1 and visit_lab_results_complete not in (., 0)) | Visit Lab Results
alkaline_phosphatase | %str( and na_visit_lab_results ne 1 and visit_lab_results_complete not in (., 0)) | Visit Lab Results
ast_vlr | %str( and na_visit_lab_results ne 1 and visit_lab_results_complete not in (., 0)) | Visit Lab Results
alt_vlr | %str( and na_visit_lab_results ne 1 and visit_lab_results_complete not in (., 0)) | Visit Lab Results
egfr_non_aa | %str( and na_visit_lab_results ne 1 and visit_lab_results_complete not in (., 0)) | Visit Lab Results
non_aa_oth | %str( and egfr_non_aa = 99 and visit_lab_results_complete not in (., 0)) | Visit Lab Results
egfr_aa | %str( and na_visit_lab_results ne 1 and visit_lab_results_complete not in (., 0)) | Visit Lab Results
aa_oth | %str( and egfr_aa = 99 and visit_lab_results_complete not in (., 0)) | Visit Lab Results
g6pd_vlr_yn | %str( and na_visit_lab_results ne 1 and visit_lab_results_complete not in (., 0)) | Visit Lab Results
g6pd_result | %str( and g6pd_vlr_yn = 1 and visit_lab_results_complete not in (., 0)) | Visit Lab Results
na_observation_notes | %str( and observationsnotes_complete not in (., 0)) | Observations Notes
obs_notes_yn | %str( and na_observation_notes ne 1 and observationsnotes_complete not in (., 0)) | Observations Notes
na_form_6wk_mri | %str( and form_6wk_mri_complete not in (., 0)) | FORM 6WK_MRI
mri_safety_checklist | %str( and na_form_6wk_mri ne 1 and form_6wk_mri_complete not in (., 0)) | FORM 6WK_MRI
field_strength1 | %str( and na_form_6wk_mri ne 1 and form_6wk_mri_complete not in (., 0)) | FORM 6WK_MRI
number_of_repetitions | %str( and na_form_6wk_mri ne 1 and form_6wk_mri_complete not in (., 0)) | FORM 6WK_MRI
number_of_repetitions1 | %str( and na_form_6wk_mri ne 1 and form_6wk_mri_complete not in (., 0)) | FORM 6WK_MRI
data_exported | %str( and na_form_6wk_mri ne 1 and form_6wk_mri_complete not in (., 0)) | FORM 6WK_MRI
date98 | %str( and na_form_6wk_mri ne 1 and form_6wk_mri_complete not in (., 0)) | FORM 6WK_MRI
na_form_devices | %str( and form_devices_complete not in (., 0)) | Form Devices
device_given | %str( and na_form_devices ne 1 and form_devices_complete not in (., 0)) | Form Devices
device_given_date | %str( and device_given = 1 and form_devices_complete not in (., 0)) | Form Devices
device_given_time | %str( and device_given = 1 and form_devices_complete not in (., 0)) | Form Devices
devices_mailed | %str( and na_form_devices ne 1 and form_devices_complete not in (., 0)) | Form Devices
date_device_mailed | %str( and devices_mailed = 1 and form_devices_complete not in (., 0)) | Form Devices
device_mailed | %str( and devices_mailed = 1 and form_devices_complete not in (., 0)) | Form Devices
date_device_receiv | %str( and devices_mailed = 1 and form_devices_complete not in (., 0)) | Form Devices
time_reciev | %str( and devices_mailed = 1 and form_devices_complete not in (., 0)) | Form Devices
date_aurora_on | %str( and devices_mailed = 1 and form_devices_complete not in (., 0)) | Form Devices
time_aurora_on | %str( and devices_mailed = 1 and form_devices_complete not in (., 0)) | Form Devices
date_aurora_off | %str( and devices_mailed = 1 and form_devices_complete not in (., 0)) | Form Devices
time_aurora_off | %str( and devices_mailed = 1 and form_devices_complete not in (., 0)) | Form Devices
date_actigraph_on | %str( and devices_mailed = 1 and form_devices_complete not in (., 0)) | Form Devices
time_actigraph_on | %str( and devices_mailed = 1 and form_devices_complete not in (., 0)) | Form Devices
date_actigraph_off | %str( and devices_mailed = 1 and form_devices_complete not in (., 0)) | Form Devices
time_actigraph_off | %str( and devices_mailed = 1 and form_devices_complete not in (., 0)) | Form Devices
date_returned | %str( and na_form_devices ne 1 and form_devices_complete not in (., 0)) | Form Devices
dev_date | %str( and na_form_devices ne 1 and form_devices_complete not in (., 0)) | Form Devices
na_early_termination_form | %str( and early_termination_fo_v_3 not in (., 0)) | Early Termination Form
early_term_yn | %str( and na_early_termination_form ne 1 and early_termination_fo_v_3 not in (., 0)) | Early Termination Form
dop_kno3 | %str( and early_term_yn = 1 and early_termination_fo_v_3 not in (., 0)) | Early Termination Form
tablets_prvd_kno3 | %str( and early_term_yn = 1 and early_termination_fo_v_3 not in (., 0)) | Early Termination Form
tablets_rtrnd_kno3 | %str( and early_term_yn = 1 and early_termination_fo_v_3 not in (., 0)) | Early Termination Form
expected_kno3 | %str( and early_term_yn = 1 and early_termination_fo_v_3 not in (., 0)) | Early Termination Form
compliance_kno3 | %str( and early_term_yn = 1 and early_termination_fo_v_3 not in (., 0)) | Early Termination Form
date_visit | %str( and early_term_yn = 1 and early_termination_fo_v_3 not in (., 0)) | Early Termination Form
iv_line_required_1_et | %str( and early_term_yn = 1 and early_termination_fo_v_3 not in (., 0)) | Early Termination Form
iv_time_1_et | %str( and iv_line_required_1_et = 1 and early_termination_fo_v_3 not in (., 0)) | Early Termination Form
preg_test_et | %str( and iv_line_required_1_et = 1 and early_termination_fo_v_3 not in (., 0)) | Early Termination Form
cmp_gold_et | %str( and iv_line_required_1_et = 1 and early_termination_fo_v_3 not in (., 0)) | Early Termination Form
nt_pro_et | %str( and iv_line_required_1_et = 1 and early_termination_fo_v_3 not in (., 0)) | Early Termination Form
cmp_gold2_4e8_et | %str( and iv_line_required_1_et = 1 and early_termination_fo_v_3 not in (., 0)) | Early Termination Form
cmp_gold2_c0d_et | %str( and iv_line_required_1_et = 1 and early_termination_fo_v_3 not in (., 0)) | Early Termination Form
g6pd_gold_tube_et | %str( and iv_line_required_1_et = 1 and early_termination_fo_v_3 not in (., 0)) | Early Termination Form
date_lab_et | %str( and iv_line_required_1_et = 1 and early_termination_fo_v_3 not in (., 0)) | Early Termination Form
headache_se_ep_et | %str( and early_term_yn = 1 and early_termination_fo_v_3 not in (., 0)) | Early Termination Form
dizziness_se_ep_et | %str( and early_term_yn = 1 and early_termination_fo_v_3 not in (., 0)) | Early Termination Form
lightheadedness_se_ep_et | %str( and early_term_yn = 1 and early_termination_fo_v_3 not in (., 0)) | Early Termination Form
low_blood_pressure_90_se_ep_et | %str( and early_term_yn = 1 and early_termination_fo_v_3 not in (., 0)) | Early Termination Form
stomach_ache_diarrhea_se_ep_et | %str( and early_term_yn = 1 and early_termination_fo_v_3 not in (., 0)) | Early Termination Form
increased_shortness_se_ep_et | %str( and early_term_yn = 1 and early_termination_fo_v_3 not in (., 0)) | Early Termination Form
flushing_se_ep_et | %str( and early_term_yn = 1 and early_termination_fo_v_3 not in (., 0)) | Early Termination Form
rash_se_ep_et | %str( and early_term_yn = 1 and early_termination_fo_v_3 not in (., 0)) | Early Termination Form
ch_in_blood_pressure_se_ep_et | %str( and early_term_yn = 1 and early_termination_fo_v_3 not in (., 0)) | Early Termination Form
swelling_se_ep_et | %str( and early_term_yn = 1 and early_termination_fo_v_3 not in (., 0)) | Early Termination Form
fatigue_se_assess_et | %str( and early_term_yn = 1 and early_termination_fo_v_3 not in (., 0)) | Early Termination Form
other_symps_se_et | %str( and early_term_yn = 1 and early_termination_fo_v_3 not in (., 0)) | Early Termination Form
orthostat_se_ep_et | %str( and early_term_yn = 1 and early_termination_fo_v_3 not in (., 0)) | Early Termination Form
phys_date_se_ep_et | %str( and early_term_yn = 1 and early_termination_fo_v_3 not in (., 0)) | Early Termination Form
height_et | %str( and early_term_yn = 1 and early_termination_fo_v_3 not in (., 0)) | Early Termination Form
height_units_et | %str( and early_term_yn = 1 and early_termination_fo_v_3 not in (., 0)) | Early Termination Form
weight_et | %str( and early_term_yn = 1 and early_termination_fo_v_3 not in (., 0)) | Early Termination Form
weight_units_et | %str( and early_term_yn = 1 and early_termination_fo_v_3 not in (., 0)) | Early Termination Form
systolic_2_et | %str( and early_term_yn = 1 and early_termination_fo_v_3 not in (., 0)) | Early Termination Form
diastolic_2_et | %str( and early_term_yn = 1 and early_termination_fo_v_3 not in (., 0)) | Early Termination Form
blood_pressure_arm_2_et | %str( and early_term_yn = 1 and early_termination_fo_v_3 not in (., 0)) | Early Termination Form
heart_rate_2_et | %str( and early_term_yn = 1 and early_termination_fo_v_3 not in (., 0)) | Early Termination Form
o2_saturation_2_et | %str( and early_term_yn = 1 and early_termination_fo_v_3 not in (., 0)) | Early Termination Form
rr_2_et | %str( and early_term_yn = 1 and early_termination_fo_v_3 not in (., 0)) | Early Termination Form
jvp_2_et | %str( and early_term_yn = 1 and early_termination_fo_v_3 not in (., 0)) | Early Termination Form
ekg_performed_et | %str( and early_term_yn = 1 and early_termination_fo_v_3 not in (., 0)) | Early Termination Form
extremities_date_et | %str( and early_term_yn = 1 and early_termination_fo_v_3 not in (., 0)) | Early Termination Form
sup_systolic_2_et | %str( and early_term_yn = 1 and early_termination_fo_v_3 not in (., 0)) | Early Termination Form
sup_diastolic_2_et | %str( and early_term_yn = 1 and early_termination_fo_v_3 not in (., 0)) | Early Termination Form
stan_systolic_2_et | %str( and early_term_yn = 1 and early_termination_fo_v_3 not in (., 0)) | Early Termination Form
stan_diastolic_2_et | %str( and early_term_yn = 1 and early_termination_fo_v_3 not in (., 0)) | Early Termination Form
orthostatic_symptoms_yn_et | %str( and early_term_yn = 1 and early_termination_fo_v_3 not in (., 0)) | Early Termination Form
phys_date_et | %str( and early_term_yn = 1 and early_termination_fo_v_3 not in (., 0)) | Early Termination Form
na_form_med_ver_p1 | %str( and form_med_ver_p1_complete not in (., 0)) | FORM MED_VER_P1
medicaton_verification_p1 | %str( and na_form_med_ver_p1 ne 1 and form_med_ver_p1_complete not in (., 0)) | FORM MED_VER_P1
med_ver_num_of_days_p1 | %str( and na_form_med_ver_p1 ne 1 and form_med_ver_p1_complete not in (., 0)) | FORM MED_VER_P1
date_of_call_p1 | %str( and medicaton_verification_p1 = 1 and form_med_ver_p1_complete not in (., 0)) | FORM MED_VER_P1
time_of_call_p1 | %str( and medicaton_verification_p1 = 1 and form_med_ver_p1_complete not in (., 0)) | FORM MED_VER_P1
med_dispensed | %str( and na_form_med_ver_p1 ne 1 and form_med_ver_p1_complete not in (., 0)) | FORM MED_VER_P1
date_of_med_p1 | %str( and na_form_med_ver_p1 ne 1 and form_med_ver_p1_complete not in (., 0)) | FORM MED_VER_P1
time_num_p1 | %str( and na_form_med_ver_p1 ne 1 and form_med_ver_p1_complete not in (., 0)) | FORM MED_VER_P1
na_form_med_ver_p2 | %str( and form_med_ver_complete not in (., 0)) | FORM MED_VER_P2
medicaton_verification | %str( and na_form_med_ver_p2 ne 1 and form_med_ver_complete not in (., 0)) | FORM MED_VER_P2
num_days_after_bl | %str( and na_form_med_ver_p2 ne 1 and form_med_ver_complete not in (., 0)) | FORM MED_VER_P2
date_of_call | %str( and na_form_med_ver_p2 ne 1 and form_med_ver_complete not in (., 0)) | FORM MED_VER_P2
time_of_call | %str( and na_form_med_ver_p2 ne 1 and form_med_ver_complete not in (., 0)) | FORM MED_VER_P2
date_of_med | %str( and na_form_med_ver_p2 ne 1 and form_med_ver_complete not in (., 0)) | FORM MED_VER_P2
time_num | %str( and na_form_med_ver_p2 ne 1 and form_med_ver_complete not in (., 0)) | FORM MED_VER_P2
na_wk_call | %str( and wk_call_complete not in (., 0)) | 1 WK Call
mouthwash | %str( and na_wk_call ne 1 and wk_call_complete not in (., 0)) | 1 WK Call
compliant_with_mouthwash | %str( and na_wk_call ne 1 and wk_call_complete not in (., 0)) | 1 WK Call
reviewed_no_viagra | %str( and na_wk_call ne 1 and wk_call_complete not in (., 0)) | 1 WK Call
dietary_restrictions | %str( and na_wk_call ne 1 and wk_call_complete not in (., 0)) | 1 WK Call
headache | %str( and na_wk_call ne 1 and wk_call_complete not in (., 0)) | 1 WK Call
dizziness | %str( and na_wk_call ne 1 and wk_call_complete not in (., 0)) | 1 WK Call
lightheadedness | %str( and na_wk_call ne 1 and wk_call_complete not in (., 0)) | 1 WK Call
low_blood_pressure_90 | %str( and na_wk_call ne 1 and wk_call_complete not in (., 0)) | 1 WK Call
stomach_ache_diarrhea | %str( and na_wk_call ne 1 and wk_call_complete not in (., 0)) | 1 WK Call
increased_shortness | %str( and na_wk_call ne 1 and wk_call_complete not in (., 0)) | 1 WK Call
flushing | %str( and na_wk_call ne 1 and wk_call_complete not in (., 0)) | 1 WK Call
rash | %str( and na_wk_call ne 1 and wk_call_complete not in (., 0)) | 1 WK Call
changes_in_blood_pressure | %str( and na_wk_call ne 1 and wk_call_complete not in (., 0)) | 1 WK Call
swelling | %str( and na_wk_call ne 1 and wk_call_complete not in (., 0)) | 1 WK Call
fatigue | %str( and na_wk_call ne 1 and wk_call_complete not in (., 0)) | 1 WK Call
oth_symps | %str( and na_wk_call ne 1 and wk_call_complete not in (., 0)) | 1 WK Call
presence | %str( and na_wk_call ne 1 and wk_call_complete not in (., 0)) | 1 WK Call
amount_of_meds | %str( and na_wk_call ne 1 and wk_call_complete not in (., 0)) | 1 WK Call
date_uptitrated_fmh | %str( and amount_of_meds = 1 and wk_call_complete not in (., 0)) | 1 WK Call
date_remn_fmh | %str( and amount_of_meds = 0 and wk_call_complete not in (., 0)) | 1 WK Call
date0934 | %str( and na_wk_call ne 1 and wk_call_complete not in (., 0)) | 1 WK Call
na_se_assessment_form | %str( and side_effect_assessme_v_4 not in (., 0)) | Side Effect Assessment Form
side_efft_asst_yn | %str( and na_se_assessment_form ne 1 and side_effect_assessme_v_4 not in (., 0)) | Side Effect Assessment Form
heart_rate_2_se | %str( and side_efft_asst_yn = 1 and side_effect_assessme_v_4 not in (., 0)) | Side Effect Assessment Form
o2_saturation_2_se | %str( and side_efft_asst_yn = 1 and side_effect_assessme_v_4 not in (., 0)) | Side Effect Assessment Form
systolic_2_se | %str( and side_efft_asst_yn = 1 and side_effect_assessme_v_4 not in (., 0)) | Side Effect Assessment Form
diastolic_2_se | %str( and side_efft_asst_yn = 1 and side_effect_assessme_v_4 not in (., 0)) | Side Effect Assessment Form
systolic_2_se2 | %str( and side_efft_asst_yn = 1 and side_effect_assessme_v_4 not in (., 0)) | Side Effect Assessment Form
diastolic_2_se2 | %str( and side_efft_asst_yn = 1 and side_effect_assessme_v_4 not in (., 0)) | Side Effect Assessment Form
orthostat_se | %str( and side_efft_asst_yn = 1 and side_effect_assessme_v_4 not in (., 0)) | Side Effect Assessment Form
date0934_se2_0b2 | %str( and side_efft_asst_yn = 1 and side_effect_assessme_v_4 not in (., 0)) | Side Effect Assessment Form
mouthwash_se | %str( and side_efft_asst_yn = 1 and side_effect_assessme_v_4 not in (., 0)) | Side Effect Assessment Form
compliant_with_mouthwash_se | %str( and side_efft_asst_yn = 1 and side_effect_assessme_v_4 not in (., 0)) | Side Effect Assessment Form
reviewed_no_viagra_se | %str( and side_efft_asst_yn = 1 and side_effect_assessme_v_4 not in (., 0)) | Side Effect Assessment Form
dietary_restrictions_se | %str( and side_efft_asst_yn = 1 and side_effect_assessme_v_4 not in (., 0)) | Side Effect Assessment Form
headache_se | %str( and side_efft_asst_yn = 1 and side_effect_assessme_v_4 not in (., 0)) | Side Effect Assessment Form
dizziness_se | %str( and side_efft_asst_yn = 1 and side_effect_assessme_v_4 not in (., 0)) | Side Effect Assessment Form
lightheadedness_se | %str( and side_efft_asst_yn = 1 and side_effect_assessme_v_4 not in (., 0)) | Side Effect Assessment Form
low_blood_pressure_90_se | %str( and side_efft_asst_yn = 1 and side_effect_assessme_v_4 not in (., 0)) | Side Effect Assessment Form
stomach_ache_diarrhea_se | %str( and side_efft_asst_yn = 1 and side_effect_assessme_v_4 not in (., 0)) | Side Effect Assessment Form
increased_shortness_se | %str( and side_efft_asst_yn = 1 and side_effect_assessme_v_4 not in (., 0)) | Side Effect Assessment Form
flushing_se | %str( and side_efft_asst_yn = 1 and side_effect_assessme_v_4 not in (., 0)) | Side Effect Assessment Form
rash_se | %str( and side_efft_asst_yn = 1 and side_effect_assessme_v_4 not in (., 0)) | Side Effect Assessment Form
changes_in_blood_pressure_se | %str( and side_efft_asst_yn = 1 and side_effect_assessme_v_4 not in (., 0)) | Side Effect Assessment Form
swelling_se | %str( and side_efft_asst_yn = 1 and side_effect_assessme_v_4 not in (., 0)) | Side Effect Assessment Form
fatigue_se | %str( and side_efft_asst_yn = 1 and side_effect_assessme_v_4 not in (., 0)) | Side Effect Assessment Form
date0934_se | %str( and side_efft_asst_yn = 1 and side_effect_assessme_v_4 not in (., 0)) | Side Effect Assessment Form
med_regimen_change | %str( and side_efft_asst_yn = 1 and side_effect_assessme_v_4 not in (., 0)) | Side Effect Assessment Form
phys_date_se | %str( and side_efft_asst_yn = 1 and side_effect_assessme_v_4 not in (., 0)) | Side Effect Assessment Form
form_p1_se | %str( and side_efft_asst_yn = 1 and side_effect_assessme_v_4 not in (., 0)) | Side Effect Assessment Form
;
/*CHECK THAT THE DATASET HAS 3 FIELDS*/
proc contents data= macro_variables;run;
proc print data=macro_variables;run;






data id_i;
set derived.ko_up_randomized ;
where study_id = "KT-1-01" ;
run;


%macro missing(ID, variable, logic, title);
proc print data= id_i label noobs;
where missing(&variable) &logic;
var study_id redcap_event_name &variable;
title1 "&ID";
title2 "&title";
title3 "&variable";
run;
%mend;
/*CHECK USING 1 ID*/
/*%missing(KT-1-01, tonometry_file1, %str( and path_and_files_complete not in (.,0) and na_path_and_files  ne  1), Path And Files); */

/*CHECK %missing(ID, variable, logic, title) WITH CALL EXECUTE ON work.macro_variables*/
/*data temp;*/
data _null_;
    set work.macro_variables;
/*    set work.report;*/
*    macro_call = cats('%missing(', study_id, ',', variable, ',', logic, ',', title,')');
    macro_call = '%missing(KT-1-01, file1, %str( and form_files_complete not in (., 0) and na_form_files ne 1 ), FORM FILES)';
    call execute (macro_call);
run;

/*CHECK THAT macro_call HAS THE CORRECT SYNTAX*/
/*proc print data=temp (obs=6) noobs;*/
/*run;*/



/*LOOP THE PROC PRINT FOR EACH OF THE 282 VARIABLES AND RESPECTIVE BRANCHING LOGIC*/
%macro report(ID);

data id_i;
    set derived.ko_up_randomized;
    where study_id = "&ID" ;
run;
%put &ID;

data _null_;
    set work.macro_variables;
    macro_call = cats('%missing(', "&ID", ',', variable, ',', logic, ',', title,')');
/*    macro_call = '%missing(KT-3-01, file1, %str( and form_files_complete not in (., 0) and na_form_files ne 1 ), FORM FILES)';*/
    call execute (macro_call);
run;

%mend;

/*CHECK FOR 1 STUDY ID*/
%report(KT-1-01);





%macro sheet(study_id);
ods Excel OPTIONS(SHEET_INTERVAL="now" SHEET_NAME="&study_id" EMBEDDED_TITLES="yes");
%mend;


/*REPEAT 282 PROC PRINTS BY participant_id*/
%macro loop(list);
%local i next_name;
%do i=1 %to %sysfunc(countw(&list, " "));
%let next_name = %scan(&list, &i," ");
%sheet(&next_name);
%report( &next_name);
%end;
%mend;
 

/*SAVE THE SAS LOG TO THE FOLLOWING TEXT FILE*/
filename test "Q:\Julio Chirinos\Knock_out_Summer_2016\documents\output\missing_data_UP_Knockout Log &sysdate..log";
proc printto log=test new;
run;



/*CREATE EXCEL FILE*/
ods Excel file="Q:\Julio Chirinos\Knock_out_Summer_2016\documents\output\UP Knockout Missing Data &sysdate..xlsx" ;

ods Excel OPTIONS(SHEET_INTERVAL="none" SHEET_NAME="KT-1-01" EMBEDDED_TITLES="yes");
%report(KT-1-01);
 
/*MISSING REPORT-REPEAT ABOVE FORMAT*/
%loop(&name_list);

/*SAS LOG*/
/*ods Excel OPTIONS(SHEET_INTERVAL="now" SHEET_NAME="log" EMBEDDED_TITLES="yes");*/
/*proc printto;run;*/
/*proc document name=mydoc(write);*/
/*                import textfile=test to logfile;run;*/
/*                replay;run;*/
/*quit;*/
 

ods Excel close;
