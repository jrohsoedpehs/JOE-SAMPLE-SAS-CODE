/*LARGE DATASET*/
data id_i;
    set raw.ko_nw ;
    where study_id = "KT-2-01" /*and study_id ne "Variable / Field Name"*/ ;
run;
/*~4 SECONDS*/

/*SUBSET*/
data id_i;
    set raw.ko_nw (keep= study_id  redcap_event_name &logicvars na_form_el);
    where study_id = "KT-2-01" /*and study_id ne "Variable / Field Name"*/ ;
run;
/*.04 SECONDS*/


/*USE KEEP= TO SPEED UP THE CREATION OF work.id_i*/

/*BRANCHING LOGIC VARIABLES ARE NEEDED IN KEEP=*/

/*USE CALL SYMPUT TO GENERATE A LIST OF BRANCHING LOGIC VARIABLES */
/*ASSIGNS DATASET FIELD VALUE TO A MACRO VARIABLE*/

/*SYNTAX*/
/*CALL SYMPUT (Macro-variable, value);*/

data _null_;
set sashelp.cars;
call symput('car_var', enginesize);
run;
%put &car_var;


proc sql /*noprint*/; 
         select distinct branching_logic_clean 
         into : logicvars separated by ' '
         from work.dictionary;
quit;


%let namelist1=; 
%let heightlist1=;
data _null_; 
 set height; 
 call symputx('name_temp',name); 
 call symputx('height_temp',height); 
 call execute('%let namelist1=&namelist1 &name_temp;');
if _N_ =1 then
 call execute('%let heightlist1=&heightlist1 &height_temp;');
else
 call execute('%let heightlist1=&heightlist1,&height_temp;');
run;
%put macro variable namemacro1: &namemacro1; 
%put macro variable heightlist1: &heightlist1; 



data work.dictionary;
    set raw.ko_nw_dictionary 
    (keep=VAR1 
          VAR2 
          VAR4 
          VAR8
          VAR12
    );
    where (VAR4 = "text" and VAR8 ne "")
        or VAR4 in("yesno","radio","file","dropdown", "Field Type",)
/*        and Field_Type notin("descriptive", "notes")*/
    ;

    if VAR12 ne "" then 
    do;
/*    REPLACE DUPLICATE SPACES WITH EXACTLY ONE SPACE*/
/*    WE NEED LEADING AND TRAILING SPACES */
/*    DO NOT TRIM*/
        branching_logic_clean = compbl(VAR12);
        branching_logic_clean = TRANWRD(branching_logic_clean,"[datetime_seconds1] = [datetime_seconds1]","");
        branching_logic_clean = TRANWRD(branching_logic_clean,"[datetime_seconds1]=[datetime_seconds1]","");
        branching_logic_clean = TRANWRD(branching_logic_clean,"[datetime_seconds]=[datetime_seconds]","");
        branching_logic_clean = TRANWRD(branching_logic_clean,"[datetime_seconds] = [datetime_seconds]","");
        branching_logic_clean = TRANWRD(branching_logic_clean,"]["," and ");
        branching_logic_clean = TRANWRD(branching_logic_clean,"]","");
        branching_logic_clean = TRANWRD(branching_logic_clean,"[","");
/*        branching_logic_clean = TRANWRD(branching_logic_clean, "<>''"," ne ");*/
        branching_logic_clean = TRANWRD(branching_logic_clean,"""","");
        branching_logic_clean = TRANWRD(branching_logic_clean,"'","");
        branching_logic_clean = TRANWRD(branching_logic_clean, "<>"," ne ");
        branching_logic_clean = TRANWRD(branching_logic_clean, "baseline_arm_1","redcap_event_name='baseline_arm_1'");
        branching_logic_clean = TRANWRD(branching_logic_clean, "1_month_arm_1","redcap_event_name='1_month_arm_1'");
        branching_logic_clean = TRANWRD(branching_logic_clean, "3_month_arm_1","redcap_event_name='3_month_arm_1'");
        branching_logic_clean = TRANWRD(branching_logic_clean, "6_month_arm_1","redcap_event_name='6_month_arm_1'");
        branching_logic_clean = TRANWRD(branching_logic_clean, "9_month_arm_1","redcap_event_name='9_month_arm_1'");
        branching_logic_clean = TRANWRD(branching_logic_clean, "12_month_arm_1","redcap_event_name='12_month_arm_1'");
        branching_logic_clean = TRANWRD(branching_logic_clean, "week_6_phase_1_arm_1","redcap_event_name='week_6_phase_1_arm_1'");
        branching_logic_clean = TRANWRD(branching_logic_clean, "week_6_phase_2_arm_1","redcap_event_name='week_6_phase_2_arm_1'");
        branching_logic_clean = TRANWRD(branching_logic_clean, "baseline_visit_arm_1","redcap_event_name='baseline_visit_arm_1'");
    end;
    if VAR1 in("na_phase_a" "na_phase_b") then delete;
    /*    HARDCODE CASES*/
/*    if branching_logic_clean="acetyl-l-carnitine | 7" then delete;*/
run;

proc freq data=work.dictionary;
    tables branching_logic_clean * VAR12 / list missing;
run;
/*proc contents data= work.dictionary; run;*/

