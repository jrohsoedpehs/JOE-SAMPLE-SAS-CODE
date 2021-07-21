libname raw "Q:\Julio Chirinos\Knock_out_Summer_2016\data\Raw";
libname derived "Q:\Julio Chirinos\Knock_out_Summer_2016\data\Derived";

footnote "SAS Program Stored in: Q:\Julio Chirinos\Knock_out_Summer_2016\programs\Draft\Missing_Data_Report.sas";

options fmtsearch=(raw.ko_up_formats);
options nofmterr;

proc format;
    value PE_variable_
        1= "form_pe_obtained"
        2= "height_2"
        3= "height_2_units"
        4= "weight_2"
        5= "weight_2_units"
        6= "systolic_2"
        7= "diastolic_2"
        8= "blood_pressure_arm_2"
        9= "heart_rate_2"
        10= "o2_saturation_2"
        11= "rr_2"
        12= "jvp_2"
        13= "ekg"
        14= "extremities_date"
        15= "sup_systolic_2"
        16= "sup_diastolic_2"
        17= "stan_systolic_2"
        18= "stan_diastolic_2"
        19= "orthostatic_symptoms_yn"
        20= "phys_date"
        21= "form_pe_complete";
run;



/*SIMPLE MISSING DATA REPORT*/

/*    set raw.ko_up (keep = study_id redcap_event_name height_2 -- form_pe_complete);*/

/*GET NUM VARS*/
proc contents data=derived.ko_up_randomized varnum;
run;

/*Physical_Exam*/
data Physical_Exam;
    set derived.ko_up_randomized (keep = 
        study_id 
        redcap_event_name 
/*        form_pe_obtained*/
        height_2
        height_2_units
        weight_2
        weight_2_units
        systolic_2
        diastolic_2
        blood_pressure_arm_2
        heart_rate_2
        o2_saturation_2
        rr_2
        jvp_2
        ekg
        extremities_date
        sup_systolic_2
        sup_diastolic_2
        stan_systolic_2
        stan_diastolic_2
        orthostatic_symptoms_yn
        phys_date
        form_pe_complete
    );
    where redcap_event_name in('baseline_visit_arm_1', 'week_6_phase_1_arm_1'
        'week_6_phase_2_arm_1');
/*    COUNT NUMBER OF MISSING */
    Physical_Exam_miss = cmiss(of height_2 -- form_pe_complete);
    if Physical_Exam_miss > 0;
run; 


/*QA DATA SHAPE*/
proc print data= Physical_Exam (obs=10) noobs;
    title "Physical_Exam";
run;
/*NOTE: DATA IS WIDE*/

/*RESHAPE DATA FROM WIDE TO LONG*/
data PE_long;
    set Physical_Exam;
    array PE(*) height_2 -- form_pe_complete;
    do PE_variable = 1 to dim(PE);
        PE_value = PE(PE_variable);
        output;
    end;
    drop height_2 -- form_pe_complete;
    format PE_variable PE_variable_.;
run;

/*QA PE_variable_*/
proc freq data= PE_long;
    table PE_variable;
run;

/*QA CHECK THAT THE DATASET IS NOT EMPTY*/
proc print data=PE_long (obs=20) noobs;
/*    where PE_value = .;*/
    title "PE_long";
run;


/*IF THE SUMMARY STATS OF THE ORIGINAL AND NEW DATASETS ARE IDENTICAL*/
/*THEN THE TRANSPOSE IS CORRECT*/
proc means data=Physical_Exam maxdec=2 n nmiss min max mean std;
    var height_2 -- form_pe_complete;
    title "Physical_Exam";
run;

proc means data=PE_long maxdec=2 n nmiss min max mean std;
    class PE_variable;
    var PE_value;
    title "PE_long";
run;

/*proc freq data= PE_long;*/
/*    table redcap_event_name;*/
/*    format redcap_event_name;*/
/*run;*/
