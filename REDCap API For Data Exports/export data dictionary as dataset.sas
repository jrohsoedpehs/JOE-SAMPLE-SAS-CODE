/*SET ROOT PATH*/
%let path = dir;


/*CREATE LIBRARIES AND FOOTNOTE*/
libname raw "&path\data\Raw";
libname derived "&path\data\Derived";
footnote "SAS Program Stored in: &path\documents\output\missing data reports call execute.sas";


/*CREATE DATE STAMPED FOLDER IN REDCAP DOWNLOADS TO STORE .CSV AND ASSOCIATED FILES*/
OPTIONS dlcreatedir;
LIBNAME data "&path\REDCap Downloads\archive%sysfunc( today(), YYMMDDn8 ) export data to SAS";


/*LIST OF VARIABLES PER PROJECT*/

/*NW Adverse Events KNOCKOUT (Repeating Events)*/
/*https://redcap.nursing.upenn.edu/redcap_v11.1.1/DataExport/index.php?pid=1123&report_id=ALL*/

%let NW_AE = 
study_id,
redcap_repeat_instrument,
redcap_repeat_instance,
adverse_event_category,
adverse_event,
date_site_notified,
startdate_time,
stopdate_time,
severity,
relation_to_study_procedures,
expected,
serious,
pi_date_signature_comments,
adverse_events_complete
;


/*API IMPORT DATA DICTIONARY*/
/*DEFINE MACRO TO IMPORT DATA DICTIONARY FROM REDCAP TO SAS*/

%MACRO API_dictionary(project, token);

/*CREATE THE FOLLOWING FILES*/
/*EXCEL CSV*/
/*TEXT THAT SAVES API COMMAND*/
/*TEXT FILE THAT SAVES THE API STATUS (SUCCESSFUL YES/NO)*/
filename my_in "&path\REDCap Downloads\archive%sysfunc( today(), YYMMDDn8 ) export data to SAS\&project._api_request.txt";
filename my_out "&path\REDCap Downloads\archive%sysfunc( today(), YYMMDDn8 ) export data to SAS\&project..csv";
filename status "&path\REDCap Downloads\archive%sysfunc( today(), YYMMDDn8 ) export data to SAS\&project._http_status.txt";

/*PROJECT TOKEN NEED TO SAVE DATA*/
/*SIMILAR TO A PASSWORD*/
%let mytoken = &token;
/*REQUEST ALL OBSERVATIONS WITH ONE ROW PER RECORD*/
data _null_ ;
file my_in ;
/*EXPORT ALL DATA*/
/*put "%NRStr(token=)&mytoken%NRStr(&content=record)%NRStr(&type=flat&format=csv)&";*/

/*EXCLUDED UNNECESSARY IDENTIFIERS BY EXPLICITLY LISTING VARIABLES TO INCLUDE*/
/*ORDER MATTERS! USE VARNUM OR ORDER OF APPEARANCE IN CODEBOOK*/
put "%NRStr(token=)&mytoken%NRStr(&content=metadata)%NRStr(&type=flat&format=csv&)&";
run;

/*Export data dictionary to .CSV file put */
/*"%NRStr(content=metadata&format=csv&token=)&token";*/

/*PROC HTTP CALL*/
/*EVERYTHING EXCEPT HEADEROUT= IS REQUIRED*/
proc http
in= my_in
out= my_out
headerout = status
/*url ="https://redcap.nursing.upenn.edu/api/"*/
/*LINK FOR PENN MEDICINE REDCAP IS ...*/
/*LINK FOR PENN NURSING REDCAP IS https://redcap.nursing.upenn.edu/api/*/
url ="https://redcap.nursing.upenn.edu/api/"
method="post";


/*CREATE MACRO VARIABLE FOR EXCEL CSV*/
%let csv_file = "&path\REDCap Downloads\archive%sysfunc( today(), YYMMDDn8 ) export data to SAS\&project..csv";

/*GOAL*/
/*NEWLINE CHARACTERS (IN FREE TEXT) ARE TREATED AS DELIMITERS FOR SAS IMPORT*/
/*SINCE THE DATA IS ALREADY COMMA DELIMITED, THIS WILL BREAK THE IMPORT*/
/*REPLACE NEWLINE CHARACTERS WITH SPACES*/

/*THIS WILL OVERWRITE THE CSV*/
/*CREATE A COPY OF THE CSV IF IT IS DIFFICULT TO OBTAIN*/

/*OPEN THE CSV, READ EACH CHARACTER LINE BY LINE AND REPLACE/OVERWRITE NEWLINE CHARACTERS WITH A SPACE*/
/*CLOSE CSV WHEN THERE ARE NO MORE CHARACTERS*/
/*INFILE MUST MATCH FILE IN DATASTEP*/
/*'0A'x, '13'x and '0D'x - ARE SYNTAX FOR ASCII newline (carriage return) characters*/
data _null_;
/*OVERWRITE EXCEL FILE*/
    infile &csv_file recfm=n sharebuffers;
    file &csv_file recfm=n;
/*OPEN THE CSV, READ EACH CHARACTER LINE BY LINE*/
    input a $char1.;
    retain open 0;
/*CLOSE CSV WHEN THERE ARE NO MORE CHARACTERS*/
    if a='"' then open=not open;
/*REPLACE/OVERWRITE NEWLINE CHARACTERS (ASCII) WITH A SPACE*/
    if a in ('0D'x '13'x '0A'x) and open then put ' ';
run;

%MEND API_dictionary;


/*%API_dictionary(project, token);*/
%API_dictionary(ko_ae_nw_dictionary, /*token*/);
%API_dictionary(nw_et_dictionary, /*token*/);
%API_dictionary(NW_med_dictionary, /*token*/);
%API_dictionary(ko_nw_dictionary, /*token*/);



/*SAS IMPORT CODE*/
/*IMPORT DATA SETS*/


/*NW ADVERSE EVENTS*/
%let csv_file = "&path\REDCap Downloads\archive%sysfunc( today(), YYMMDDn8 ) export data to SAS\ko_ae_nw.csv";

OPTIONS nofmterr;

proc format;
    value $redcap_repeat_instrument_ adverse_events='Adverse Events';
    value adverse_event_category_ 1='abnormal sensation of swallowing' 2='aches in the joints' 
        3='acute exacerbation of bronchiectasis' 4='atrial fibrillation' 
        5='belching' 6='bilateral knee pain' 
        7='bloating' 8='blurred vision' 
        9='bronchitis' 10='calves aching' 
        11='chest pain' 12='cough' 
        13='cramps' 14='creatinine increase' 
        15='diarrhea' 16='dizziness' 
        17='edema' 18='fatigue' 
        19='fever' 20='flu' 
        21='gassiness' 22='headache' 
        23='hip pain' 24='hypoglycemic episode' 
        25='increased stomach acid' 26='insomnia' 
        27='leg cramps' 28='lightheadedness' 
        29='lower back pain' 30='hypoxemia' 
        31='nasal discharge' 32='nausea' 
        33='nervousness' 34='o2 desaturation' 
        35='oral thrush' 36='palpitations' 
        37='positive orthostat' 38='rapid heart beat' 
        39='restlessness' 40='shortness of breath' 
        41='shortness of breath during the peak exercise test' 42='sinus infection' 
        43='skin irritation' 44='sore throat' 
        45='soreness' 46='spasms' 
        47='stomach ache' 48='swelling' 
        49='thigh cramps' 50='vomiting' 
        51='weakness' 52='fatigue during the peak exercise test' 
        999='other';
    value severity_ 1='mild' 2='moderate' 
        3='severe' 4='life-threatening';
    value relation_to_study_procedures_ 1='related' 2='unrelated' 
        3='possibly related';
    value expected_ 1='Yes' 0='No' 
        2='Expected complication of HFpEF';
    value serious_ 1='Yes' 0='No';
    value adverse_events_complete_ 0='Incomplete' 1='Unverified' 
        2='Complete';

    run;

data work.redcap; %let _EFIERR_ = 0;
infile &csv_file  delimiter = ',' MISSOVER DSD lrecl=32767 firstobs=2;

    informat subject_id $500. ;
    informat redcap_repeat_instrument $500. ;
    informat redcap_repeat_instance best32. ;
    informat adverse_event_category best32. ;
    informat adverse_event $5000. ;
    informat date_site_notified yymmdd10. ;
    informat startdate_time yymmdd10. ;
    informat stopdate_time yymmdd10. ;
    informat severity best32. ;
    informat relation_to_study_procedures best32. ;
    informat expected best32. ;
    informat serious best32. ;
    informat pi_date_signature_comments $5000. ;
    informat adverse_events_complete best32. ;

    format subject_id $500. ;
    format redcap_repeat_instrument $500. ;
    format redcap_repeat_instance best12. ;
    format adverse_event_category best12. ;
    format adverse_event $5000. ;
    format date_site_notified yymmdd10. ;
    format startdate_time yymmdd10. ;
    format stopdate_time yymmdd10. ;
    format severity best12. ;
    format relation_to_study_procedures best12. ;
    format expected best12. ;
    format serious best12. ;
    format pi_date_signature_comments $5000. ;
    format adverse_events_complete best12. ;

input
    subject_id $
    redcap_repeat_instrument $
    redcap_repeat_instance
    adverse_event_category
    adverse_event $
    date_site_notified
    startdate_time
    stopdate_time
    severity
    relation_to_study_procedures
    expected
    serious
    pi_date_signature_comments $
    adverse_events_complete
;
if _ERROR_ then call symput('_EFIERR_',"1");
run;

proc contents;run;

data redcap;
    set redcap;
    label subject_id='Subject ID';
    label redcap_repeat_instrument='Repeat Instrument';
    label redcap_repeat_instance='Repeat Instance';
    label adverse_event_category='Adverse Event Category';
    label adverse_event='Adverse Event Detail';
    label date_site_notified='Date Site Notified ';
    label startdate_time='StartDate/Time';
    label stopdate_time='StopDate/Time';
    label severity='Severity';
    label relation_to_study_procedures='Relation to Study Procedures ';
    label expected='Expected';
    label serious='Serious';
    label pi_date_signature_comments='PI Date/Signature & Comments';
    label adverse_events_complete='Complete?';
    format redcap_repeat_instrument redcap_repeat_instrument_.;
    format adverse_event_category adverse_event_category_.;
    format severity severity_.;
    format relation_to_study_procedures relation_to_study_procedures_.;
    format expected expected_.;
    format serious serious_.;
    format adverse_events_complete adverse_events_complete_.;
run;
proc contents;run;

data redcap;
    set redcap;
    label study_id='Subject ID';
    label redcap_repeat_instrument='Repeat Instrument';
    label redcap_repeat_instance='Repeat Instance';
    label adverse_event_category='Adverse Event Category';
    label adverse_event='Adverse Event Detail';
    label date_site_notified='Date Site Notified ';
    label startdate_time='StartDate/Time';
    label stopdate_time='StopDate/Time';
    label severity='Severity';
    label relation_to_study_procedures='Relation to Study Procedures ';
    label expected='Expected';
    label serious='Serious';
    label pi_date_signature_comments='PI Date/Signature & Comments';
    label adverse_events_complete='Complete?';
    format redcap_repeat_instrument redcap_repeat_instrument_.;
    format adverse_event_category adverse_event_category_.;
    format severity severity_.;
    format relation_to_study_procedures relation_to_study_procedures_.;
    format expected expected_.;
    format serious serious_.;
    format adverse_events_complete adverse_events_complete_.;
run;

proc contents data=redcap; run;

data raw.ko_ae_nw;
set redcap;
run;


/*NW EARLY TERMINATION*/
%let csv_file = "&path\REDCap Downloads\archive%sysfunc( today(), YYMMDDn8 ) export data to SAS\nw_early_termination.csv";

OPTIONS nofmterr;

proc format library=raw.nw_early_term_formats;
    value na_early_termination_form_ 1='Yes' 0='No';
    value early_term_yn_ 1='Yes' 0='No';
    value iv_line_required_1_et_ 1='Labs will be collected' 0='Labs will NOT be collected';
    value preg_test_et_ 1='Yes' 0='No' 
        99='N/A';
    value cmp_gold_et_ 1='Yes' 0='No' 
        99='N/A';
    value nt_pro_et_ 1='Yes' 0='No' 
        99='N/A';
    value cmp_gold2_4e8_et_ 1='Yes' 0='No' 
        99='N/A';
    value cmp_gold2_c0d_et_ 1='Yes' 0='No' 
        99='N/A';
    value g6pd_gold_tube_et_ 1='Yes' 0='No' 
        99='N/A';
    value biomarkers_urine_50_cc_ 1='Yes' 0='No' 
        99='N/A';
    value biomarkers_plasma_ 1='Yes' 0='No' 
        99='N/A';
    value biomarkers_serum_ 1='Yes' 0='No' 
        99='N/A';
    value biomarkers_saliva_ 1='Yes' 0='No' 
        99='N/A';
    value headache_se_ep_et_ 1='Yes' 0='No';
    value dizziness_se_ep_et_ 1='Yes' 0='No';
    value lightheadedness_se_ep_et_ 1='Yes' 0='No';
    value low_blood_pressure_90_se_ep_et_ 1='Yes' 0='No';
    value stomach_ache_diarrhea_se_ep_et_ 1='Yes' 0='No';
    value increased_shortness_se_ep_et_ 1='Yes' 0='No';
    value flushing_se_ep_et_ 1='Yes' 0='No';
    value rash_se_ep_et_ 1='Yes' 0='No';
    value ch_in_blood_pressure_se_ep_et_ 1='Yes' 0='No';
    value swelling_se_ep_et_ 1='Yes' 0='No';
    value fatigue_se_assess_et_ 1='Yes' 0='No';
    value other_symps_se_et_ 1='Yes' 0='No';
    value orthostat_se_ep_et_ 1='Yes' 0='No';
    value height_units_et_ 1='cm' 0='in';
    value weight_units_et_ 1='kg' 0='lbs';
    value blood_pressure_arm_2_et_ 1='Right Arm' 2='Left Arm';
    value ekg_performed_et_ 1='Yes' 0='No' 
        2='N/A';
    value orthostatic_symptoms_yn_et_ 1='Yes' 0='No' 
        2='N/A';
    value early_termination_fo_v_0_ 0='Incomplete' 1='Unverified' 
        2='Complete';

    run;
options fmtsearch=(raw.nw_early_term_formats);

data work.redcap; %let _EFIERR_ = 0;
infile &csv_file  delimiter = ',' MISSOVER DSD lrecl=32767 firstobs=2;

    informat study_id $500. ;
    informat na_early_termination_form best32. ;
    informat early_term_yn best32. ;
    informat dop_kno3 yymmdd10. ;
    informat tablets_prvd_kno3 best32. ;
    informat tablets_rtrnd_kno3 best32. ;
    informat expected_kno3 best32. ;
    informat compliance_kno3 best32. ;
    informat date_visit yymmdd10. ;
    informat rsn_trmntn $5000. ;
    informat iv_line_required_1_et best32. ;
    informat iv_time_1_et time5. ;
    informat gauge_1_et $500. ;
    informat site_1_et $500. ;
    informat preg_test_et best32. ;
    informat cmp_gold_et best32. ;
    informat nt_pro_et best32. ;
    informat cmp_gold2_4e8_et best32. ;
    informat cmp_gold2_c0d_et best32. ;
    informat g6pd_gold_tube_et best32. ;
    informat biomarkers_urine_50_cc best32. ;
    informat biomarkers_plasma best32. ;
    informat biomarkers_serum best32. ;
    informat biomarkers_saliva best32. ;
    informat notes_pm_et $5000. ;
    informat date_lab_et yymmdd10. ;
    informat headache_se_ep_et best32. ;
    informat dizziness_se_ep_et best32. ;
    informat lightheadedness_se_ep_et best32. ;
    informat low_blood_pressure_90_se_ep_et best32. ;
    informat stomach_ache_diarrhea_se_ep_et best32. ;
    informat increased_shortness_se_ep_et best32. ;
    informat flushing_se_ep_et best32. ;
    informat rash_se_ep_et best32. ;
    informat ch_in_blood_pressure_se_ep_et best32. ;
    informat swelling_se_ep_et best32. ;
    informat fatigue_se_assess_et best32. ;
    informat other_symps_se_et best32. ;
    informat orthostat_se_ep_et best32. ;
    informat orthostat_se_dscr_ep_et $5000. ;
    informat phys_date_se_ep_et yymmdd10. ;
    informat height_et best32. ;
    informat height_units_et best32. ;
    informat weight_et best32. ;
    informat weight_units_et best32. ;
    informat systolic_2_et best32. ;
    informat diastolic_2_et best32. ;
    informat blood_pressure_arm_2_et best32. ;
    informat heart_rate_2_et best32. ;
    informat o2_saturation_2_et best32. ;
    informat rr_2_et best32. ;
    informat jvp_2_et best32. ;
    informat jvp_category_et $500. ;
    informat ekg_performed_et best32. ;
    informat heart_2_et $5000. ;
    informat lungs_2_et $5000. ;
    informat abd_2_et $5000. ;
    informat extremities_2_et $5000. ;
    informat physical_notes_et $5000. ;
    informat extremities_date_et yymmdd10. ;
    informat extremities_signature_et $500. ;
    informat sup_systolic_2_et best32. ;
    informat sup_diastolic_2_et best32. ;
    informat stan_systolic_2_et best32. ;
    informat stan_diastolic_2_et best32. ;
    informat orthostatic_symptoms_yn_et best32. ;
    informat ortho_sympt_descr_et $5000. ;
    informat comments_phy_et $5000. ;
    informat phys_date_et yymmdd10. ;
    informat addl_notes_etv $5000. ;
    informat early_termination_fo_v_0 best32. ;

    format study_id $500. ;
    format na_early_termination_form best12. ;
    format early_term_yn best12. ;
    format dop_kno3 yymmdd10. ;
    format tablets_prvd_kno3 best12. ;
    format tablets_rtrnd_kno3 best12. ;
    format expected_kno3 best12. ;
    format compliance_kno3 best12. ;
    format date_visit yymmdd10. ;
    format rsn_trmntn $5000. ;
    format iv_line_required_1_et best12. ;
    format iv_time_1_et time5. ;
    format gauge_1_et $500. ;
    format site_1_et $500. ;
    format preg_test_et best12. ;
    format cmp_gold_et best12. ;
    format nt_pro_et best12. ;
    format cmp_gold2_4e8_et best12. ;
    format cmp_gold2_c0d_et best12. ;
    format g6pd_gold_tube_et best12. ;
    format biomarkers_urine_50_cc best12. ;
    format biomarkers_plasma best12. ;
    format biomarkers_serum best12. ;
    format biomarkers_saliva best12. ;
    format notes_pm_et $5000. ;
    format date_lab_et yymmdd10. ;
    format headache_se_ep_et best12. ;
    format dizziness_se_ep_et best12. ;
    format lightheadedness_se_ep_et best12. ;
    format low_blood_pressure_90_se_ep_et best12. ;
    format stomach_ache_diarrhea_se_ep_et best12. ;
    format increased_shortness_se_ep_et best12. ;
    format flushing_se_ep_et best12. ;
    format rash_se_ep_et best12. ;
    format ch_in_blood_pressure_se_ep_et best12. ;
    format swelling_se_ep_et best12. ;
    format fatigue_se_assess_et best12. ;
    format other_symps_se_et best12. ;
    format orthostat_se_ep_et best12. ;
    format orthostat_se_dscr_ep_et $5000. ;
    format phys_date_se_ep_et yymmdd10. ;
    format height_et best12. ;
    format height_units_et best12. ;
    format weight_et best12. ;
    format weight_units_et best12. ;
    format systolic_2_et best12. ;
    format diastolic_2_et best12. ;
    format blood_pressure_arm_2_et best12. ;
    format heart_rate_2_et best12. ;
    format o2_saturation_2_et best12. ;
    format rr_2_et best12. ;
    format jvp_2_et best12. ;
    format jvp_category_et $500. ;
    format ekg_performed_et best12. ;
    format heart_2_et $5000. ;
    format lungs_2_et $5000. ;
    format abd_2_et $5000. ;
    format extremities_2_et $5000. ;
    format physical_notes_et $5000. ;
    format extremities_date_et yymmdd10. ;
    format extremities_signature_et $500. ;
    format sup_systolic_2_et best12. ;
    format sup_diastolic_2_et best12. ;
    format stan_systolic_2_et best12. ;
    format stan_diastolic_2_et best12. ;
    format orthostatic_symptoms_yn_et best12. ;
    format ortho_sympt_descr_et $5000. ;
    format comments_phy_et $5000. ;
    format phys_date_et yymmdd10. ;
    format addl_notes_etv $5000. ;
    format early_termination_fo_v_0 best12. ;

input
    study_id $
    na_early_termination_form
    early_term_yn
    dop_kno3
    tablets_prvd_kno3
    tablets_rtrnd_kno3
    expected_kno3
    compliance_kno3
    date_visit
    rsn_trmntn $
    iv_line_required_1_et
    iv_time_1_et
    gauge_1_et $
    site_1_et $
    preg_test_et
    cmp_gold_et
    nt_pro_et
    cmp_gold2_4e8_et
    cmp_gold2_c0d_et
    g6pd_gold_tube_et
    biomarkers_urine_50_cc
    biomarkers_plasma
    biomarkers_serum
    biomarkers_saliva
    notes_pm_et $
    date_lab_et
    headache_se_ep_et
    dizziness_se_ep_et
    lightheadedness_se_ep_et
    low_blood_pressure_90_se_ep_et
    stomach_ache_diarrhea_se_ep_et
    increased_shortness_se_ep_et
    flushing_se_ep_et
    rash_se_ep_et
    ch_in_blood_pressure_se_ep_et
    swelling_se_ep_et
    fatigue_se_assess_et
    other_symps_se_et
    orthostat_se_ep_et
    orthostat_se_dscr_ep_et $
    phys_date_se_ep_et
    height_et
    height_units_et
    weight_et
    weight_units_et
    systolic_2_et
    diastolic_2_et
    blood_pressure_arm_2_et
    heart_rate_2_et
    o2_saturation_2_et
    rr_2_et
    jvp_2_et
    jvp_category_et $
    ekg_performed_et
    heart_2_et $
    lungs_2_et $
    abd_2_et $
    extremities_2_et $
    physical_notes_et $
    extremities_date_et
    extremities_signature_et $
    sup_systolic_2_et
    sup_diastolic_2_et
    stan_systolic_2_et
    stan_diastolic_2_et
    orthostatic_symptoms_yn_et
    ortho_sympt_descr_et $
    comments_phy_et $
    phys_date_et
    addl_notes_etv $
    early_termination_fo_v_0
;
if _ERROR_ then call symput('_EFIERR_',"1");
run;

proc contents;run;

data redcap;
    set redcap;
    label study_id='Study ID';
    label na_early_termination_form='Not Applicable';
    label early_term_yn='Did the subject have an Early Termination Visit?';
    label dop_kno3='Date of last Prescription';
    label tablets_prvd_kno3='Number of tablets provided';
    label tablets_rtrnd_kno3='Number of tablets returned';
    label expected_kno3='Number they should have taken';
    label compliance_kno3='Compliance %';
    label date_visit='Date of visit';
    label rsn_trmntn='Reason for termination';
    label iv_line_required_1_et='        ';
    label iv_time_1_et='Time (24: hr): ';
    label gauge_1_et='Gauge';
    label site_1_et='Site';
    label preg_test_et='Pregnancy test (WOCBP) - urine';
    label cmp_gold_et='Comprehensive Metabolic panel- green tube';
    label nt_pro_et='NTproBNP - lavender tube ';
    label cmp_gold2_4e8_et='Methemoglobin - green tube ';
    label cmp_gold2_c0d_et='CBC - purple tube ';
    label g6pd_gold_tube_et='G6PD deficiency screening  (males of African, Asian or Mediterranean decent) - red tube';
    label biomarkers_urine_50_cc='Urine (~50 cc)';
    label biomarkers_plasma='Plasma  - Purple top ';
    label biomarkers_serum='Serum - Red Top           ';
    label biomarkers_saliva='Saliva ';
    label notes_pm_et='Notes';
    label date_lab_et='Date';
    label headache_se_ep_et='Headache';
    label dizziness_se_ep_et='Dizziness';
    label lightheadedness_se_ep_et='Lightheadedness';
    label low_blood_pressure_90_se_ep_et='Low blood pressure (< 90)';
    label stomach_ache_diarrhea_se_ep_et='Stomach Ache, diarrhea, nausea, or vomiting';
    label increased_shortness_se_ep_et='Increased Shortness of breath';
    label flushing_se_ep_et='Flushing';
    label rash_se_ep_et='Rash';
    label ch_in_blood_pressure_se_ep_et='Changes in blood pressure when standing up';
    label swelling_se_ep_et='Swelling';
    label fatigue_se_assess_et='Fatigue';
    label other_symps_se_et='Other symptoms';
    label orthostat_se_ep_et='Presence of orthostatic symptoms? ';
    label orthostat_se_dscr_ep_et='If yes to any side effects please explain';
    label phys_date_se_ep_et='Date';
    label height_et='Height';
    label height_units_et='Height Units';
    label weight_et='Weight';
    label weight_units_et='Weight Units';
    label systolic_2_et='Systolic';
    label diastolic_2_et='Diastolic';
    label blood_pressure_arm_2_et='Blood Pressure site';
    label heart_rate_2_et='Heart Rate:';
    label o2_saturation_2_et='O2 Saturation:';
    label rr_2_et='RR:';
    label jvp_2_et='JVP: ';
    label jvp_category_et='JVP:';
    label ekg_performed_et='EKG Performed';
    label heart_2_et='Heart:';
    label lungs_2_et='Lungs:';
    label abd_2_et='Abd:';
    label extremities_2_et='Extremities:';
    label physical_notes_et='Additional Notes';
    label extremities_date_et='Date:';
    label extremities_signature_et='Signature: ';
    label sup_systolic_2_et='Systolic';
    label sup_diastolic_2_et='Diastolic';
    label stan_systolic_2_et='Systolic';
    label stan_diastolic_2_et='Diastolic';
    label orthostatic_symptoms_yn_et='Orthostatic symptoms present? ';
    label ortho_sympt_descr_et='If orthostatic symptoms are present, please describe the symptoms: ';
    label comments_phy_et='Comments';
    label phys_date_et='Date';
    label addl_notes_etv=' Additional Notes ';
    label early_termination_fo_v_0='Complete?';
    format na_early_termination_form na_early_termination_form_.;
    format early_term_yn early_term_yn_.;
    format iv_line_required_1_et iv_line_required_1_et_.;
    format preg_test_et preg_test_et_.;
    format cmp_gold_et cmp_gold_et_.;
    format nt_pro_et nt_pro_et_.;
    format cmp_gold2_4e8_et cmp_gold2_4e8_et_.;
    format cmp_gold2_c0d_et cmp_gold2_c0d_et_.;
    format g6pd_gold_tube_et g6pd_gold_tube_et_.;
    format biomarkers_urine_50_cc biomarkers_urine_50_cc_.;
    format biomarkers_plasma biomarkers_plasma_.;
    format biomarkers_serum biomarkers_serum_.;
    format biomarkers_saliva biomarkers_saliva_.;
    format headache_se_ep_et headache_se_ep_et_.;
    format dizziness_se_ep_et dizziness_se_ep_et_.;
    format lightheadedness_se_ep_et lightheadedness_se_ep_et_.;
    format low_blood_pressure_90_se_ep_et low_blood_pressure_90_se_ep_et_.;
    format stomach_ache_diarrhea_se_ep_et stomach_ache_diarrhea_se_ep_et_.;
    format increased_shortness_se_ep_et increased_shortness_se_ep_et_.;
    format flushing_se_ep_et flushing_se_ep_et_.;
    format rash_se_ep_et rash_se_ep_et_.;
    format ch_in_blood_pressure_se_ep_et ch_in_blood_pressure_se_ep_et_.;
    format swelling_se_ep_et swelling_se_ep_et_.;
    format fatigue_se_assess_et fatigue_se_assess_et_.;
    format other_symps_se_et other_symps_se_et_.;
    format orthostat_se_ep_et orthostat_se_ep_et_.;
    format height_units_et height_units_et_.;
    format weight_units_et weight_units_et_.;
    format blood_pressure_arm_2_et blood_pressure_arm_2_et_.;
    format ekg_performed_et ekg_performed_et_.;
    format orthostatic_symptoms_yn_et orthostatic_symptoms_yn_et_.;
    format early_termination_fo_v_0 early_termination_fo_v_0_.;
run;

proc contents data=redcap; run;

data raw.nw_early_termination;
set redcap;
run;


/*NW MEDICATION COMPLIANCE*/
%let csv_file = "&path\REDCap Downloads\archive%sysfunc( today(), YYMMDDn8 ) export data to SAS\NW_medication_compliance.csv";

OPTIONS nofmterr;

proc format library=raw.NW_med_formats ;
    value na_phase_a_ 1='Yes' 0='No';
    value med_ext_low_ 1='Yes' 0='No';
    value pa_uptitrated_ 1='Yes' 0='No';
    value pa_freq_high_dose_ 1='3 Times Per Day';
    value pa_freq_low_dose_ 1='2 Times Per Day';
    value knock_out_study_medi_v_0_ 0='Incomplete' 1='Unverified' 
        2='Complete';
    value na_phase_b_ 1='Yes' 0='No';
    value pb_med_ext_low_ 1='Yes' 0='No';
    value pb_uptitrated_ 1='Yes' 0='No';
    value pb_freq_high_dose_ 1='3 Times Per Day';
    value pb_freq_low_dose_ 1='2 Times Per Day';
    value knock_out_study_medi_v_1_ 0='Incomplete' 1='Unverified' 
        2='Complete';

    run;
options fmtsearch=(raw.NW_med_formats );
data work.redcap; %let _EFIERR_ = 0;
infile &csv_file  delimiter = ',' MISSOVER DSD lrecl=32767 firstobs=2;

    informat study_id $500. ;
    informat na_phase_a best32. ;
    informat med_ext_low best32. ;
    informat num_extra_cap best32. ;
    informat pa_date_meds_started yymmdd10. ;
    informat pa_date_1week_call yymmdd10. ;
    informat pa_uptitrated best32. ;
    informat pa_date_of_uptitration yymmdd10. ;
    informat pa_freq_high_dose best32. ;
    informat pa_date_rmnd_2pday yymmdd10. ;
    informat pa_date_final_visit yymmdd10. ;
    informat pa_freq_low_dose best32. ;
    informat num_meds_final_day_a best32. ;
    informat pa_capsules_left_over best32. ;
    informat phase_a_compliance best32. ;
    informat comments_a $5000. ;
    informat knock_out_study_medi_v_0 best32. ;
    informat na_phase_b best32. ;
    informat pb_med_ext_low best32. ;
    informat pb_num_extra_cap best32. ;
    informat pb_date_meds_started yymmdd10. ;
    informat pb_date_1week_call yymmdd10. ;
    informat pb_uptitrated best32. ;
    informat pb_date_of_uptitration yymmdd10. ;
    informat pb_freq_high_dose best32. ;
    informat pb_date_rmnd_2pday yymmdd10. ;
    informat pb_date_final_visit yymmdd10. ;
    informat pb_freq_low_dose best32. ;
    informat num_meds_final_day_b best32. ;
    informat pb_capsules_left_over best32. ;
    informat phase_b_compliance best32. ;
    informat comments_b $5000. ;
    informat knock_out_study_medi_v_1 best32. ;

    format study_id $500. ;
    format na_phase_a best12. ;
    format med_ext_low best12. ;
    format num_extra_cap best12. ;
    format pa_date_meds_started yymmdd10. ;
    format pa_date_1week_call yymmdd10. ;
    format pa_uptitrated best12. ;
    format pa_date_of_uptitration yymmdd10. ;
    format pa_freq_high_dose best12. ;
    format pa_date_rmnd_2pday yymmdd10. ;
    format pa_date_final_visit yymmdd10. ;
    format pa_freq_low_dose best12. ;
    format num_meds_final_day_a best12. ;
    format pa_capsules_left_over best12. ;
    format phase_a_compliance best12. ;
    format comments_a $5000. ;
    format knock_out_study_medi_v_0 best12. ;
    format na_phase_b best12. ;
    format pb_med_ext_low best12. ;
    format pb_num_extra_cap best12. ;
    format pb_date_meds_started yymmdd10. ;
    format pb_date_1week_call yymmdd10. ;
    format pb_uptitrated best12. ;
    format pb_date_of_uptitration yymmdd10. ;
    format pb_freq_high_dose best12. ;
    format pb_date_rmnd_2pday yymmdd10. ;
    format pb_date_final_visit yymmdd10. ;
    format pb_freq_low_dose best12. ;
    format num_meds_final_day_b best12. ;
    format pb_capsules_left_over best12. ;
    format phase_b_compliance best12. ;
    format comments_b $5000. ;
    format knock_out_study_medi_v_1 best12. ;

input
    study_id $
    na_phase_a
    med_ext_low
    num_extra_cap
    pa_date_meds_started
    pa_date_1week_call
    pa_uptitrated
    pa_date_of_uptitration
    pa_freq_high_dose
    pa_date_rmnd_2pday
    pa_date_final_visit
    pa_freq_low_dose
    num_meds_final_day_a
    pa_capsules_left_over
    phase_a_compliance
    comments_a $
    knock_out_study_medi_v_0
    na_phase_b
    pb_med_ext_low
    pb_num_extra_cap
    pb_date_meds_started
    pb_date_1week_call
    pb_uptitrated
    pb_date_of_uptitration
    pb_freq_high_dose
    pb_date_rmnd_2pday
    pb_date_final_visit
    pb_freq_low_dose
    num_meds_final_day_b
    pb_capsules_left_over
    phase_b_compliance
    comments_b $
    knock_out_study_medi_v_1
;
if _ERROR_ then call symput('_EFIERR_',"1");
run;

proc contents;run;

data redcap;
    set redcap;
    label study_id='Study ID';
    label na_phase_a='Not Applicable';
    label med_ext_low='Did the subject receive a medication extension?';
    label num_extra_cap='Number of extra capsules given';
    label pa_date_meds_started='Date Medications Were Started ';
    label pa_date_1week_call='Date of 1-Week Call';
    label pa_uptitrated='Was Patient Uptitrated to 3 times per day?';
    label pa_date_of_uptitration='Date of Uptitration ';
    label pa_freq_high_dose='Frequency';
    label pa_date_rmnd_2pday='Date That Patient Remained on Medications Twice Per Day';
    label pa_date_final_visit='Date of Final Visit';
    label pa_freq_low_dose='Frequency';
    label num_meds_final_day_a='Number of medication on final day ';
    label pa_capsules_left_over='Number of Capsules Left Over';
    label phase_a_compliance='Percent Compliance %';
    label comments_a='Comments';
    label knock_out_study_medi_v_0='Complete?';
    label na_phase_b=' Not Applicable';
    label pb_med_ext_low='Did the subject receive a medication extension?';
    label pb_num_extra_cap='Number of extra capsules given';
    label pb_date_meds_started='Date Medications Were Started ';
    label pb_date_1week_call='Date of 1-Week Call';
    label pb_uptitrated='Was Patient Uptitrated to 3 times per day?';
    label pb_date_of_uptitration='Date of Uptitration ';
    label pb_freq_high_dose='Frequency';
    label pb_date_rmnd_2pday='Date That Patient Remained on Medications Twice Per Day';
    label pb_date_final_visit='Date of Final Visit';
    label pb_freq_low_dose='Frequency';
    label num_meds_final_day_b='Number of medication on final day ';
    label pb_capsules_left_over='Number of Capsules Left Over';
    label phase_b_compliance='Percent Compliance %';
    label comments_b='Comments';
    label knock_out_study_medi_v_1='Complete?';
    format na_phase_a na_phase_a_.;
    format med_ext_low med_ext_low_.;
    format pa_uptitrated pa_uptitrated_.;
    format pa_freq_high_dose pa_freq_high_dose_.;
    format pa_freq_low_dose pa_freq_low_dose_.;
    format knock_out_study_medi_v_0 knock_out_study_medi_v_0_.;
    format na_phase_b na_phase_b_.;
    format pb_med_ext_low pb_med_ext_low_.;
    format pb_uptitrated pb_uptitrated_.;
    format pb_freq_high_dose pb_freq_high_dose_.;
    format pb_freq_low_dose pb_freq_low_dose_.;
    format knock_out_study_medi_v_1 knock_out_study_medi_v_1_.;
run;

proc contents data=redcap; run;
data raw.NW_medication_compliance;
set redcap;
run;


/*NW KNOCKOUT*/
/* Edit the following line to reflect the full path to your CSV file */
%let csv_file = "&path\REDCap Downloads\archive%sysfunc( today(), YYMMDDn8 ) export data to SAS\ko_nw.csv";

OPTIONS nofmterr;

proc format library=raw.ko_nw_formats ;
    value $redcap_event_name_ baseline_visit_arm_1='Baseline visit' week_1_phase_1_arm_1='Week 1 Phase 1' 
        week_6_phase_1_arm_1='Week 6 Phase 1' week_1_phase_2_arm_1='Week 1 Phase 2' 
        week_6_phase_2_arm_1='week 6 Phase 2';
    value na_form_el_ 1='Yes' 0='No';
    value data_obtained_yn_ 1='Yes' 0='No';
    value heart_failure_ 1='Yes' 0='No';
    value lv_ejection_ 1='Yes' 0='No';
    value medical_therapy_ 1='Yes' 0='No';
    value filling_pressures_ 1='Yes' 0='No';
    value mitral_ratio_ 1='Yes' 0='No';
    value left_atrium_ 1='Yes' 0='No';
    value chronic_loop_ 1='Yes' 0='No';
    value natriuretic_peptides_ 1='Yes' 0='No';
    value either_lateral_ 1='Yes' 0='No';
    value capillary_wedge_ 1='Yes' 0='No';
    value iv_diuretics_ 1='Yes' 0='No';
    value supine_systolic_ 1='Yes' 0='No';
    value pregnancy_ 1='Yes' 0='No';
    value orthostatic_hypotension_ 1='Yes' 0='No';
    value native_conduction_ 1='Yes' 0='No';
    value hemoglobin_ 1='Yes' 0='No';
    value inability_exercise_ 1='Yes' 0='No';
    value valvular_disease_ 1='Yes' 0='No';
    value hypertrophic_ 1='Yes' 0='No';
    value pericardial_disease_ 1='Yes' 0='No';
    value current_angina_ 1='Yes' 0='No';
    value coronary_syndrome_ 1='Yes' 0='No';
    value primary_pulmonary_ 1='Yes' 0='No';
    value chronic_obstructive_ 1='Yes' 0='No';
    value stress_testing_ 1='Yes' 0='No';
    value ventricular_ejection_ 1='Yes' 0='No';
    value phosphodiesterase_ 1='Yes' 0='No';
    value organic_nitrates_ 1='Yes' 0='No';
    value liver_disease_ 1='Yes' 0='No';
    value egfr_ 1='Yes' 0='No';
    value g6pd_deficiency_ 1='Yes' 0='No';
    value methemoglobinemia_ 1='Yes' 0='No';
    value hyperkalemia_serum_ 1='Yes' 0='No';
    value ventricular_dysfunction_ 1='Yes' 0='No';
    value medical_condition_ 1='Yes' 0='No';
    value contraindications_to_mri_ 1='Yes' 0='No';
    value intra_luminal_implant_ 1='Yes' 0='No';
    value life_assist_device_ 1='Yes' 0='No';
    value vascular_clip_ 1='Yes' 0='No';
    value visceral_organs_ 1='Yes' 0='No';
    value intracranial_implants_ 1='Yes' 0='No';
    value non_removable_piercings_ 1='Yes' 0='No';
    value personal_history_ 1='Yes' 0='No';
    value radiologic_evaluation_ 1='Yes' 0='No';
    value form_el_complete_ 0='Incomplete' 1='Unverified' 
        2='Complete';
    value na_form_bl_cl_ 1='Yes' 0='No';
    value consent_yn_ 1='Yes' 0='No';
    value urine_yn_ 1='Yes' 0='No';
    value urine_radio_ 1='Neg' 2='Pos' 
        3='NA';
    value diet_yn_ 1='Yes' 0='No';
    value vital_yn_ 1='Yes' 0='No';
    value mw6_yn_ 1='Yes' 0='No';
    value quality_yn_ 1='Yes' 0='No';
    value cognitive_test_yn_ 1='Yes' 0='No';
    value blood_yn_ 1='Yes' 0='No';
    value g6pd_yn_ 1='YES' 0='NO G6PD deficiency screening required';
    value art_tono_yn_ 1='Yes' 0='No';
    value echo_yn_ 1='Yes' 0='No';
    value ekg_bl_ 1='Yes' 0='No';
    value labs_yn_ 1='Yes' 0='No';
    value hemo_yn_ 1='Yes' 0='No';
    value creati_yn_ 1='Yes' 0='No';
    value egfr_yn_ 1='Yes' 0='No';
    value meth_yn_ 1='Yes' 0='No';
    value potas_yn_ 1='Yes' 0='No';
    value ntpro_yn_ 1='Yes' 0='No';
    value med_dis_yn_ 1='Yes' 0='No';
    value form_bl_cl_complete_ 0='Incomplete' 1='Unverified' 
        2='Complete';
    value na_form_6wk_cl_ 1='Yes' 0='No';
    value urine_pregnancy_test_ 1='Yes' 0='No';
    value urine_pregnancy_results_ 1='Negative' 2='Positive,' 
        3='NA';
    value dietary_questionnaire_ 1='Yes' 0='No';
    value physical_exam_ 1='Yes' 0='No';
    value orthostatics_ 1='Yes' 0='No';
    value vital_signs_ 1='Yes' 0='No';
    value questionnaires_kccq_ 1='Yes' 0='No';
    value potential_side_effects_ 1='Yes' 0='No';
    value cognitive_test2_yn_ 1='Yes' 0='No';
    value blood_draws_before_ 1='Yes' 0='No';
    value light_breakfast_ 1='Yes' 0='No';
    value blood_draws_after_ 1='Yes' 0='No';
    value arterial_tonometry_ 1='Yes' 0='No';
    value doppler_echocardiogram_ 1='Yes' 0='No';
    value ekg_p1_ 1='Yes' 0='No';
    value bicycle_exercise_test_ 1='Yes' 0='No';
    value muscle_mri_ 1='Yes' 0='No';
    value medication_dispensed_ 1='Yes' 0='No';
    value stage_2_meds_ 1='Yes' 0='No';
    value stage_1_meds_ 1='Yes' 0='No';
    value pill_count_yn_ 1='Yes' 0='No';
    value cardiac_mri_performed_p1_ 1='Yes' 0='No';
    value form_6wk_cl_complete_ 0='Incomplete' 1='Unverified' 
        2='Complete';
    value na_form_6wk_cl_p2_ 1='Yes' 0='No';
    value urine_pregnancy_test_p2_ 1='Yes' 0='No';
    value urine_pregnancy_results_p2_ 1='Negative' 2='Positive,' 
        3='NA';
    value dietary_questionnaire_p2_ 1='Yes' 0='No';
    value physical_exam_p2_ 1='Yes' 0='No';
    value orthostatics_p2_ 1='Yes' 0='No';
    value vital_signs_p2_ 1='Yes' 0='No';
    value questionnaires_kccq_p2_ 1='Yes' 0='No';
    value potential_side_effects_p2_ 1='Yes' 0='No';
    value cognitive_test3_yn_ 1='Yes' 0='No';
    value blood_draws_before_p2_ 1='Yes' 0='No';
    value light_breakfast_p2_ 1='Yes' 0='No';
    value blood_draws_after_p2_ 1='Yes' 0='No';
    value arterial_tonometry_p2_ 1='Yes' 0='No';
    value doppler_echocardiogram_p2_ 1='Yes' 0='No';
    value ekg_p2_ 1='Yes' 0='No';
    value bicycle_exercise_test_p2_ 1='Yes' 0='No';
    value muscle_mri_p2_ 1='Yes' 0='No';
    value stage_1_meds_p2_ 1='Yes' 0='No';
    value pill_count_yn_p2_ 1='Yes' 0='No';
    value cardiac_mri_initials_p2_ 1='Yes' 0='No';
    value form_bl_cl_cmplt_p2_ 1='Yes' 0='No';
    value medication_dispensed_p2_ 1='Yes' 0='No';
    value form_6wk_cl_p2_complete_ 0='Incomplete' 1='Unverified' 
        2='Complete';
    value na_form_6wk_mri_ 1='Yes' 0='No';
    value mri_safety_checklist_ 1='Yes' 0='No';
    value field_strength1_ 1='3T' 2='7T';
    value number_of_repetitions_ 1='90 contractions per 2 minutes' 2='Other';
    value number_of_repetitions1_ 1='90 contractions per 2 minutes' 2='Other';
    value data_exported_ 1='Yes' 0='No';
    value complete_mri_ 1='Yes' 0='No';
    value form_6wk_mri_complete_ 0='Incomplete' 1='Unverified' 
        2='Complete';
    value na_form_cardiac_mri_ 1='Yes' 0='No';
    value form_mri_enrolled_ 1='Yes' 0='No';
    value form_mri_reviewed_ 1='Yes' 0='No';
    value form_mri_weight_units_ 1='lbs' 2='kg' 
        3='other';
    value form_mri_basis1_ 1='Yes' 0='No';
    value form_mri_basis2_ 1='Yes' 0='No';
    value form_mri_meds_ 1='Yes' 0='No';
    value form_mri_stable_ 1='Yes' 0='No';
    value form_mri_beta_blockers_ 1='Yes' 0='No';
    value form_mri_nitrates_ 1='Yes' 0='No';
    value form_mri_post_reported_ 1='No symptoms' 2='Following symptom(s)';
    value form_mri_post_discharge_ 1='Yes' 0='No';
    value form_cardiac_mri_complete_ 0='Incomplete' 1='Unverified' 
        2='Complete';
    value na_form_mh_ 1='Yes' 0='No';
    value penn_chart_ 1='Yes' 0='No';
    value gender_ 1='MALE' 2='FEMALE';
    value race___1_ 0='Unchecked' 1='Checked';
    value race___2_ 0='Unchecked' 1='Checked';
    value race___3_ 0='Unchecked' 1='Checked';
    value race___4_ 0='Unchecked' 1='Checked';
    value race___5_ 0='Unchecked' 1='Checked';
    value race___6_ 0='Unchecked' 1='Checked';
    value type_decent_ 1='YES' 0='NO';
    value acutecoronary_ 1='Yes' 0='No';
    value prior_angina_ 1='Yes' 0='No';
    value any_arrhythmia_ 1='Yes' 0='No';
    value valv_disease_surgery_ 1='Yes' 0='No';
    value htn_ 1='Yes' 0='No';
    value high_cholesterol_ 1='Yes' 0='No';
    value peripheral_vascular_ 1='Yes' 0='No';
    value diabetes_ 1='Yes' 0='No';
    value insulin_ 1='Yes' 0='No';
    value cva_tia_ 1='Yes' 0='No';
    value pulmonary_embolism_dvt_ 1='Yes' 0='No';
    value osa_ 1='Yes' 0='No';
    value cpap_ 1='Yes' 0='No';
    value copd_asthma_ 1='Yes' 0='No';
    value osteoarthritis_ 1='Yes' 0='No';
    value cabg_ 1='Yes' 0='No';
    value peripheral_ 1='Yes' 0='No';
    value valvular_surgery_ 1='Yes' 0='No';
    value congenital_surgery_ 1='Yes' 0='No';
    value trauma_requiring_surgery_ 1='Yes' 0='No';
    value current_smoker_ 1='Yes' 0='No';
    value prior_smoker_ 1='Yes' 0='No';
    value current_alcohol_ 1='Yes' 0='No';
    value prior_alcohol_ 1='Yes' 0='No';
    value recreational_drug_use_ 1='Yes' 0='No';
    value occupation_yn_ 1='Yes' 0='No';
    value nyhaclass_ 1='I = no Sx' 2='II = symptoms with sig exertion' 
        3='III = symptoms with mild exertion' 4='IV = rest symptoms; generally if can climb 1 flight of stairs without significant difficulty, NYHA Class < III';
    value orthopnea_ 1='Yes' 0='No';
    value paroxysmal_nocturnal_ 1='Yes' 0='No';
    value lower_extremity_edema_ 1='Yes' 0='No';
    value block_miles_ 1='Blocks' 2='Miles' 
        3='Other';
    value prev_hrt_catheter_ 1='Yes' 0='No';
    value pcwp_12_ 1='Yes' 0='No';
    value lvedp_16_ 1='Yes' 0='No';
    value prior_stress_test_ 1='Yes' 0='No';
    value form_mh_complete_ 0='Incomplete' 1='Unverified' 
        2='Complete';
    value na_form_lab_pre_medication_ 1='Yes' 0='No';
    value iv_line_required_1_ 1='IV Line required' 0='NO IV Line required';
    value preg_test_ 1='Yes' 0='No' 
        99='N/A';
    value cmp_gold_ 1='Yes' 0='No';
    value pax_gene_ 1='Yes' 0='No';
    value nt_pro_ 1='Yes' 0='No';
    value form_lab_methemoglobin_ 1='Yes' 0='No';
    value form_lab_cbc_ 1='Yes' 0='No';
    value g6pd_test_ 1='Yes' 0='No' 
        99='N/A';
    value urine_cc_ 1='Yes' 0='No';
    value plasma_purp_ 1='Yes' 0='No';
    value serum_red_ 1='Yes' 0='No';
    value saliva_tube_ 1='Yes' 0='No';
    value form_lab_6412_complete_ 0='Incomplete' 1='Unverified' 
        2='Complete';
    value na_form_lab_peak_bike_ 1='Yes' 0='No';
    value complete_lab_v3_ 1='Yes' 0='No';
    value plasma_bike_ 1='Yes' 0='No';
    value serum_bike_ 1='Yes' 0='No';
    value form_lab_pre_medicat_v_0_ 0='Incomplete' 1='Unverified' 
        2='Complete';
    value na_form_lab_post_med_ 1='Yes' 0='No';
    value complete_lab_v2_ 1='Yes' 0='No';
    value urine_post_ 1='Yes' 0='No';
    value plasma_post_ 1='Yes' 0='No';
    value serum_post_ 1='Yes' 0='No';
    value saliva_post_ 1='Yes' 0='No';
    value form_lab_pre_medicat_v_1_ 0='Incomplete' 1='Unverified' 
        2='Complete';
    value na_physical_exam_ 1='Yes' 0='No';
    value form_pe_obtained_ 1='Yes' 0='No';
    value height_2_units_ 1='cm' 0='in';
    value weight_2_units_ 1='kg' 0='lbs';
    value blood_pressure_arm_2_ 1='Right Arm' 2='Left Arm';
    value ekg_ 1='Yes' 0='No';
    value orthostatic_symptoms_yn_ 1='Yes' 0='No';
    value sars_yn_ 1='Yes' 0='No';
    value form_pe_complete_ 0='Incomplete' 1='Unverified' 
        2='Complete';
    value na_end_phase_se_review_ 1='Yes' 0='No';
    value mouthwash_se_ep_ 1='Yes' 0='No';
    value compliant_with_mouthwash_se_ep_ 1='Yes' 0='No';
    value reviewed_no_viagra_se_ep_ 1='Yes' 0='No' 
        3='N/A';
    value dietary_restrictions_se_ep_ 1='Yes' 0='No';
    value headache_se_ep_ 1='Yes' 0='No';
    value dizziness_se_ep_ 1='Yes' 0='No';
    value lightheadedness_se_ep_ 1='Yes' 0='No';
    value low_blood_pressure_90_se_ep_ 1='Yes' 0='No';
    value stomach_ache_diarrhea_se_ep_ 1='Yes' 0='No';
    value increased_shortness_se_ep_ 1='Yes' 0='No';
    value flushing_se_ep_ 1='Yes' 0='No';
    value rash_se_ep_ 1='Yes' 0='No';
    value ch_in_blood_pressure_se_ep_ 1='Yes' 0='No';
    value swelling_se_ep_ 1='Yes' 0='No';
    value fatigue_se_assess_ 1='Yes' 0='No';
    value other_symps_se_ 1='Yes' 0='No';
    value orthostat_se_ep_ 1='Yes' 0='No';
    value form_p1_se_ep_ 1='Yes' 0='No';
    value end_phase_side_effec_v_2_ 0='Incomplete' 1='Unverified' 
        2='Complete';
    value na_form_mh_p1_p2_ 1='Yes' 0='No';
    value penn_chart_6p_ 1='Yes' 0='No';
    value gender_6p_ 1='Male' 2='Female';
    value race_6p___1_ 0='Unchecked' 1='Checked';
    value race_6p___2_ 0='Unchecked' 1='Checked';
    value race_6p___3_ 0='Unchecked' 1='Checked';
    value race_6p___4_ 0='Unchecked' 1='Checked';
    value race_6p___5_ 0='Unchecked' 1='Checked';
    value race_6p___6_ 0='Unchecked' 1='Checked';
    value type_decent_6p_ 1='Yes' 0='No';
    value acutecoronary_6p_ 1='Yes' 0='No';
    value prior_angina_6p_ 1='Yes' 0='No';
    value any_arrhythmia_6p_ 1='Yes' 0='No';
    value valv_disease_surgery_6p_ 1='Yes' 0='No';
    value htn_6p_ 1='Yes' 0='No';
    value high_cholesterol_6p_ 1='Yes' 0='No';
    value peripheral_vascular_6p_ 1='Yes' 0='No';
    value diabetes_6p_ 1='Yes' 0='No';
    value insulin_6p_ 1='Yes' 0='No';
    value cva_tia_6p_ 1='Yes' 0='No';
    value pulmonary_embolism_dvt_6p_ 1='Yes' 0='No';
    value osa_6p_ 1='Yes' 0='No';
    value cpap_6p_ 1='Yes' 0='No';
    value copd_asthma_6p_ 1='Yes' 0='No';
    value osteoarthritis_6p_ 1='Yes' 0='No';
    value cabg_6p_ 1='Yes' 0='No';
    value peripheral_6p_ 1='Yes' 0='No';
    value valvular_surgery_6p_ 1='Yes' 0='No';
    value congenital_surgery_6p_ 1='Yes' 0='No';
    value trauma_requiring_surgery_6p_ 1='Yes' 0='No';
    value current_smoker_6p_ 1='Yes' 0='No';
    value prior_smoker_6p_ 1='Yes' 0='No';
    value current_alcohol_6p_ 1='Yes' 0='No';
    value prior_alcohol_6p_ 1='Yes' 0='No';
    value recreational_drug_use_6p_ 1='Yes' 0='No';
    value nyhaclass_6p_ 1='no Sx' 2='symptoms with sig exertion' 
        3='symptoms with mild exertion' 4='rest symptoms; generally if can climb 1 flight of stairs without significant difficulty, NYHA Class < III';
    value orthopnea_6p_ 1='Yes' 0='No';
    value paroxysmal_nocturnal_6p_ 1='Yes' 0='No';
    value lower_extremity_edema_6p_ 1='Yes' 0='No';
    value block_miles_6p_ 1='Blocks' 2='Miles';
    value prev_hrt_catheter_6p_ 1='Yes' 0='No';
    value pcwp_12_6p_ 1='Yes' 0='No';
    value lvedp_16_6p_ 1='Yes' 0='No';
    value prior_stress_test_6p_ 1='Yes' 0='No';
    value bl_mh_cmplt_6p_ 1='Yes' 0='No';
    value form_mh_8174_complete_ 0='Incomplete' 1='Unverified' 
        2='Complete';
    value na_medications_ 1='Yes' 0='No';
    value num_med_ 1='1' 2='2' 
        3='3' 4='4' 
        5='5' 6='6' 
        7='7' 8='8' 
        9='9' 10='10' 
        11='11' 12='12' 
        13='13' 14='14' 
        15='15' 16='16' 
        17='17' 18='18' 
        19='19' 20='20' 
        21='21' 22='22' 
        23='23' 24='24' 
        25='25' 26='26' 
        27='27' 28='28' 
        29='29' 30='30';
    value meds_1_ 4='Aspirin' 5='Clopidogrel (Plavix?)' 
        6='Dipyridamole' 7='Prasugrel (Effient)' 
        8='Ticagrelor (Brillanta)' 9='Rivaroxaban (Xarelto)' 
        10='Dabigatran (Pradaxa)' 11='Apixaban (Eliquis)' 
        12='Heparin (various)' 13='Warfarin (Coumadin)' 
        14='ACE Inhibitors' 15='Benazepril (Lotensin)' 
        16='Captopril (Capoten)' 17='Enalapril (Vasotec)' 
        18='Fosinopril (Monopril)' 19='Lisinopril (Prinivil, Zestril)' 
        20='Moexipril (Univasc)' 21='Perindopril (Aceon)' 
        22='Quinapril (Accupril)' 23='Ramipril (Altace)' 
        24='Trandolapril (Mavik)' 25='Candesartan (Atacand)' 
        26='Eprosartan (Teveten)' 27='Irbesartan (Avapro)' 
        28='Losartan (Cozaar)' 29='Telmisartan (Micardis)' 
        30='Valsartan (Diovan)' 31='Acebutolol (Sectral)' 
        32='Atenolol (Tenormin)' 33='Betaxolol (Kerlone)' 
        34='Bisoprolol/hydrochlorothiazide (Ziac)' 35='Bisoprolol (Zebeta)' 
        36='Metoprolol (Lopressor, Toprol XL)' 37='Nadolol (Corgard)' 
        38='Propranolol (Inderal)' 39='Sotalol (Betapace)' 
        40='Carvedilol (Coreg)' 41='Amlodipine (Norvasc, Lotrel)' 
        42='Diltiazem (Cardizem, Tiazac)' 43='Felodipine (Plendil)' 
        44='Nifedipine (Adalat, Procardia)' 45='Nimodipine (Nimotop)' 
        46='Nisoldipine (Sular)' 47='Verapamil (Calan, Verelan)' 
        48='Atorvastatin (Lipitor)' 49='Rosuvastatin (Crestor)' 
        50='Lovastatin (Mevacor, Altocor, Altoprev)' 51='Pitavastatin (Livalo)' 
        52='Ezetimibe/Simvastatin (Vytorin)' 53='Niacin' 
        54='Digoxin (Lanoxin)' 55='Amiloride (Midamor)' 
        56='Bumetanide (Bumex)' 57='Chlorothiazide (Diuril)' 
        58='Chlorthalidone (Hygroton)' 59='Furosemide (Lasix)' 
        60='Hydrochlorothiazide (Esidrix, Hydrodiuril)' 61='Indapamide (Lozol)' 
        62='Spironolactone (Aldactone)' 63='Eplerenone (Inspra)' 
        64='Isosorbide mononitrate (Imdur)' 65='Isosorbide dinitrate' 
        66='Nitroglycerin' 67='Hydralazine (Apresoline)' 
        68='Methyldopa (Aldomet)' 69='Doxazosin (Cardura)' 
        70='Prazosin (Minipress)' 71='Terazosin (Hytrin)' 
        72='Clonidine (Catapres)' 73='Minoxidil (Loniten)' 
        74='Simvastatin' 75='Ethacrynic acid' 
        76='Edoxaban' 999='Other';
    value units_1_ 1='mg' 2='ug' 
        3='Units' 999='Other';
    value freq_1_ 1='FREQUENCY' 2='EVERY MORNING' 
        3='DAILY' 4='TWICE DAILY' 
        5='3 TIMES DAILY' 6='4 TIMES DAILY' 
        7='AS NEEDED' 999='OTHER';
    value route_1_ 1='By mouth' 2='Topically' 
        3='Sublingual' 4='Subcutaneous' 
        999='Other';
    value recent_start_date_1_ 1='Yes' 0='No';
    value recent_end_date_1_ 1='Yes' 0='No';
    value meds_2_ 4='Aspirin' 5='Clopidogrel (Plavix)' 
        6='Dipyridamole' 7='Prasugrel (Effient)' 
        8='Ticagrelor (Brillanta)' 9='Rivaroxaban (Xarelto)' 
        10='Dabigatran (Pradaxa)' 11='Apixaban (Eliquis)' 
        12='Heparin (various)' 13='Warfarin (Coumadin)' 
        14='ACE Inhibitors' 15='Benazepril (Lotensin)' 
        16='Captopril (Capoten)' 17='Enalapril (Vasotec)' 
        18='Fosinopril (Monopril)' 19='Lisinopril (Prinivil, Zestril)' 
        20='Moexipril (Univasc)' 21='Perindopril (Aceon)' 
        22='Quinapril (Accupril)' 23='Ramipril (Altace)' 
        24='Trandolapril (Mavik)' 25='Candesartan (Atacand)' 
        26='Eprosartan (Teveten)' 27='Irbesartan (Avapro)' 
        28='Losartan (Cozaar)' 29='Telmisartan (Micardis)' 
        30='Valsartan (Diovan)' 31='Acebutolol (Sectral)' 
        32='Atenolol (Tenormin)' 33='Betaxolol (Kerlone)' 
        34='Bisoprolol/hydrochlorothiazide (Ziac)' 35='Bisoprolol (Zebeta)' 
        36='Metoprolol (Lopressor, Toprol XL)' 37='Nadolol (Corgard)' 
        38='Propranolol (Inderal)' 39='Sotalol (Betapace)' 
        40='Carvedilol (Coreg)' 41='Amlodipine (Norvasc, Lotrel)' 
        42='Diltiazem (Cardizem, Tiazac)' 43='Felodipine (Plendil)' 
        44='Nifedipine (Adalat, Procardia)' 45='Nimodipine (Nimotop)' 
        46='Nisoldipine (Sular)' 47='Verapamil (Calan, Verelan)' 
        48='Atorvastatin (Lipitor)' 49='Rosuvastatin (Crestor)' 
        50='Lovastatin (Mevacor, Altocor, Altoprev)' 51='Pitavastatin (Livalo)' 
        52='Ezetimibe/Simvastatin (Vytorin)' 53='Niacin' 
        54='Digoxin (Lanoxin)' 55='Amiloride (Midamor)' 
        56='Bumetanide (Bumex)' 57='Chlorothiazide (Diuril)' 
        58='Chlorthalidone (Hygroton)' 59='Furosemide (Lasix)' 
        60='Hydrochlorothiazide (Esidrix, Hydrodiuril)' 61='Indapamide (Lozol)' 
        62='Spironolactone (Aldactone)' 63='Eplerenone (Inspra)' 
        64='Isosorbide mononitrate (Imdur)' 65='Isosorbide dinitrate' 
        66='Nitroglycerin' 67='Hydralazine (Apresoline)' 
        68='Methyldopa (Aldomet)' 69='Doxazosin (Cardura)' 
        70='Prazosin (Minipress)' 71='Terazosin (Hytrin)' 
        72='Clonidine (Catapres)' 73='Minoxidil (Loniten)' 
        74='Simvastatin' 75='Ethacrynic acid' 
        76='Edoxaban' 999='Other';
    value units_2_ 1='mg' 2='ug' 
        3='Units' 999='Other';
    value freq_2_ 1='FREQUENCY' 2='EVERY MORNING' 
        3='DAILY' 4='TWICE DAILY' 
        5='3 TIMES DAILY' 6='4 TIMES DAILY' 
        7='AS NEEDED' 999='OTHER';
    value route_2_ 1='By mouth' 2='Topically' 
        3='Sublingual' 4='Subcutaneous' 
        999='Other';
    value recent_start_date_2_ 1='Yes' 0='No';
    value recent_end_date_2_ 1='Yes' 0='No';
    value meds_3_ 4='Aspirin' 5='Clopidogrel (Plavix)' 
        6='Dipyridamole' 7='Prasugrel (Effient)' 
        8='Ticagrelor (Brillanta)' 9='Rivaroxaban (Xarelto)' 
        10='Dabigatran (Pradaxa)' 11='Apixaban (Eliquis)' 
        12='Heparin (various)' 13='Warfarin (Coumadin)' 
        14='ACE Inhibitors' 15='Benazepril (Lotensin)' 
        16='Captopril (Capoten)' 17='Enalapril (Vasotec)' 
        18='Fosinopril (Monopril)' 19='Lisinopril (Prinivil, Zestril)' 
        20='Moexipril (Univasc)' 21='Perindopril (Aceon)' 
        22='Quinapril (Accupril)' 23='Ramipril (Altace)' 
        24='Trandolapril (Mavik)' 25='Candesartan (Atacand)' 
        26='Eprosartan (Teveten)' 27='Irbesartan (Avapro)' 
        28='Losartan (Cozaar)' 29='Telmisartan (Micardis)' 
        30='Valsartan (Diovan)' 31='Acebutolol (Sectral)' 
        32='Atenolol (Tenormin)' 33='Betaxolol (Kerlone)' 
        34='Bisoprolol/hydrochlorothiazide (Ziac)' 35='Bisoprolol (Zebeta)' 
        36='Metoprolol (Lopressor, Toprol XL)' 37='Nadolol (Corgard)' 
        38='Propranolol (Inderal)' 39='Sotalol (Betapace)' 
        40='Carvedilol (Coreg)' 41='Amlodipine (Norvasc, Lotrel)' 
        42='Diltiazem (Cardizem, Tiazac)' 43='Felodipine (Plendil)' 
        44='Nifedipine (Adalat, Procardia)' 45='Nimodipine (Nimotop)' 
        46='Nisoldipine (Sular)' 47='Verapamil (Calan, Verelan)' 
        48='Atorvastatin (Lipitor)' 49='Rosuvastatin (Crestor)' 
        50='Lovastatin (Mevacor, Altocor, Altoprev)' 51='Pitavastatin (Livalo)' 
        52='Ezetimibe/Simvastatin (Vytorin)' 53='Niacin' 
        54='Digoxin (Lanoxin)' 55='Amiloride (Midamor)' 
        56='Bumetanide (Bumex)' 57='Chlorothiazide (Diuril)' 
        58='Chlorthalidone (Hygroton)' 59='Furosemide (Lasix)' 
        60='Hydrochlorothiazide (Esidrix, Hydrodiuril)' 61='Indapamide (Lozol)' 
        62='Spironolactone (Aldactone)' 63='Eplerenone (Inspra)' 
        64='Isosorbide mononitrate (Imdur)' 65='Isosorbide dinitrate' 
        66='Nitroglycerin' 67='Hydralazine (Apresoline)' 
        68='Methyldopa (Aldomet)' 69='Doxazosin (Cardura)' 
        70='Prazosin (Minipress)' 71='Terazosin (Hytrin)' 
        72='Clonidine (Catapres)' 73='Minoxidil (Loniten)' 
        74='Simvastatin' 75='Ethacrynic acid' 
        76='Edoxaban' 999='Other';
    value units_3_ 1='mg' 2='ug' 
        3='Units' 999='Other';
    value freq_3_ 1='FREQUENCY' 2='EVERY MORNING' 
        3='DAILY' 4='TWICE DAILY' 
        5='3 TIMES DAILY' 6='4 TIMES DAILY' 
        7='AS NEEDED' 999='OTHER';
    value route_3_ 1='By mouth' 2='Topically' 
        3='Sublingual' 4='Subcutaneous' 
        999='Other';
    value recent_start_date_3_ 1='Yes' 0='No';
    value recent_end_date_3_ 1='Yes' 0='No';
    value meds_4_ 4='Aspirin' 5='Clopidogrel (Plavix)' 
        6='Dipyridamole' 7='Prasugrel (Effient)' 
        8='Ticagrelor (Brillanta)' 9='Rivaroxaban (Xarelto)' 
        10='Dabigatran (Pradaxa)' 11='Apixaban (Eliquis)' 
        12='Heparin (various)' 13='Warfarin (Coumadin)' 
        14='ACE Inhibitors' 15='Benazepril (Lotensin)' 
        16='Captopril (Capoten)' 17='Enalapril (Vasotec)' 
        18='Fosinopril (Monopril)' 19='Lisinopril (Prinivil, Zestril)' 
        20='Moexipril (Univasc)' 21='Perindopril (Aceon)' 
        22='Quinapril (Accupril)' 23='Ramipril (Altace)' 
        24='Trandolapril (Mavik)' 25='Candesartan (Atacand)' 
        26='Eprosartan (Teveten)' 27='Irbesartan (Avapro)' 
        28='Losartan (Cozaar)' 29='Telmisartan (Micardis)' 
        30='Valsartan (Diovan)' 31='Acebutolol (Sectral)' 
        32='Atenolol (Tenormin)' 33='Betaxolol (Kerlone)' 
        34='Bisoprolol/hydrochlorothiazide (Ziac)' 35='Bisoprolol (Zebeta)' 
        36='Metoprolol (Lopressor, Toprol XL)' 37='Nadolol (Corgard)' 
        38='Propranolol (Inderal)' 39='Sotalol (Betapace)' 
        40='Carvedilol (Coreg)' 41='Amlodipine (Norvasc, Lotrel)' 
        42='Diltiazem (Cardizem, Tiazac)' 43='Felodipine (Plendil)' 
        44='Nifedipine (Adalat, Procardia)' 45='Nimodipine (Nimotop)' 
        46='Nisoldipine (Sular)' 47='Verapamil (Calan, Verelan)' 
        48='Atorvastatin (Lipitor)' 49='Rosuvastatin (Crestor)' 
        50='Lovastatin (Mevacor, Altocor, Altoprev)' 51='Pitavastatin (Livalo)' 
        52='Ezetimibe/Simvastatin (Vytorin)' 53='Niacin' 
        54='Digoxin (Lanoxin)' 55='Amiloride (Midamor)' 
        56='Bumetanide (Bumex)' 57='Chlorothiazide (Diuril)' 
        58='Chlorthalidone (Hygroton)' 59='Furosemide (Lasix)' 
        60='Hydrochlorothiazide (Esidrix, Hydrodiuril)' 61='Indapamide (Lozol)' 
        62='Spironolactone (Aldactone)' 63='Eplerenone (Inspra)' 
        64='Isosorbide mononitrate (Imdur)' 65='Isosorbide dinitrate' 
        66='Nitroglycerin' 67='Hydralazine (Apresoline)' 
        68='Methyldopa (Aldomet)' 69='Doxazosin (Cardura)' 
        70='Prazosin (Minipress)' 71='Terazosin (Hytrin)' 
        72='Clonidine (Catapres)' 73='Minoxidil (Loniten)' 
        74='Simvastatin' 75='Ethacrynic acid' 
        76='Edoxaban' 999='Other';
    value units_4_ 1='mg' 2='ug' 
        3='Units' 999='Other';
    value freq_4_ 1='FREQUENCY' 2='EVERY MORNING' 
        3='DAILY' 4='TWICE DAILY' 
        5='3 TIMES DAILY' 6='4 TIMES DAILY' 
        7='AS NEEDED' 999='OTHER';
    value route_4_ 1='By mouth' 2='Topically' 
        3='Sublingual' 4='Subcutaneous' 
        999='Other';
    value recent_start_date_4_ 1='Yes' 0='No';
    value recent_end_date_4_ 1='Yes' 0='No';
    value meds_5_ 4='Aspirin' 5='Clopidogrel (Plavix)' 
        6='Dipyridamole' 7='Prasugrel (Effient)' 
        8='Ticagrelor (Brillanta)' 9='Rivaroxaban (Xarelto)' 
        10='Dabigatran (Pradaxa)' 11='Apixaban (Eliquis)' 
        12='Heparin (various)' 13='Warfarin (Coumadin)' 
        14='ACE Inhibitors' 15='Benazepril (Lotensin)' 
        16='Captopril (Capoten)' 17='Enalapril (Vasotec)' 
        18='Fosinopril (Monopril)' 19='Lisinopril (Prinivil, Zestril)' 
        20='Moexipril (Univasc)' 21='Perindopril (Aceon)' 
        22='Quinapril (Accupril)' 23='Ramipril (Altace)' 
        24='Trandolapril (Mavik)' 25='Candesartan (Atacand)' 
        26='Eprosartan (Teveten)' 27='Irbesartan (Avapro)' 
        28='Losartan (Cozaar)' 29='Telmisartan (Micardis)' 
        30='Valsartan (Diovan)' 31='Acebutolol (Sectral)' 
        32='Atenolol (Tenormin)' 33='Betaxolol (Kerlone)' 
        34='Bisoprolol/hydrochlorothiazide (Ziac)' 35='Bisoprolol (Zebeta)' 
        36='Metoprolol (Lopressor, Toprol XL)' 37='Nadolol (Corgard)' 
        38='Propranolol (Inderal)' 39='Sotalol (Betapace)' 
        40='Carvedilol (Coreg)' 41='Amlodipine (Norvasc, Lotrel)' 
        42='Diltiazem (Cardizem, Tiazac)' 43='Felodipine (Plendil)' 
        44='Nifedipine (Adalat, Procardia)' 45='Nimodipine (Nimotop)' 
        46='Nisoldipine (Sular)' 47='Verapamil (Calan, Verelan)' 
        48='Atorvastatin (Lipitor)' 49='Rosuvastatin (Crestor)' 
        50='Lovastatin (Mevacor, Altocor, Altoprev)' 51='Pitavastatin (Livalo)' 
        52='Ezetimibe/Simvastatin (Vytorin)' 53='Niacin' 
        54='Digoxin (Lanoxin)' 55='Amiloride (Midamor)' 
        56='Bumetanide (Bumex)' 57='Chlorothiazide (Diuril)' 
        58='Chlorthalidone (Hygroton)' 59='Furosemide (Lasix)' 
        60='Hydrochlorothiazide (Esidrix, Hydrodiuril)' 61='Indapamide (Lozol)' 
        62='Spironolactone (Aldactone)' 63='Eplerenone (Inspra)' 
        64='Isosorbide mononitrate (Imdur)' 65='Isosorbide dinitrate' 
        66='Nitroglycerin' 67='Hydralazine (Apresoline)' 
        68='Methyldopa (Aldomet)' 69='Doxazosin (Cardura)' 
        70='Prazosin (Minipress)' 71='Terazosin (Hytrin)' 
        72='Clonidine (Catapres)' 73='Minoxidil (Loniten)' 
        74='Simvastatin' 75='Ethacrynic acid' 
        76='Edoxaban' 999='Other';
    value units_5_ 1='mg' 2='ug' 
        3='Units' 999='Other';
    value freq_5_ 1='FREQUENCY' 2='EVERY MORNING' 
        3='DAILY' 4='TWICE DAILY' 
        5='3 TIMES DAILY' 6='4 TIMES DAILY' 
        7='AS NEEDED' 999='OTHER';
    value route_5_ 1='By mouth' 2='Topically' 
        3='Sublingual' 4='Subcutaneous' 
        999='Other';
    value recent_start_date_5_ 1='Yes' 0='No';
    value recent_end_date_5_ 1='Yes' 0='No';
    value meds_6_ 4='Aspirin' 5='Clopidogrel (Plavix)' 
        6='Dipyridamole' 7='Prasugrel (Effient)' 
        8='Ticagrelor (Brillanta)' 9='Rivaroxaban (Xarelto)' 
        10='Dabigatran (Pradaxa)' 11='Apixaban (Eliquis)' 
        12='Heparin (various)' 13='Warfarin (Coumadin)' 
        14='ACE Inhibitors' 15='Benazepril (Lotensin)' 
        16='Captopril (Capoten)' 17='Enalapril (Vasotec)' 
        18='Fosinopril (Monopril)' 19='Lisinopril (Prinivil, Zestril)' 
        20='Moexipril (Univasc)' 21='Perindopril (Aceon)' 
        22='Quinapril (Accupril)' 23='Ramipril (Altace)' 
        24='Trandolapril (Mavik)' 25='Candesartan (Atacand)' 
        26='Eprosartan (Teveten)' 27='Irbesartan (Avapro)' 
        28='Losartan (Cozaar)' 29='Telmisartan (Micardis)' 
        30='Valsartan (Diovan)' 31='Acebutolol (Sectral)' 
        32='Atenolol (Tenormin)' 33='Betaxolol (Kerlone)' 
        34='Bisoprolol/hydrochlorothiazide (Ziac)' 35='Bisoprolol (Zebeta)' 
        36='Metoprolol (Lopressor, Toprol XL)' 37='Nadolol (Corgard)' 
        38='Propranolol (Inderal)' 39='Sotalol (Betapace)' 
        40='Carvedilol (Coreg)' 41='Amlodipine (Norvasc, Lotrel)' 
        42='Diltiazem (Cardizem, Tiazac)' 43='Felodipine (Plendil)' 
        44='Nifedipine (Adalat, Procardia)' 45='Nimodipine (Nimotop)' 
        46='Nisoldipine (Sular)' 47='Verapamil (Calan, Verelan)' 
        48='Atorvastatin (Lipitor)' 49='Rosuvastatin (Crestor)' 
        50='Lovastatin (Mevacor, Altocor, Altoprev)' 51='Pitavastatin (Livalo)' 
        52='Ezetimibe/Simvastatin (Vytorin)' 53='Niacin' 
        54='Digoxin (Lanoxin)' 55='Amiloride (Midamor)' 
        56='Bumetanide (Bumex)' 57='Chlorothiazide (Diuril)' 
        58='Chlorthalidone (Hygroton)' 59='Furosemide (Lasix)' 
        60='Hydrochlorothiazide (Esidrix, Hydrodiuril)' 61='Indapamide (Lozol)' 
        62='Spironolactone (Aldactone)' 63='Eplerenone (Inspra)' 
        64='Isosorbide mononitrate (Imdur)' 65='Isosorbide dinitrate' 
        66='Nitroglycerin' 67='Hydralazine (Apresoline)' 
        68='Methyldopa (Aldomet)' 69='Doxazosin (Cardura)' 
        70='Prazosin (Minipress)' 71='Terazosin (Hytrin)' 
        72='Clonidine (Catapres)' 73='Minoxidil (Loniten)' 
        74='Simvastatin' 75='Ethacrynic acid' 
        76='Edoxaban' 999='Other';
    value units_6_ 1='mg' 2='ug' 
        3='Units' 999='Other';
    value freq_6_ 1='FREQUENCY' 2='EVERY MORNING' 
        3='DAILY' 4='TWICE DAILY' 
        5='3 TIMES DAILY' 6='4 TIMES DAILY' 
        7='AS NEEDED' 999='OTHER';
    value route_6_ 1='By mouth' 2='Topically' 
        3='Sublingual' 4='Subcutaneous' 
        999='Other';
    value recent_start_date_6_ 1='Yes' 0='No';
    value recent_end_date_6_ 1='Yes' 0='No';
    value meds_7_ 4='Aspirin' 5='Clopidogrel (Plavix)' 
        6='Dipyridamole' 7='Prasugrel (Effient)' 
        8='Ticagrelor (Brillanta)' 9='Rivaroxaban (Xarelto)' 
        10='Dabigatran (Pradaxa)' 11='Apixaban (Eliquis)' 
        12='Heparin (various)' 13='Warfarin (Coumadin)' 
        14='ACE Inhibitors' 15='Benazepril (Lotensin)' 
        16='Captopril (Capoten)' 17='Enalapril (Vasotec)' 
        18='Fosinopril (Monopril)' 19='Lisinopril (Prinivil, Zestril)' 
        20='Moexipril (Univasc)' 21='Perindopril (Aceon)' 
        22='Quinapril (Accupril)' 23='Ramipril (Altace)' 
        24='Trandolapril (Mavik)' 25='Candesartan (Atacand)' 
        26='Eprosartan (Teveten)' 27='Irbesartan (Avapro)' 
        28='Losartan (Cozaar)' 29='Telmisartan (Micardis)' 
        30='Valsartan (Diovan)' 31='Acebutolol (Sectral)' 
        32='Atenolol (Tenormin)' 33='Betaxolol (Kerlone)' 
        34='Bisoprolol/hydrochlorothiazide (Ziac)' 35='Bisoprolol (Zebeta)' 
        36='Metoprolol (Lopressor, Toprol XL)' 37='Nadolol (Corgard)' 
        38='Propranolol (Inderal)' 39='Sotalol (Betapace)' 
        40='Carvedilol (Coreg)' 41='Amlodipine (Norvasc, Lotrel)' 
        42='Diltiazem (Cardizem, Tiazac)' 43='Felodipine (Plendil)' 
        44='Nifedipine (Adalat, Procardia)' 45='Nimodipine (Nimotop)' 
        46='Nisoldipine (Sular)' 47='Verapamil (Calan, Verelan)' 
        48='Atorvastatin (Lipitor)' 49='Rosuvastatin (Crestor)' 
        50='Lovastatin (Mevacor, Altocor, Altoprev)' 51='Pitavastatin (Livalo)' 
        52='Ezetimibe/Simvastatin (Vytorin)' 53='Niacin' 
        54='Digoxin (Lanoxin)' 55='Amiloride (Midamor)' 
        56='Bumetanide (Bumex)' 57='Chlorothiazide (Diuril)' 
        58='Chlorthalidone (Hygroton)' 59='Furosemide (Lasix)' 
        60='Hydrochlorothiazide (Esidrix, Hydrodiuril)' 61='Indapamide (Lozol)' 
        62='Spironolactone (Aldactone)' 63='Eplerenone (Inspra)' 
        64='Isosorbide mononitrate (Imdur)' 65='Isosorbide dinitrate' 
        66='Nitroglycerin' 67='Hydralazine (Apresoline)' 
        68='Methyldopa (Aldomet)' 69='Doxazosin (Cardura)' 
        70='Prazosin (Minipress)' 71='Terazosin (Hytrin)' 
        72='Clonidine (Catapres)' 73='Minoxidil (Loniten)' 
        74='Simvastatin' 75='Ethacrynic acid' 
        76='Edoxaban' 999='Other';
    value units_7_ 1='mg' 2='ug' 
        3='Units' 999='Other';
    value freq_7_ 1='FREQUENCY' 2='EVERY MORNING' 
        3='DAILY' 4='TWICE DAILY' 
        5='3 TIMES DAILY' 6='4 TIMES DAILY' 
        7='AS NEEDED' 999='OTHER';
    value route_7_ 1='By mouth' 2='Topically' 
        3='Sublingual' 4='Subcutaneous' 
        999='Other';
    value recent_start_date_7_ 1='Yes' 0='No';
    value recent_end_date_7_ 1='Yes' 0='No';
    value meds_8_ 4='Aspirin' 5='Clopidogrel (Plavix)' 
        6='Dipyridamole' 7='Prasugrel (Effient)' 
        8='Ticagrelor (Brillanta)' 9='Rivaroxaban (Xarelto)' 
        10='Dabigatran (Pradaxa)' 11='Apixaban (Eliquis)' 
        12='Heparin (various)' 13='Warfarin (Coumadin)' 
        14='ACE Inhibitors' 15='Benazepril (Lotensin)' 
        16='Captopril (Capoten)' 17='Enalapril (Vasotec)' 
        18='Fosinopril (Monopril)' 19='Lisinopril (Prinivil, Zestril)' 
        20='Moexipril (Univasc)' 21='Perindopril (Aceon)' 
        22='Quinapril (Accupril)' 23='Ramipril (Altace)' 
        24='Trandolapril (Mavik)' 25='Candesartan (Atacand)' 
        26='Eprosartan (Teveten)' 27='Irbesartan (Avapro)' 
        28='Losartan (Cozaar)' 29='Telmisartan (Micardis)' 
        30='Valsartan (Diovan)' 31='Acebutolol (Sectral)' 
        32='Atenolol (Tenormin)' 33='Betaxolol (Kerlone)' 
        34='Bisoprolol/hydrochlorothiazide (Ziac)' 35='Bisoprolol (Zebeta)' 
        36='Metoprolol (Lopressor, Toprol XL)' 37='Nadolol (Corgard)' 
        38='Propranolol (Inderal)' 39='Sotalol (Betapace)' 
        40='Carvedilol (Coreg)' 41='Amlodipine (Norvasc, Lotrel)' 
        42='Diltiazem (Cardizem, Tiazac)' 43='Felodipine (Plendil)' 
        44='Nifedipine (Adalat, Procardia)' 45='Nimodipine (Nimotop)' 
        46='Nisoldipine (Sular)' 47='Verapamil (Calan, Verelan)' 
        48='Atorvastatin (Lipitor)' 49='Rosuvastatin (Crestor)' 
        50='Lovastatin (Mevacor, Altocor, Altoprev)' 51='Pitavastatin (Livalo)' 
        52='Ezetimibe/Simvastatin (Vytorin)' 53='Niacin' 
        54='Digoxin (Lanoxin)' 55='Amiloride (Midamor)' 
        56='Bumetanide (Bumex)' 57='Chlorothiazide (Diuril)' 
        58='Chlorthalidone (Hygroton)' 59='Furosemide (Lasix)' 
        60='Hydrochlorothiazide (Esidrix, Hydrodiuril)' 61='Indapamide (Lozol)' 
        62='Spironolactone (Aldactone)' 63='Eplerenone (Inspra)' 
        64='Isosorbide mononitrate (Imdur)' 65='Isosorbide dinitrate' 
        66='Nitroglycerin' 67='Hydralazine (Apresoline)' 
        68='Methyldopa (Aldomet)' 69='Doxazosin (Cardura)' 
        70='Prazosin (Minipress)' 71='Terazosin (Hytrin)' 
        72='Clonidine (Catapres)' 73='Minoxidil (Loniten)' 
        74='Simvastatin' 75='Ethacrynic acid' 
        76='Edoxaban' 999='Other';
    value units_8_ 1='mg' 2='ug' 
        3='Units' 999='Other';
    value freq_8_ 1='FREQUENCY' 2='EVERY MORNING' 
        3='DAILY' 4='TWICE DAILY' 
        5='3 TIMES DAILY' 6='4 TIMES DAILY' 
        7='AS NEEDED' 999='OTHER';
    value route_8_ 1='By mouth' 2='Topically' 
        3='Sublingual' 4='Subcutaneous' 
        999='Other';
    value recent_start_date_8_ 1='Yes' 0='No';
    value recent_end_date_8_ 1='Yes' 0='No';
    value meds_9_ 4='Aspirin' 5='Clopidogrel (Plavix)' 
        6='Dipyridamole' 7='Prasugrel (Effient)' 
        8='Ticagrelor (Brillanta)' 9='Rivaroxaban (Xarelto)' 
        10='Dabigatran (Pradaxa)' 11='Apixaban (Eliquis)' 
        12='Heparin (various)' 13='Warfarin (Coumadin)' 
        14='ACE Inhibitors' 15='Benazepril (Lotensin)' 
        16='Captopril (Capoten)' 17='Enalapril (Vasotec)' 
        18='Fosinopril (Monopril)' 19='Lisinopril (Prinivil, Zestril)' 
        20='Moexipril (Univasc)' 21='Perindopril (Aceon)' 
        22='Quinapril (Accupril)' 23='Ramipril (Altace)' 
        24='Trandolapril (Mavik)' 25='Candesartan (Atacand)' 
        26='Eprosartan (Teveten)' 27='Irbesartan (Avapro)' 
        28='Losartan (Cozaar)' 29='Telmisartan (Micardis)' 
        30='Valsartan (Diovan)' 31='Acebutolol (Sectral)' 
        32='Atenolol (Tenormin)' 33='Betaxolol (Kerlone)' 
        34='Bisoprolol/hydrochlorothiazide (Ziac)' 35='Bisoprolol (Zebeta)' 
        36='Metoprolol (Lopressor, Toprol XL)' 37='Nadolol (Corgard)' 
        38='Propranolol (Inderal)' 39='Sotalol (Betapace)' 
        40='Carvedilol (Coreg)' 41='Amlodipine (Norvasc, Lotrel)' 
        42='Diltiazem (Cardizem, Tiazac)' 43='Felodipine (Plendil)' 
        44='Nifedipine (Adalat, Procardia)' 45='Nimodipine (Nimotop)' 
        46='Nisoldipine (Sular)' 47='Verapamil (Calan, Verelan)' 
        48='Atorvastatin (Lipitor)' 49='Rosuvastatin (Crestor)' 
        50='Lovastatin (Mevacor, Altocor, Altoprev)' 51='Pitavastatin (Livalo)' 
        52='Ezetimibe/Simvastatin (Vytorin)' 53='Niacin' 
        54='Digoxin (Lanoxin)' 55='Amiloride (Midamor)' 
        56='Bumetanide (Bumex)' 57='Chlorothiazide (Diuril)' 
        58='Chlorthalidone (Hygroton)' 59='Furosemide (Lasix)' 
        60='Hydrochlorothiazide (Esidrix, Hydrodiuril)' 61='Indapamide (Lozol)' 
        62='Spironolactone (Aldactone)' 63='Eplerenone (Inspra)' 
        64='Isosorbide mononitrate (Imdur)' 65='Isosorbide dinitrate' 
        66='Nitroglycerin' 67='Hydralazine (Apresoline)' 
        68='Methyldopa (Aldomet)' 69='Doxazosin (Cardura)' 
        70='Prazosin (Minipress)' 71='Terazosin (Hytrin)' 
        72='Clonidine (Catapres)' 73='Minoxidil (Loniten)' 
        74='Simvastatin' 75='Ethacrynic acid' 
        76='Edoxaban' 999='Other';
    value units_9_ 1='mg' 2='ug' 
        3='Units' 999='Other';
    value freq_9_ 1='FREQUENCY' 2='EVERY MORNING' 
        3='DAILY' 4='TWICE DAILY' 
        5='3 TIMES DAILY' 6='4 TIMES DAILY' 
        7='AS NEEDED' 999='OTHER';
    value route_9_ 1='By mouth' 2='Topically' 
        3='Sublingual' 4='Subcutaneous' 
        999='Other';
    value recent_start_date_9_ 1='Yes' 0='No';
    value recent_end_date_9_ 1='Yes' 0='No';
    value meds_10_ 4='Aspirin' 5='Clopidogrel (Plavix)' 
        6='Dipyridamole' 7='Prasugrel (Effient)' 
        8='Ticagrelor (Brillanta)' 9='Rivaroxaban (Xarelto)' 
        10='Dabigatran (Pradaxa)' 11='Apixaban (Eliquis)' 
        12='Heparin (various)' 13='Warfarin (Coumadin)' 
        14='ACE Inhibitors' 15='Benazepril (Lotensin)' 
        16='Captopril (Capoten)' 17='Enalapril (Vasotec)' 
        18='Fosinopril (Monopril)' 19='Lisinopril (Prinivil, Zestril)' 
        20='Moexipril (Univasc)' 21='Perindopril (Aceon)' 
        22='Quinapril (Accupril)' 23='Ramipril (Altace)' 
        24='Trandolapril (Mavik)' 25='Candesartan (Atacand)' 
        26='Eprosartan (Teveten)' 27='Irbesartan (Avapro)' 
        28='Losartan (Cozaar)' 29='Telmisartan (Micardis)' 
        30='Valsartan (Diovan)' 31='Acebutolol (Sectral)' 
        32='Atenolol (Tenormin)' 33='Betaxolol (Kerlone)' 
        34='Bisoprolol/hydrochlorothiazide (Ziac)' 35='Bisoprolol (Zebeta)' 
        36='Metoprolol (Lopressor, Toprol XL)' 37='Nadolol (Corgard)' 
        38='Propranolol (Inderal)' 39='Sotalol (Betapace)' 
        40='Carvedilol (Coreg)' 41='Amlodipine (Norvasc, Lotrel)' 
        42='Diltiazem (Cardizem, Tiazac)' 43='Felodipine (Plendil)' 
        44='Nifedipine (Adalat, Procardia)' 45='Nimodipine (Nimotop)' 
        46='Nisoldipine (Sular)' 47='Verapamil (Calan, Verelan)' 
        48='Atorvastatin (Lipitor)' 49='Rosuvastatin (Crestor)' 
        50='Lovastatin (Mevacor, Altocor, Altoprev)' 51='Pitavastatin (Livalo)' 
        52='Ezetimibe/Simvastatin (Vytorin)' 53='Niacin' 
        54='Digoxin (Lanoxin)' 55='Amiloride (Midamor)' 
        56='Bumetanide (Bumex)' 57='Chlorothiazide (Diuril)' 
        58='Chlorthalidone (Hygroton)' 59='Furosemide (Lasix)' 
        60='Hydrochlorothiazide (Esidrix, Hydrodiuril)' 61='Indapamide (Lozol)' 
        62='Spironolactone (Aldactone)' 63='Eplerenone (Inspra)' 
        64='Isosorbide mononitrate (Imdur)' 65='Isosorbide dinitrate' 
        66='Nitroglycerin' 67='Hydralazine (Apresoline)' 
        68='Methyldopa (Aldomet)' 69='Doxazosin (Cardura)' 
        70='Prazosin (Minipress)' 71='Terazosin (Hytrin)' 
        72='Clonidine (Catapres)' 73='Minoxidil (Loniten)' 
        74='Simvastatin' 75='Ethacrynic acid' 
        76='Edoxaban' 999='Other';
    value units_10_ 1='mg' 2='ug' 
        3='Units' 999='Other';
    value freq_10_ 1='FREQUENCY' 2='EVERY MORNING' 
        3='DAILY' 4='TWICE DAILY' 
        5='3 TIMES DAILY' 6='4 TIMES DAILY' 
        7='AS NEEDED' 999='OTHER';
    value route_10_ 1='By mouth' 2='Topically' 
        3='Sublingual' 4='Subcutaneous' 
        999='Other';
    value recent_start_date_10_ 1='Yes' 0='No';
    value recent_end_date_10_ 1='Yes' 0='No';
    value meds_11_ 4='Aspirin' 5='Clopidogrel (Plavix)' 
        6='Dipyridamole' 7='Prasugrel (Effient)' 
        8='Ticagrelor (Brillanta)' 9='Rivaroxaban (Xarelto)' 
        10='Dabigatran (Pradaxa)' 11='Apixaban (Eliquis)' 
        12='Heparin (various)' 13='Warfarin (Coumadin)' 
        14='ACE Inhibitors' 15='Benazepril (Lotensin)' 
        16='Captopril (Capoten)' 17='Enalapril (Vasotec)' 
        18='Fosinopril (Monopril)' 19='Lisinopril (Prinivil, Zestril)' 
        20='Moexipril (Univasc)' 21='Perindopril (Aceon)' 
        22='Quinapril (Accupril)' 23='Ramipril (Altace)' 
        24='Trandolapril (Mavik)' 25='Candesartan (Atacand)' 
        26='Eprosartan (Teveten)' 27='Irbesartan (Avapro)' 
        28='Losartan (Cozaar)' 29='Telmisartan (Micardis)' 
        30='Valsartan (Diovan)' 31='Acebutolol (Sectral)' 
        32='Atenolol (Tenormin)' 33='Betaxolol (Kerlone)' 
        34='Bisoprolol/hydrochlorothiazide (Ziac)' 35='Bisoprolol (Zebeta)' 
        36='Metoprolol (Lopressor, Toprol XL)' 37='Nadolol (Corgard)' 
        38='Propranolol (Inderal)' 39='Sotalol (Betapace)' 
        40='Carvedilol (Coreg)' 41='Amlodipine (Norvasc, Lotrel)' 
        42='Diltiazem (Cardizem, Tiazac)' 43='Felodipine (Plendil)' 
        44='Nifedipine (Adalat, Procardia)' 45='Nimodipine (Nimotop)' 
        46='Nisoldipine (Sular)' 47='Verapamil (Calan, Verelan)' 
        48='Atorvastatin (Lipitor)' 49='Rosuvastatin (Crestor)' 
        50='Lovastatin (Mevacor, Altocor, Altoprev)' 51='Pitavastatin (Livalo)' 
        52='Ezetimibe/Simvastatin (Vytorin)' 53='Niacin' 
        54='Digoxin (Lanoxin)' 55='Amiloride (Midamor)' 
        56='Bumetanide (Bumex)' 57='Chlorothiazide (Diuril)' 
        58='Chlorthalidone (Hygroton)' 59='Furosemide (Lasix)' 
        60='Hydrochlorothiazide (Esidrix, Hydrodiuril)' 61='Indapamide (Lozol)' 
        62='Spironolactone (Aldactone)' 63='Eplerenone (Inspra)' 
        64='Isosorbide mononitrate (Imdur)' 65='Isosorbide dinitrate' 
        66='Nitroglycerin' 67='Hydralazine (Apresoline)' 
        68='Methyldopa (Aldomet)' 69='Doxazosin (Cardura)' 
        70='Prazosin (Minipress)' 71='Terazosin (Hytrin)' 
        72='Clonidine (Catapres)' 73='Minoxidil (Loniten)' 
        74='Simvastatin' 75='Ethacrynic acid' 
        76='Edoxaban' 999='Other';
    value units_11_ 1='mg' 2='ug' 
        3='Units' 999='Other';
    value freq_11_ 1='FREQUENCY' 2='EVERY MORNING' 
        3='DAILY' 4='TWICE DAILY' 
        5='3 TIMES DAILY' 6='4 TIMES DAILY' 
        7='AS NEEDED' 999='OTHER';
    value route_11_ 1='By mouth' 2='Topically' 
        3='Sublingual' 4='Subcutaneous' 
        999='Other';
    value recent_start_date_11_ 1='Yes' 0='No';
    value recent_end_date_11_ 1='Yes' 0='No';
    value meds_12_ 4='Aspirin' 5='Clopidogrel (Plavix)' 
        6='Dipyridamole' 7='Prasugrel (Effient)' 
        8='Ticagrelor (Brillanta)' 9='Rivaroxaban (Xarelto)' 
        10='Dabigatran (Pradaxa)' 11='Apixaban (Eliquis)' 
        12='Heparin (various)' 13='Warfarin (Coumadin)' 
        14='ACE Inhibitors' 15='Benazepril (Lotensin)' 
        16='Captopril (Capoten)' 17='Enalapril (Vasotec)' 
        18='Fosinopril (Monopril)' 19='Lisinopril (Prinivil, Zestril)' 
        20='Moexipril (Univasc)' 21='Perindopril (Aceon)' 
        22='Quinapril (Accupril)' 23='Ramipril (Altace)' 
        24='Trandolapril (Mavik)' 25='Candesartan (Atacand)' 
        26='Eprosartan (Teveten)' 27='Irbesartan (Avapro)' 
        28='Losartan (Cozaar)' 29='Telmisartan (Micardis)' 
        30='Valsartan (Diovan)' 31='Acebutolol (Sectral)' 
        32='Atenolol (Tenormin)' 33='Betaxolol (Kerlone)' 
        34='Bisoprolol/hydrochlorothiazide (Ziac)' 35='Bisoprolol (Zebeta)' 
        36='Metoprolol (Lopressor, Toprol XL)' 37='Nadolol (Corgard)' 
        38='Propranolol (Inderal)' 39='Sotalol (Betapace)' 
        40='Carvedilol (Coreg)' 41='Amlodipine (Norvasc, Lotrel)' 
        42='Diltiazem (Cardizem, Tiazac)' 43='Felodipine (Plendil)' 
        44='Nifedipine (Adalat, Procardia)' 45='Nimodipine (Nimotop)' 
        46='Nisoldipine (Sular)' 47='Verapamil (Calan, Verelan)' 
        48='Atorvastatin (Lipitor)' 49='Rosuvastatin (Crestor)' 
        50='Lovastatin (Mevacor, Altocor, Altoprev)' 51='Pitavastatin (Livalo)' 
        52='Ezetimibe/Simvastatin (Vytorin)' 53='Niacin' 
        54='Digoxin (Lanoxin)' 55='Amiloride (Midamor)' 
        56='Bumetanide (Bumex)' 57='Chlorothiazide (Diuril)' 
        58='Chlorthalidone (Hygroton)' 59='Furosemide (Lasix)' 
        60='Hydrochlorothiazide (Esidrix, Hydrodiuril)' 61='Indapamide (Lozol)' 
        62='Spironolactone (Aldactone)' 63='Eplerenone (Inspra)' 
        64='Isosorbide mononitrate (Imdur)' 65='Isosorbide dinitrate' 
        66='Nitroglycerin' 67='Hydralazine (Apresoline)' 
        68='Methyldopa (Aldomet)' 69='Doxazosin (Cardura)' 
        70='Prazosin (Minipress)' 71='Terazosin (Hytrin)' 
        72='Clonidine (Catapres)' 73='Minoxidil (Loniten)' 
        74='Simvastatin' 75='Ethacrynic acid' 
        76='Edoxaban' 999='Other';
    value units_12_ 1='mg' 2='ug' 
        3='Units' 999='Other';
    value freq_12_ 1='FREQUENCY' 2='EVERY MORNING' 
        3='DAILY' 4='TWICE DAILY' 
        5='3 TIMES DAILY' 6='4 TIMES DAILY' 
        7='AS NEEDED' 999='OTHER';
    value route_12_ 1='By mouth' 2='Topically' 
        3='Sublingual' 4='Subcutaneous' 
        999='Other';
    value recent_start_date_12_ 1='Yes' 0='No';
    value recent_end_date_12_ 1='Yes' 0='No';
    value meds_13_ 4='Aspirin' 5='Clopidogrel (Plavix)' 
        6='Dipyridamole' 7='Prasugrel (Effient)' 
        8='Ticagrelor (Brillanta)' 9='Rivaroxaban (Xarelto)' 
        10='Dabigatran (Pradaxa)' 11='Apixaban (Eliquis)' 
        12='Heparin (various)' 13='Warfarin (Coumadin)' 
        14='ACE Inhibitors' 15='Benazepril (Lotensin)' 
        16='Captopril (Capoten)' 17='Enalapril (Vasotec)' 
        18='Fosinopril (Monopril)' 19='Lisinopril (Prinivil, Zestril)' 
        20='Moexipril (Univasc)' 21='Perindopril (Aceon)' 
        22='Quinapril (Accupril)' 23='Ramipril (Altace)' 
        24='Trandolapril (Mavik)' 25='Candesartan (Atacand)' 
        26='Eprosartan (Teveten)' 27='Irbesartan (Avapro)' 
        28='Losartan (Cozaar)' 29='Telmisartan (Micardis)' 
        30='Valsartan (Diovan)' 31='Acebutolol (Sectral)' 
        32='Atenolol (Tenormin)' 33='Betaxolol (Kerlone)' 
        34='Bisoprolol/hydrochlorothiazide (Ziac)' 35='Bisoprolol (Zebeta)' 
        36='Metoprolol (Lopressor, Toprol XL)' 37='Nadolol (Corgard)' 
        38='Propranolol (Inderal)' 39='Sotalol (Betapace)' 
        40='Carvedilol (Coreg)' 41='Amlodipine (Norvasc, Lotrel)' 
        42='Diltiazem (Cardizem, Tiazac)' 43='Felodipine (Plendil)' 
        44='Nifedipine (Adalat, Procardia)' 45='Nimodipine (Nimotop)' 
        46='Nisoldipine (Sular)' 47='Verapamil (Calan, Verelan)' 
        48='Atorvastatin (Lipitor)' 49='Rosuvastatin (Crestor)' 
        50='Lovastatin (Mevacor, Altocor, Altoprev)' 51='Pitavastatin (Livalo)' 
        52='Ezetimibe/Simvastatin (Vytorin)' 53='Niacin' 
        54='Digoxin (Lanoxin)' 55='Amiloride (Midamor)' 
        56='Bumetanide (Bumex)' 57='Chlorothiazide (Diuril)' 
        58='Chlorthalidone (Hygroton)' 59='Furosemide (Lasix)' 
        60='Hydrochlorothiazide (Esidrix, Hydrodiuril)' 61='Indapamide (Lozol)' 
        62='Spironolactone (Aldactone)' 63='Eplerenone (Inspra)' 
        64='Isosorbide mononitrate (Imdur)' 65='Isosorbide dinitrate' 
        66='Nitroglycerin' 67='Hydralazine (Apresoline)' 
        68='Methyldopa (Aldomet)' 69='Doxazosin (Cardura)' 
        70='Prazosin (Minipress)' 71='Terazosin (Hytrin)' 
        72='Clonidine (Catapres)' 73='Minoxidil (Loniten)' 
        74='Simvastatin' 75='Ethacrynic acid' 
        76='Edoxaban' 999='Other';
    value units_13_ 1='mg' 2='ug' 
        3='Units' 999='Other';
    value freq_13_ 1='FREQUENCY' 2='EVERY MORNING' 
        3='DAILY' 4='TWICE DAILY' 
        5='3 TIMES DAILY' 6='4 TIMES DAILY' 
        7='AS NEEDED' 999='OTHER';
    value route_13_ 1='By mouth' 2='Topically' 
        3='Sublingual' 4='Subcutaneous' 
        999='Other';
    value recent_start_date_13_ 1='Yes' 0='No';
    value recent_end_date_13_ 1='Yes' 0='No';
    value meds_14_ 4='Aspirin' 5='Clopidogrel (Plavix)' 
        6='Dipyridamole' 7='Prasugrel (Effient)' 
        8='Ticagrelor (Brillanta)' 9='Rivaroxaban (Xarelto)' 
        10='Dabigatran (Pradaxa)' 11='Apixaban (Eliquis)' 
        12='Heparin (various)' 13='Warfarin (Coumadin)' 
        14='ACE Inhibitors' 15='Benazepril (Lotensin)' 
        16='Captopril (Capoten)' 17='Enalapril (Vasotec)' 
        18='Fosinopril (Monopril)' 19='Lisinopril (Prinivil, Zestril)' 
        20='Moexipril (Univasc)' 21='Perindopril (Aceon)' 
        22='Quinapril (Accupril)' 23='Ramipril (Altace)' 
        24='Trandolapril (Mavik)' 25='Candesartan (Atacand)' 
        26='Eprosartan (Teveten)' 27='Irbesartan (Avapro)' 
        28='Losartan (Cozaar)' 29='Telmisartan (Micardis)' 
        30='Valsartan (Diovan)' 31='Acebutolol (Sectral)' 
        32='Atenolol (Tenormin)' 33='Betaxolol (Kerlone)' 
        34='Bisoprolol/hydrochlorothiazide (Ziac)' 35='Bisoprolol (Zebeta)' 
        36='Metoprolol (Lopressor, Toprol XL)' 37='Nadolol (Corgard)' 
        38='Propranolol (Inderal)' 39='Sotalol (Betapace)' 
        40='Carvedilol (Coreg)' 41='Amlodipine (Norvasc, Lotrel)' 
        42='Diltiazem (Cardizem, Tiazac)' 43='Felodipine (Plendil)' 
        44='Nifedipine (Adalat, Procardia)' 45='Nimodipine (Nimotop)' 
        46='Nisoldipine (Sular)' 47='Verapamil (Calan, Verelan)' 
        48='Atorvastatin (Lipitor)' 49='Rosuvastatin (Crestor)' 
        50='Lovastatin (Mevacor, Altocor, Altoprev)' 51='Pitavastatin (Livalo)' 
        52='Ezetimibe/Simvastatin (Vytorin)' 53='Niacin' 
        54='Digoxin (Lanoxin)' 55='Amiloride (Midamor)' 
        56='Bumetanide (Bumex)' 57='Chlorothiazide (Diuril)' 
        58='Chlorthalidone (Hygroton)' 59='Furosemide (Lasix)' 
        60='Hydrochlorothiazide (Esidrix, Hydrodiuril)' 61='Indapamide (Lozol)' 
        62='Spironolactone (Aldactone)' 63='Eplerenone (Inspra)' 
        64='Isosorbide mononitrate (Imdur)' 65='Isosorbide dinitrate' 
        66='Nitroglycerin' 67='Hydralazine (Apresoline)' 
        68='Methyldopa (Aldomet)' 69='Doxazosin (Cardura)' 
        70='Prazosin (Minipress)' 71='Terazosin (Hytrin)' 
        72='Clonidine (Catapres)' 73='Minoxidil (Loniten)' 
        74='Simvastatin' 75='Ethacrynic acid' 
        76='Edoxaban' 999='Other';
    value units_14_ 1='mg' 2='ug' 
        3='Units' 999='Other';
    value freq_14_ 1='FREQUENCY' 2='EVERY MORNING' 
        3='DAILY' 4='TWICE DAILY' 
        5='3 TIMES DAILY' 6='4 TIMES DAILY' 
        7='AS NEEDED' 999='OTHER';
    value route_14_ 1='By mouth' 2='Topically' 
        3='Sublingual' 4='Subcutaneous' 
        999='Other';
    value recent_start_date_14_ 1='Yes' 0='No';
    value recent_end_date_14_ 1='Yes' 0='No';
    value meds_15_ 4='Aspirin' 5='Clopidogrel (Plavix)' 
        6='Dipyridamole' 7='Prasugrel (Effient)' 
        8='Ticagrelor (Brillanta)' 9='Rivaroxaban (Xarelto)' 
        10='Dabigatran (Pradaxa)' 11='Apixaban (Eliquis)' 
        12='Heparin (various)' 13='Warfarin (Coumadin)' 
        14='ACE Inhibitors' 15='Benazepril (Lotensin)' 
        16='Captopril (Capoten)' 17='Enalapril (Vasotec)' 
        18='Fosinopril (Monopril)' 19='Lisinopril (Prinivil, Zestril)' 
        20='Moexipril (Univasc)' 21='Perindopril (Aceon)' 
        22='Quinapril (Accupril)' 23='Ramipril (Altace)' 
        24='Trandolapril (Mavik)' 25='Candesartan (Atacand)' 
        26='Eprosartan (Teveten)' 27='Irbesartan (Avapro)' 
        28='Losartan (Cozaar)' 29='Telmisartan (Micardis)' 
        30='Valsartan (Diovan)' 31='Acebutolol (Sectral)' 
        32='Atenolol (Tenormin)' 33='Betaxolol (Kerlone)' 
        34='Bisoprolol/hydrochlorothiazide (Ziac)' 35='Bisoprolol (Zebeta)' 
        36='Metoprolol (Lopressor, Toprol XL)' 37='Nadolol (Corgard)' 
        38='Propranolol (Inderal)' 39='Sotalol (Betapace)' 
        40='Carvedilol (Coreg)' 41='Amlodipine (Norvasc, Lotrel)' 
        42='Diltiazem (Cardizem, Tiazac)' 43='Felodipine (Plendil)' 
        44='Nifedipine (Adalat, Procardia)' 45='Nimodipine (Nimotop)' 
        46='Nisoldipine (Sular)' 47='Verapamil (Calan, Verelan)' 
        48='Atorvastatin (Lipitor)' 49='Rosuvastatin (Crestor)' 
        50='Lovastatin (Mevacor, Altocor, Altoprev)' 51='Pitavastatin (Livalo)' 
        52='Ezetimibe/Simvastatin (Vytorin)' 53='Niacin' 
        54='Digoxin (Lanoxin)' 55='Amiloride (Midamor)' 
        56='Bumetanide (Bumex)' 57='Chlorothiazide (Diuril)' 
        58='Chlorthalidone (Hygroton)' 59='Furosemide (Lasix)' 
        60='Hydrochlorothiazide (Esidrix, Hydrodiuril)' 61='Indapamide (Lozol)' 
        62='Spironolactone (Aldactone)' 63='Eplerenone (Inspra)' 
        64='Isosorbide mononitrate (Imdur)' 65='Isosorbide dinitrate' 
        66='Nitroglycerin' 67='Hydralazine (Apresoline)' 
        68='Methyldopa (Aldomet)' 69='Doxazosin (Cardura)' 
        70='Prazosin (Minipress)' 71='Terazosin (Hytrin)' 
        72='Clonidine (Catapres)' 73='Minoxidil (Loniten)' 
        74='Simvastatin' 75='Ethacrynic acid' 
        76='Edoxaban' 999='Other';
    value units_15_ 1='mg' 2='ug' 
        3='Units' 999='Other';
    value freq_15_ 1='FREQUENCY' 2='EVERY MORNING' 
        3='DAILY' 4='TWICE DAILY' 
        5='3 TIMES DAILY' 6='4 TIMES DAILY' 
        7='AS NEEDED' 999='OTHER';
    value route_15_ 1='By mouth' 2='Topically' 
        3='Sublingual' 4='Subcutaneous' 
        999='Other';
    value recent_start_date_15_ 1='Yes' 0='No';
    value recent_end_date_15_ 1='Yes' 0='No';
    value meds_16_ 4='Aspirin' 5='Clopidogrel (Plavix)' 
        6='Dipyridamole' 7='Prasugrel (Effient)' 
        8='Ticagrelor (Brillanta)' 9='Rivaroxaban (Xarelto)' 
        10='Dabigatran (Pradaxa)' 11='Apixaban (Eliquis)' 
        12='Heparin (various)' 13='Warfarin (Coumadin)' 
        14='ACE Inhibitors' 15='Benazepril (Lotensin)' 
        16='Captopril (Capoten)' 17='Enalapril (Vasotec)' 
        18='Fosinopril (Monopril)' 19='Lisinopril (Prinivil, Zestril)' 
        20='Moexipril (Univasc)' 21='Perindopril (Aceon)' 
        22='Quinapril (Accupril)' 23='Ramipril (Altace)' 
        24='Trandolapril (Mavik)' 25='Candesartan (Atacand)' 
        26='Eprosartan (Teveten)' 27='Irbesartan (Avapro)' 
        28='Losartan (Cozaar)' 29='Telmisartan (Micardis)' 
        30='Valsartan (Diovan)' 31='Acebutolol (Sectral)' 
        32='Atenolol (Tenormin)' 33='Betaxolol (Kerlone)' 
        34='Bisoprolol/hydrochlorothiazide (Ziac)' 35='Bisoprolol (Zebeta)' 
        36='Metoprolol (Lopressor, Toprol XL)' 37='Nadolol (Corgard)' 
        38='Propranolol (Inderal)' 39='Sotalol (Betapace)' 
        40='Carvedilol (Coreg)' 41='Amlodipine (Norvasc, Lotrel)' 
        42='Diltiazem (Cardizem, Tiazac)' 43='Felodipine (Plendil)' 
        44='Nifedipine (Adalat, Procardia)' 45='Nimodipine (Nimotop)' 
        46='Nisoldipine (Sular)' 47='Verapamil (Calan, Verelan)' 
        48='Atorvastatin (Lipitor)' 49='Rosuvastatin (Crestor)' 
        50='Lovastatin (Mevacor, Altocor, Altoprev)' 51='Pitavastatin (Livalo)' 
        52='Ezetimibe/Simvastatin (Vytorin)' 53='Niacin' 
        54='Digoxin (Lanoxin)' 55='Amiloride (Midamor)' 
        56='Bumetanide (Bumex)' 57='Chlorothiazide (Diuril)' 
        58='Chlorthalidone (Hygroton)' 59='Furosemide (Lasix)' 
        60='Hydrochlorothiazide (Esidrix, Hydrodiuril)' 61='Indapamide (Lozol)' 
        62='Spironolactone (Aldactone)' 63='Eplerenone (Inspra)' 
        64='Isosorbide mononitrate (Imdur)' 65='Isosorbide dinitrate' 
        66='Nitroglycerin' 67='Hydralazine (Apresoline)' 
        68='Methyldopa (Aldomet)' 69='Doxazosin (Cardura)' 
        70='Prazosin (Minipress)' 71='Terazosin (Hytrin)' 
        72='Clonidine (Catapres)' 73='Minoxidil (Loniten)' 
        74='Simvastatin' 75='Ethacrynic acid' 
        76='Edoxaban' 999='Other';
    value units_16_ 1='mg' 2='ug' 
        3='Units' 999='Other';
    value freq_16_ 1='FREQUENCY' 2='EVERY MORNING' 
        3='DAILY' 4='TWICE DAILY' 
        5='3 TIMES DAILY' 6='4 TIMES DAILY' 
        7='AS NEEDED' 999='OTHER';
    value route_16_ 1='By mouth' 2='Topically' 
        3='Sublingual' 4='Subcutaneous' 
        999='Other';
    value recent_start_date_16_ 1='Yes' 0='No';
    value recent_end_date_16_ 1='Yes' 0='No';
    value meds_17_ 4='Aspirin' 5='Clopidogrel (Plavix)' 
        6='Dipyridamole' 7='Prasugrel (Effient)' 
        8='Ticagrelor (Brillanta)' 9='Rivaroxaban (Xarelto)' 
        10='Dabigatran (Pradaxa)' 11='Apixaban (Eliquis)' 
        12='Heparin (various)' 13='Warfarin (Coumadin)' 
        14='ACE Inhibitors' 15='Benazepril (Lotensin)' 
        16='Captopril (Capoten)' 17='Enalapril (Vasotec)' 
        18='Fosinopril (Monopril)' 19='Lisinopril (Prinivil, Zestril)' 
        20='Moexipril (Univasc)' 21='Perindopril (Aceon)' 
        22='Quinapril (Accupril)' 23='Ramipril (Altace)' 
        24='Trandolapril (Mavik)' 25='Candesartan (Atacand)' 
        26='Eprosartan (Teveten)' 27='Irbesartan (Avapro)' 
        28='Losartan (Cozaar)' 29='Telmisartan (Micardis)' 
        30='Valsartan (Diovan)' 31='Acebutolol (Sectral)' 
        32='Atenolol (Tenormin)' 33='Betaxolol (Kerlone)' 
        34='Bisoprolol/hydrochlorothiazide (Ziac)' 35='Bisoprolol (Zebeta)' 
        36='Metoprolol (Lopressor, Toprol XL)' 37='Nadolol (Corgard)' 
        38='Propranolol (Inderal)' 39='Sotalol (Betapace)' 
        40='Carvedilol (Coreg)' 41='Amlodipine (Norvasc, Lotrel)' 
        42='Diltiazem (Cardizem, Tiazac)' 43='Felodipine (Plendil)' 
        44='Nifedipine (Adalat, Procardia)' 45='Nimodipine (Nimotop)' 
        46='Nisoldipine (Sular)' 47='Verapamil (Calan, Verelan)' 
        48='Atorvastatin (Lipitor)' 49='Rosuvastatin (Crestor)' 
        50='Lovastatin (Mevacor, Altocor, Altoprev)' 51='Pitavastatin (Livalo)' 
        52='Ezetimibe/Simvastatin (Vytorin)' 53='Niacin' 
        54='Digoxin (Lanoxin)' 55='Amiloride (Midamor)' 
        56='Bumetanide (Bumex)' 57='Chlorothiazide (Diuril)' 
        58='Chlorthalidone (Hygroton)' 59='Furosemide (Lasix)' 
        60='Hydrochlorothiazide (Esidrix, Hydrodiuril)' 61='Indapamide (Lozol)' 
        62='Spironolactone (Aldactone)' 63='Eplerenone (Inspra)' 
        64='Isosorbide mononitrate (Imdur)' 65='Isosorbide dinitrate' 
        66='Nitroglycerin' 67='Hydralazine (Apresoline)' 
        68='Methyldopa (Aldomet)' 69='Doxazosin (Cardura)' 
        70='Prazosin (Minipress)' 71='Terazosin (Hytrin)' 
        72='Clonidine (Catapres)' 73='Minoxidil (Loniten)' 
        74='Simvastatin' 75='Ethacrynic acid' 
        76='Edoxaban' 999='Other';
    value units_17_ 1='mg' 2='ug' 
        3='Units' 999='Other';
    value freq_17_ 1='FREQUENCY' 2='EVERY MORNING' 
        3='DAILY' 4='TWICE DAILY' 
        5='3 TIMES DAILY' 6='4 TIMES DAILY' 
        7='AS NEEDED' 999='OTHER';
    value route_17_ 1='By mouth' 2='Topically' 
        3='Sublingual' 4='Subcutaneous' 
        999='Other';
    value recent_start_date_17_ 1='Yes' 0='No';
    value recent_end_date_17_ 1='Yes' 0='No';
    value meds_18_ 4='Aspirin' 5='Clopidogrel (Plavix)' 
        6='Dipyridamole' 7='Prasugrel (Effient)' 
        8='Ticagrelor (Brillanta)' 9='Rivaroxaban (Xarelto)' 
        10='Dabigatran (Pradaxa)' 11='Apixaban (Eliquis)' 
        12='Heparin (various)' 13='Warfarin (Coumadin)' 
        14='ACE Inhibitors' 15='Benazepril (Lotensin)' 
        16='Captopril (Capoten)' 17='Enalapril (Vasotec)' 
        18='Fosinopril (Monopril)' 19='Lisinopril (Prinivil, Zestril)' 
        20='Moexipril (Univasc)' 21='Perindopril (Aceon)' 
        22='Quinapril (Accupril)' 23='Ramipril (Altace)' 
        24='Trandolapril (Mavik)' 25='Candesartan (Atacand)' 
        26='Eprosartan (Teveten)' 27='Irbesartan (Avapro)' 
        28='Losartan (Cozaar)' 29='Telmisartan (Micardis)' 
        30='Valsartan (Diovan)' 31='Acebutolol (Sectral)' 
        32='Atenolol (Tenormin)' 33='Betaxolol (Kerlone)' 
        34='Bisoprolol/hydrochlorothiazide (Ziac)' 35='Bisoprolol (Zebeta)' 
        36='Metoprolol (Lopressor, Toprol XL)' 37='Nadolol (Corgard)' 
        38='Propranolol (Inderal)' 39='Sotalol (Betapace)' 
        40='Carvedilol (Coreg)' 41='Amlodipine (Norvasc, Lotrel)' 
        42='Diltiazem (Cardizem, Tiazac)' 43='Felodipine (Plendil)' 
        44='Nifedipine (Adalat, Procardia)' 45='Nimodipine (Nimotop)' 
        46='Nisoldipine (Sular)' 47='Verapamil (Calan, Verelan)' 
        48='Atorvastatin (Lipitor)' 49='Rosuvastatin (Crestor)' 
        50='Lovastatin (Mevacor, Altocor, Altoprev)' 51='Pitavastatin (Livalo)' 
        52='Ezetimibe/Simvastatin (Vytorin)' 53='Niacin' 
        54='Digoxin (Lanoxin)' 55='Amiloride (Midamor)' 
        56='Bumetanide (Bumex)' 57='Chlorothiazide (Diuril)' 
        58='Chlorthalidone (Hygroton)' 59='Furosemide (Lasix)' 
        60='Hydrochlorothiazide (Esidrix, Hydrodiuril)' 61='Indapamide (Lozol)' 
        62='Spironolactone (Aldactone)' 63='Eplerenone (Inspra)' 
        64='Isosorbide mononitrate (Imdur)' 65='Isosorbide dinitrate' 
        66='Nitroglycerin' 67='Hydralazine (Apresoline)' 
        68='Methyldopa (Aldomet)' 69='Doxazosin (Cardura)' 
        70='Prazosin (Minipress)' 71='Terazosin (Hytrin)' 
        72='Clonidine (Catapres)' 73='Minoxidil (Loniten)' 
        74='Simvastatin' 75='Ethacrynic acid' 
        76='Edoxaban' 999='Other';
    value units_18_ 1='mg' 2='ug' 
        3='Units' 999='Other';
    value freq_18_ 1='FREQUENCY' 2='EVERY MORNING' 
        3='DAILY' 4='TWICE DAILY' 
        5='3 TIMES DAILY' 6='4 TIMES DAILY' 
        7='AS NEEDED' 999='OTHER';
    value route_18_ 1='By mouth' 2='Topically' 
        3='Sublingual' 4='Subcutaneous' 
        999='Other';
    value recent_start_date_18_ 1='Yes' 0='No';
    value recent_end_date_18_ 1='Yes' 0='No';
    value meds_19_ 4='Aspirin' 5='Clopidogrel (Plavix)' 
        6='Dipyridamole' 7='Prasugrel (Effient)' 
        8='Ticagrelor (Brillanta)' 9='Rivaroxaban (Xarelto)' 
        10='Dabigatran (Pradaxa)' 11='Apixaban (Eliquis)' 
        12='Heparin (various)' 13='Warfarin (Coumadin)' 
        14='ACE Inhibitors' 15='Benazepril (Lotensin)' 
        16='Captopril (Capoten)' 17='Enalapril (Vasotec)' 
        18='Fosinopril (Monopril)' 19='Lisinopril (Prinivil, Zestril)' 
        20='Moexipril (Univasc)' 21='Perindopril (Aceon)' 
        22='Quinapril (Accupril)' 23='Ramipril (Altace)' 
        24='Trandolapril (Mavik)' 25='Candesartan (Atacand)' 
        26='Eprosartan (Teveten)' 27='Irbesartan (Avapro)' 
        28='Losartan (Cozaar)' 29='Telmisartan (Micardis)' 
        30='Valsartan (Diovan)' 31='Acebutolol (Sectral)' 
        32='Atenolol (Tenormin)' 33='Betaxolol (Kerlone)' 
        34='Bisoprolol/hydrochlorothiazide (Ziac)' 35='Bisoprolol (Zebeta)' 
        36='Metoprolol (Lopressor, Toprol XL)' 37='Nadolol (Corgard)' 
        38='Propranolol (Inderal)' 39='Sotalol (Betapace)' 
        40='Carvedilol (Coreg)' 41='Amlodipine (Norvasc, Lotrel)' 
        42='Diltiazem (Cardizem, Tiazac)' 43='Felodipine (Plendil)' 
        44='Nifedipine (Adalat, Procardia)' 45='Nimodipine (Nimotop)' 
        46='Nisoldipine (Sular)' 47='Verapamil (Calan, Verelan)' 
        48='Atorvastatin (Lipitor)' 49='Rosuvastatin (Crestor)' 
        50='Lovastatin (Mevacor, Altocor, Altoprev)' 51='Pitavastatin (Livalo)' 
        52='Ezetimibe/Simvastatin (Vytorin)' 53='Niacin' 
        54='Digoxin (Lanoxin)' 55='Amiloride (Midamor)' 
        56='Bumetanide (Bumex)' 57='Chlorothiazide (Diuril)' 
        58='Chlorthalidone (Hygroton)' 59='Furosemide (Lasix)' 
        60='Hydrochlorothiazide (Esidrix, Hydrodiuril)' 61='Indapamide (Lozol)' 
        62='Spironolactone (Aldactone)' 63='Eplerenone (Inspra)' 
        64='Isosorbide mononitrate (Imdur)' 65='Isosorbide dinitrate' 
        66='Nitroglycerin' 67='Hydralazine (Apresoline)' 
        68='Methyldopa (Aldomet)' 69='Doxazosin (Cardura)' 
        70='Prazosin (Minipress)' 71='Terazosin (Hytrin)' 
        72='Clonidine (Catapres)' 73='Minoxidil (Loniten)' 
        74='Simvastatin' 75='Ethacrynic acid' 
        76='Edoxaban' 999='Other';
    value units_19_ 1='mg' 2='ug' 
        3='Units' 999='Other';
    value freq_19_ 1='FREQUENCY' 2='EVERY MORNING' 
        3='DAILY' 4='TWICE DAILY' 
        5='3 TIMES DAILY' 6='4 TIMES DAILY' 
        7='AS NEEDED' 999='OTHER';
    value route_19_ 1='By mouth' 2='Topically' 
        3='Sublingual' 4='Subcutaneous' 
        999='Other';
    value recent_start_date_19_ 1='Yes' 0='No';
    value recent_end_date_19_ 1='Yes' 0='No';
    value meds_20_ 4='Aspirin' 5='Clopidogrel (Plavix)' 
        6='Dipyridamole' 7='Prasugrel (Effient)' 
        8='Ticagrelor (Brillanta)' 9='Rivaroxaban (Xarelto)' 
        10='Dabigatran (Pradaxa)' 11='Apixaban (Eliquis)' 
        12='Heparin (various)' 13='Warfarin (Coumadin)' 
        14='ACE Inhibitors' 15='Benazepril (Lotensin)' 
        16='Captopril (Capoten)' 17='Enalapril (Vasotec)' 
        18='Fosinopril (Monopril)' 19='Lisinopril (Prinivil, Zestril)' 
        20='Moexipril (Univasc)' 21='Perindopril (Aceon)' 
        22='Quinapril (Accupril)' 23='Ramipril (Altace)' 
        24='Trandolapril (Mavik)' 25='Candesartan (Atacand)' 
        26='Eprosartan (Teveten)' 27='Irbesartan (Avapro)' 
        28='Losartan (Cozaar)' 29='Telmisartan (Micardis)' 
        30='Valsartan (Diovan)' 31='Acebutolol (Sectral)' 
        32='Atenolol (Tenormin)' 33='Betaxolol (Kerlone)' 
        34='Bisoprolol/hydrochlorothiazide (Ziac)' 35='Bisoprolol (Zebeta)' 
        36='Metoprolol (Lopressor, Toprol XL)' 37='Nadolol (Corgard)' 
        38='Propranolol (Inderal)' 39='Sotalol (Betapace)' 
        40='Carvedilol (Coreg)' 41='Amlodipine (Norvasc, Lotrel)' 
        42='Diltiazem (Cardizem, Tiazac)' 43='Felodipine (Plendil)' 
        44='Nifedipine (Adalat, Procardia)' 45='Nimodipine (Nimotop)' 
        46='Nisoldipine (Sular)' 47='Verapamil (Calan, Verelan)' 
        48='Atorvastatin (Lipitor)' 49='Rosuvastatin (Crestor)' 
        50='Lovastatin (Mevacor, Altocor, Altoprev)' 51='Pitavastatin (Livalo)' 
        52='Ezetimibe/Simvastatin (Vytorin)' 53='Niacin' 
        54='Digoxin (Lanoxin)' 55='Amiloride (Midamor)' 
        56='Bumetanide (Bumex)' 57='Chlorothiazide (Diuril)' 
        58='Chlorthalidone (Hygroton)' 59='Furosemide (Lasix)' 
        60='Hydrochlorothiazide (Esidrix, Hydrodiuril)' 61='Indapamide (Lozol)' 
        62='Spironolactone (Aldactone)' 63='Eplerenone (Inspra)' 
        64='Isosorbide mononitrate (Imdur)' 65='Isosorbide dinitrate' 
        66='Nitroglycerin' 67='Hydralazine (Apresoline)' 
        68='Methyldopa (Aldomet)' 69='Doxazosin (Cardura)' 
        70='Prazosin (Minipress)' 71='Terazosin (Hytrin)' 
        72='Clonidine (Catapres)' 73='Minoxidil (Loniten)' 
        74='Simvastatin' 75='Ethacrynic acid' 
        76='Edoxaban' 999='Other';
    value units_20_ 1='mg' 2='ug' 
        3='Units' 999='Other';
    value freq_20_ 1='FREQUENCY' 2='EVERY MORNING' 
        3='DAILY' 4='TWICE DAILY' 
        5='3 TIMES DAILY' 6='4 TIMES DAILY' 
        7='AS NEEDED' 999='OTHER';
    value route_20_ 1='By mouth' 2='Topically' 
        3='Sublingual' 4='Subcutaneous' 
        999='Other';
    value recent_start_date_20_ 1='Yes' 0='No';
    value recent_end_date_20_ 1='Yes' 0='No';
    value meds_21_ 4='Aspirin' 5='Clopidogrel (Plavix)' 
        6='Dipyridamole' 7='Prasugrel (Effient)' 
        8='Ticagrelor (Brillanta)' 9='Rivaroxaban (Xarelto)' 
        10='Dabigatran (Pradaxa)' 11='Apixaban (Eliquis)' 
        12='Heparin (various)' 13='Warfarin (Coumadin)' 
        14='ACE Inhibitors' 15='Benazepril (Lotensin)' 
        16='Captopril (Capoten)' 17='Enalapril (Vasotec)' 
        18='Fosinopril (Monopril)' 19='Lisinopril (Prinivil, Zestril)' 
        20='Moexipril (Univasc)' 21='Perindopril (Aceon)' 
        22='Quinapril (Accupril)' 23='Ramipril (Altace)' 
        24='Trandolapril (Mavik)' 25='Candesartan (Atacand)' 
        26='Eprosartan (Teveten)' 27='Irbesartan (Avapro)' 
        28='Losartan (Cozaar)' 29='Telmisartan (Micardis)' 
        30='Valsartan (Diovan)' 31='Acebutolol (Sectral)' 
        32='Atenolol (Tenormin)' 33='Betaxolol (Kerlone)' 
        34='Bisoprolol/hydrochlorothiazide (Ziac)' 35='Bisoprolol (Zebeta)' 
        36='Metoprolol (Lopressor, Toprol XL)' 37='Nadolol (Corgard)' 
        38='Propranolol (Inderal)' 39='Sotalol (Betapace)' 
        40='Carvedilol (Coreg)' 41='Amlodipine (Norvasc, Lotrel)' 
        42='Diltiazem (Cardizem, Tiazac)' 43='Felodipine (Plendil)' 
        44='Nifedipine (Adalat, Procardia)' 45='Nimodipine (Nimotop)' 
        46='Nisoldipine (Sular)' 47='Verapamil (Calan, Verelan)' 
        48='Atorvastatin (Lipitor)' 49='Rosuvastatin (Crestor)' 
        50='Lovastatin (Mevacor, Altocor, Altoprev)' 51='Pitavastatin (Livalo)' 
        52='Ezetimibe/Simvastatin (Vytorin)' 53='Niacin' 
        54='Digoxin (Lanoxin)' 55='Amiloride (Midamor)' 
        56='Bumetanide (Bumex)' 57='Chlorothiazide (Diuril)' 
        58='Chlorthalidone (Hygroton)' 59='Furosemide (Lasix)' 
        60='Hydrochlorothiazide (Esidrix, Hydrodiuril)' 61='Indapamide (Lozol)' 
        62='Spironolactone (Aldactone)' 63='Eplerenone (Inspra)' 
        64='Isosorbide mononitrate (Imdur)' 65='Isosorbide dinitrate' 
        66='Nitroglycerin' 67='Hydralazine (Apresoline)' 
        68='Methyldopa (Aldomet)' 69='Doxazosin (Cardura)' 
        70='Prazosin (Minipress)' 71='Terazosin (Hytrin)' 
        72='Clonidine (Catapres)' 73='Minoxidil (Loniten)' 
        74='Simvastatin' 75='Ethacrynic acid' 
        76='Edoxaban' 999='Other';
    value units_21_ 1='mg' 2='ug' 
        3='Units' 999='Other';
    value freq_21_ 1='FREQUENCY' 2='EVERY MORNING' 
        3='DAILY' 4='TWICE DAILY' 
        5='3 TIMES DAILY' 6='4 TIMES DAILY' 
        7='AS NEEDED' 999='OTHER';
    value route_21_ 1='By mouth' 2='Topically' 
        3='Sublingual' 4='Subcutaneous' 
        999='Other';
    value recent_start_date_21_ 1='Yes' 0='No';
    value recent_end_date_21_ 1='Yes' 0='No';
    value meds_22_ 4='Aspirin' 5='Clopidogrel (Plavix)' 
        6='Dipyridamole' 7='Prasugrel (Effient)' 
        8='Ticagrelor (Brillanta)' 9='Rivaroxaban (Xarelto)' 
        10='Dabigatran (Pradaxa)' 11='Apixaban (Eliquis)' 
        12='Heparin (various)' 13='Warfarin (Coumadin)' 
        14='ACE Inhibitors' 15='Benazepril (Lotensin)' 
        16='Captopril (Capoten)' 17='Enalapril (Vasotec)' 
        18='Fosinopril (Monopril)' 19='Lisinopril (Prinivil, Zestril)' 
        20='Moexipril (Univasc)' 21='Perindopril (Aceon)' 
        22='Quinapril (Accupril)' 23='Ramipril (Altace)' 
        24='Trandolapril (Mavik)' 25='Candesartan (Atacand)' 
        26='Eprosartan (Teveten)' 27='Irbesartan (Avapro)' 
        28='Losartan (Cozaar)' 29='Telmisartan (Micardis)' 
        30='Valsartan (Diovan)' 31='Acebutolol (Sectral)' 
        32='Atenolol (Tenormin)' 33='Betaxolol (Kerlone)' 
        34='Bisoprolol/hydrochlorothiazide (Ziac)' 35='Bisoprolol (Zebeta)' 
        36='Metoprolol (Lopressor, Toprol XL)' 37='Nadolol (Corgard)' 
        38='Propranolol (Inderal)' 39='Sotalol (Betapace)' 
        40='Carvedilol (Coreg)' 41='Amlodipine (Norvasc, Lotrel)' 
        42='Diltiazem (Cardizem, Tiazac)' 43='Felodipine (Plendil)' 
        44='Nifedipine (Adalat, Procardia)' 45='Nimodipine (Nimotop)' 
        46='Nisoldipine (Sular)' 47='Verapamil (Calan, Verelan)' 
        48='Atorvastatin (Lipitor)' 49='Rosuvastatin (Crestor)' 
        50='Lovastatin (Mevacor, Altocor, Altoprev)' 51='Pitavastatin (Livalo)' 
        52='Ezetimibe/Simvastatin (Vytorin)' 53='Niacin' 
        54='Digoxin (Lanoxin)' 55='Amiloride (Midamor)' 
        56='Bumetanide (Bumex)' 57='Chlorothiazide (Diuril)' 
        58='Chlorthalidone (Hygroton)' 59='Furosemide (Lasix)' 
        60='Hydrochlorothiazide (Esidrix, Hydrodiuril)' 61='Indapamide (Lozol)' 
        62='Spironolactone (Aldactone)' 63='Eplerenone (Inspra)' 
        64='Isosorbide mononitrate (Imdur)' 65='Isosorbide dinitrate' 
        66='Nitroglycerin' 67='Hydralazine (Apresoline)' 
        68='Methyldopa (Aldomet)' 69='Doxazosin (Cardura)' 
        70='Prazosin (Minipress)' 71='Terazosin (Hytrin)' 
        72='Clonidine (Catapres)' 73='Minoxidil (Loniten)' 
        74='Simvastatin' 75='Ethacrynic acid' 
        76='Edoxaban' 999='Other';
    value units_22_ 1='mg' 2='ug' 
        3='Units' 999='Other';
    value freq_22_ 1='FREQUENCY' 2='EVERY MORNING' 
        3='DAILY' 4='TWICE DAILY' 
        5='3 TIMES DAILY' 6='4 TIMES DAILY' 
        7='AS NEEDED' 999='OTHER';
    value route_22_ 1='By mouth' 2='Topically' 
        3='Sublingual' 4='Subcutaneous' 
        999='Other';
    value recent_start_date_22_ 1='Yes' 0='No';
    value recent_end_date_22_ 1='Yes' 0='No';
    value meds_23_ 4='Aspirin' 5='Clopidogrel (Plavix)' 
        6='Dipyridamole' 7='Prasugrel (Effient)' 
        8='Ticagrelor (Brillanta)' 9='Rivaroxaban (Xarelto)' 
        10='Dabigatran (Pradaxa)' 11='Apixaban (Eliquis)' 
        12='Heparin (various)' 13='Warfarin (Coumadin)' 
        14='ACE Inhibitors' 15='Benazepril (Lotensin)' 
        16='Captopril (Capoten)' 17='Enalapril (Vasotec)' 
        18='Fosinopril (Monopril)' 19='Lisinopril (Prinivil, Zestril)' 
        20='Moexipril (Univasc)' 21='Perindopril (Aceon)' 
        22='Quinapril (Accupril)' 23='Ramipril (Altace)' 
        24='Trandolapril (Mavik)' 25='Candesartan (Atacand)' 
        26='Eprosartan (Teveten)' 27='Irbesartan (Avapro)' 
        28='Losartan (Cozaar)' 29='Telmisartan (Micardis)' 
        30='Valsartan (Diovan)' 31='Acebutolol (Sectral)' 
        32='Atenolol (Tenormin)' 33='Betaxolol (Kerlone)' 
        34='Bisoprolol/hydrochlorothiazide (Ziac)' 35='Bisoprolol (Zebeta)' 
        36='Metoprolol (Lopressor, Toprol XL)' 37='Nadolol (Corgard)' 
        38='Propranolol (Inderal)' 39='Sotalol (Betapace)' 
        40='Carvedilol (Coreg)' 41='Amlodipine (Norvasc, Lotrel)' 
        42='Diltiazem (Cardizem, Tiazac)' 43='Felodipine (Plendil)' 
        44='Nifedipine (Adalat, Procardia)' 45='Nimodipine (Nimotop)' 
        46='Nisoldipine (Sular)' 47='Verapamil (Calan, Verelan)' 
        48='Atorvastatin (Lipitor)' 49='Rosuvastatin (Crestor)' 
        50='Lovastatin (Mevacor, Altocor, Altoprev)' 51='Pitavastatin (Livalo)' 
        52='Ezetimibe/Simvastatin (Vytorin)' 53='Niacin' 
        54='Digoxin (Lanoxin)' 55='Amiloride (Midamor)' 
        56='Bumetanide (Bumex)' 57='Chlorothiazide (Diuril)' 
        58='Chlorthalidone (Hygroton)' 59='Furosemide (Lasix)' 
        60='Hydrochlorothiazide (Esidrix, Hydrodiuril)' 61='Indapamide (Lozol)' 
        62='Spironolactone (Aldactone)' 63='Eplerenone (Inspra)' 
        64='Isosorbide mononitrate (Imdur)' 65='Isosorbide dinitrate' 
        66='Nitroglycerin' 67='Hydralazine (Apresoline)' 
        68='Methyldopa (Aldomet)' 69='Doxazosin (Cardura)' 
        70='Prazosin (Minipress)' 71='Terazosin (Hytrin)' 
        72='Clonidine (Catapres)' 73='Minoxidil (Loniten)' 
        74='Simvastatin' 75='Ethacrynic acid' 
        76='Edoxaban' 999='Other';
    value units_23_ 1='mg' 2='ug' 
        3='Units' 999='Other';
    value freq_23_ 1='FREQUENCY' 2='EVERY MORNING' 
        3='DAILY' 4='TWICE DAILY' 
        5='3 TIMES DAILY' 6='4 TIMES DAILY' 
        7='AS NEEDED' 999='OTHER';
    value route_23_ 1='By mouth' 2='Topically' 
        3='Sublingual' 4='Subcutaneous' 
        999='Other';
    value recent_start_date_23_ 1='Yes' 0='No';
    value recent_end_date_23_ 1='Yes' 0='No';
    value meds_24_ 4='Aspirin' 5='Clopidogrel (Plavix)' 
        6='Dipyridamole' 7='Prasugrel (Effient)' 
        8='Ticagrelor (Brillanta)' 9='Rivaroxaban (Xarelto)' 
        10='Dabigatran (Pradaxa)' 11='Apixaban (Eliquis)' 
        12='Heparin (various)' 13='Warfarin (Coumadin)' 
        14='ACE Inhibitors' 15='Benazepril (Lotensin)' 
        16='Captopril (Capoten)' 17='Enalapril (Vasotec)' 
        18='Fosinopril (Monopril)' 19='Lisinopril (Prinivil, Zestril)' 
        20='Moexipril (Univasc)' 21='Perindopril (Aceon)' 
        22='Quinapril (Accupril)' 23='Ramipril (Altace)' 
        24='Trandolapril (Mavik)' 25='Candesartan (Atacand)' 
        26='Eprosartan (Teveten)' 27='Irbesartan (Avapro)' 
        28='Losartan (Cozaar)' 29='Telmisartan (Micardis)' 
        30='Valsartan (Diovan)' 31='Acebutolol (Sectral)' 
        32='Atenolol (Tenormin)' 33='Betaxolol (Kerlone)' 
        34='Bisoprolol/hydrochlorothiazide (Ziac)' 35='Bisoprolol (Zebeta)' 
        36='Metoprolol (Lopressor, Toprol XL)' 37='Nadolol (Corgard)' 
        38='Propranolol (Inderal)' 39='Sotalol (Betapace)' 
        40='Carvedilol (Coreg)' 41='Amlodipine (Norvasc, Lotrel)' 
        42='Diltiazem (Cardizem, Tiazac)' 43='Felodipine (Plendil)' 
        44='Nifedipine (Adalat, Procardia)' 45='Nimodipine (Nimotop)' 
        46='Nisoldipine (Sular)' 47='Verapamil (Calan, Verelan)' 
        48='Atorvastatin (Lipitor)' 49='Rosuvastatin (Crestor)' 
        50='Lovastatin (Mevacor, Altocor, Altoprev)' 51='Pitavastatin (Livalo)' 
        52='Ezetimibe/Simvastatin (Vytorin)' 53='Niacin' 
        54='Digoxin (Lanoxin)' 55='Amiloride (Midamor)' 
        56='Bumetanide (Bumex)' 57='Chlorothiazide (Diuril)' 
        58='Chlorthalidone (Hygroton)' 59='Furosemide (Lasix)' 
        60='Hydrochlorothiazide (Esidrix, Hydrodiuril)' 61='Indapamide (Lozol)' 
        62='Spironolactone (Aldactone)' 63='Eplerenone (Inspra)' 
        64='Isosorbide mononitrate (Imdur)' 65='Isosorbide dinitrate' 
        66='Nitroglycerin' 67='Hydralazine (Apresoline)' 
        68='Methyldopa (Aldomet)' 69='Doxazosin (Cardura)' 
        70='Prazosin (Minipress)' 71='Terazosin (Hytrin)' 
        72='Clonidine (Catapres)' 73='Minoxidil (Loniten)' 
        74='Simvastatin' 75='Ethacrynic acid' 
        76='Edoxaban' 999='Other';
    value units_24_ 1='mg' 2='ug' 
        3='Units' 999='Other';
    value freq_24_ 1='FREQUENCY' 2='EVERY MORNING' 
        3='DAILY' 4='TWICE DAILY' 
        5='3 TIMES DAILY' 6='4 TIMES DAILY' 
        7='AS NEEDED' 999='OTHER';
    value route_24_ 1='By mouth' 2='Topically' 
        3='Sublingual' 4='Subcutaneous' 
        999='Other';
    value recent_start_date_24_ 1='Yes' 0='No';
    value recent_end_date_24_ 1='Yes' 0='No';
    value meds_25_ 4='Aspirin' 5='Clopidogrel (Plavix)' 
        6='Dipyridamole' 7='Prasugrel (Effient)' 
        8='Ticagrelor (Brillanta)' 9='Rivaroxaban (Xarelto)' 
        10='Dabigatran (Pradaxa)' 11='Apixaban (Eliquis)' 
        12='Heparin (various)' 13='Warfarin (Coumadin)' 
        14='ACE Inhibitors' 15='Benazepril (Lotensin)' 
        16='Captopril (Capoten)' 17='Enalapril (Vasotec)' 
        18='Fosinopril (Monopril)' 19='Lisinopril (Prinivil, Zestril)' 
        20='Moexipril (Univasc)' 21='Perindopril (Aceon)' 
        22='Quinapril (Accupril)' 23='Ramipril (Altace)' 
        24='Trandolapril (Mavik)' 25='Candesartan (Atacand)' 
        26='Eprosartan (Teveten)' 27='Irbesartan (Avapro)' 
        28='Losartan (Cozaar)' 29='Telmisartan (Micardis)' 
        30='Valsartan (Diovan)' 31='Acebutolol (Sectral)' 
        32='Atenolol (Tenormin)' 33='Betaxolol (Kerlone)' 
        34='Bisoprolol/hydrochlorothiazide (Ziac)' 35='Bisoprolol (Zebeta)' 
        36='Metoprolol (Lopressor, Toprol XL)' 37='Nadolol (Corgard)' 
        38='Propranolol (Inderal)' 39='Sotalol (Betapace)' 
        40='Carvedilol (Coreg)' 41='Amlodipine (Norvasc, Lotrel)' 
        42='Diltiazem (Cardizem, Tiazac)' 43='Felodipine (Plendil)' 
        44='Nifedipine (Adalat, Procardia)' 45='Nimodipine (Nimotop)' 
        46='Nisoldipine (Sular)' 47='Verapamil (Calan, Verelan)' 
        48='Atorvastatin (Lipitor)' 49='Rosuvastatin (Crestor)' 
        50='Lovastatin (Mevacor, Altocor, Altoprev)' 51='Pitavastatin (Livalo)' 
        52='Ezetimibe/Simvastatin (Vytorin)' 53='Niacin' 
        54='Digoxin (Lanoxin)' 55='Amiloride (Midamor)' 
        56='Bumetanide (Bumex)' 57='Chlorothiazide (Diuril)' 
        58='Chlorthalidone (Hygroton)' 59='Furosemide (Lasix)' 
        60='Hydrochlorothiazide (Esidrix, Hydrodiuril)' 61='Indapamide (Lozol)' 
        62='Spironolactone (Aldactone)' 63='Eplerenone (Inspra)' 
        64='Isosorbide mononitrate (Imdur)' 65='Isosorbide dinitrate' 
        66='Nitroglycerin' 67='Hydralazine (Apresoline)' 
        68='Methyldopa (Aldomet)' 69='Doxazosin (Cardura)' 
        70='Prazosin (Minipress)' 71='Terazosin (Hytrin)' 
        72='Clonidine (Catapres)' 73='Minoxidil (Loniten)' 
        74='Simvastatin' 75='Ethacrynic acid' 
        76='Edoxaban' 999='Other';
    value units_25_ 1='mg' 2='ug' 
        3='Units' 999='Other';
    value freq_25_ 1='FREQUENCY' 2='EVERY MORNING' 
        3='DAILY' 4='TWICE DAILY' 
        5='3 TIMES DAILY' 6='4 TIMES DAILY' 
        7='AS NEEDED' 999='OTHER';
    value route_25_ 1='By mouth' 2='Topically' 
        3='Sublingual' 4='Subcutaneous' 
        999='Other';
    value recent_start_date_25_ 1='Yes' 0='No';
    value recent_end_date_25_ 1='Yes' 0='No';
    value meds_26_ 4='Aspirin' 5='Clopidogrel (Plavix)' 
        6='Dipyridamole' 7='Prasugrel (Effient)' 
        8='Ticagrelor (Brillanta)' 9='Rivaroxaban (Xarelto)' 
        10='Dabigatran (Pradaxa)' 11='Apixaban (Eliquis)' 
        12='Heparin (various)' 13='Warfarin (Coumadin)' 
        14='ACE Inhibitors' 15='Benazepril (Lotensin)' 
        16='Captopril (Capoten)' 17='Enalapril (Vasotec)' 
        18='Fosinopril (Monopril)' 19='Lisinopril (Prinivil, Zestril)' 
        20='Moexipril (Univasc)' 21='Perindopril (Aceon)' 
        22='Quinapril (Accupril)' 23='Ramipril (Altace)' 
        24='Trandolapril (Mavik)' 25='Candesartan (Atacand)' 
        26='Eprosartan (Teveten)' 27='Irbesartan (Avapro)' 
        28='Losartan (Cozaar)' 29='Telmisartan (Micardis)' 
        30='Valsartan (Diovan)' 31='Acebutolol (Sectral)' 
        32='Atenolol (Tenormin)' 33='Betaxolol (Kerlone)' 
        34='Bisoprolol/hydrochlorothiazide (Ziac)' 35='Bisoprolol (Zebeta)' 
        36='Metoprolol (Lopressor, Toprol XL)' 37='Nadolol (Corgard)' 
        38='Propranolol (Inderal)' 39='Sotalol (Betapace)' 
        40='Carvedilol (Coreg)' 41='Amlodipine (Norvasc, Lotrel)' 
        42='Diltiazem (Cardizem, Tiazac)' 43='Felodipine (Plendil)' 
        44='Nifedipine (Adalat, Procardia)' 45='Nimodipine (Nimotop)' 
        46='Nisoldipine (Sular)' 47='Verapamil (Calan, Verelan)' 
        48='Atorvastatin (Lipitor)' 49='Rosuvastatin (Crestor)' 
        50='Lovastatin (Mevacor, Altocor, Altoprev)' 51='Pitavastatin (Livalo)' 
        52='Ezetimibe/Simvastatin (Vytorin)' 53='Niacin' 
        54='Digoxin (Lanoxin)' 55='Amiloride (Midamor)' 
        56='Bumetanide (Bumex)' 57='Chlorothiazide (Diuril)' 
        58='Chlorthalidone (Hygroton)' 59='Furosemide (Lasix)' 
        60='Hydrochlorothiazide (Esidrix, Hydrodiuril)' 61='Indapamide (Lozol)' 
        62='Spironolactone (Aldactone)' 63='Eplerenone (Inspra)' 
        64='Isosorbide mononitrate (Imdur)' 65='Isosorbide dinitrate' 
        66='Nitroglycerin' 67='Hydralazine (Apresoline)' 
        68='Methyldopa (Aldomet)' 69='Doxazosin (Cardura)' 
        70='Prazosin (Minipress)' 71='Terazosin (Hytrin)' 
        72='Clonidine (Catapres)' 73='Minoxidil (Loniten)' 
        74='Simvastatin' 75='Ethacrynic acid' 
        76='Edoxaban' 999='Other';
    value units_26_ 1='mg' 2='ug' 
        3='Units' 999='Other';
    value freq_26_ 1='FREQUENCY' 2='EVERY MORNING' 
        3='DAILY' 4='TWICE DAILY' 
        5='3 TIMES DAILY' 6='4 TIMES DAILY' 
        7='AS NEEDED' 999='OTHER';
    value route_26_ 1='By mouth' 2='Topically' 
        3='Sublingual' 4='Subcutaneous' 
        999='Other';
    value recent_start_date_26_ 1='Yes' 0='No';
    value recent_end_date_26_ 1='Yes' 0='No';
    value meds_27_ 4='Aspirin' 5='Clopidogrel (Plavix)' 
        6='Dipyridamole' 7='Prasugrel (Effient)' 
        8='Ticagrelor (Brillanta)' 9='Rivaroxaban (Xarelto)' 
        10='Dabigatran (Pradaxa)' 11='Apixaban (Eliquis)' 
        12='Heparin (various)' 13='Warfarin (Coumadin)' 
        14='ACE Inhibitors' 15='Benazepril (Lotensin)' 
        16='Captopril (Capoten)' 17='Enalapril (Vasotec)' 
        18='Fosinopril (Monopril)' 19='Lisinopril (Prinivil, Zestril)' 
        20='Moexipril (Univasc)' 21='Perindopril (Aceon)' 
        22='Quinapril (Accupril)' 23='Ramipril (Altace)' 
        24='Trandolapril (Mavik)' 25='Candesartan (Atacand)' 
        26='Eprosartan (Teveten)' 27='Irbesartan (Avapro)' 
        28='Losartan (Cozaar)' 29='Telmisartan (Micardis)' 
        30='Valsartan (Diovan)' 31='Acebutolol (Sectral)' 
        32='Atenolol (Tenormin)' 33='Betaxolol (Kerlone)' 
        34='Bisoprolol/hydrochlorothiazide (Ziac)' 35='Bisoprolol (Zebeta)' 
        36='Metoprolol (Lopressor, Toprol XL)' 37='Nadolol (Corgard)' 
        38='Propranolol (Inderal)' 39='Sotalol (Betapace)' 
        40='Carvedilol (Coreg)' 41='Amlodipine (Norvasc, Lotrel)' 
        42='Diltiazem (Cardizem, Tiazac)' 43='Felodipine (Plendil)' 
        44='Nifedipine (Adalat, Procardia)' 45='Nimodipine (Nimotop)' 
        46='Nisoldipine (Sular)' 47='Verapamil (Calan, Verelan)' 
        48='Atorvastatin (Lipitor)' 49='Rosuvastatin (Crestor)' 
        50='Lovastatin (Mevacor, Altocor, Altoprev)' 51='Pitavastatin (Livalo)' 
        52='Ezetimibe/Simvastatin (Vytorin)' 53='Niacin' 
        54='Digoxin (Lanoxin)' 55='Amiloride (Midamor)' 
        56='Bumetanide (Bumex)' 57='Chlorothiazide (Diuril)' 
        58='Chlorthalidone (Hygroton)' 59='Furosemide (Lasix)' 
        60='Hydrochlorothiazide (Esidrix, Hydrodiuril)' 61='Indapamide (Lozol)' 
        62='Spironolactone (Aldactone)' 63='Eplerenone (Inspra)' 
        64='Isosorbide mononitrate (Imdur)' 65='Isosorbide dinitrate' 
        66='Nitroglycerin' 67='Hydralazine (Apresoline)' 
        68='Methyldopa (Aldomet)' 69='Doxazosin (Cardura)' 
        70='Prazosin (Minipress)' 71='Terazosin (Hytrin)' 
        72='Clonidine (Catapres)' 73='Minoxidil (Loniten)' 
        74='Simvastatin' 75='Ethacrynic acid' 
        76='Edoxaban' 999='Other';
    value units_27_ 1='mg' 2='ug' 
        3='Units' 999='Other';
    value freq_27_ 1='FREQUENCY' 2='EVERY MORNING' 
        3='DAILY' 4='TWICE DAILY' 
        5='3 TIMES DAILY' 6='4 TIMES DAILY' 
        7='AS NEEDED' 999='OTHER';
    value route_27_ 1='By mouth' 2='Topically' 
        3='Sublingual' 4='Subcutaneous' 
        999='Other';
    value recent_start_date_27_ 1='Yes' 0='No';
    value recent_end_date_27_ 1='Yes' 0='No';
    value meds_28_ 4='Aspirin' 5='Clopidogrel (Plavix)' 
        6='Dipyridamole' 7='Prasugrel (Effient)' 
        8='Ticagrelor (Brillanta)' 9='Rivaroxaban (Xarelto)' 
        10='Dabigatran (Pradaxa)' 11='Apixaban (Eliquis)' 
        12='Heparin (various)' 13='Warfarin (Coumadin)' 
        14='ACE Inhibitors' 15='Benazepril (Lotensin)' 
        16='Captopril (Capoten)' 17='Enalapril (Vasotec)' 
        18='Fosinopril (Monopril)' 19='Lisinopril (Prinivil, Zestril)' 
        20='Moexipril (Univasc)' 21='Perindopril (Aceon)' 
        22='Quinapril (Accupril)' 23='Ramipril (Altace)' 
        24='Trandolapril (Mavik)' 25='Candesartan (Atacand)' 
        26='Eprosartan (Teveten)' 27='Irbesartan (Avapro)' 
        28='Losartan (Cozaar)' 29='Telmisartan (Micardis)' 
        30='Valsartan (Diovan)' 31='Acebutolol (Sectral)' 
        32='Atenolol (Tenormin)' 33='Betaxolol (Kerlone)' 
        34='Bisoprolol/hydrochlorothiazide (Ziac)' 35='Bisoprolol (Zebeta)' 
        36='Metoprolol (Lopressor, Toprol XL)' 37='Nadolol (Corgard)' 
        38='Propranolol (Inderal)' 39='Sotalol (Betapace)' 
        40='Carvedilol (Coreg)' 41='Amlodipine (Norvasc, Lotrel)' 
        42='Diltiazem (Cardizem, Tiazac)' 43='Felodipine (Plendil)' 
        44='Nifedipine (Adalat, Procardia)' 45='Nimodipine (Nimotop)' 
        46='Nisoldipine (Sular)' 47='Verapamil (Calan, Verelan)' 
        48='Atorvastatin (Lipitor)' 49='Rosuvastatin (Crestor)' 
        50='Lovastatin (Mevacor, Altocor, Altoprev)' 51='Pitavastatin (Livalo)' 
        52='Ezetimibe/Simvastatin (Vytorin)' 53='Niacin' 
        54='Digoxin (Lanoxin)' 55='Amiloride (Midamor)' 
        56='Bumetanide (Bumex)' 57='Chlorothiazide (Diuril)' 
        58='Chlorthalidone (Hygroton)' 59='Furosemide (Lasix)' 
        60='Hydrochlorothiazide (Esidrix, Hydrodiuril)' 61='Indapamide (Lozol)' 
        62='Spironolactone (Aldactone)' 63='Eplerenone (Inspra)' 
        64='Isosorbide mononitrate (Imdur)' 65='Isosorbide dinitrate' 
        66='Nitroglycerin' 67='Hydralazine (Apresoline)' 
        68='Methyldopa (Aldomet)' 69='Doxazosin (Cardura)' 
        70='Prazosin (Minipress)' 71='Terazosin (Hytrin)' 
        72='Clonidine (Catapres)' 73='Minoxidil (Loniten)' 
        74='Simvastatin' 75='Ethacrynic acid' 
        76='Edoxaban' 999='Other';
    value units_28_ 1='mg' 2='ug' 
        3='Units' 999='Other';
    value freq_28_ 1='FREQUENCY' 2='EVERY MORNING' 
        3='DAILY' 4='TWICE DAILY' 
        5='3 TIMES DAILY' 6='4 TIMES DAILY' 
        7='AS NEEDED' 999='OTHER';
    value route_28_ 1='By mouth' 2='Topically' 
        3='Sublingual' 4='Subcutaneous' 
        999='Other';
    value recent_start_date_28_ 1='Yes' 0='No';
    value recent_end_date_28_ 1='Yes' 0='No';
    value meds_29_ 4='Aspirin' 5='Clopidogrel (Plavix)' 
        6='Dipyridamole' 7='Prasugrel (Effient)' 
        8='Ticagrelor (Brillanta)' 9='Rivaroxaban (Xarelto)' 
        10='Dabigatran (Pradaxa)' 11='Apixaban (Eliquis)' 
        12='Heparin (various)' 13='Warfarin (Coumadin)' 
        14='ACE Inhibitors' 15='Benazepril (Lotensin)' 
        16='Captopril (Capoten)' 17='Enalapril (Vasotec)' 
        18='Fosinopril (Monopril)' 19='Lisinopril (Prinivil, Zestril)' 
        20='Moexipril (Univasc)' 21='Perindopril (Aceon)' 
        22='Quinapril (Accupril)' 23='Ramipril (Altace)' 
        24='Trandolapril (Mavik)' 25='Candesartan (Atacand)' 
        26='Eprosartan (Teveten)' 27='Irbesartan (Avapro)' 
        28='Losartan (Cozaar)' 29='Telmisartan (Micardis)' 
        30='Valsartan (Diovan)' 31='Acebutolol (Sectral)' 
        32='Atenolol (Tenormin)' 33='Betaxolol (Kerlone)' 
        34='Bisoprolol/hydrochlorothiazide (Ziac)' 35='Bisoprolol (Zebeta)' 
        36='Metoprolol (Lopressor, Toprol XL)' 37='Nadolol (Corgard)' 
        38='Propranolol (Inderal)' 39='Sotalol (Betapace)' 
        40='Carvedilol (Coreg)' 41='Amlodipine (Norvasc, Lotrel)' 
        42='Diltiazem (Cardizem, Tiazac)' 43='Felodipine (Plendil)' 
        44='Nifedipine (Adalat, Procardia)' 45='Nimodipine (Nimotop)' 
        46='Nisoldipine (Sular)' 47='Verapamil (Calan, Verelan)' 
        48='Atorvastatin (Lipitor)' 49='Rosuvastatin (Crestor)' 
        50='Lovastatin (Mevacor, Altocor, Altoprev)' 51='Pitavastatin (Livalo)' 
        52='Ezetimibe/Simvastatin (Vytorin)' 53='Niacin' 
        54='Digoxin (Lanoxin)' 55='Amiloride (Midamor)' 
        56='Bumetanide (Bumex)' 57='Chlorothiazide (Diuril)' 
        58='Chlorthalidone (Hygroton)' 59='Furosemide (Lasix)' 
        60='Hydrochlorothiazide (Esidrix, Hydrodiuril)' 61='Indapamide (Lozol)' 
        62='Spironolactone (Aldactone)' 63='Eplerenone (Inspra)' 
        64='Isosorbide mononitrate (Imdur)' 65='Isosorbide dinitrate' 
        66='Nitroglycerin' 67='Hydralazine (Apresoline)' 
        68='Methyldopa (Aldomet)' 69='Doxazosin (Cardura)' 
        70='Prazosin (Minipress)' 71='Terazosin (Hytrin)' 
        72='Clonidine (Catapres)' 73='Minoxidil (Loniten)' 
        74='Simvastatin' 75='Ethacrynic acid' 
        76='Edoxaban' 999='Other';
    value units_29_ 1='mg' 2='ug' 
        3='Units' 999='Other';
    value freq_29_ 1='FREQUENCY' 2='EVERY MORNING' 
        3='DAILY' 4='TWICE DAILY' 
        5='3 TIMES DAILY' 6='4 TIMES DAILY' 
        7='AS NEEDED' 999='OTHER';
    value route_29_ 1='By mouth' 2='Topically' 
        3='Sublingual' 4='Subcutaneous' 
        999='Other';
    value recent_start_date_29_ 1='Yes' 0='No';
    value recent_end_date_29_ 1='Yes' 0='No';
    value meds_30_ 4='Aspirin' 5='Clopidogrel (Plavix)' 
        6='Dipyridamole' 7='Prasugrel (Effient)' 
        8='Ticagrelor (Brillanta)' 9='Rivaroxaban (Xarelto)' 
        10='Dabigatran (Pradaxa)' 11='Apixaban (Eliquis)' 
        12='Heparin (various)' 13='Warfarin (Coumadin)' 
        14='ACE Inhibitors' 15='Benazepril (Lotensin)' 
        16='Captopril (Capoten)' 17='Enalapril (Vasotec)' 
        18='Fosinopril (Monopril)' 19='Lisinopril (Prinivil, Zestril)' 
        20='Moexipril (Univasc)' 21='Perindopril (Aceon)' 
        22='Quinapril (Accupril)' 23='Ramipril (Altace)' 
        24='Trandolapril (Mavik)' 25='Candesartan (Atacand)' 
        26='Eprosartan (Teveten)' 27='Irbesartan (Avapro)' 
        28='Losartan (Cozaar)' 29='Telmisartan (Micardis)' 
        30='Valsartan (Diovan)' 31='Acebutolol (Sectral)' 
        32='Atenolol (Tenormin)' 33='Betaxolol (Kerlone)' 
        34='Bisoprolol/hydrochlorothiazide (Ziac)' 35='Bisoprolol (Zebeta)' 
        36='Metoprolol (Lopressor, Toprol XL)' 37='Nadolol (Corgard)' 
        38='Propranolol (Inderal)' 39='Sotalol (Betapace)' 
        40='Carvedilol (Coreg)' 41='Amlodipine (Norvasc, Lotrel)' 
        42='Diltiazem (Cardizem, Tiazac)' 43='Felodipine (Plendil)' 
        44='Nifedipine (Adalat, Procardia)' 45='Nimodipine (Nimotop)' 
        46='Nisoldipine (Sular)' 47='Verapamil (Calan, Verelan)' 
        48='Atorvastatin (Lipitor)' 49='Rosuvastatin (Crestor)' 
        50='Lovastatin (Mevacor, Altocor, Altoprev)' 51='Pitavastatin (Livalo)' 
        52='Ezetimibe/Simvastatin (Vytorin)' 53='Niacin' 
        54='Digoxin (Lanoxin)' 55='Amiloride (Midamor)' 
        56='Bumetanide (Bumex)' 57='Chlorothiazide (Diuril)' 
        58='Chlorthalidone (Hygroton)' 59='Furosemide (Lasix)' 
        60='Hydrochlorothiazide (Esidrix, Hydrodiuril)' 61='Indapamide (Lozol)' 
        62='Spironolactone (Aldactone)' 63='Eplerenone (Inspra)' 
        64='Isosorbide mononitrate (Imdur)' 65='Isosorbide dinitrate' 
        66='Nitroglycerin' 67='Hydralazine (Apresoline)' 
        68='Methyldopa (Aldomet)' 69='Doxazosin (Cardura)' 
        70='Prazosin (Minipress)' 71='Terazosin (Hytrin)' 
        72='Clonidine (Catapres)' 73='Minoxidil (Loniten)' 
        74='Simvastatin' 75='Ethacrynic acid' 
        76='Edoxaban' 999='Other';
    value units_30_ 1='mg' 2='ug' 
        3='Units' 999='Other';
    value freq_30_ 1='FREQUENCY' 2='EVERY MORNING' 
        3='DAILY' 4='TWICE DAILY' 
        5='3 TIMES DAILY' 6='4 TIMES DAILY' 
        7='AS NEEDED' 999='OTHER';
    value route_30_ 1='By mouth' 2='Topically' 
        3='Sublingual' 4='Subcutaneous' 
        999='Other';
    value recent_start_date_30_ 1='Yes' 0='No';
    value recent_end_date_30_ 1='Yes' 0='No';
    value data_epic_med_ 1='Yes' 0='No';
    value medications_complete_ 0='Incomplete' 1='Unverified' 
        2='Complete';
    value na_cognitive_testing_ 1='Yes' 0='No';
    value shopping_test_yn_ 1='Yes' 0='No';
    value gorton_test_yn_ 1='Yes' 0='No';
    value detection_test_yn_ 1='Yes' 0='No';
    value identification_test_yn_ 1='Yes' 0='No';
    value card_test_yn_ 1='Yes' 0='No';
    value one_back_test_yn_ 1='Yes' 0='No';
    value delayed_recall_test_yn_ 1='Yes' 0='No';
    value data_backed_up_yn_ 1='Yes' 0='No';
    value cognitive_testing_complete_ 0='Incomplete' 1='Unverified' 
        2='Complete';
    value na_form_vp_ 1='Yes' 0='No';
    value ster_carotid_1_ 1='Right' 0='Left';
    value ster_femoral_1_ 1='Right' 0='Left';
    value ster_radial_1_ 1='Right' 0='Left';
    value bp_collected_yn_ 1='Yes' 0='No';
    value carotid_1_ 1='Right' 0='Left';
    value carotid_vasc_ 1='Right' 0='Left';
    value femora_1_ 1='Right' 0='Left';
    value femora_vasc_ 1='Right' 0='Left';
    value radial_1_ 1='Right' 0='Left';
    value radial_vasc_ 1='Right' 0='Left';
    value lvot_flow_ 1='Yes' 0='No';
    value form_vp_complete_ 0='Incomplete' 1='Unverified' 
        2='Complete';
    value na_form_6mwt_ 1='Yes' 0='No';
    value checklist_bl_6mwt___1_ 0='Unchecked' 1='Checked';
    value checklist_bl_6mwt___2_ 0='Unchecked' 1='Checked';
    value checklist_bl_6mwt___3_ 0='Unchecked' 1='Checked';
    value checklist_bl_6mwt___4_ 0='Unchecked' 1='Checked';
    value checklist_bl_6mwt___5_ 0='Unchecked' 1='Checked';
    value checklist_bl_6mwt___6_ 0='Unchecked' 1='Checked';
    value pretest_instruction___1_ 0='Unchecked' 1='Checked';
    value pretest_instruction___2_ 0='Unchecked' 1='Checked';
    value complete_6mwt_ 1='Yes' 0='No';
    value form_6mwt_complete_ 0='Incomplete' 1='Unverified' 
        2='Complete';
    value na_form_6wk_ex_ 1='Yes' 0='No';
    value stage_1_yn_ 1='Yes' 0='No';
    value stage_1_ultras_1_ 1='Yes' 0='No';
    value stage_2_yn_ 1='Yes' 0='No';
    value stage_2_ultras_1_ 1='Yes' 0='No';
    value stage_3_yn_ 1='Yes' 0='No';
    value stage_3_ultras_1_ 1='Yes' 0='No';
    value stage_4_yn_ 1='Yes' 0='No';
    value stage_4_ultras_1_ 1='Yes' 0='No';
    value stage_5_yn_ 1='Yes' 0='No';
    value stage_5_ultras_1_ 1='Yes' 0='No';
    value stage_6_yn_ 1='Yes' 0='No';
    value stage_6_ults_1_ 1='Yes' 0='No';
    value stage_7_yn_ 1='Yes' 0='No';
    value stage_7_ultras_1_ 1='Yes' 0='No';
    value stage_8_yn_ 1='Yes' 0='No';
    value stage_8_ultras_1_ 1='Yes' 0='No';
    value stage_9_yn_ 1='Yes' 0='No';
    value stage_9_ultras_1_ 1='Yes' 0='No';
    value stage_10_yn_ 1='Yes' 0='No';
    value stage_10_ultras_1_ 1='Yes' 0='No';
    value peak_ultras_1_ 1='Yes' 0='No';
    value recov_ultras_1_ 1='Yes' 0='No';
    value nirs_completed_yn_ 1='Yes' 0='No';
    value complet_ex_ 1='Yes' 0='No';
    value form_6wk_ex_complete_ 0='Incomplete' 1='Unverified' 
        2='Complete';
    value na_end_phase_dosing_ 1='Yes' 0='No';
    value end_phase_dosing_complete_ 0='Incomplete' 1='Unverified' 
        2='Complete';
    value na_counseling_ 1='Yes' 0='No';
    value diet_complete_ 1='Yes' 0='No';
    value form_cns_complete_ 0='Incomplete' 1='Unverified' 
        2='Complete';
    value na_ekg_interpretation_ 1='Yes' 0='No';
    value ekg_interpretation_complete_ 0='Incomplete' 1='Unverified' 
        2='Complete';
    value na_kccq_ 1='Yes' 0='No';
    value activity_dressing_ 1='Extremely limited' 2='Quite a bit limited' 
        3='Moderately limited' 4='Slightly limited' 
        5='Not at all limited' 6='limited for other reasons or did not do the activity';
    value activity_showering_ 1='Extremely limited' 2='Quite a bit limited' 
        3='Moderately limited' 4='Slightly limited' 
        5='Not at all limited' 6='limited for other reasons or did not do the activity';
    value activity_walking_ 1='Extremely limited' 2='Quite a bit limited' 
        3='Moderately limited' 4='Slightly limited' 
        5='Not at all limited' 6='limited for other reasons or did not do the activity';
    value activity_work_ 1='Extremely limited' 2='Quite a bit limited' 
        3='Moderately limited' 4='Slightly limited' 
        5='Not at all limited' 6='limited for other reasons or did not do the activity';
    value activity_climbing_ 1='Extremely limited' 2='Quite a bit limited' 
        3='Moderately limited' 4='Slightly limited' 
        5='Not at all limited' 6='limited for other reasons or did not do the activity';
    value activity_run_ 1='Extremely limited' 2='Quite a bit limited' 
        3='Moderately limited' 4='Slightly limited' 
        5='Not at all limited' 6='limited for other reasons or did not do the activity';
    value heart_failure_chage_ 1='Much worse' 2='Slightly worse' 
        3='not changed' 4='slightly better' 
        5='much better' 6='I''ve had no symptoms over the last 2 weeks';
    value frequency_swelling_ 1='Every morning' 2='3 or more times a week, but not every day' 
        3='1-2 times a week' 4='Less than once a week' 
        5='Never over the past 2 weeks';
    value swelling_bother_ 1='Extremely bothersome' 2='Quite a bit bothersome' 
        3='Moderately bothersome' 4='Slightly bothersome' 
        5='Not at all bothersome' 6='I''ve had no swelling';
    value fatigue_limit_ 1='All of the time' 2='Several times per day' 
        3='At least once a day' 4='3 or more times per week but not every day' 
        5='1-2 times per week' 6='Less than once a week' 
        7='Never over the past 2 weeks';
    value fatigue_bother_ 1='Extremely bothersome' 2='Quite a bit bothersome' 
        3='Moderately bothersome' 4='Slightly bothersome' 
        5='Not at all bothersome' 6='I''ve had no fatigue';
    value breath_limited_ 1='All of the time' 2='Several times per day' 
        3='At least once a day' 4='3 or more times per week but not every day' 
        5='1-2 times per week' 6='Less than once a week' 
        7='Never over the past 2 weeks';
    value shortness_bother_ 1='Extremely bothersome' 2='Quite a bit bothersome' 
        3='Moderately bothersome' 4='Slightly bothersome' 
        5='Not at all bothersome' 6='I''ve had no shortness of breath';
    value sleep_sittingup_ 1='Every night' 2='3 or more times a week, but not every day' 
        3='1-2 times a week' 4='less than once a week' 
        5='Never over the past 2 weeks';
    value heartfail_contact_ 1='Not at all sure' 2='Not very sure' 
        3='Somewhat sure' 4='Mostly sure' 
        5='Completely sure';
    value heart_fail_worse_ 1='Do not understand at al' 2='Do not understand very well' 
        3='Somewhat understand' 4='Mostly understand' 
        5='Completely understand';
    value enjoyment_limit_ 1='It has extremely limited my enjoyment of life' 2='It has limited my enjoyment of life quite a bit' 
        3='It has moderately limited my enjoyment of life' 4='It has slightly limited my enjoyment of life' 
        5='It has not limited my enjoyment of life at all';
    value heartfail_life_ 1='Not at all satisfied' 2='Mostly dissatisfied' 
        3='Somewhat satisfies' 4='Mostly satisfied' 
        5='Completely satisfied';
    value discouraged_heartfail_ 1='I felt that way all of the time' 2='I felt that way most of the time' 
        3='I occasionally felt that way' 4='I rarely felt that way' 
        5='I never felt that way';
    value hobbies_ 1='Severly limited' 2='Limited quite a bit' 
        3='Modeerately limited' 4='Slightly limited' 
        5='Did not limit at all' 6='Does not apply or did not do for other reasons';
    value working_ 1='Severly limited' 2='Limited quite a bit' 
        3='Modeerately limited' 4='Slightly limited' 
        5='Did not limit at all' 6='Does not apply or did not do for other reasons';
    value family_visit_ 1='Severly limited' 2='Limited quite a bit' 
        3='Modeerately limited' 4='Slightly limited' 
        5='Did not limit at all' 6='Does not apply or did not do for other reasons';
    value intimate_relationships_ 1='Severly limited' 2='Limited quite a bit' 
        3='Modeerately limited' 4='Slightly limited' 
        5='Did not limit at all' 6='Does not apply or did not do for other reasons';
    value kccq_complete_ 0='Incomplete' 1='Unverified' 
        2='Complete';
    value na_visit_lab_results_ 1='Yes' 0='No';
    value egfr_non_aa_ 1='>60' 0='< 60' 
        99='Other';
    value egfr_aa_ 1='>60' 0='< 60' 
        99='Other';
    value g6pd_vlr_yn_ 1='Yes' 0='No' 
        99='N/A';
    value g6pd_result_ 1='Normal' 0='Abnormal' 
        99='Other';
    value visit_lab_results_complete_ 0='Incomplete' 1='Unverified' 
        2='Complete';
    value na_form_files_ 1='Yes' 0='No';
    value bike_ex_yn_ 1='Yes' 0='No';
    value aurora_export_ 1='Yes' 0='No';
    value placed_in_jlab_ 1='Yes' 0='No';
    value uploaded_to_redcap_ 1='Yes' 0='No';
    value transmittal_sheet_ 1='Yes' 0='No';
    value aurora_watch_transaction_ 1='Yes' 0='No';
    value actigraph_transaction_ 1='Yes' 0='No';
    value placed_calendar_reminder_ 1='Yes' 0='No' 
        99='N/A';
    value labs_signed_ 1='Yes' 0='No';
    value g6pd_ 1='Yes' 0='No' 
        99='N/A';
    value completion_ 1='Yes' 0='No';
    value form_files_ 1='Yes' 0='No';
    value form_files_complete_ 0='Incomplete' 1='Unverified' 
        2='Complete';
    value na_path_and_files_2_ 1='Yes' 0='No';
    value pth_fil_com_bl_ 1='Yes' 2='No';
    value path_and_files_2_complete_ 0='Incomplete' 1='Unverified' 
        2='Complete';
    value na_path_and_files_ 1='Yes' 0='No';
    value tonometry_file_1_na_ 1='Yes' 0='No';
    value tonometry_file2_na_ 1='Yes' 0='No';
    value tonometry_file3_na_ 1='Yes' 0='No';
    value tonometry_file4_na_ 1='Yes' 0='No';
    value pth_fil_com_ 1='Yes' 2='No';
    value path_and_files_complete_ 0='Incomplete' 1='Unverified' 
        2='Complete';
    value na_form_med_ver_p1_ 1='Yes' 0='No';
    value medicaton_verification_p1_ 1='Yes' 0='No' 
        99='N/A';
    value med_dispensed_ 1='Yes' 0='No';
    value form_med_ver_p1_ 1='Yes' 0='No';
    value form_med_ver_p1_complete_ 0='Incomplete' 1='Unverified' 
        2='Complete';
    value na_form_med_ver_p2_ 1='Yes' 0='No';
    value medicaton_verification_ 1='Yes' 0='No' 
        99='N/A';
    value form_med_ver_ 1='Yes' 0='No';
    value form_med_ver_complete_ 0='Incomplete' 1='Unverified' 
        2='Complete';
    value na_wk_call_ 1='Yes' 0='No';
    value mouthwash_ 1='Yes' 0='No';
    value compliant_with_mouthwash_ 1='Yes' 0='No';
    value reviewed_no_viagra_ 1='Yes' 0='No';
    value dietary_restrictions_ 1='Yes' 0='No';
    value headache_ 1='Yes' 0='No';
    value dizziness_ 1='Yes' 0='No';
    value lightheadedness_ 1='Yes' 0='No';
    value low_blood_pressure_90_ 1='Yes' 0='No';
    value stomach_ache_diarrhea_ 1='Yes' 0='No';
    value increased_shortness_ 1='Yes' 0='No';
    value flushing_ 1='Yes' 0='No';
    value rash_ 1='Yes' 0='No';
    value changes_in_blood_pressure_ 1='Yes' 0='No';
    value swelling_ 1='Yes' 0='No';
    value fatigue_ 1='Yes' 0='No';
    value oth_symps_ 1='Yes' 0='No';
    value presence_ 1='Yes' 0='No';
    value amount_of_meds_ 1='Yes' 0='No';
    value form_p1_ 1='Yes' 0='No';
    value wk_call_complete_ 0='Incomplete' 1='Unverified' 
        2='Complete';
    value na_se_assessment_form_ 1='Yes' 0='No';
    value side_efft_asst_yn_ 1='Yes' 0='No';
    value orthostat_se_ 1='Yes' 0='No';
    value mouthwash_se_ 1='Yes' 0='No';
    value compliant_with_mouthwash_se_ 1='Yes' 0='No';
    value reviewed_no_viagra_se_ 1='Yes' 0='No' 
        3='N/A';
    value dietary_restrictions_se_ 1='Yes' 0='No';
    value headache_se_ 1='Yes' 0='No';
    value dizziness_se_ 1='Yes' 0='No';
    value lightheadedness_se_ 1='Yes' 0='No';
    value low_blood_pressure_90_se_ 1='Yes' 0='No';
    value stomach_ache_diarrhea_se_ 1='Yes' 0='No';
    value increased_shortness_se_ 1='Yes' 0='No';
    value flushing_se_ 1='Yes' 0='No';
    value rash_se_ 1='Yes' 0='No';
    value changes_in_blood_pressure_se_ 1='Yes' 0='No';
    value swelling_se_ 1='Yes' 0='No';
    value fatigue_se_ 1='Yes' 0='No';
    value other_symptoms_se_ 1='Yes' 0='No';
    value med_regimen_change_ 1='Yes' 0='No';
    value form_p1_se_ 1='Yes' 0='No';
    value side_effect_assessme_v_3_ 0='Incomplete' 1='Unverified' 
        2='Complete';
    value na_form_devices_ 1='Yes' 0='No';
    value device_given_ 1='Yes' 0='No';
    value devices_mailed_ 1='Yes' 0='No';
    value form_devices_complete_ 0='Incomplete' 1='Unverified' 
        2='Complete';
    value obs_notes_yn_ 1='Yes' 0='No';
    value observationsnotes_complete_ 0='Incomplete' 1='Unverified' 
        2='Complete';

    run;
options fmtsearch=(raw.ko_nw_formats );

data work.redcap; %let _EFIERR_ = 0;
infile &csv_file  delimiter = ',' MISSOVER DSD lrecl=32767 firstobs=2;

    informat study_id $500. ;
    informat redcap_event_name $500. ;
    informat na_form_el best32. ;
    informat data_obtained_yn best32. ;
    informat heart_failure best32. ;
    informat nyha_class $500. ;
    informat lv_ejection best32. ;
    informat lvef $500. ;
    informat study_type $500. ;
    informat date1 yymmdd10. ;
    informat medical_therapy best32. ;
    informat filling_pressures best32. ;
    informat mitral_ratio best32. ;
    informat left_atrium best32. ;
    informat index $500. ;
    informat date2 yymmdd10. ;
    informat chronic_loop best32. ;
    informat drug_dose $500. ;
    informat natriuretic_peptides best32. ;
    informat bnp_level $500. ;
    informat date3 yymmdd10. ;
    informat either_lateral best32. ;
    informat capillary_wedge best32. ;
    informat value $500. ;
    informat date4 yymmdd10. ;
    informat iv_diuretics best32. ;
    informat date5 yymmdd10. ;
    informat location $500. ;
    informat verified_by $500. ;
    informat date6 yymmdd10. ;
    informat supine_systolic best32. ;
    informat supine_sys1 $500. ;
    informat supine_dia1 $500. ;
    informat pregnancy best32. ;
    informat orthostatic_hypotension best32. ;
    informat supine_sys2 $500. ;
    informat supine_dia2 $500. ;
    informat standing_sys1 $500. ;
    informat standing_dia1 $500. ;
    informat native_conduction best32. ;
    informat hemoglobin best32. ;
    informat baseline_labs $500. ;
    informat inability_exercise best32. ;
    informat valvular_disease best32. ;
    informat hypertrophic best32. ;
    informat pericardial_disease best32. ;
    informat current_angina best32. ;
    informat coronary_syndrome best32. ;
    informat primary_pulmonary best32. ;
    informat chronic_obstructive best32. ;
    informat stress_testing best32. ;
    informat ventricular_ejection best32. ;
    informat phosphodiesterase best32. ;
    informat organic_nitrates best32. ;
    informat liver_disease best32. ;
    informat alt $500. ;
    informat ast $500. ;
    informat alb $500. ;
    informat egfr best32. ;
    informat baseline_egfr $500. ;
    informat g6pd_deficiency best32. ;
    informat methemoglobinemia best32. ;
    informat methemoglobin $500. ;
    informat hyperkalemia_serum best32. ;
    informat hyperkalemia $500. ;
    informat ventricular_dysfunction best32. ;
    informat medical_condition best32. ;
    informat contraindications_to_mri best32. ;
    informat intra_luminal_implant best32. ;
    informat life_assist_device best32. ;
    informat vascular_clip best32. ;
    informat visceral_organs best32. ;
    informat intracranial_implants best32. ;
    informat non_removable_piercings best32. ;
    informat personal_history best32. ;
    informat radiologic_evaluation best32. ;
    informat comments_form_el $5000. ;
    informat verified_by1 $500. ;
    informat date7 yymmdd10. ;
    informat form_el_complete best32. ;
    informat na_form_bl_cl best32. ;
    informat consent_yn best32. ;
    informat consent_ini $500. ;
    informat urine_yn best32. ;
    informat urine_radio best32. ;
    informat urine_ini $500. ;
    informat diet_yn best32. ;
    informat diet_ini $500. ;
    informat vital_yn best32. ;
    informat vital_ini $500. ;
    informat mw6_yn best32. ;
    informat mw6_ini $500. ;
    informat quality_yn best32. ;
    informat quality_ini $500. ;
    informat cognitive_test_yn best32. ;
    informat cognitive_test_ini $500. ;
    informat blood_yn best32. ;
    informat blood_ini $500. ;
    informat g6pd_yn best32. ;
    informat g6pd_ini $500. ;
    informat art_tono_yn best32. ;
    informat art_tono_ini $500. ;
    informat echo_yn best32. ;
    informat echo_ini $500. ;
    informat ekg_bl best32. ;
    informat ekg_initials_bl $500. ;
    informat labs_yn best32. ;
    informat hemo_yn best32. ;
    informat hemo_value $500. ;
    informat hemo_ini $500. ;
    informat creati_yn best32. ;
    informat creati_value $500. ;
    informat creati_ini $500. ;
    informat egfr_yn best32. ;
    informat egfr_value $500. ;
    informat egfr_ini $500. ;
    informat meth_yn best32. ;
    informat meth_value $500. ;
    informat meth_ini $500. ;
    informat potas_yn best32. ;
    informat potas_value $500. ;
    informat potas_ini $500. ;
    informat ntpro_yn best32. ;
    informat ntpro_value $500. ;
    informat ntpro_initials $500. ;
    informat med_dis_yn best32. ;
    informat med_dis_ini $500. ;
    informat bl_ch_name $500. ;
    informat bl_ch_date $500. ;
    informat form_bl_cl_complete best32. ;
    informat na_form_6wk_cl best32. ;
    informat urine_pregnancy_test best32. ;
    informat urine_pregnancy_results best32. ;
    informat urine_pregnancy_ini $500. ;
    informat dietary_questionnaire best32. ;
    informat dietary_questionnaire_ini $500. ;
    informat physical_exam best32. ;
    informat physical_exam_ini $500. ;
    informat orthostatics best32. ;
    informat orthostatics_ini $500. ;
    informat vital_signs best32. ;
    informat vital_signs_ini $500. ;
    informat questionnaires_kccq best32. ;
    informat questionnaires_kccq_ini $500. ;
    informat potential_side_effects best32. ;
    informat potential_side_effects_ini $500. ;
    informat cognitive_test2_yn best32. ;
    informat congitive_test2_ini $500. ;
    informat blood_draws_before best32. ;
    informat blood_draws_before_ini $500. ;
    informat light_breakfast best32. ;
    informat light_breakfast_ini $500. ;
    informat blood_draws_after best32. ;
    informat blood_draws_after_ini $500. ;
    informat arterial_tonometry best32. ;
    informat arterial_tonometry_ini $500. ;
    informat doppler_echocardiogram best32. ;
    informat doppler_echocardiogram_ini $500. ;
    informat ekg_p1 best32. ;
    informat ekg_initials_p1 $500. ;
    informat bicycle_exercise_test best32. ;
    informat bicycle_exercise_test_ini $500. ;
    informat muscle_mri best32. ;
    informat muscle_mri_ini $500. ;
    informat medication_dispensed best32. ;
    informat stage_2_meds_ini $500. ;
    informat stage_2_meds best32. ;
    informat stage_1_meds_ini $500. ;
    informat stage_1_meds best32. ;
    informat pill_count_ini $500. ;
    informat pill_count_yn best32. ;
    informat pill_count_ini2_d9f $500. ;
    informat cardiac_mri_performed_p1 best32. ;
    informat cardiac_mri_initials_p1 $500. ;
    informat date_6wk_cl_p1 yymmdd10. ;
    informat signature_6wk_cl_p1 $500. ;
    informat form_6wk_cl_complete best32. ;
    informat na_form_6wk_cl_p2 best32. ;
    informat urine_pregnancy_test_p2 best32. ;
    informat urine_pregnancy_results_p2 best32. ;
    informat urine_pregnancy_ini_p2 $500. ;
    informat dietary_questionnaire_p2 best32. ;
    informat dietary_questionnaire_ini_p2 $500. ;
    informat physical_exam_p2 best32. ;
    informat physical_exam_ini_p2 $500. ;
    informat orthostatics_p2 best32. ;
    informat orthostatics_ini_p2 $500. ;
    informat vital_signs_p2 best32. ;
    informat vital_signs_ini_p2 $500. ;
    informat questionnaires_kccq_p2 best32. ;
    informat questionnaires_kccq_ini_p2 $500. ;
    informat potential_side_effects_p2 best32. ;
    informat potential_side_effects_ini_p2 $500. ;
    informat cognitive_test3_yn best32. ;
    informat cognitive_test3_ini $500. ;
    informat blood_draws_before_p2 best32. ;
    informat blood_draws_before_ini_p2 $500. ;
    informat light_breakfast_p2 best32. ;
    informat light_breakfast_ini_p2 $500. ;
    informat blood_draws_after_p2 best32. ;
    informat blood_draws_after_ini_p2 $500. ;
    informat arterial_tonometry_p2 best32. ;
    informat arterial_tonometry_ini_p2 $500. ;
    informat doppler_echocardiogram_p2 best32. ;
    informat doppler_echocardiogram_ini_p2 $500. ;
    informat ekg_p2 best32. ;
    informat ekg_initials_p2 $500. ;
    informat bicycle_exercise_test_p2 best32. ;
    informat bicycle_exercise_test_ini_p2 $500. ;
    informat muscle_mri_p2 best32. ;
    informat muscle_mri_ini_p2 $500. ;
    informat stage_1_meds_p2 best32. ;
    informat pill_count_ini_p2 $500. ;
    informat pill_count_yn_p2 best32. ;
    informat pill_count_ini2_d9f_p2 $500. ;
    informat cardiac_mri_initials_p2 best32. ;
    informat cardiac_mri_initials_phase_2 $500. ;
    informat form_bl_cl_cmplt_p2 best32. ;
    informat medication_dispensed_p2 best32. ;
    informat stage_2_meds_ini_p2 $500. ;
    informat name_6wk_cl_p2 $500. ;
    informat date_6wk_cl_p2 yymmdd10. ;
    informat signature_6wk_cl_p2 $500. ;
    informat form_6wk_cl_p2_complete best32. ;
    informat na_form_6wk_mri best32. ;
    informat mri_safety_checklist best32. ;
    informat initials $500. ;
    informat field_strength1 best32. ;
    informat load_used1 $500. ;
    informat number_of_repetitions best32. ;
    informat repetitions_oth $500. ;
    informat load_used_psi $500. ;
    informat number_of_repetitions1 best32. ;
    informat other_asl $500. ;
    informat comments $5000. ;
    informat data_exported best32. ;
    informat sig $500. ;
    informat date98 yymmdd10. ;
    informat complete_mri best32. ;
    informat form_6wk_mri_complete best32. ;
    informat na_form_cardiac_mri best32. ;
    informat form_mri_enrolled best32. ;
    informat form_mri_reviewed best32. ;
    informat form_mri_performed $500. ;
    informat form_mri_time time5. ;
    informat form_mri_hr best32. ;
    informat form_mri_systolic best32. ;
    informat form_mri_diastolic best32. ;
    informat form_mri_weight best32. ;
    informat form_mri_weight_units best32. ;
    informat mri_form_weight_other $5000. ;
    informat form_mri_basis1 best32. ;
    informat form_mri_basis2 best32. ;
    informat form_mri_meds best32. ;
    informat form_mri_stable best32. ;
    informat form_mri_beta_blockers best32. ;
    informat form_mri_nitrates best32. ;
    informat form_mri_base_ecg $5000. ;
    informat form_mri_comment $5000. ;
    informat form_mri_post_time time5. ;
    informat form_mri_post_hr best32. ;
    informat form_mri_post_systolic best32. ;
    informat form_mri_post_diastolic best32. ;
    informat form_mri_post_ecg $5000. ;
    informat form_mri_post_reported best32. ;
    informat form_mri_post_symptoms $5000. ;
    informat form_mri_post_discharge best32. ;
    informat form_cardiac_mri_complete best32. ;
    informat na_form_mh best32. ;
    informat penn_chart best32. ;
    informat age best32. ;
    informat gender best32. ;
    informat race___1 best32. ;
    informat race___2 best32. ;
    informat race___3 best32. ;
    informat race___4 best32. ;
    informat race___5 best32. ;
    informat race___6 best32. ;
    informat race_oth $5000. ;
    informat type_decent best32. ;
    informat acutecoronary best32. ;
    informat acutecoronary_ai $5000. ;
    informat prior_angina best32. ;
    informat prior_angina_ai $5000. ;
    informat any_arrhythmia best32. ;
    informat any_arrhythmia_ai $5000. ;
    informat valv_disease_surgery best32. ;
    informat valv_disease_surgery_ai $5000. ;
    informat htn best32. ;
    informat htn_ai $5000. ;
    informat high_cholesterol best32. ;
    informat high_cholesterol_ai $5000. ;
    informat peripheral_vascular best32. ;
    informat peripheral_vascular_ai $5000. ;
    informat diabetes best32. ;
    informat diabetes_ai $5000. ;
    informat insulin best32. ;
    informat insulin_ai $5000. ;
    informat cva_tia best32. ;
    informat cva_tia_ai $5000. ;
    informat pulmonary_embolism_dvt best32. ;
    informat pulmonary_embolism_dvt_ai $5000. ;
    informat osa best32. ;
    informat osa_ai $5000. ;
    informat cpap best32. ;
    informat cpap_ai $5000. ;
    informat copd_asthma best32. ;
    informat copd_asthma_ai $5000. ;
    informat osteoarthritis best32. ;
    informat osteoarthritis_ai $5000. ;
    informat other_conditions $5000. ;
    informat other_conditions_ai $5000. ;
    informat cabg best32. ;
    informat cabg_ai $5000. ;
    informat peripheral best32. ;
    informat peripheral_ai $5000. ;
    informat valvular_surgery best32. ;
    informat valvular_ai $5000. ;
    informat congenital_surgery best32. ;
    informat congenital_surgery_ai $5000. ;
    informat trauma_requiring_surgery best32. ;
    informat trauma_req_surgery_ai $5000. ;
    informat other_surgeries $5000. ;
    informat current_smoker best32. ;
    informat pack_years best32. ;
    informat prior_smoker best32. ;
    informat prior_smoker_ai $5000. ;
    informat current_alcohol best32. ;
    informat drinks_day best32. ;
    informat drinks_add_info $5000. ;
    informat prior_alcohol best32. ;
    informat prior_alcohol_ai $5000. ;
    informat recreational_drug_use best32. ;
    informat recreational_drug_usead $5000. ;
    informat occupation_yn best32. ;
    informat occupation $5000. ;
    informat signature $500. ;
    informat date9 yymmdd10. ;
    informat nyhaclass best32. ;
    informat orthopnea best32. ;
    informat paroxysmal_nocturnal best32. ;
    informat lower_extremity_edema best32. ;
    informat num_of_stairs best32. ;
    informat reason_for_stopping $5000. ;
    informat distance best32. ;
    informat block_miles best32. ;
    informat distance_other $5000. ;
    informat stop_walk $5000. ;
    informat crvalue best32. ;
    informat crdate yymmdd10. ;
    informat egfr_value2 best32. ;
    informat egfr_date yymmdd10. ;
    informat nt_pro_bnp_value best32. ;
    informat nt_pro_bnp_date yymmdd10. ;
    informat hemoglobin_value best32. ;
    informat hemoglobin_date yymmdd10. ;
    informat hematocrit_value best32. ;
    informat hematocrit_date yymmdd10. ;
    informat hemoglobin_a1c_value best32. ;
    informat hemoglobin_a1c_date yymmdd10. ;
    informat other_lab_data $5000. ;
    informat cholesterol_total best32. ;
    informat cholesterol_total_date yymmdd10. ;
    informat triglycerides_value best32. ;
    informat triglycerides_date yymmdd10. ;
    informat hdl_cholesterol best32. ;
    informat hdl_cholesterol_date yymmdd10. ;
    informat ldl best32. ;
    informat ldl_date yymmdd10. ;
    informat vldl best32. ;
    informat vldl_date yymmdd10. ;
    informat non_hdl best32. ;
    informat non_hdl_date yymmdd10. ;
    informat prev_hrt_catheter best32. ;
    informat pcwp_12 best32. ;
    informat lvedp_16 best32. ;
    informat hrt_catheter_date yymmdd10. ;
    informat pcwp_value best32. ;
    informat lvedp_value best32. ;
    informat prior_stress_test best32. ;
    informat stress_test_date yymmdd10. ;
    informat stress_test_result $500. ;
    informat comments_stress_test $5000. ;
    informat allergies $5000. ;
    informat performed_by_date yymmdd10. ;
    informat performed_by_signature $500. ;
    informat form_mh_complete best32. ;
    informat datetime_seconds1 $500. ;
    informat na_form_lab_pre_medication best32. ;
    informat iv_line_required_1 best32. ;
    informat iv_time_1 time5. ;
    informat gauge_1 $500. ;
    informat site_1 $500. ;
    informat preg_test best32. ;
    informat cmp_gold best32. ;
    informat pax_gene best32. ;
    informat nt_pro best32. ;
    informat form_lab_methemoglobin best32. ;
    informat form_lab_cbc best32. ;
    informat g6pd_test best32. ;
    informat urine_cc best32. ;
    informat plasma_purp best32. ;
    informat serum_red best32. ;
    informat saliva_tube best32. ;
    informat notes_pm $5000. ;
    informat perf_by_lab $500. ;
    informat date_lab yymmdd10. ;
    informat form_lab_6412_complete best32. ;
    informat na_form_lab_peak_bike best32. ;
    informat iv_time_1_v3 time5. ;
    informat complete_lab_v3 best32. ;
    informat plasma_bike best32. ;
    informat serum_bike best32. ;
    informat notes_pb $5000. ;
    informat form_lab_pre_medicat_v_0 best32. ;
    informat na_form_lab_post_med best32. ;
    informat iv_time_1_v2 time5. ;
    informat complete_lab_v2 best32. ;
    informat urine_post best32. ;
    informat plasma_post best32. ;
    informat serum_post best32. ;
    informat saliva_post best32. ;
    informat notes_2hr $5000. ;
    informat form_lab_pre_medicat_v_1 best32. ;
    informat na_physical_exam best32. ;
    informat form_pe_obtained best32. ;
    informat height_2 best32. ;
    informat height_2_units best32. ;
    informat weight_2 best32. ;
    informat weight_2_units best32. ;
    informat systolic_2 best32. ;
    informat diastolic_2 best32. ;
    informat blood_pressure_arm_2 best32. ;
    informat heart_rate_2 best32. ;
    informat o2_saturation_2 best32. ;
    informat hr $500. ;
    informat rr_2 best32. ;
    informat jvp_2 best32. ;
    informat jvp_category $500. ;
    informat ekg best32. ;
    informat heart_2 $5000. ;
    informat lungs_2 $5000. ;
    informat abd_2 $5000. ;
    informat extremities_2 $5000. ;
    informat additional_notes_pe $5000. ;
    informat extrem_performed $500. ;
    informat extremities_date yymmdd10. ;
    informat extremities_signature $500. ;
    informat sup_systolic_2 best32. ;
    informat sup_diastolic_2 best32. ;
    informat stan_systolic_2 best32. ;
    informat stan_diastolic_2 best32. ;
    informat orthostatic_symptoms_yn best32. ;
    informat ortho_sympt_descr $5000. ;
    informat comments_phy $5000. ;
    informat sars_yn best32. ;
    informat sars_vaccine $5000. ;
    informat sars_dose_date $5000. ;
    informat sars_notes $5000. ;
    informat phys_by $500. ;
    informat phys_date yymmdd10. ;
    informat form_pe_complete best32. ;
    informat na_end_phase_se_review best32. ;
    informat mouthwash_se_ep best32. ;
    informat compliant_with_mouthwash_se_ep best32. ;
    informat reviewed_no_viagra_se_ep best32. ;
    informat dietary_restrictions_se_ep best32. ;
    informat headache_se_ep best32. ;
    informat dizziness_se_ep best32. ;
    informat lightheadedness_se_ep best32. ;
    informat low_blood_pressure_90_se_ep best32. ;
    informat stomach_ache_diarrhea_se_ep best32. ;
    informat increased_shortness_se_ep best32. ;
    informat flushing_se_ep best32. ;
    informat rash_se_ep best32. ;
    informat ch_in_blood_pressure_se_ep best32. ;
    informat swelling_se_ep best32. ;
    informat fatigue_se_assess best32. ;
    informat other_symps_se best32. ;
    informat orthostat_se_ep best32. ;
    informat orthostat_se_dscr_ep $5000. ;
    informat performed_by776_se_ep $500. ;
    informat phys_date_se_ep yymmdd10. ;
    informat form_p1_se_ep best32. ;
    informat end_phase_side_effec_v_2 best32. ;
    informat na_form_mh_p1_p2 best32. ;
    informat penn_chart_6p best32. ;
    informat age_6p best32. ;
    informat gender_6p best32. ;
    informat race_6p___1 best32. ;
    informat race_6p___2 best32. ;
    informat race_6p___3 best32. ;
    informat race_6p___4 best32. ;
    informat race_6p___5 best32. ;
    informat race_6p___6 best32. ;
    informat race_oth_6p $500. ;
    informat type_decent_6p best32. ;
    informat acutecoronary_6p best32. ;
    informat acutecoronary_ai_6p $500. ;
    informat prior_angina_6p best32. ;
    informat prior_angina_ai_6p $500. ;
    informat any_arrhythmia_6p best32. ;
    informat any_arrhythmia_ai_6p $500. ;
    informat valv_disease_surgery_6p best32. ;
    informat valv_disease_surgery_ai_6p $500. ;
    informat htn_6p best32. ;
    informat htn_ai_6p $500. ;
    informat high_cholesterol_6p best32. ;
    informat high_cholesterol_ai_6p $500. ;
    informat peripheral_vascular_6p best32. ;
    informat peripheral_vascular_ai_6p $500. ;
    informat diabetes_6p best32. ;
    informat diabetes_ai_6p $500. ;
    informat insulin_6p best32. ;
    informat insulin_ai_6p $500. ;
    informat cva_tia_6p best32. ;
    informat cva_tia_ai_6p $500. ;
    informat pulmonary_embolism_dvt_6p best32. ;
    informat pulmonary_embolism_dvt_ai_6p $500. ;
    informat osa_6p best32. ;
    informat osa_ai_6p $500. ;
    informat cpap_6p best32. ;
    informat cpap_ai_6p $500. ;
    informat copd_asthma_6p best32. ;
    informat copd_asthma_ai_6p $500. ;
    informat osteoarthritis_6p best32. ;
    informat osteoarthritis_ai_6p $500. ;
    informat other_conditions_6p $500. ;
    informat other_conditions_ai_6p $500. ;
    informat cabg_6p best32. ;
    informat cabg_ai_6p $500. ;
    informat peripheral_6p best32. ;
    informat peripheral_ai_6p $500. ;
    informat valvular_surgery_6p best32. ;
    informat valvular_ai_6p $500. ;
    informat congenital_surgery_6p best32. ;
    informat congenital_surgery_ai_6p $500. ;
    informat trauma_requiring_surgery_6p best32. ;
    informat trauma_req_surgery_ai_6p $500. ;
    informat other_surgeries_6p $500. ;
    informat current_smoker_6p best32. ;
    informat pack_years_6p best32. ;
    informat prior_smoker_6p best32. ;
    informat prior_smoker_ai_6p $500. ;
    informat current_alcohol_6p best32. ;
    informat drinks_day_6p best32. ;
    informat prior_alcohol_6p best32. ;
    informat prior_alcohol_ai_6p $500. ;
    informat recreational_drug_use_6p best32. ;
    informat recreational_drug_usead_6p $500. ;
    informat occupation_6p $500. ;
    informat signature_6p $500. ;
    informat date9_6p yymmdd10. ;
    informat nyhaclass_6p best32. ;
    informat orthopnea_6p best32. ;
    informat paroxysmal_nocturnal_6p best32. ;
    informat lower_extremity_edema_6p best32. ;
    informat num_of_stairs_6p best32. ;
    informat reason_for_stopping_6p $500. ;
    informat distance_6p best32. ;
    informat block_miles_6p best32. ;
    informat stop_walk_6p $500. ;
    informat crvalue_6p best32. ;
    informat crdate_6p yymmdd10. ;
    informat egfr_value2_6p best32. ;
    informat egfr_date_6p yymmdd10. ;
    informat nt_pro_bnp_value_6p best32. ;
    informat nt_pro_bnp_date_6p yymmdd10. ;
    informat hemoglobin_value_6p best32. ;
    informat hemoglobin_date_6p yymmdd10. ;
    informat hematocrit_value_6p best32. ;
    informat hematocrit_date_6p yymmdd10. ;
    informat hemoglobin_a1c_value_6p best32. ;
    informat hemoglobin_a1c_date_6p yymmdd10. ;
    informat other_lab_data_6p $500. ;
    informat prev_hrt_catheter_6p best32. ;
    informat hrt_catheter_date_6p yymmdd10. ;
    informat pcwp_12_6p best32. ;
    informat pcwp_value_6p best32. ;
    informat lvedp_16_6p best32. ;
    informat lvedp_value_6p best32. ;
    informat prior_stress_test_6p best32. ;
    informat stress_test_date_6p yymmdd10. ;
    informat stress_test_result_6p $500. ;
    informat comments_stress_test_6p $5000. ;
    informat allergies_6p $500. ;
    informat performed_by_date_6p yymmdd10. ;
    informat performed_by_signature_6p $500. ;
    informat bl_mh_cmplt_6p best32. ;
    informat form_mh_8174_complete best32. ;
    informat na_medications best32. ;
    informat date_med yymmdd10. ;
    informat num_med best32. ;
    informat meds_1 best32. ;
    informat med_oth_1 $500. ;
    informat dose_1 best32. ;
    informat comb_dose_1 best32. ;
    informat units_1 best32. ;
    informat units_oth_1 $500. ;
    informat freq_1 best32. ;
    informat freq_oth_1 $500. ;
    informat route_1 best32. ;
    informat route_oth_1 $500. ;
    informat recent_start_date_1 best32. ;
    informat start_date_1 yymmdd10. ;
    informat recent_end_date_1 best32. ;
    informat end_date_1 yymmdd10. ;
    informat meds_2 best32. ;
    informat med_oth_2 $500. ;
    informat dose_2 best32. ;
    informat comb_dose_2 best32. ;
    informat units_2 best32. ;
    informat units_oth_2 $500. ;
    informat freq_2 best32. ;
    informat freq_oth_2 $500. ;
    informat route_2 best32. ;
    informat route_oth_2 $500. ;
    informat recent_start_date_2 best32. ;
    informat start_date_2 yymmdd10. ;
    informat recent_end_date_2 best32. ;
    informat end_date_2 yymmdd10. ;
    informat meds_3 best32. ;
    informat med_oth_3 $500. ;
    informat dose_3 best32. ;
    informat comb_dose_3 best32. ;
    informat units_3 best32. ;
    informat units_oth_3 $500. ;
    informat freq_3 best32. ;
    informat freq_oth_3 $500. ;
    informat route_3 best32. ;
    informat route_oth_3 $500. ;
    informat recent_start_date_3 best32. ;
    informat start_date_3 yymmdd10. ;
    informat recent_end_date_3 best32. ;
    informat end_date_3 yymmdd10. ;
    informat meds_4 best32. ;
    informat med_oth_4 $500. ;
    informat dose_4 best32. ;
    informat comb_dose_4 best32. ;
    informat units_4 best32. ;
    informat units_oth_4 $500. ;
    informat freq_4 best32. ;
    informat freq_oth_4 $500. ;
    informat route_4 best32. ;
    informat route_oth_4 $500. ;
    informat recent_start_date_4 best32. ;
    informat start_date_4 yymmdd10. ;
    informat recent_end_date_4 best32. ;
    informat end_date_4 yymmdd10. ;
    informat meds_5 best32. ;
    informat med_oth_5 $500. ;
    informat dose_5 best32. ;
    informat comb_dose_5 best32. ;
    informat units_5 best32. ;
    informat units_oth_5 $500. ;
    informat freq_5 best32. ;
    informat freq_oth_5 $500. ;
    informat route_5 best32. ;
    informat route_oth_5 $500. ;
    informat recent_start_date_5 best32. ;
    informat start_date_5 yymmdd10. ;
    informat recent_end_date_5 best32. ;
    informat end_date_5 yymmdd10. ;
    informat meds_6 best32. ;
    informat med_oth_6 $500. ;
    informat dose_6 best32. ;
    informat comb_dose_6 best32. ;
    informat units_6 best32. ;
    informat units_oth_6 $500. ;
    informat freq_6 best32. ;
    informat freq_oth_6 $500. ;
    informat route_6 best32. ;
    informat route_oth_6 $500. ;
    informat recent_start_date_6 best32. ;
    informat start_date_6 yymmdd10. ;
    informat recent_end_date_6 best32. ;
    informat end_date_6 yymmdd10. ;
    informat meds_7 best32. ;
    informat med_oth_7 $500. ;
    informat dose_7 best32. ;
    informat comb_dose_7 best32. ;
    informat units_7 best32. ;
    informat units_oth_7 $500. ;
    informat freq_7 best32. ;
    informat freq_oth_7 $500. ;
    informat route_7 best32. ;
    informat route_oth_7 $500. ;
    informat recent_start_date_7 best32. ;
    informat start_date_7 yymmdd10. ;
    informat recent_end_date_7 best32. ;
    informat end_date_7 yymmdd10. ;
    informat meds_8 best32. ;
    informat med_oth_8 $500. ;
    informat dose_8 best32. ;
    informat comb_dose_8 best32. ;
    informat units_8 best32. ;
    informat units_oth_8 $500. ;
    informat freq_8 best32. ;
    informat freq_oth_8 $500. ;
    informat route_8 best32. ;
    informat route_oth_8 $500. ;
    informat recent_start_date_8 best32. ;
    informat start_date_8 yymmdd10. ;
    informat recent_end_date_8 best32. ;
    informat end_date_8 yymmdd10. ;
    informat meds_9 best32. ;
    informat med_oth_9 $500. ;
    informat dose_9 best32. ;
    informat comb_dose_9 best32. ;
    informat units_9 best32. ;
    informat units_oth_9 $500. ;
    informat freq_9 best32. ;
    informat freq_oth_9 $500. ;
    informat route_9 best32. ;
    informat route_oth_9 $500. ;
    informat recent_start_date_9 best32. ;
    informat start_date_9 yymmdd10. ;
    informat recent_end_date_9 best32. ;
    informat end_date_9 yymmdd10. ;
    informat meds_10 best32. ;
    informat med_oth_10 $500. ;
    informat dose_10 best32. ;
    informat comb_dose_10 best32. ;
    informat units_10 best32. ;
    informat units_oth_10 $500. ;
    informat freq_10 best32. ;
    informat freq_oth_10 $500. ;
    informat route_10 best32. ;
    informat route_oth_10 $500. ;
    informat recent_start_date_10 best32. ;
    informat start_date_10 yymmdd10. ;
    informat recent_end_date_10 best32. ;
    informat end_date_10 yymmdd10. ;
    informat meds_11 best32. ;
    informat med_oth_11 $500. ;
    informat dose_11 best32. ;
    informat comb_dose_11 best32. ;
    informat units_11 best32. ;
    informat units_oth_11 $500. ;
    informat freq_11 best32. ;
    informat freq_oth_11 $500. ;
    informat route_11 best32. ;
    informat route_oth_11 $500. ;
    informat recent_start_date_11 best32. ;
    informat start_date_11 yymmdd10. ;
    informat recent_end_date_11 best32. ;
    informat end_date_11 yymmdd10. ;
    informat meds_12 best32. ;
    informat med_oth_12 $500. ;
    informat dose_12 best32. ;
    informat comb_dose_12 best32. ;
    informat units_12 best32. ;
    informat units_oth_12 $500. ;
    informat freq_12 best32. ;
    informat freq_oth_12 $500. ;
    informat route_12 best32. ;
    informat route_oth_12 $500. ;
    informat recent_start_date_12 best32. ;
    informat start_date_12 yymmdd10. ;
    informat recent_end_date_12 best32. ;
    informat end_date_12 yymmdd10. ;
    informat meds_13 best32. ;
    informat med_oth_13 $500. ;
    informat dose_13 best32. ;
    informat comb_dose_13 best32. ;
    informat units_13 best32. ;
    informat units_oth_13 $500. ;
    informat freq_13 best32. ;
    informat freq_oth_13 $500. ;
    informat route_13 best32. ;
    informat route_oth_13 $500. ;
    informat recent_start_date_13 best32. ;
    informat start_date_13 yymmdd10. ;
    informat recent_end_date_13 best32. ;
    informat end_date_13 yymmdd10. ;
    informat meds_14 best32. ;
    informat med_oth_14 $500. ;
    informat dose_14 best32. ;
    informat comb_dose_14 best32. ;
    informat units_14 best32. ;
    informat units_oth_14 $500. ;
    informat freq_14 best32. ;
    informat freq_oth_14 $500. ;
    informat route_14 best32. ;
    informat route_oth_14 $500. ;
    informat recent_start_date_14 best32. ;
    informat start_date_14 yymmdd10. ;
    informat recent_end_date_14 best32. ;
    informat end_date_14 yymmdd10. ;
    informat meds_15 best32. ;
    informat med_oth_15 $500. ;
    informat dose_15 best32. ;
    informat comb_dose_15 best32. ;
    informat units_15 best32. ;
    informat units_oth_15 $500. ;
    informat freq_15 best32. ;
    informat freq_oth_15 $500. ;
    informat route_15 best32. ;
    informat route_oth_15 $500. ;
    informat recent_start_date_15 best32. ;
    informat start_date_15 yymmdd10. ;
    informat recent_end_date_15 best32. ;
    informat end_date_15 yymmdd10. ;
    informat meds_16 best32. ;
    informat med_oth_16 $500. ;
    informat dose_16 best32. ;
    informat comb_dose_16 best32. ;
    informat units_16 best32. ;
    informat units_oth_16 $500. ;
    informat freq_16 best32. ;
    informat freq_oth_16 $500. ;
    informat route_16 best32. ;
    informat route_oth_16 $500. ;
    informat recent_start_date_16 best32. ;
    informat start_date_16 yymmdd10. ;
    informat recent_end_date_16 best32. ;
    informat end_date_16 yymmdd10. ;
    informat meds_17 best32. ;
    informat med_oth_17 $500. ;
    informat dose_17 best32. ;
    informat comb_dose_17 best32. ;
    informat units_17 best32. ;
    informat units_oth_17 $500. ;
    informat freq_17 best32. ;
    informat freq_oth_17 $500. ;
    informat route_17 best32. ;
    informat route_oth_17 $500. ;
    informat recent_start_date_17 best32. ;
    informat start_date_17 yymmdd10. ;
    informat recent_end_date_17 best32. ;
    informat end_date_17 yymmdd10. ;
    informat meds_18 best32. ;
    informat med_oth_18 $500. ;
    informat dose_18 best32. ;
    informat comb_dose_18 best32. ;
    informat units_18 best32. ;
    informat units_oth_18 $500. ;
    informat freq_18 best32. ;
    informat freq_oth_18 $500. ;
    informat route_18 best32. ;
    informat route_oth_18 $500. ;
    informat recent_start_date_18 best32. ;
    informat start_date_18 yymmdd10. ;
    informat recent_end_date_18 best32. ;
    informat end_date_18 yymmdd10. ;
    informat meds_19 best32. ;
    informat med_oth_19 $500. ;
    informat dose_19 best32. ;
    informat comb_dose_19 best32. ;
    informat units_19 best32. ;
    informat units_oth_19 $500. ;
    informat freq_19 best32. ;
    informat freq_oth_19 $500. ;
    informat route_19 best32. ;
    informat route_oth_19 $500. ;
    informat recent_start_date_19 best32. ;
    informat start_date_19 yymmdd10. ;
    informat recent_end_date_19 best32. ;
    informat end_date_19 yymmdd10. ;
    informat meds_20 best32. ;
    informat med_oth_20 $500. ;
    informat dose_20 best32. ;
    informat comb_dose_20 best32. ;
    informat units_20 best32. ;
    informat units_oth_20 $500. ;
    informat freq_20 best32. ;
    informat freq_oth_20 $500. ;
    informat route_20 best32. ;
    informat route_oth_20 $500. ;
    informat recent_start_date_20 best32. ;
    informat start_date_20 yymmdd10. ;
    informat recent_end_date_20 best32. ;
    informat end_date_20 yymmdd10. ;
    informat meds_21 best32. ;
    informat med_oth_21 $500. ;
    informat dose_21 best32. ;
    informat comb_dose_21 best32. ;
    informat units_21 best32. ;
    informat units_oth_21 $500. ;
    informat freq_21 best32. ;
    informat freq_oth_21 $500. ;
    informat route_21 best32. ;
    informat route_oth_21 $500. ;
    informat recent_start_date_21 best32. ;
    informat start_date_21 yymmdd10. ;
    informat recent_end_date_21 best32. ;
    informat end_date_21 yymmdd10. ;
    informat meds_22 best32. ;
    informat med_oth_22 $500. ;
    informat dose_22 best32. ;
    informat comb_dose_22 best32. ;
    informat units_22 best32. ;
    informat units_oth_22 $500. ;
    informat freq_22 best32. ;
    informat freq_oth_22 $500. ;
    informat route_22 best32. ;
    informat route_oth_22 $500. ;
    informat recent_start_date_22 best32. ;
    informat start_date_22 yymmdd10. ;
    informat recent_end_date_22 best32. ;
    informat end_date_22 yymmdd10. ;
    informat meds_23 best32. ;
    informat med_oth_23 $500. ;
    informat dose_23 best32. ;
    informat comb_dose_23 best32. ;
    informat units_23 best32. ;
    informat units_oth_23 $500. ;
    informat freq_23 best32. ;
    informat freq_oth_23 $500. ;
    informat route_23 best32. ;
    informat route_oth_23 $500. ;
    informat recent_start_date_23 best32. ;
    informat start_date_23 yymmdd10. ;
    informat recent_end_date_23 best32. ;
    informat end_date_23 yymmdd10. ;
    informat meds_24 best32. ;
    informat med_oth_24 $500. ;
    informat dose_24 best32. ;
    informat comb_dose_24 best32. ;
    informat units_24 best32. ;
    informat units_oth_24 $500. ;
    informat freq_24 best32. ;
    informat freq_oth_24 $500. ;
    informat route_24 best32. ;
    informat route_oth_24 $500. ;
    informat recent_start_date_24 best32. ;
    informat start_date_24 yymmdd10. ;
    informat recent_end_date_24 best32. ;
    informat end_date_24 yymmdd10. ;
    informat meds_25 best32. ;
    informat med_oth_25 $500. ;
    informat dose_25 best32. ;
    informat comb_dose_25 best32. ;
    informat units_25 best32. ;
    informat units_oth_25 $500. ;
    informat freq_25 best32. ;
    informat freq_oth_25 $500. ;
    informat route_25 best32. ;
    informat route_oth_25 $500. ;
    informat recent_start_date_25 best32. ;
    informat start_date_25 yymmdd10. ;
    informat recent_end_date_25 best32. ;
    informat end_date_25 yymmdd10. ;
    informat meds_26 best32. ;
    informat med_oth_26 $500. ;
    informat dose_26 best32. ;
    informat comb_dose_26 best32. ;
    informat units_26 best32. ;
    informat units_oth_26 $500. ;
    informat freq_26 best32. ;
    informat freq_oth_26 $500. ;
    informat route_26 best32. ;
    informat route_oth_26 $500. ;
    informat recent_start_date_26 best32. ;
    informat start_date_26 yymmdd10. ;
    informat recent_end_date_26 best32. ;
    informat end_date_26 yymmdd10. ;
    informat meds_27 best32. ;
    informat med_oth_27 $500. ;
    informat dose_27 best32. ;
    informat comb_dose_27 best32. ;
    informat units_27 best32. ;
    informat units_oth_27 $500. ;
    informat freq_27 best32. ;
    informat freq_oth_27 $500. ;
    informat route_27 best32. ;
    informat route_oth_27 $500. ;
    informat recent_start_date_27 best32. ;
    informat start_date_27 yymmdd10. ;
    informat recent_end_date_27 best32. ;
    informat end_date_27 yymmdd10. ;
    informat meds_28 best32. ;
    informat med_oth_28 $500. ;
    informat dose_28 best32. ;
    informat comb_dose_28 best32. ;
    informat units_28 best32. ;
    informat units_oth_28 $500. ;
    informat freq_28 best32. ;
    informat freq_oth_28 $500. ;
    informat route_28 best32. ;
    informat route_oth_28 $500. ;
    informat recent_start_date_28 best32. ;
    informat start_date_28 yymmdd10. ;
    informat recent_end_date_28 best32. ;
    informat end_date_28 yymmdd10. ;
    informat meds_29 best32. ;
    informat med_oth_29 $500. ;
    informat dose_29 best32. ;
    informat comb_dose_29 best32. ;
    informat units_29 best32. ;
    informat units_oth_29 $500. ;
    informat freq_29 best32. ;
    informat freq_oth_29 $500. ;
    informat route_29 best32. ;
    informat route_oth_29 $500. ;
    informat recent_start_date_29 best32. ;
    informat start_date_29 yymmdd10. ;
    informat recent_end_date_29 best32. ;
    informat end_date_29 yymmdd10. ;
    informat meds_30 best32. ;
    informat med_oth_30 $500. ;
    informat dose_30 best32. ;
    informat comb_dose_30 best32. ;
    informat units_30 best32. ;
    informat units_oth_30 $500. ;
    informat freq_30 best32. ;
    informat freq_oth_30 $500. ;
    informat route_30 best32. ;
    informat route_oth_30 $500. ;
    informat recent_start_date_30 best32. ;
    informat start_date_30 yymmdd10. ;
    informat recent_end_date_30 best32. ;
    informat end_date_30 yymmdd10. ;
    informat data_epic_med best32. ;
    informat med_comments $5000. ;
    informat medications_complete best32. ;
    informat na_cognitive_testing best32. ;
    informat shopping_test_yn best32. ;
    informat gorton_test_yn best32. ;
    informat detection_test_yn best32. ;
    informat identification_test_yn best32. ;
    informat card_test_yn best32. ;
    informat one_back_test_yn best32. ;
    informat delayed_recall_test_yn best32. ;
    informat data_backed_up_yn best32. ;
    informat cognitive_comments $5000. ;
    informat form_ct_name $500. ;
    informat form_ct_date yymmdd10. ;
    informat signature_cog_test $500. ;
    informat cognitive_testing_complete best32. ;
    informat na_form_vp best32. ;
    informat ult_sd_perf_1 $500. ;
    informat sternal_angle_to_carotid_1 best32. ;
    informat ster_carotid_1 best32. ;
    informat sternal_angle_to_femoral_1 best32. ;
    informat ster_femoral_1 best32. ;
    informat sternal_angle_to_radial_1 best32. ;
    informat ster_radial_1 best32. ;
    informat sternal_length best32. ;
    informat bp_collected_yn best32. ;
    informat bp_study_id best32. ;
    informat pb_plus_systolic $500. ;
    informat bp_plus_diastolic best32. ;
    informat pre_bike_systolic_1 best32. ;
    informat pre_bike_diastolic_1 best32. ;
    informat time_1 time5. ;
    informat hr_1 best32. ;
    informat map best32. ;
    informat initials_1 $500. ;
    informat carotid_1 best32. ;
    informat carotid_tonometry $500. ;
    informat carotid_vasc best32. ;
    informat femora_1 best32. ;
    informat femoral_tonometry $500. ;
    informat femora_vasc best32. ;
    informat radial_1 best32. ;
    informat radial_tonometry $500. ;
    informat radial_vasc best32. ;
    informat lvot_flow best32. ;
    informat comment_1 $5000. ;
    informat form_vp_name $500. ;
    informat form_vp_date yymmdd10. ;
    informat form_vp_complete best32. ;
    informat na_form_6mwt best32. ;
    informat checklist_bl_6mwt___1 best32. ;
    informat checklist_bl_6mwt___2 best32. ;
    informat checklist_bl_6mwt___3 best32. ;
    informat checklist_bl_6mwt___4 best32. ;
    informat checklist_bl_6mwt___5 best32. ;
    informat checklist_bl_6mwt___6 best32. ;
    informat dyspnea_borg_score best32. ;
    informat fatigue_borg_score best32. ;
    informat heart_rate best32. ;
    informat pulse_oximetry best32. ;
    informat systolic_bf best32. ;
    informat diastolic_bf best32. ;
    informat pretest_instruction___1 best32. ;
    informat pretest_instruction___2 best32. ;
    informat post_dyspnea_borg best32. ;
    informat post_fatigue_borg best32. ;
    informat post_bpm best32. ;
    informat post_pulse_oximetry best32. ;
    informat systolic_af best32. ;
    informat diastolic_af best32. ;
    informat test_start_time time5. ;
    informat total_meters_walked best32. ;
    informat notes $5000. ;
    informat perform_date yymmdd10. ;
    informat perform_sig $500. ;
    informat complete_6mwt best32. ;
    informat form_6mwt_complete best32. ;
    informat na_form_6wk_ex best32. ;
    informat bicyc_1 time5. ;
    informat initial_1 $500. ;
    informat stage_1_yn best32. ;
    informat stage_1_systolic_1 best32. ;
    informat stage_1_diastolic_1 best32. ;
    informat stage_1_hr_1 best32. ;
    informat stage_1_o2_1 best32. ;
    informat stage_1_ultras_1 best32. ;
    informat stage_2_yn best32. ;
    informat stage_2_systolic_1 best32. ;
    informat stage_2_diastolic_1 best32. ;
    informat stage_2_hr_1 best32. ;
    informat stage_2_o2_1 best32. ;
    informat stage_2_ultras_1 best32. ;
    informat stage_3_yn best32. ;
    informat stage_3_systolic_1 best32. ;
    informat stage_3_diastolic_1 best32. ;
    informat stage_3_hr_1 best32. ;
    informat stage_3_o2_1 best32. ;
    informat stage_3_ultras_1 best32. ;
    informat stage_4_yn best32. ;
    informat stage_4_systolic_1 best32. ;
    informat stage_4_diastolic_1 best32. ;
    informat stage_4_hr_1 best32. ;
    informat stage_4_o2_1 best32. ;
    informat stage_4_ultras_1 best32. ;
    informat stage_5_yn best32. ;
    informat stage_5_systolic_1 best32. ;
    informat stage_5_diastolic_1 best32. ;
    informat stage_5_hr_1 best32. ;
    informat stage_5_o2_1 best32. ;
    informat stage_5_ultras_1 best32. ;
    informat stage_6_yn best32. ;
    informat stage_6_systolic_1 best32. ;
    informat stage_6_diastolic_1 best32. ;
    informat stage_6_hr_1 best32. ;
    informat stage_6_o2_1 best32. ;
    informat stage_6_ults_1 best32. ;
    informat stage_7_yn best32. ;
    informat stage_7_systolic_1 best32. ;
    informat stage_7_diastolic_1 best32. ;
    informat stage_7_hr_1 best32. ;
    informat stage_7_o2_1 best32. ;
    informat stage_7_ultras_1 best32. ;
    informat stage_8_yn best32. ;
    informat stage_8_systolic_1 best32. ;
    informat stage_8_diastolic_1 best32. ;
    informat stage_8_hr_1 best32. ;
    informat stage_8_o2_1 best32. ;
    informat stage_8_ultras_1 best32. ;
    informat stage_9_yn best32. ;
    informat stage_9_systolic_1 best32. ;
    informat stage_9_diastolic_1 best32. ;
    informat stage_9_hr_1 best32. ;
    informat stage_9_o2_1 best32. ;
    informat stage_9_ultras_1 best32. ;
    informat stage_10_yn best32. ;
    informat stage_10_systolic_1 best32. ;
    informat stage_10_diastolic_1 best32. ;
    informat stage_10_hr_1 best32. ;
    informat stage_10_o2_1 best32. ;
    informat stage_10_ultras_1 best32. ;
    informat peak_bld_systolic_1 best32. ;
    informat peak_bld_diastolic_1 best32. ;
    informat peak_hr_1 best32. ;
    informat peak_o2_sat_1 best32. ;
    informat peak_ultras_1 best32. ;
    informat recov_bld_systolic_1 best32. ;
    informat recov_bld_diastolic_1 best32. ;
    informat recov_hr_1 best32. ;
    informat recov_o2_1 best32. ;
    informat recov_ultras_1 best32. ;
    informat exerc_time_1 time5. ;
    informat peak_exerc_1 best32. ;
    informat peak_borg_1 best32. ;
    informat dyspnea_1 $500. ;
    informat fatique_1 $500. ;
    informat nirs_completed_yn best32. ;
    informat notes_6wkex $5000. ;
    informat perf_by_ex $500. ;
    informat date_ex yymmdd10. ;
    informat complet_ex best32. ;
    informat form_6wk_ex_complete best32. ;
    informat na_end_phase_dosing best32. ;
    informat administered_by $500. ;
    informat epd_date yymmdd10. ;
    informat epd_time time5. ;
    informat end_phase_dosing_complete best32. ;
    informat na_counseling best32. ;
    informat diet_complete best32. ;
    informat counsel_diet $500. ;
    informat complete_by_diet $500. ;
    informat date_diet yymmdd10. ;
    informat form_cns_complete best32. ;
    informat na_ekg_interpretation best32. ;
    informat ekg_interpretation $5000. ;
    informat ekg_interpretation_complete best32. ;
    informat na_kccq best32. ;
    informat activity_dressing best32. ;
    informat activity_showering best32. ;
    informat activity_walking best32. ;
    informat activity_work best32. ;
    informat activity_climbing best32. ;
    informat activity_run best32. ;
    informat heart_failure_chage best32. ;
    informat frequency_swelling best32. ;
    informat swelling_bother best32. ;
    informat fatigue_limit best32. ;
    informat fatigue_bother best32. ;
    informat breath_limited best32. ;
    informat shortness_bother best32. ;
    informat sleep_sittingup best32. ;
    informat heartfail_contact best32. ;
    informat heart_fail_worse best32. ;
    informat enjoyment_limit best32. ;
    informat heartfail_life best32. ;
    informat discouraged_heartfail best32. ;
    informat hobbies best32. ;
    informat working best32. ;
    informat family_visit best32. ;
    informat intimate_relationships best32. ;
    informat kccq_complete best32. ;
    informat na_visit_lab_results best32. ;
    informat hemoglobin_vlr best32. ;
    informat methemoglobin_ best32. ;
    informat nt_pro_bnp_vlr best32. ;
    informat white_blood_cells best32. ;
    informat red_blood_cells best32. ;
    informat hemoglobin_vlr2 best32. ;
    informat hematocrit best32. ;
    informat rdw best32. ;
    informat mch best32. ;
    informat mchc best32. ;
    informat mcv best32. ;
    informat platelets best32. ;
    informat glucose best32. ;
    informat urea_nitrogen best32. ;
    informat creatinine best32. ;
    informat sodium best32. ;
    informat potassium best32. ;
    informat chloride best32. ;
    informat calcium best32. ;
    informat protein_total best32. ;
    informat albumin best32. ;
    informat biblirubin_total best32. ;
    informat alkaline_phosphatase best32. ;
    informat ast_vlr best32. ;
    informat alt_vlr best32. ;
    informat egfr_non_aa best32. ;
    informat non_aa_oth best32. ;
    informat egfr_aa best32. ;
    informat aa_oth best32. ;
    informat g6pd_vlr_yn best32. ;
    informat g6pd_result best32. ;
    informat result_oth $500. ;
    informat oxyhemoglobin $500. ;
    informat o2_ct $500. ;
    informat carboxyhemoglobin best32. ;
    informat carbon_dioxide best32. ;
    informat anion_gap best32. ;
    informat visit_lab_results_complete best32. ;
    informat na_form_files best32. ;
    informat file1 $500. ;
    informat file2 $500. ;
    informat file3 $500. ;
    informat file4 $500. ;
    informat file5 $500. ;
    informat file6 $500. ;
    informat file7 $500. ;
    informat file8 $500. ;
    informat bike_ex_yn best32. ;
    informat file9 $500. ;
    informat aurora_export best32. ;
    informat placed_in_jlab best32. ;
    informat uploaded_to_redcap best32. ;
    informat transmittal_sheet best32. ;
    informat aurora_watch_transaction best32. ;
    informat actigraph_transaction best32. ;
    informat placed_calendar_reminder best32. ;
    informat labs_signed best32. ;
    informat g6pd best32. ;
    informat completion best32. ;
    informat notes_calendar $5000. ;
    informat date99 yymmdd10. ;
    informat signature77 $500. ;
    informat form_files best32. ;
    informat form_files_complete best32. ;
    informat na_path_and_files_2 best32. ;
    informat echo_path_bl $500. ;
    informat tonometry_path_bl $500. ;
    informat aurora_file_path_bl $500. ;
    informat pth_fil_com_bl best32. ;
    informat path_and_files_2_complete best32. ;
    informat na_path_and_files best32. ;
    informat echo_path $500. ;
    informat tonometry_path $500. ;
    informat tonometry_file1 $500. ;
    informat tonometry_file_1_na best32. ;
    informat tonometry_file2 $500. ;
    informat tonometry_file2_na best32. ;
    informat tonometry_file3 $500. ;
    informat tonometry_file3_na best32. ;
    informat tonometry_file4 $500. ;
    informat tonometry_file4_na best32. ;
    informat cardiopulmonary_file_1 $500. ;
    informat aurora_file_path $500. ;
    informat actigraph_file_path $500. ;
    informat cardiopulmonary_file_path $500. ;
    informat plantar_flexor_file_path $500. ;
    informat pth_fil_com best32. ;
    informat path_and_files_complete best32. ;
    informat na_form_med_ver_p1 best32. ;
    informat medicaton_verification_p1 best32. ;
    informat med_ver_num_of_days_p1 best32. ;
    informat date_of_call_p1 yymmdd10. ;
    informat time_of_call_p1 time5. ;
    informat med_dispensed best32. ;
    informat date_of_med_p1 yymmdd10. ;
    informat time_num_p1 time5. ;
    informat form_med_ver_p1 best32. ;
    informat form_med_ver_p1_complete best32. ;
    informat na_form_med_ver_p2 best32. ;
    informat medicaton_verification best32. ;
    informat num_days_after_bl best32. ;
    informat date_of_call yymmdd10. ;
    informat time_of_call time5. ;
    informat date_of_med yymmdd10. ;
    informat time_num time5. ;
    informat form_med_ver best32. ;
    informat form_med_ver_complete best32. ;
    informat na_wk_call best32. ;
    informat mouthwash best32. ;
    informat compliant_with_mouthwash best32. ;
    informat reviewed_no_viagra best32. ;
    informat dietary_restrictions best32. ;
    informat headache best32. ;
    informat dizziness best32. ;
    informat lightheadedness best32. ;
    informat low_blood_pressure_90 best32. ;
    informat stomach_ache_diarrhea best32. ;
    informat increased_shortness best32. ;
    informat flushing best32. ;
    informat rash best32. ;
    informat changes_in_blood_pressure best32. ;
    informat swelling best32. ;
    informat fatigue best32. ;
    informat oth_symps best32. ;
    informat presence best32. ;
    informat if_yes_subject_needs_to $5000. ;
    informat amount_of_meds best32. ;
    informat date_uptitrated_fmh yymmdd10. ;
    informat date_remn_fmh yymmdd10. ;
    informat date0934 yymmdd10. ;
    informat signature564 $500. ;
    informat form_p1 best32. ;
    informat wk_call_complete best32. ;
    informat na_se_assessment_form best32. ;
    informat side_efft_asst_yn best32. ;
    informat heart_rate_2_se best32. ;
    informat o2_saturation_2_se best32. ;
    informat systolic_2_se best32. ;
    informat diastolic_2_se best32. ;
    informat systolic_2_se2 best32. ;
    informat diastolic_2_se2 best32. ;
    informat orthostat_se best32. ;
    informat orthostat_se_dscr $5000. ;
    informat bp_drop_comments $5000. ;
    informat orthostatic_pb1 $500. ;
    informat orthostatic_sig $500. ;
    informat orthostatic_date $500. ;
    informat heart_comments $5000. ;
    informat lung_comments $5000. ;
    informat abd_comments $5000. ;
    informat extrem_comments $5000. ;
    informat se_assessment_notes $5000. ;
    informat performed_by776_se2_c7c $500. ;
    informat signature564_se2_0f0 $500. ;
    informat date0934_se2_0b2 yymmdd10. ;
    informat mouthwash_se best32. ;
    informat compliant_with_mouthwash_se best32. ;
    informat reviewed_no_viagra_se best32. ;
    informat dietary_restrictions_se best32. ;
    informat headache_se best32. ;
    informat dizziness_se best32. ;
    informat lightheadedness_se best32. ;
    informat low_blood_pressure_90_se best32. ;
    informat stomach_ache_diarrhea_se best32. ;
    informat increased_shortness_se best32. ;
    informat flushing_se best32. ;
    informat rash_se best32. ;
    informat changes_in_blood_pressure_se best32. ;
    informat swelling_se best32. ;
    informat fatigue_se best32. ;
    informat other_symptoms_se best32. ;
    informat comments_se $5000. ;
    informat performed_by776_se $500. ;
    informat date0934_se yymmdd10. ;
    informat med_regimen_change best32. ;
    informat med_regimen_change_dscr $5000. ;
    informat phys_by_se $500. ;
    informat phys_date_se yymmdd10. ;
    informat form_p1_se best32. ;
    informat side_effect_assessme_v_3 best32. ;
    informat na_form_devices best32. ;
    informat device_given best32. ;
    informat device_given_date yymmdd10. ;
    informat device_given_time time5. ;
    informat aurora_id $500. ;
    informat actigraph_id $500. ;
    informat devices_mailed best32. ;
    informat aurora_mailed $500. ;
    informat actigraph_mailed $500. ;
    informat date_device_mailed yymmdd10. ;
    informat device_mailed time5. ;
    informat date_device_receiv yymmdd10. ;
    informat time_reciev time5. ;
    informat date_aurora_on yymmdd10. ;
    informat time_aurora_on time5. ;
    informat date_aurora_off yymmdd10. ;
    informat time_aurora_off time5. ;
    informat date_actigraph_on yymmdd10. ;
    informat time_actigraph_on time5. ;
    informat date_actigraph_off yymmdd10. ;
    informat time_actigraph_off time5. ;
    informat date_returned yymmdd10. ;
    informat device_notes $5000. ;
    informat perf_by_dev $500. ;
    informat dev_date yymmdd10. ;
    informat form_devices_complete best32. ;
    informat obs_notes_yn best32. ;
    informat obs_notes $5000. ;
    informat observationsnotes_complete best32. ;

    format study_id $500. ;
    format redcap_event_name $500. ;
    format na_form_el best12. ;
    format data_obtained_yn best12. ;
    format heart_failure best12. ;
    format nyha_class $500. ;
    format lv_ejection best12. ;
    format lvef $500. ;
    format study_type $500. ;
    format date1 yymmdd10. ;
    format medical_therapy best12. ;
    format filling_pressures best12. ;
    format mitral_ratio best12. ;
    format left_atrium best12. ;
    format index $500. ;
    format date2 yymmdd10. ;
    format chronic_loop best12. ;
    format drug_dose $500. ;
    format natriuretic_peptides best12. ;
    format bnp_level $500. ;
    format date3 yymmdd10. ;
    format either_lateral best12. ;
    format capillary_wedge best12. ;
    format value $500. ;
    format date4 yymmdd10. ;
    format iv_diuretics best12. ;
    format date5 yymmdd10. ;
    format location $500. ;
    format verified_by $500. ;
    format date6 yymmdd10. ;
    format supine_systolic best12. ;
    format supine_sys1 $500. ;
    format supine_dia1 $500. ;
    format pregnancy best12. ;
    format orthostatic_hypotension best12. ;
    format supine_sys2 $500. ;
    format supine_dia2 $500. ;
    format standing_sys1 $500. ;
    format standing_dia1 $500. ;
    format native_conduction best12. ;
    format hemoglobin best12. ;
    format baseline_labs $500. ;
    format inability_exercise best12. ;
    format valvular_disease best12. ;
    format hypertrophic best12. ;
    format pericardial_disease best12. ;
    format current_angina best12. ;
    format coronary_syndrome best12. ;
    format primary_pulmonary best12. ;
    format chronic_obstructive best12. ;
    format stress_testing best12. ;
    format ventricular_ejection best12. ;
    format phosphodiesterase best12. ;
    format organic_nitrates best12. ;
    format liver_disease best12. ;
    format alt $500. ;
    format ast $500. ;
    format alb $500. ;
    format egfr best12. ;
    format baseline_egfr $500. ;
    format g6pd_deficiency best12. ;
    format methemoglobinemia best12. ;
    format methemoglobin $500. ;
    format hyperkalemia_serum best12. ;
    format hyperkalemia $500. ;
    format ventricular_dysfunction best12. ;
    format medical_condition best12. ;
    format contraindications_to_mri best12. ;
    format intra_luminal_implant best12. ;
    format life_assist_device best12. ;
    format vascular_clip best12. ;
    format visceral_organs best12. ;
    format intracranial_implants best12. ;
    format non_removable_piercings best12. ;
    format personal_history best12. ;
    format radiologic_evaluation best12. ;
    format comments_form_el $5000. ;
    format verified_by1 $500. ;
    format date7 yymmdd10. ;
    format form_el_complete best12. ;
    format na_form_bl_cl best12. ;
    format consent_yn best12. ;
    format consent_ini $500. ;
    format urine_yn best12. ;
    format urine_radio best12. ;
    format urine_ini $500. ;
    format diet_yn best12. ;
    format diet_ini $500. ;
    format vital_yn best12. ;
    format vital_ini $500. ;
    format mw6_yn best12. ;
    format mw6_ini $500. ;
    format quality_yn best12. ;
    format quality_ini $500. ;
    format cognitive_test_yn best12. ;
    format cognitive_test_ini $500. ;
    format blood_yn best12. ;
    format blood_ini $500. ;
    format g6pd_yn best12. ;
    format g6pd_ini $500. ;
    format art_tono_yn best12. ;
    format art_tono_ini $500. ;
    format echo_yn best12. ;
    format echo_ini $500. ;
    format ekg_bl best12. ;
    format ekg_initials_bl $500. ;
    format labs_yn best12. ;
    format hemo_yn best12. ;
    format hemo_value $500. ;
    format hemo_ini $500. ;
    format creati_yn best12. ;
    format creati_value $500. ;
    format creati_ini $500. ;
    format egfr_yn best12. ;
    format egfr_value $500. ;
    format egfr_ini $500. ;
    format meth_yn best12. ;
    format meth_value $500. ;
    format meth_ini $500. ;
    format potas_yn best12. ;
    format potas_value $500. ;
    format potas_ini $500. ;
    format ntpro_yn best12. ;
    format ntpro_value $500. ;
    format ntpro_initials $500. ;
    format med_dis_yn best12. ;
    format med_dis_ini $500. ;
    format bl_ch_name $500. ;
    format bl_ch_date $500. ;
    format form_bl_cl_complete best12. ;
    format na_form_6wk_cl best12. ;
    format urine_pregnancy_test best12. ;
    format urine_pregnancy_results best12. ;
    format urine_pregnancy_ini $500. ;
    format dietary_questionnaire best12. ;
    format dietary_questionnaire_ini $500. ;
    format physical_exam best12. ;
    format physical_exam_ini $500. ;
    format orthostatics best12. ;
    format orthostatics_ini $500. ;
    format vital_signs best12. ;
    format vital_signs_ini $500. ;
    format questionnaires_kccq best12. ;
    format questionnaires_kccq_ini $500. ;
    format potential_side_effects best12. ;
    format potential_side_effects_ini $500. ;
    format cognitive_test2_yn best12. ;
    format congitive_test2_ini $500. ;
    format blood_draws_before best12. ;
    format blood_draws_before_ini $500. ;
    format light_breakfast best12. ;
    format light_breakfast_ini $500. ;
    format blood_draws_after best12. ;
    format blood_draws_after_ini $500. ;
    format arterial_tonometry best12. ;
    format arterial_tonometry_ini $500. ;
    format doppler_echocardiogram best12. ;
    format doppler_echocardiogram_ini $500. ;
    format ekg_p1 best12. ;
    format ekg_initials_p1 $500. ;
    format bicycle_exercise_test best12. ;
    format bicycle_exercise_test_ini $500. ;
    format muscle_mri best12. ;
    format muscle_mri_ini $500. ;
    format medication_dispensed best12. ;
    format stage_2_meds_ini $500. ;
    format stage_2_meds best12. ;
    format stage_1_meds_ini $500. ;
    format stage_1_meds best12. ;
    format pill_count_ini $500. ;
    format pill_count_yn best12. ;
    format pill_count_ini2_d9f $500. ;
    format cardiac_mri_performed_p1 best12. ;
    format cardiac_mri_initials_p1 $500. ;
    format date_6wk_cl_p1 yymmdd10. ;
    format signature_6wk_cl_p1 $500. ;
    format form_6wk_cl_complete best12. ;
    format na_form_6wk_cl_p2 best12. ;
    format urine_pregnancy_test_p2 best12. ;
    format urine_pregnancy_results_p2 best12. ;
    format urine_pregnancy_ini_p2 $500. ;
    format dietary_questionnaire_p2 best12. ;
    format dietary_questionnaire_ini_p2 $500. ;
    format physical_exam_p2 best12. ;
    format physical_exam_ini_p2 $500. ;
    format orthostatics_p2 best12. ;
    format orthostatics_ini_p2 $500. ;
    format vital_signs_p2 best12. ;
    format vital_signs_ini_p2 $500. ;
    format questionnaires_kccq_p2 best12. ;
    format questionnaires_kccq_ini_p2 $500. ;
    format potential_side_effects_p2 best12. ;
    format potential_side_effects_ini_p2 $500. ;
    format cognitive_test3_yn best12. ;
    format cognitive_test3_ini $500. ;
    format blood_draws_before_p2 best12. ;
    format blood_draws_before_ini_p2 $500. ;
    format light_breakfast_p2 best12. ;
    format light_breakfast_ini_p2 $500. ;
    format blood_draws_after_p2 best12. ;
    format blood_draws_after_ini_p2 $500. ;
    format arterial_tonometry_p2 best12. ;
    format arterial_tonometry_ini_p2 $500. ;
    format doppler_echocardiogram_p2 best12. ;
    format doppler_echocardiogram_ini_p2 $500. ;
    format ekg_p2 best12. ;
    format ekg_initials_p2 $500. ;
    format bicycle_exercise_test_p2 best12. ;
    format bicycle_exercise_test_ini_p2 $500. ;
    format muscle_mri_p2 best12. ;
    format muscle_mri_ini_p2 $500. ;
    format stage_1_meds_p2 best12. ;
    format pill_count_ini_p2 $500. ;
    format pill_count_yn_p2 best12. ;
    format pill_count_ini2_d9f_p2 $500. ;
    format cardiac_mri_initials_p2 best12. ;
    format cardiac_mri_initials_phase_2 $500. ;
    format form_bl_cl_cmplt_p2 best12. ;
    format medication_dispensed_p2 best12. ;
    format stage_2_meds_ini_p2 $500. ;
    format name_6wk_cl_p2 $500. ;
    format date_6wk_cl_p2 yymmdd10. ;
    format signature_6wk_cl_p2 $500. ;
    format form_6wk_cl_p2_complete best12. ;
    format na_form_6wk_mri best12. ;
    format mri_safety_checklist best12. ;
    format initials $500. ;
    format field_strength1 best12. ;
    format load_used1 $500. ;
    format number_of_repetitions best12. ;
    format repetitions_oth $500. ;
    format load_used_psi $500. ;
    format number_of_repetitions1 best12. ;
    format other_asl $500. ;
    format comments $5000. ;
    format data_exported best12. ;
    format sig $500. ;
    format date98 yymmdd10. ;
    format complete_mri best12. ;
    format form_6wk_mri_complete best12. ;
    format na_form_cardiac_mri best12. ;
    format form_mri_enrolled best12. ;
    format form_mri_reviewed best12. ;
    format form_mri_performed $500. ;
    format form_mri_time time5. ;
    format form_mri_hr best12. ;
    format form_mri_systolic best12. ;
    format form_mri_diastolic best12. ;
    format form_mri_weight best12. ;
    format form_mri_weight_units best12. ;
    format mri_form_weight_other $5000. ;
    format form_mri_basis1 best12. ;
    format form_mri_basis2 best12. ;
    format form_mri_meds best12. ;
    format form_mri_stable best12. ;
    format form_mri_beta_blockers best12. ;
    format form_mri_nitrates best12. ;
    format form_mri_base_ecg $5000. ;
    format form_mri_comment $5000. ;
    format form_mri_post_time time5. ;
    format form_mri_post_hr best12. ;
    format form_mri_post_systolic best12. ;
    format form_mri_post_diastolic best12. ;
    format form_mri_post_ecg $5000. ;
    format form_mri_post_reported best12. ;
    format form_mri_post_symptoms $5000. ;
    format form_mri_post_discharge best12. ;
    format form_cardiac_mri_complete best12. ;
    format na_form_mh best12. ;
    format penn_chart best12. ;
    format age best12. ;
    format gender best12. ;
    format race___1 best12. ;
    format race___2 best12. ;
    format race___3 best12. ;
    format race___4 best12. ;
    format race___5 best12. ;
    format race___6 best12. ;
    format race_oth $5000. ;
    format type_decent best12. ;
    format acutecoronary best12. ;
    format acutecoronary_ai $5000. ;
    format prior_angina best12. ;
    format prior_angina_ai $5000. ;
    format any_arrhythmia best12. ;
    format any_arrhythmia_ai $5000. ;
    format valv_disease_surgery best12. ;
    format valv_disease_surgery_ai $5000. ;
    format htn best12. ;
    format htn_ai $5000. ;
    format high_cholesterol best12. ;
    format high_cholesterol_ai $5000. ;
    format peripheral_vascular best12. ;
    format peripheral_vascular_ai $5000. ;
    format diabetes best12. ;
    format diabetes_ai $5000. ;
    format insulin best12. ;
    format insulin_ai $5000. ;
    format cva_tia best12. ;
    format cva_tia_ai $5000. ;
    format pulmonary_embolism_dvt best12. ;
    format pulmonary_embolism_dvt_ai $5000. ;
    format osa best12. ;
    format osa_ai $5000. ;
    format cpap best12. ;
    format cpap_ai $5000. ;
    format copd_asthma best12. ;
    format copd_asthma_ai $5000. ;
    format osteoarthritis best12. ;
    format osteoarthritis_ai $5000. ;
    format other_conditions $5000. ;
    format other_conditions_ai $5000. ;
    format cabg best12. ;
    format cabg_ai $5000. ;
    format peripheral best12. ;
    format peripheral_ai $5000. ;
    format valvular_surgery best12. ;
    format valvular_ai $5000. ;
    format congenital_surgery best12. ;
    format congenital_surgery_ai $5000. ;
    format trauma_requiring_surgery best12. ;
    format trauma_req_surgery_ai $5000. ;
    format other_surgeries $5000. ;
    format current_smoker best12. ;
    format pack_years best12. ;
    format prior_smoker best12. ;
    format prior_smoker_ai $5000. ;
    format current_alcohol best12. ;
    format drinks_day best12. ;
    format drinks_add_info $5000. ;
    format prior_alcohol best12. ;
    format prior_alcohol_ai $5000. ;
    format recreational_drug_use best12. ;
    format recreational_drug_usead $5000. ;
    format occupation_yn best12. ;
    format occupation $5000. ;
    format signature $500. ;
    format date9 yymmdd10. ;
    format nyhaclass best12. ;
    format orthopnea best12. ;
    format paroxysmal_nocturnal best12. ;
    format lower_extremity_edema best12. ;
    format num_of_stairs best12. ;
    format reason_for_stopping $5000. ;
    format distance best12. ;
    format block_miles best12. ;
    format distance_other $5000. ;
    format stop_walk $5000. ;
    format crvalue best12. ;
    format crdate yymmdd10. ;
    format egfr_value2 best12. ;
    format egfr_date yymmdd10. ;
    format nt_pro_bnp_value best12. ;
    format nt_pro_bnp_date yymmdd10. ;
    format hemoglobin_value best12. ;
    format hemoglobin_date yymmdd10. ;
    format hematocrit_value best12. ;
    format hematocrit_date yymmdd10. ;
    format hemoglobin_a1c_value best12. ;
    format hemoglobin_a1c_date yymmdd10. ;
    format other_lab_data $5000. ;
    format cholesterol_total best12. ;
    format cholesterol_total_date yymmdd10. ;
    format triglycerides_value best12. ;
    format triglycerides_date yymmdd10. ;
    format hdl_cholesterol best12. ;
    format hdl_cholesterol_date yymmdd10. ;
    format ldl best12. ;
    format ldl_date yymmdd10. ;
    format vldl best12. ;
    format vldl_date yymmdd10. ;
    format non_hdl best12. ;
    format non_hdl_date yymmdd10. ;
    format prev_hrt_catheter best12. ;
    format pcwp_12 best12. ;
    format lvedp_16 best12. ;
    format hrt_catheter_date yymmdd10. ;
    format pcwp_value best12. ;
    format lvedp_value best12. ;
    format prior_stress_test best12. ;
    format stress_test_date yymmdd10. ;
    format stress_test_result $500. ;
    format comments_stress_test $5000. ;
    format allergies $5000. ;
    format performed_by_date yymmdd10. ;
    format performed_by_signature $500. ;
    format form_mh_complete best12. ;
    format datetime_seconds1 $500. ;
    format na_form_lab_pre_medication best12. ;
    format iv_line_required_1 best12. ;
    format iv_time_1 time5. ;
    format gauge_1 $500. ;
    format site_1 $500. ;
    format preg_test best12. ;
    format cmp_gold best12. ;
    format pax_gene best12. ;
    format nt_pro best12. ;
    format form_lab_methemoglobin best12. ;
    format form_lab_cbc best12. ;
    format g6pd_test best12. ;
    format urine_cc best12. ;
    format plasma_purp best12. ;
    format serum_red best12. ;
    format saliva_tube best12. ;
    format notes_pm $5000. ;
    format perf_by_lab $500. ;
    format date_lab yymmdd10. ;
    format form_lab_6412_complete best12. ;
    format na_form_lab_peak_bike best12. ;
    format iv_time_1_v3 time5. ;
    format complete_lab_v3 best12. ;
    format plasma_bike best12. ;
    format serum_bike best12. ;
    format notes_pb $5000. ;
    format form_lab_pre_medicat_v_0 best12. ;
    format na_form_lab_post_med best12. ;
    format iv_time_1_v2 time5. ;
    format complete_lab_v2 best12. ;
    format urine_post best12. ;
    format plasma_post best12. ;
    format serum_post best12. ;
    format saliva_post best12. ;
    format notes_2hr $5000. ;
    format form_lab_pre_medicat_v_1 best12. ;
    format na_physical_exam best12. ;
    format form_pe_obtained best12. ;
    format height_2 best12. ;
    format height_2_units best12. ;
    format weight_2 best12. ;
    format weight_2_units best12. ;
    format systolic_2 best12. ;
    format diastolic_2 best12. ;
    format blood_pressure_arm_2 best12. ;
    format heart_rate_2 best12. ;
    format o2_saturation_2 best12. ;
    format hr $500. ;
    format rr_2 best12. ;
    format jvp_2 best12. ;
    format jvp_category $500. ;
    format ekg best12. ;
    format heart_2 $5000. ;
    format lungs_2 $5000. ;
    format abd_2 $5000. ;
    format extremities_2 $5000. ;
    format additional_notes_pe $5000. ;
    format extrem_performed $500. ;
    format extremities_date yymmdd10. ;
    format extremities_signature $500. ;
    format sup_systolic_2 best12. ;
    format sup_diastolic_2 best12. ;
    format stan_systolic_2 best12. ;
    format stan_diastolic_2 best12. ;
    format orthostatic_symptoms_yn best12. ;
    format ortho_sympt_descr $5000. ;
    format comments_phy $5000. ;
    format sars_yn best12. ;
    format sars_vaccine $5000. ;
    format sars_dose_date $5000. ;
    format sars_notes $5000. ;
    format phys_by $500. ;
    format phys_date yymmdd10. ;
    format form_pe_complete best12. ;
    format na_end_phase_se_review best12. ;
    format mouthwash_se_ep best12. ;
    format compliant_with_mouthwash_se_ep best12. ;
    format reviewed_no_viagra_se_ep best12. ;
    format dietary_restrictions_se_ep best12. ;
    format headache_se_ep best12. ;
    format dizziness_se_ep best12. ;
    format lightheadedness_se_ep best12. ;
    format low_blood_pressure_90_se_ep best12. ;
    format stomach_ache_diarrhea_se_ep best12. ;
    format increased_shortness_se_ep best12. ;
    format flushing_se_ep best12. ;
    format rash_se_ep best12. ;
    format ch_in_blood_pressure_se_ep best12. ;
    format swelling_se_ep best12. ;
    format fatigue_se_assess best12. ;
    format other_symps_se best12. ;
    format orthostat_se_ep best12. ;
    format orthostat_se_dscr_ep $5000. ;
    format performed_by776_se_ep $500. ;
    format phys_date_se_ep yymmdd10. ;
    format form_p1_se_ep best12. ;
    format end_phase_side_effec_v_2 best12. ;
    format na_form_mh_p1_p2 best12. ;
    format penn_chart_6p best12. ;
    format age_6p best12. ;
    format gender_6p best12. ;
    format race_6p___1 best12. ;
    format race_6p___2 best12. ;
    format race_6p___3 best12. ;
    format race_6p___4 best12. ;
    format race_6p___5 best12. ;
    format race_6p___6 best12. ;
    format race_oth_6p $500. ;
    format type_decent_6p best12. ;
    format acutecoronary_6p best12. ;
    format acutecoronary_ai_6p $500. ;
    format prior_angina_6p best12. ;
    format prior_angina_ai_6p $500. ;
    format any_arrhythmia_6p best12. ;
    format any_arrhythmia_ai_6p $500. ;
    format valv_disease_surgery_6p best12. ;
    format valv_disease_surgery_ai_6p $500. ;
    format htn_6p best12. ;
    format htn_ai_6p $500. ;
    format high_cholesterol_6p best12. ;
    format high_cholesterol_ai_6p $500. ;
    format peripheral_vascular_6p best12. ;
    format peripheral_vascular_ai_6p $500. ;
    format diabetes_6p best12. ;
    format diabetes_ai_6p $500. ;
    format insulin_6p best12. ;
    format insulin_ai_6p $500. ;
    format cva_tia_6p best12. ;
    format cva_tia_ai_6p $500. ;
    format pulmonary_embolism_dvt_6p best12. ;
    format pulmonary_embolism_dvt_ai_6p $500. ;
    format osa_6p best12. ;
    format osa_ai_6p $500. ;
    format cpap_6p best12. ;
    format cpap_ai_6p $500. ;
    format copd_asthma_6p best12. ;
    format copd_asthma_ai_6p $500. ;
    format osteoarthritis_6p best12. ;
    format osteoarthritis_ai_6p $500. ;
    format other_conditions_6p $500. ;
    format other_conditions_ai_6p $500. ;
    format cabg_6p best12. ;
    format cabg_ai_6p $500. ;
    format peripheral_6p best12. ;
    format peripheral_ai_6p $500. ;
    format valvular_surgery_6p best12. ;
    format valvular_ai_6p $500. ;
    format congenital_surgery_6p best12. ;
    format congenital_surgery_ai_6p $500. ;
    format trauma_requiring_surgery_6p best12. ;
    format trauma_req_surgery_ai_6p $500. ;
    format other_surgeries_6p $500. ;
    format current_smoker_6p best12. ;
    format pack_years_6p best12. ;
    format prior_smoker_6p best12. ;
    format prior_smoker_ai_6p $500. ;
    format current_alcohol_6p best12. ;
    format drinks_day_6p best12. ;
    format prior_alcohol_6p best12. ;
    format prior_alcohol_ai_6p $500. ;
    format recreational_drug_use_6p best12. ;
    format recreational_drug_usead_6p $500. ;
    format occupation_6p $500. ;
    format signature_6p $500. ;
    format date9_6p yymmdd10. ;
    format nyhaclass_6p best12. ;
    format orthopnea_6p best12. ;
    format paroxysmal_nocturnal_6p best12. ;
    format lower_extremity_edema_6p best12. ;
    format num_of_stairs_6p best12. ;
    format reason_for_stopping_6p $500. ;
    format distance_6p best12. ;
    format block_miles_6p best12. ;
    format stop_walk_6p $500. ;
    format crvalue_6p best12. ;
    format crdate_6p yymmdd10. ;
    format egfr_value2_6p best12. ;
    format egfr_date_6p yymmdd10. ;
    format nt_pro_bnp_value_6p best12. ;
    format nt_pro_bnp_date_6p yymmdd10. ;
    format hemoglobin_value_6p best12. ;
    format hemoglobin_date_6p yymmdd10. ;
    format hematocrit_value_6p best12. ;
    format hematocrit_date_6p yymmdd10. ;
    format hemoglobin_a1c_value_6p best12. ;
    format hemoglobin_a1c_date_6p yymmdd10. ;
    format other_lab_data_6p $500. ;
    format prev_hrt_catheter_6p best12. ;
    format hrt_catheter_date_6p yymmdd10. ;
    format pcwp_12_6p best12. ;
    format pcwp_value_6p best12. ;
    format lvedp_16_6p best12. ;
    format lvedp_value_6p best12. ;
    format prior_stress_test_6p best12. ;
    format stress_test_date_6p yymmdd10. ;
    format stress_test_result_6p $500. ;
    format comments_stress_test_6p $5000. ;
    format allergies_6p $500. ;
    format performed_by_date_6p yymmdd10. ;
    format performed_by_signature_6p $500. ;
    format bl_mh_cmplt_6p best12. ;
    format form_mh_8174_complete best12. ;
    format na_medications best12. ;
    format date_med yymmdd10. ;
    format num_med best12. ;
    format meds_1 best12. ;
    format med_oth_1 $500. ;
    format dose_1 best12. ;
    format comb_dose_1 best12. ;
    format units_1 best12. ;
    format units_oth_1 $500. ;
    format freq_1 best12. ;
    format freq_oth_1 $500. ;
    format route_1 best12. ;
    format route_oth_1 $500. ;
    format recent_start_date_1 best12. ;
    format start_date_1 yymmdd10. ;
    format recent_end_date_1 best12. ;
    format end_date_1 yymmdd10. ;
    format meds_2 best12. ;
    format med_oth_2 $500. ;
    format dose_2 best12. ;
    format comb_dose_2 best12. ;
    format units_2 best12. ;
    format units_oth_2 $500. ;
    format freq_2 best12. ;
    format freq_oth_2 $500. ;
    format route_2 best12. ;
    format route_oth_2 $500. ;
    format recent_start_date_2 best12. ;
    format start_date_2 yymmdd10. ;
    format recent_end_date_2 best12. ;
    format end_date_2 yymmdd10. ;
    format meds_3 best12. ;
    format med_oth_3 $500. ;
    format dose_3 best12. ;
    format comb_dose_3 best12. ;
    format units_3 best12. ;
    format units_oth_3 $500. ;
    format freq_3 best12. ;
    format freq_oth_3 $500. ;
    format route_3 best12. ;
    format route_oth_3 $500. ;
    format recent_start_date_3 best12. ;
    format start_date_3 yymmdd10. ;
    format recent_end_date_3 best12. ;
    format end_date_3 yymmdd10. ;
    format meds_4 best12. ;
    format med_oth_4 $500. ;
    format dose_4 best12. ;
    format comb_dose_4 best12. ;
    format units_4 best12. ;
    format units_oth_4 $500. ;
    format freq_4 best12. ;
    format freq_oth_4 $500. ;
    format route_4 best12. ;
    format route_oth_4 $500. ;
    format recent_start_date_4 best12. ;
    format start_date_4 yymmdd10. ;
    format recent_end_date_4 best12. ;
    format end_date_4 yymmdd10. ;
    format meds_5 best12. ;
    format med_oth_5 $500. ;
    format dose_5 best12. ;
    format comb_dose_5 best12. ;
    format units_5 best12. ;
    format units_oth_5 $500. ;
    format freq_5 best12. ;
    format freq_oth_5 $500. ;
    format route_5 best12. ;
    format route_oth_5 $500. ;
    format recent_start_date_5 best12. ;
    format start_date_5 yymmdd10. ;
    format recent_end_date_5 best12. ;
    format end_date_5 yymmdd10. ;
    format meds_6 best12. ;
    format med_oth_6 $500. ;
    format dose_6 best12. ;
    format comb_dose_6 best12. ;
    format units_6 best12. ;
    format units_oth_6 $500. ;
    format freq_6 best12. ;
    format freq_oth_6 $500. ;
    format route_6 best12. ;
    format route_oth_6 $500. ;
    format recent_start_date_6 best12. ;
    format start_date_6 yymmdd10. ;
    format recent_end_date_6 best12. ;
    format end_date_6 yymmdd10. ;
    format meds_7 best12. ;
    format med_oth_7 $500. ;
    format dose_7 best12. ;
    format comb_dose_7 best12. ;
    format units_7 best12. ;
    format units_oth_7 $500. ;
    format freq_7 best12. ;
    format freq_oth_7 $500. ;
    format route_7 best12. ;
    format route_oth_7 $500. ;
    format recent_start_date_7 best12. ;
    format start_date_7 yymmdd10. ;
    format recent_end_date_7 best12. ;
    format end_date_7 yymmdd10. ;
    format meds_8 best12. ;
    format med_oth_8 $500. ;
    format dose_8 best12. ;
    format comb_dose_8 best12. ;
    format units_8 best12. ;
    format units_oth_8 $500. ;
    format freq_8 best12. ;
    format freq_oth_8 $500. ;
    format route_8 best12. ;
    format route_oth_8 $500. ;
    format recent_start_date_8 best12. ;
    format start_date_8 yymmdd10. ;
    format recent_end_date_8 best12. ;
    format end_date_8 yymmdd10. ;
    format meds_9 best12. ;
    format med_oth_9 $500. ;
    format dose_9 best12. ;
    format comb_dose_9 best12. ;
    format units_9 best12. ;
    format units_oth_9 $500. ;
    format freq_9 best12. ;
    format freq_oth_9 $500. ;
    format route_9 best12. ;
    format route_oth_9 $500. ;
    format recent_start_date_9 best12. ;
    format start_date_9 yymmdd10. ;
    format recent_end_date_9 best12. ;
    format end_date_9 yymmdd10. ;
    format meds_10 best12. ;
    format med_oth_10 $500. ;
    format dose_10 best12. ;
    format comb_dose_10 best12. ;
    format units_10 best12. ;
    format units_oth_10 $500. ;
    format freq_10 best12. ;
    format freq_oth_10 $500. ;
    format route_10 best12. ;
    format route_oth_10 $500. ;
    format recent_start_date_10 best12. ;
    format start_date_10 yymmdd10. ;
    format recent_end_date_10 best12. ;
    format end_date_10 yymmdd10. ;
    format meds_11 best12. ;
    format med_oth_11 $500. ;
    format dose_11 best12. ;
    format comb_dose_11 best12. ;
    format units_11 best12. ;
    format units_oth_11 $500. ;
    format freq_11 best12. ;
    format freq_oth_11 $500. ;
    format route_11 best12. ;
    format route_oth_11 $500. ;
    format recent_start_date_11 best12. ;
    format start_date_11 yymmdd10. ;
    format recent_end_date_11 best12. ;
    format end_date_11 yymmdd10. ;
    format meds_12 best12. ;
    format med_oth_12 $500. ;
    format dose_12 best12. ;
    format comb_dose_12 best12. ;
    format units_12 best12. ;
    format units_oth_12 $500. ;
    format freq_12 best12. ;
    format freq_oth_12 $500. ;
    format route_12 best12. ;
    format route_oth_12 $500. ;
    format recent_start_date_12 best12. ;
    format start_date_12 yymmdd10. ;
    format recent_end_date_12 best12. ;
    format end_date_12 yymmdd10. ;
    format meds_13 best12. ;
    format med_oth_13 $500. ;
    format dose_13 best12. ;
    format comb_dose_13 best12. ;
    format units_13 best12. ;
    format units_oth_13 $500. ;
    format freq_13 best12. ;
    format freq_oth_13 $500. ;
    format route_13 best12. ;
    format route_oth_13 $500. ;
    format recent_start_date_13 best12. ;
    format start_date_13 yymmdd10. ;
    format recent_end_date_13 best12. ;
    format end_date_13 yymmdd10. ;
    format meds_14 best12. ;
    format med_oth_14 $500. ;
    format dose_14 best12. ;
    format comb_dose_14 best12. ;
    format units_14 best12. ;
    format units_oth_14 $500. ;
    format freq_14 best12. ;
    format freq_oth_14 $500. ;
    format route_14 best12. ;
    format route_oth_14 $500. ;
    format recent_start_date_14 best12. ;
    format start_date_14 yymmdd10. ;
    format recent_end_date_14 best12. ;
    format end_date_14 yymmdd10. ;
    format meds_15 best12. ;
    format med_oth_15 $500. ;
    format dose_15 best12. ;
    format comb_dose_15 best12. ;
    format units_15 best12. ;
    format units_oth_15 $500. ;
    format freq_15 best12. ;
    format freq_oth_15 $500. ;
    format route_15 best12. ;
    format route_oth_15 $500. ;
    format recent_start_date_15 best12. ;
    format start_date_15 yymmdd10. ;
    format recent_end_date_15 best12. ;
    format end_date_15 yymmdd10. ;
    format meds_16 best12. ;
    format med_oth_16 $500. ;
    format dose_16 best12. ;
    format comb_dose_16 best12. ;
    format units_16 best12. ;
    format units_oth_16 $500. ;
    format freq_16 best12. ;
    format freq_oth_16 $500. ;
    format route_16 best12. ;
    format route_oth_16 $500. ;
    format recent_start_date_16 best12. ;
    format start_date_16 yymmdd10. ;
    format recent_end_date_16 best12. ;
    format end_date_16 yymmdd10. ;
    format meds_17 best12. ;
    format med_oth_17 $500. ;
    format dose_17 best12. ;
    format comb_dose_17 best12. ;
    format units_17 best12. ;
    format units_oth_17 $500. ;
    format freq_17 best12. ;
    format freq_oth_17 $500. ;
    format route_17 best12. ;
    format route_oth_17 $500. ;
    format recent_start_date_17 best12. ;
    format start_date_17 yymmdd10. ;
    format recent_end_date_17 best12. ;
    format end_date_17 yymmdd10. ;
    format meds_18 best12. ;
    format med_oth_18 $500. ;
    format dose_18 best12. ;
    format comb_dose_18 best12. ;
    format units_18 best12. ;
    format units_oth_18 $500. ;
    format freq_18 best12. ;
    format freq_oth_18 $500. ;
    format route_18 best12. ;
    format route_oth_18 $500. ;
    format recent_start_date_18 best12. ;
    format start_date_18 yymmdd10. ;
    format recent_end_date_18 best12. ;
    format end_date_18 yymmdd10. ;
    format meds_19 best12. ;
    format med_oth_19 $500. ;
    format dose_19 best12. ;
    format comb_dose_19 best12. ;
    format units_19 best12. ;
    format units_oth_19 $500. ;
    format freq_19 best12. ;
    format freq_oth_19 $500. ;
    format route_19 best12. ;
    format route_oth_19 $500. ;
    format recent_start_date_19 best12. ;
    format start_date_19 yymmdd10. ;
    format recent_end_date_19 best12. ;
    format end_date_19 yymmdd10. ;
    format meds_20 best12. ;
    format med_oth_20 $500. ;
    format dose_20 best12. ;
    format comb_dose_20 best12. ;
    format units_20 best12. ;
    format units_oth_20 $500. ;
    format freq_20 best12. ;
    format freq_oth_20 $500. ;
    format route_20 best12. ;
    format route_oth_20 $500. ;
    format recent_start_date_20 best12. ;
    format start_date_20 yymmdd10. ;
    format recent_end_date_20 best12. ;
    format end_date_20 yymmdd10. ;
    format meds_21 best12. ;
    format med_oth_21 $500. ;
    format dose_21 best12. ;
    format comb_dose_21 best12. ;
    format units_21 best12. ;
    format units_oth_21 $500. ;
    format freq_21 best12. ;
    format freq_oth_21 $500. ;
    format route_21 best12. ;
    format route_oth_21 $500. ;
    format recent_start_date_21 best12. ;
    format start_date_21 yymmdd10. ;
    format recent_end_date_21 best12. ;
    format end_date_21 yymmdd10. ;
    format meds_22 best12. ;
    format med_oth_22 $500. ;
    format dose_22 best12. ;
    format comb_dose_22 best12. ;
    format units_22 best12. ;
    format units_oth_22 $500. ;
    format freq_22 best12. ;
    format freq_oth_22 $500. ;
    format route_22 best12. ;
    format route_oth_22 $500. ;
    format recent_start_date_22 best12. ;
    format start_date_22 yymmdd10. ;
    format recent_end_date_22 best12. ;
    format end_date_22 yymmdd10. ;
    format meds_23 best12. ;
    format med_oth_23 $500. ;
    format dose_23 best12. ;
    format comb_dose_23 best12. ;
    format units_23 best12. ;
    format units_oth_23 $500. ;
    format freq_23 best12. ;
    format freq_oth_23 $500. ;
    format route_23 best12. ;
    format route_oth_23 $500. ;
    format recent_start_date_23 best12. ;
    format start_date_23 yymmdd10. ;
    format recent_end_date_23 best12. ;
    format end_date_23 yymmdd10. ;
    format meds_24 best12. ;
    format med_oth_24 $500. ;
    format dose_24 best12. ;
    format comb_dose_24 best12. ;
    format units_24 best12. ;
    format units_oth_24 $500. ;
    format freq_24 best12. ;
    format freq_oth_24 $500. ;
    format route_24 best12. ;
    format route_oth_24 $500. ;
    format recent_start_date_24 best12. ;
    format start_date_24 yymmdd10. ;
    format recent_end_date_24 best12. ;
    format end_date_24 yymmdd10. ;
    format meds_25 best12. ;
    format med_oth_25 $500. ;
    format dose_25 best12. ;
    format comb_dose_25 best12. ;
    format units_25 best12. ;
    format units_oth_25 $500. ;
    format freq_25 best12. ;
    format freq_oth_25 $500. ;
    format route_25 best12. ;
    format route_oth_25 $500. ;
    format recent_start_date_25 best12. ;
    format start_date_25 yymmdd10. ;
    format recent_end_date_25 best12. ;
    format end_date_25 yymmdd10. ;
    format meds_26 best12. ;
    format med_oth_26 $500. ;
    format dose_26 best12. ;
    format comb_dose_26 best12. ;
    format units_26 best12. ;
    format units_oth_26 $500. ;
    format freq_26 best12. ;
    format freq_oth_26 $500. ;
    format route_26 best12. ;
    format route_oth_26 $500. ;
    format recent_start_date_26 best12. ;
    format start_date_26 yymmdd10. ;
    format recent_end_date_26 best12. ;
    format end_date_26 yymmdd10. ;
    format meds_27 best12. ;
    format med_oth_27 $500. ;
    format dose_27 best12. ;
    format comb_dose_27 best12. ;
    format units_27 best12. ;
    format units_oth_27 $500. ;
    format freq_27 best12. ;
    format freq_oth_27 $500. ;
    format route_27 best12. ;
    format route_oth_27 $500. ;
    format recent_start_date_27 best12. ;
    format start_date_27 yymmdd10. ;
    format recent_end_date_27 best12. ;
    format end_date_27 yymmdd10. ;
    format meds_28 best12. ;
    format med_oth_28 $500. ;
    format dose_28 best12. ;
    format comb_dose_28 best12. ;
    format units_28 best12. ;
    format units_oth_28 $500. ;
    format freq_28 best12. ;
    format freq_oth_28 $500. ;
    format route_28 best12. ;
    format route_oth_28 $500. ;
    format recent_start_date_28 best12. ;
    format start_date_28 yymmdd10. ;
    format recent_end_date_28 best12. ;
    format end_date_28 yymmdd10. ;
    format meds_29 best12. ;
    format med_oth_29 $500. ;
    format dose_29 best12. ;
    format comb_dose_29 best12. ;
    format units_29 best12. ;
    format units_oth_29 $500. ;
    format freq_29 best12. ;
    format freq_oth_29 $500. ;
    format route_29 best12. ;
    format route_oth_29 $500. ;
    format recent_start_date_29 best12. ;
    format start_date_29 yymmdd10. ;
    format recent_end_date_29 best12. ;
    format end_date_29 yymmdd10. ;
    format meds_30 best12. ;
    format med_oth_30 $500. ;
    format dose_30 best12. ;
    format comb_dose_30 best12. ;
    format units_30 best12. ;
    format units_oth_30 $500. ;
    format freq_30 best12. ;
    format freq_oth_30 $500. ;
    format route_30 best12. ;
    format route_oth_30 $500. ;
    format recent_start_date_30 best12. ;
    format start_date_30 yymmdd10. ;
    format recent_end_date_30 best12. ;
    format end_date_30 yymmdd10. ;
    format data_epic_med best12. ;
    format med_comments $5000. ;
    format medications_complete best12. ;
    format na_cognitive_testing best12. ;
    format shopping_test_yn best12. ;
    format gorton_test_yn best12. ;
    format detection_test_yn best12. ;
    format identification_test_yn best12. ;
    format card_test_yn best12. ;
    format one_back_test_yn best12. ;
    format delayed_recall_test_yn best12. ;
    format data_backed_up_yn best12. ;
    format cognitive_comments $5000. ;
    format form_ct_name $500. ;
    format form_ct_date yymmdd10. ;
    format signature_cog_test $500. ;
    format cognitive_testing_complete best12. ;
    format na_form_vp best12. ;
    format ult_sd_perf_1 $500. ;
    format sternal_angle_to_carotid_1 best12. ;
    format ster_carotid_1 best12. ;
    format sternal_angle_to_femoral_1 best12. ;
    format ster_femoral_1 best12. ;
    format sternal_angle_to_radial_1 best12. ;
    format ster_radial_1 best12. ;
    format sternal_length best12. ;
    format bp_collected_yn best12. ;
    format bp_study_id best12. ;
    format pb_plus_systolic $500. ;
    format bp_plus_diastolic best12. ;
    format pre_bike_systolic_1 best12. ;
    format pre_bike_diastolic_1 best12. ;
    format time_1 time5. ;
    format hr_1 best12. ;
    format map best12. ;
    format initials_1 $500. ;
    format carotid_1 best12. ;
    format carotid_tonometry $500. ;
    format carotid_vasc best12. ;
    format femora_1 best12. ;
    format femoral_tonometry $500. ;
    format femora_vasc best12. ;
    format radial_1 best12. ;
    format radial_tonometry $500. ;
    format radial_vasc best12. ;
    format lvot_flow best12. ;
    format comment_1 $5000. ;
    format form_vp_name $500. ;
    format form_vp_date yymmdd10. ;
    format form_vp_complete best12. ;
    format na_form_6mwt best12. ;
    format checklist_bl_6mwt___1 best12. ;
    format checklist_bl_6mwt___2 best12. ;
    format checklist_bl_6mwt___3 best12. ;
    format checklist_bl_6mwt___4 best12. ;
    format checklist_bl_6mwt___5 best12. ;
    format checklist_bl_6mwt___6 best12. ;
    format dyspnea_borg_score best12. ;
    format fatigue_borg_score best12. ;
    format heart_rate best12. ;
    format pulse_oximetry best12. ;
    format systolic_bf best12. ;
    format diastolic_bf best12. ;
    format pretest_instruction___1 best12. ;
    format pretest_instruction___2 best12. ;
    format post_dyspnea_borg best12. ;
    format post_fatigue_borg best12. ;
    format post_bpm best12. ;
    format post_pulse_oximetry best12. ;
    format systolic_af best12. ;
    format diastolic_af best12. ;
    format test_start_time time5. ;
    format total_meters_walked best12. ;
    format notes $5000. ;
    format perform_date yymmdd10. ;
    format perform_sig $500. ;
    format complete_6mwt best12. ;
    format form_6mwt_complete best12. ;
    format na_form_6wk_ex best12. ;
    format bicyc_1 time5. ;
    format initial_1 $500. ;
    format stage_1_yn best12. ;
    format stage_1_systolic_1 best12. ;
    format stage_1_diastolic_1 best12. ;
    format stage_1_hr_1 best12. ;
    format stage_1_o2_1 best12. ;
    format stage_1_ultras_1 best12. ;
    format stage_2_yn best12. ;
    format stage_2_systolic_1 best12. ;
    format stage_2_diastolic_1 best12. ;
    format stage_2_hr_1 best12. ;
    format stage_2_o2_1 best12. ;
    format stage_2_ultras_1 best12. ;
    format stage_3_yn best12. ;
    format stage_3_systolic_1 best12. ;
    format stage_3_diastolic_1 best12. ;
    format stage_3_hr_1 best12. ;
    format stage_3_o2_1 best12. ;
    format stage_3_ultras_1 best12. ;
    format stage_4_yn best12. ;
    format stage_4_systolic_1 best12. ;
    format stage_4_diastolic_1 best12. ;
    format stage_4_hr_1 best12. ;
    format stage_4_o2_1 best12. ;
    format stage_4_ultras_1 best12. ;
    format stage_5_yn best12. ;
    format stage_5_systolic_1 best12. ;
    format stage_5_diastolic_1 best12. ;
    format stage_5_hr_1 best12. ;
    format stage_5_o2_1 best12. ;
    format stage_5_ultras_1 best12. ;
    format stage_6_yn best12. ;
    format stage_6_systolic_1 best12. ;
    format stage_6_diastolic_1 best12. ;
    format stage_6_hr_1 best12. ;
    format stage_6_o2_1 best12. ;
    format stage_6_ults_1 best12. ;
    format stage_7_yn best12. ;
    format stage_7_systolic_1 best12. ;
    format stage_7_diastolic_1 best12. ;
    format stage_7_hr_1 best12. ;
    format stage_7_o2_1 best12. ;
    format stage_7_ultras_1 best12. ;
    format stage_8_yn best12. ;
    format stage_8_systolic_1 best12. ;
    format stage_8_diastolic_1 best12. ;
    format stage_8_hr_1 best12. ;
    format stage_8_o2_1 best12. ;
    format stage_8_ultras_1 best12. ;
    format stage_9_yn best12. ;
    format stage_9_systolic_1 best12. ;
    format stage_9_diastolic_1 best12. ;
    format stage_9_hr_1 best12. ;
    format stage_9_o2_1 best12. ;
    format stage_9_ultras_1 best12. ;
    format stage_10_yn best12. ;
    format stage_10_systolic_1 best12. ;
    format stage_10_diastolic_1 best12. ;
    format stage_10_hr_1 best12. ;
    format stage_10_o2_1 best12. ;
    format stage_10_ultras_1 best12. ;
    format peak_bld_systolic_1 best12. ;
    format peak_bld_diastolic_1 best12. ;
    format peak_hr_1 best12. ;
    format peak_o2_sat_1 best12. ;
    format peak_ultras_1 best12. ;
    format recov_bld_systolic_1 best12. ;
    format recov_bld_diastolic_1 best12. ;
    format recov_hr_1 best12. ;
    format recov_o2_1 best12. ;
    format recov_ultras_1 best12. ;
    format exerc_time_1 time5. ;
    format peak_exerc_1 best12. ;
    format peak_borg_1 best12. ;
    format dyspnea_1 $500. ;
    format fatique_1 $500. ;
    format nirs_completed_yn best12. ;
    format notes_6wkex $5000. ;
    format perf_by_ex $500. ;
    format date_ex yymmdd10. ;
    format complet_ex best12. ;
    format form_6wk_ex_complete best12. ;
    format na_end_phase_dosing best12. ;
    format administered_by $500. ;
    format epd_date yymmdd10. ;
    format epd_time time5. ;
    format end_phase_dosing_complete best12. ;
    format na_counseling best12. ;
    format diet_complete best12. ;
    format counsel_diet $500. ;
    format complete_by_diet $500. ;
    format date_diet yymmdd10. ;
    format form_cns_complete best12. ;
    format na_ekg_interpretation best12. ;
    format ekg_interpretation $5000. ;
    format ekg_interpretation_complete best12. ;
    format na_kccq best12. ;
    format activity_dressing best12. ;
    format activity_showering best12. ;
    format activity_walking best12. ;
    format activity_work best12. ;
    format activity_climbing best12. ;
    format activity_run best12. ;
    format heart_failure_chage best12. ;
    format frequency_swelling best12. ;
    format swelling_bother best12. ;
    format fatigue_limit best12. ;
    format fatigue_bother best12. ;
    format breath_limited best12. ;
    format shortness_bother best12. ;
    format sleep_sittingup best12. ;
    format heartfail_contact best12. ;
    format heart_fail_worse best12. ;
    format enjoyment_limit best12. ;
    format heartfail_life best12. ;
    format discouraged_heartfail best12. ;
    format hobbies best12. ;
    format working best12. ;
    format family_visit best12. ;
    format intimate_relationships best12. ;
    format kccq_complete best12. ;
    format na_visit_lab_results best12. ;
    format hemoglobin_vlr best12. ;
    format methemoglobin_ best12. ;
    format nt_pro_bnp_vlr best12. ;
    format white_blood_cells best12. ;
    format red_blood_cells best12. ;
    format hemoglobin_vlr2 best12. ;
    format hematocrit best12. ;
    format rdw best12. ;
    format mch best12. ;
    format mchc best12. ;
    format mcv best12. ;
    format platelets best12. ;
    format glucose best12. ;
    format urea_nitrogen best12. ;
    format creatinine best12. ;
    format sodium best12. ;
    format potassium best12. ;
    format chloride best12. ;
    format calcium best12. ;
    format protein_total best12. ;
    format albumin best12. ;
    format biblirubin_total best12. ;
    format alkaline_phosphatase best12. ;
    format ast_vlr best12. ;
    format alt_vlr best12. ;
    format egfr_non_aa best12. ;
    format non_aa_oth best12. ;
    format egfr_aa best12. ;
    format aa_oth best12. ;
    format g6pd_vlr_yn best12. ;
    format g6pd_result best12. ;
    format result_oth $500. ;
    format oxyhemoglobin $500. ;
    format o2_ct $500. ;
    format carboxyhemoglobin best12. ;
    format carbon_dioxide best12. ;
    format anion_gap best12. ;
    format visit_lab_results_complete best12. ;
    format na_form_files best12. ;
    format file1 $500. ;
    format file2 $500. ;
    format file3 $500. ;
    format file4 $500. ;
    format file5 $500. ;
    format file6 $500. ;
    format file7 $500. ;
    format file8 $500. ;
    format bike_ex_yn best12. ;
    format file9 $500. ;
    format aurora_export best12. ;
    format placed_in_jlab best12. ;
    format uploaded_to_redcap best12. ;
    format transmittal_sheet best12. ;
    format aurora_watch_transaction best12. ;
    format actigraph_transaction best12. ;
    format placed_calendar_reminder best12. ;
    format labs_signed best12. ;
    format g6pd best12. ;
    format completion best12. ;
    format notes_calendar $5000. ;
    format date99 yymmdd10. ;
    format signature77 $500. ;
    format form_files best12. ;
    format form_files_complete best12. ;
    format na_path_and_files_2 best12. ;
    format echo_path_bl $500. ;
    format tonometry_path_bl $500. ;
    format aurora_file_path_bl $500. ;
    format pth_fil_com_bl best12. ;
    format path_and_files_2_complete best12. ;
    format na_path_and_files best12. ;
    format echo_path $500. ;
    format tonometry_path $500. ;
    format tonometry_file1 $500. ;
    format tonometry_file_1_na best12. ;
    format tonometry_file2 $500. ;
    format tonometry_file2_na best12. ;
    format tonometry_file3 $500. ;
    format tonometry_file3_na best12. ;
    format tonometry_file4 $500. ;
    format tonometry_file4_na best12. ;
    format cardiopulmonary_file_1 $500. ;
    format aurora_file_path $500. ;
    format actigraph_file_path $500. ;
    format cardiopulmonary_file_path $500. ;
    format plantar_flexor_file_path $500. ;
    format pth_fil_com best12. ;
    format path_and_files_complete best12. ;
    format na_form_med_ver_p1 best12. ;
    format medicaton_verification_p1 best12. ;
    format med_ver_num_of_days_p1 best12. ;
    format date_of_call_p1 yymmdd10. ;
    format time_of_call_p1 time5. ;
    format med_dispensed best12. ;
    format date_of_med_p1 yymmdd10. ;
    format time_num_p1 time5. ;
    format form_med_ver_p1 best12. ;
    format form_med_ver_p1_complete best12. ;
    format na_form_med_ver_p2 best12. ;
    format medicaton_verification best12. ;
    format num_days_after_bl best12. ;
    format date_of_call yymmdd10. ;
    format time_of_call time5. ;
    format date_of_med yymmdd10. ;
    format time_num time5. ;
    format form_med_ver best12. ;
    format form_med_ver_complete best12. ;
    format na_wk_call best12. ;
    format mouthwash best12. ;
    format compliant_with_mouthwash best12. ;
    format reviewed_no_viagra best12. ;
    format dietary_restrictions best12. ;
    format headache best12. ;
    format dizziness best12. ;
    format lightheadedness best12. ;
    format low_blood_pressure_90 best12. ;
    format stomach_ache_diarrhea best12. ;
    format increased_shortness best12. ;
    format flushing best12. ;
    format rash best12. ;
    format changes_in_blood_pressure best12. ;
    format swelling best12. ;
    format fatigue best12. ;
    format oth_symps best12. ;
    format presence best12. ;
    format if_yes_subject_needs_to $5000. ;
    format amount_of_meds best12. ;
    format date_uptitrated_fmh yymmdd10. ;
    format date_remn_fmh yymmdd10. ;
    format date0934 yymmdd10. ;
    format signature564 $500. ;
    format form_p1 best12. ;
    format wk_call_complete best12. ;
    format na_se_assessment_form best12. ;
    format side_efft_asst_yn best12. ;
    format heart_rate_2_se best12. ;
    format o2_saturation_2_se best12. ;
    format systolic_2_se best12. ;
    format diastolic_2_se best12. ;
    format systolic_2_se2 best12. ;
    format diastolic_2_se2 best12. ;
    format orthostat_se best12. ;
    format orthostat_se_dscr $5000. ;
    format bp_drop_comments $5000. ;
    format orthostatic_pb1 $500. ;
    format orthostatic_sig $500. ;
    format orthostatic_date $500. ;
    format heart_comments $5000. ;
    format lung_comments $5000. ;
    format abd_comments $5000. ;
    format extrem_comments $5000. ;
    format se_assessment_notes $5000. ;
    format performed_by776_se2_c7c $500. ;
    format signature564_se2_0f0 $500. ;
    format date0934_se2_0b2 yymmdd10. ;
    format mouthwash_se best12. ;
    format compliant_with_mouthwash_se best12. ;
    format reviewed_no_viagra_se best12. ;
    format dietary_restrictions_se best12. ;
    format headache_se best12. ;
    format dizziness_se best12. ;
    format lightheadedness_se best12. ;
    format low_blood_pressure_90_se best12. ;
    format stomach_ache_diarrhea_se best12. ;
    format increased_shortness_se best12. ;
    format flushing_se best12. ;
    format rash_se best12. ;
    format changes_in_blood_pressure_se best12. ;
    format swelling_se best12. ;
    format fatigue_se best12. ;
    format other_symptoms_se best12. ;
    format comments_se $5000. ;
    format performed_by776_se $500. ;
    format date0934_se yymmdd10. ;
    format med_regimen_change best12. ;
    format med_regimen_change_dscr $5000. ;
    format phys_by_se $500. ;
    format phys_date_se yymmdd10. ;
    format form_p1_se best12. ;
    format side_effect_assessme_v_3 best12. ;
    format na_form_devices best12. ;
    format device_given best12. ;
    format device_given_date yymmdd10. ;
    format device_given_time time5. ;
    format aurora_id $500. ;
    format actigraph_id $500. ;
    format devices_mailed best12. ;
    format aurora_mailed $500. ;
    format actigraph_mailed $500. ;
    format date_device_mailed yymmdd10. ;
    format device_mailed time5. ;
    format date_device_receiv yymmdd10. ;
    format time_reciev time5. ;
    format date_aurora_on yymmdd10. ;
    format time_aurora_on time5. ;
    format date_aurora_off yymmdd10. ;
    format time_aurora_off time5. ;
    format date_actigraph_on yymmdd10. ;
    format time_actigraph_on time5. ;
    format date_actigraph_off yymmdd10. ;
    format time_actigraph_off time5. ;
    format date_returned yymmdd10. ;
    format device_notes $5000. ;
    format perf_by_dev $500. ;
    format dev_date yymmdd10. ;
    format form_devices_complete best12. ;
    format obs_notes_yn best12. ;
    format obs_notes $5000. ;
    format observationsnotes_complete best12. ;

input
    study_id $
    redcap_event_name $
    na_form_el
    data_obtained_yn
    heart_failure
    nyha_class $
    lv_ejection
    lvef $
    study_type $
    date1
    medical_therapy
    filling_pressures
    mitral_ratio
    left_atrium
    index $
    date2
    chronic_loop
    drug_dose $
    natriuretic_peptides
    bnp_level $
    date3
    either_lateral
    capillary_wedge
    value $
    date4
    iv_diuretics
    date5
    location $
    verified_by $
    date6
    supine_systolic
    supine_sys1 $
    supine_dia1 $
    pregnancy
    orthostatic_hypotension
    supine_sys2 $
    supine_dia2 $
    standing_sys1 $
    standing_dia1 $
    native_conduction
    hemoglobin
    baseline_labs $
    inability_exercise
    valvular_disease
    hypertrophic
    pericardial_disease
    current_angina
    coronary_syndrome
    primary_pulmonary
    chronic_obstructive
    stress_testing
    ventricular_ejection
    phosphodiesterase
    organic_nitrates
    liver_disease
    alt $
    ast $
    alb $
    egfr
    baseline_egfr $
    g6pd_deficiency
    methemoglobinemia
    methemoglobin $
    hyperkalemia_serum
    hyperkalemia $
    ventricular_dysfunction
    medical_condition
    contraindications_to_mri
    intra_luminal_implant
    life_assist_device
    vascular_clip
    visceral_organs
    intracranial_implants
    non_removable_piercings
    personal_history
    radiologic_evaluation
    comments_form_el $
    verified_by1 $
    date7
    form_el_complete
    na_form_bl_cl
    consent_yn
    consent_ini $
    urine_yn
    urine_radio
    urine_ini $
    diet_yn
    diet_ini $
    vital_yn
    vital_ini $
    mw6_yn
    mw6_ini $
    quality_yn
    quality_ini $
    cognitive_test_yn
    cognitive_test_ini $
    blood_yn
    blood_ini $
    g6pd_yn
    g6pd_ini $
    art_tono_yn
    art_tono_ini $
    echo_yn
    echo_ini $
    ekg_bl
    ekg_initials_bl $
    labs_yn
    hemo_yn
    hemo_value $
    hemo_ini $
    creati_yn
    creati_value $
    creati_ini $
    egfr_yn
    egfr_value $
    egfr_ini $
    meth_yn
    meth_value $
    meth_ini $
    potas_yn
    potas_value $
    potas_ini $
    ntpro_yn
    ntpro_value $
    ntpro_initials $
    med_dis_yn
    med_dis_ini $
    bl_ch_name $
    bl_ch_date $
    form_bl_cl_complete
    na_form_6wk_cl
    urine_pregnancy_test
    urine_pregnancy_results
    urine_pregnancy_ini $
    dietary_questionnaire
    dietary_questionnaire_ini $
    physical_exam
    physical_exam_ini $
    orthostatics
    orthostatics_ini $
    vital_signs
    vital_signs_ini $
    questionnaires_kccq
    questionnaires_kccq_ini $
    potential_side_effects
    potential_side_effects_ini $
    cognitive_test2_yn
    congitive_test2_ini $
    blood_draws_before
    blood_draws_before_ini $
    light_breakfast
    light_breakfast_ini $
    blood_draws_after
    blood_draws_after_ini $
    arterial_tonometry
    arterial_tonometry_ini $
    doppler_echocardiogram
    doppler_echocardiogram_ini $
    ekg_p1
    ekg_initials_p1 $
    bicycle_exercise_test
    bicycle_exercise_test_ini $
    muscle_mri
    muscle_mri_ini $
    medication_dispensed
    stage_2_meds_ini $
    stage_2_meds
    stage_1_meds_ini $
    stage_1_meds
    pill_count_ini $
    pill_count_yn
    pill_count_ini2_d9f $
    cardiac_mri_performed_p1
    cardiac_mri_initials_p1 $
    date_6wk_cl_p1
    signature_6wk_cl_p1 $
    form_6wk_cl_complete
    na_form_6wk_cl_p2
    urine_pregnancy_test_p2
    urine_pregnancy_results_p2
    urine_pregnancy_ini_p2 $
    dietary_questionnaire_p2
    dietary_questionnaire_ini_p2 $
    physical_exam_p2
    physical_exam_ini_p2 $
    orthostatics_p2
    orthostatics_ini_p2 $
    vital_signs_p2
    vital_signs_ini_p2 $
    questionnaires_kccq_p2
    questionnaires_kccq_ini_p2 $
    potential_side_effects_p2
    potential_side_effects_ini_p2 $
    cognitive_test3_yn
    cognitive_test3_ini $
    blood_draws_before_p2
    blood_draws_before_ini_p2 $
    light_breakfast_p2
    light_breakfast_ini_p2 $
    blood_draws_after_p2
    blood_draws_after_ini_p2 $
    arterial_tonometry_p2
    arterial_tonometry_ini_p2 $
    doppler_echocardiogram_p2
    doppler_echocardiogram_ini_p2 $
    ekg_p2
    ekg_initials_p2 $
    bicycle_exercise_test_p2
    bicycle_exercise_test_ini_p2 $
    muscle_mri_p2
    muscle_mri_ini_p2 $
    stage_1_meds_p2
    pill_count_ini_p2 $
    pill_count_yn_p2
    pill_count_ini2_d9f_p2 $
    cardiac_mri_initials_p2
    cardiac_mri_initials_phase_2 $
    form_bl_cl_cmplt_p2
    medication_dispensed_p2
    stage_2_meds_ini_p2 $
    name_6wk_cl_p2 $
    date_6wk_cl_p2
    signature_6wk_cl_p2 $
    form_6wk_cl_p2_complete
    na_form_6wk_mri
    mri_safety_checklist
    initials $
    field_strength1
    load_used1 $
    number_of_repetitions
    repetitions_oth $
    load_used_psi $
    number_of_repetitions1
    other_asl $
    comments $
    data_exported
    sig $
    date98
    complete_mri
    form_6wk_mri_complete
    na_form_cardiac_mri
    form_mri_enrolled
    form_mri_reviewed
    form_mri_performed $
    form_mri_time
    form_mri_hr
    form_mri_systolic
    form_mri_diastolic
    form_mri_weight
    form_mri_weight_units
    mri_form_weight_other $
    form_mri_basis1
    form_mri_basis2
    form_mri_meds
    form_mri_stable
    form_mri_beta_blockers
    form_mri_nitrates
    form_mri_base_ecg $
    form_mri_comment $
    form_mri_post_time
    form_mri_post_hr
    form_mri_post_systolic
    form_mri_post_diastolic
    form_mri_post_ecg $
    form_mri_post_reported
    form_mri_post_symptoms $
    form_mri_post_discharge
    form_cardiac_mri_complete
    na_form_mh
    penn_chart
    age
    gender
    race___1
    race___2
    race___3
    race___4
    race___5
    race___6
    race_oth $
    type_decent
    acutecoronary
    acutecoronary_ai $
    prior_angina
    prior_angina_ai $
    any_arrhythmia
    any_arrhythmia_ai $
    valv_disease_surgery
    valv_disease_surgery_ai $
    htn
    htn_ai $
    high_cholesterol
    high_cholesterol_ai $
    peripheral_vascular
    peripheral_vascular_ai $
    diabetes
    diabetes_ai $
    insulin
    insulin_ai $
    cva_tia
    cva_tia_ai $
    pulmonary_embolism_dvt
    pulmonary_embolism_dvt_ai $
    osa
    osa_ai $
    cpap
    cpap_ai $
    copd_asthma
    copd_asthma_ai $
    osteoarthritis
    osteoarthritis_ai $
    other_conditions $
    other_conditions_ai $
    cabg
    cabg_ai $
    peripheral
    peripheral_ai $
    valvular_surgery
    valvular_ai $
    congenital_surgery
    congenital_surgery_ai $
    trauma_requiring_surgery
    trauma_req_surgery_ai $
    other_surgeries $
    current_smoker
    pack_years
    prior_smoker
    prior_smoker_ai $
    current_alcohol
    drinks_day
    drinks_add_info $
    prior_alcohol
    prior_alcohol_ai $
    recreational_drug_use
    recreational_drug_usead $
    occupation_yn
    occupation $
    signature $
    date9
    nyhaclass
    orthopnea
    paroxysmal_nocturnal
    lower_extremity_edema
    num_of_stairs
    reason_for_stopping $
    distance
    block_miles
    distance_other $
    stop_walk $
    crvalue
    crdate
    egfr_value2
    egfr_date
    nt_pro_bnp_value
    nt_pro_bnp_date
    hemoglobin_value
    hemoglobin_date
    hematocrit_value
    hematocrit_date
    hemoglobin_a1c_value
    hemoglobin_a1c_date
    other_lab_data $
    cholesterol_total
    cholesterol_total_date
    triglycerides_value
    triglycerides_date
    hdl_cholesterol
    hdl_cholesterol_date
    ldl
    ldl_date
    vldl
    vldl_date
    non_hdl
    non_hdl_date
    prev_hrt_catheter
    pcwp_12
    lvedp_16
    hrt_catheter_date
    pcwp_value
    lvedp_value
    prior_stress_test
    stress_test_date
    stress_test_result $
    comments_stress_test $
    allergies $
    performed_by_date
    performed_by_signature $
    form_mh_complete
    datetime_seconds1 $
    na_form_lab_pre_medication
    iv_line_required_1
    iv_time_1
    gauge_1 $
    site_1 $
    preg_test
    cmp_gold
    pax_gene
    nt_pro
    form_lab_methemoglobin
    form_lab_cbc
    g6pd_test
    urine_cc
    plasma_purp
    serum_red
    saliva_tube
    notes_pm $
    perf_by_lab $
    date_lab
    form_lab_6412_complete
    na_form_lab_peak_bike
    iv_time_1_v3
    complete_lab_v3
    plasma_bike
    serum_bike
    notes_pb $
    form_lab_pre_medicat_v_0
    na_form_lab_post_med
    iv_time_1_v2
    complete_lab_v2
    urine_post
    plasma_post
    serum_post
    saliva_post
    notes_2hr $
    form_lab_pre_medicat_v_1
    na_physical_exam
    form_pe_obtained
    height_2
    height_2_units
    weight_2
    weight_2_units
    systolic_2
    diastolic_2
    blood_pressure_arm_2
    heart_rate_2
    o2_saturation_2
    hr $
    rr_2
    jvp_2
    jvp_category $
    ekg
    heart_2 $
    lungs_2 $
    abd_2 $
    extremities_2 $
    additional_notes_pe $
    extrem_performed $
    extremities_date
    extremities_signature $
    sup_systolic_2
    sup_diastolic_2
    stan_systolic_2
    stan_diastolic_2
    orthostatic_symptoms_yn
    ortho_sympt_descr $
    comments_phy $
    sars_yn
    sars_vaccine $
    sars_dose_date $
    sars_notes $
    phys_by $
    phys_date
    form_pe_complete
    na_end_phase_se_review
    mouthwash_se_ep
    compliant_with_mouthwash_se_ep
    reviewed_no_viagra_se_ep
    dietary_restrictions_se_ep
    headache_se_ep
    dizziness_se_ep
    lightheadedness_se_ep
    low_blood_pressure_90_se_ep
    stomach_ache_diarrhea_se_ep
    increased_shortness_se_ep
    flushing_se_ep
    rash_se_ep
    ch_in_blood_pressure_se_ep
    swelling_se_ep
    fatigue_se_assess
    other_symps_se
    orthostat_se_ep
    orthostat_se_dscr_ep $
    performed_by776_se_ep $
    phys_date_se_ep
    form_p1_se_ep
    end_phase_side_effec_v_2
    na_form_mh_p1_p2
    penn_chart_6p
    age_6p
    gender_6p
    race_6p___1
    race_6p___2
    race_6p___3
    race_6p___4
    race_6p___5
    race_6p___6
    race_oth_6p $
    type_decent_6p
    acutecoronary_6p
    acutecoronary_ai_6p $
    prior_angina_6p
    prior_angina_ai_6p $
    any_arrhythmia_6p
    any_arrhythmia_ai_6p $
    valv_disease_surgery_6p
    valv_disease_surgery_ai_6p $
    htn_6p
    htn_ai_6p $
    high_cholesterol_6p
    high_cholesterol_ai_6p $
    peripheral_vascular_6p
    peripheral_vascular_ai_6p $
    diabetes_6p
    diabetes_ai_6p $
    insulin_6p
    insulin_ai_6p $
    cva_tia_6p
    cva_tia_ai_6p $
    pulmonary_embolism_dvt_6p
    pulmonary_embolism_dvt_ai_6p $
    osa_6p
    osa_ai_6p $
    cpap_6p
    cpap_ai_6p $
    copd_asthma_6p
    copd_asthma_ai_6p $
    osteoarthritis_6p
    osteoarthritis_ai_6p $
    other_conditions_6p $
    other_conditions_ai_6p $
    cabg_6p
    cabg_ai_6p $
    peripheral_6p
    peripheral_ai_6p $
    valvular_surgery_6p
    valvular_ai_6p $
    congenital_surgery_6p
    congenital_surgery_ai_6p $
    trauma_requiring_surgery_6p
    trauma_req_surgery_ai_6p $
    other_surgeries_6p $
    current_smoker_6p
    pack_years_6p
    prior_smoker_6p
    prior_smoker_ai_6p $
    current_alcohol_6p
    drinks_day_6p
    prior_alcohol_6p
    prior_alcohol_ai_6p $
    recreational_drug_use_6p
    recreational_drug_usead_6p $
    occupation_6p $
    signature_6p $
    date9_6p
    nyhaclass_6p
    orthopnea_6p
    paroxysmal_nocturnal_6p
    lower_extremity_edema_6p
    num_of_stairs_6p
    reason_for_stopping_6p $
    distance_6p
    block_miles_6p
    stop_walk_6p $
    crvalue_6p
    crdate_6p
    egfr_value2_6p
    egfr_date_6p
    nt_pro_bnp_value_6p
    nt_pro_bnp_date_6p
    hemoglobin_value_6p
    hemoglobin_date_6p
    hematocrit_value_6p
    hematocrit_date_6p
    hemoglobin_a1c_value_6p
    hemoglobin_a1c_date_6p
    other_lab_data_6p $
    prev_hrt_catheter_6p
    hrt_catheter_date_6p
    pcwp_12_6p
    pcwp_value_6p
    lvedp_16_6p
    lvedp_value_6p
    prior_stress_test_6p
    stress_test_date_6p
    stress_test_result_6p $
    comments_stress_test_6p $
    allergies_6p $
    performed_by_date_6p
    performed_by_signature_6p $
    bl_mh_cmplt_6p
    form_mh_8174_complete
    na_medications
    date_med
    num_med
    meds_1
    med_oth_1 $
    dose_1
    comb_dose_1
    units_1
    units_oth_1 $
    freq_1
    freq_oth_1 $
    route_1
    route_oth_1 $
    recent_start_date_1
    start_date_1
    recent_end_date_1
    end_date_1
    meds_2
    med_oth_2 $
    dose_2
    comb_dose_2
    units_2
    units_oth_2 $
    freq_2
    freq_oth_2 $
    route_2
    route_oth_2 $
    recent_start_date_2
    start_date_2
    recent_end_date_2
    end_date_2
    meds_3
    med_oth_3 $
    dose_3
    comb_dose_3
    units_3
    units_oth_3 $
    freq_3
    freq_oth_3 $
    route_3
    route_oth_3 $
    recent_start_date_3
    start_date_3
    recent_end_date_3
    end_date_3
    meds_4
    med_oth_4 $
    dose_4
    comb_dose_4
    units_4
    units_oth_4 $
    freq_4
    freq_oth_4 $
    route_4
    route_oth_4 $
    recent_start_date_4
    start_date_4
    recent_end_date_4
    end_date_4
    meds_5
    med_oth_5 $
    dose_5
    comb_dose_5
    units_5
    units_oth_5 $
    freq_5
    freq_oth_5 $
    route_5
    route_oth_5 $
    recent_start_date_5
    start_date_5
    recent_end_date_5
    end_date_5
    meds_6
    med_oth_6 $
    dose_6
    comb_dose_6
    units_6
    units_oth_6 $
    freq_6
    freq_oth_6 $
    route_6
    route_oth_6 $
    recent_start_date_6
    start_date_6
    recent_end_date_6
    end_date_6
    meds_7
    med_oth_7 $
    dose_7
    comb_dose_7
    units_7
    units_oth_7 $
    freq_7
    freq_oth_7 $
    route_7
    route_oth_7 $
    recent_start_date_7
    start_date_7
    recent_end_date_7
    end_date_7
    meds_8
    med_oth_8 $
    dose_8
    comb_dose_8
    units_8
    units_oth_8 $
    freq_8
    freq_oth_8 $
    route_8
    route_oth_8 $
    recent_start_date_8
    start_date_8
    recent_end_date_8
    end_date_8
    meds_9
    med_oth_9 $
    dose_9
    comb_dose_9
    units_9
    units_oth_9 $
    freq_9
    freq_oth_9 $
    route_9
    route_oth_9 $
    recent_start_date_9
    start_date_9
    recent_end_date_9
    end_date_9
    meds_10
    med_oth_10 $
    dose_10
    comb_dose_10
    units_10
    units_oth_10 $
    freq_10
    freq_oth_10 $
    route_10
    route_oth_10 $
    recent_start_date_10
    start_date_10
    recent_end_date_10
    end_date_10
    meds_11
    med_oth_11 $
    dose_11
    comb_dose_11
    units_11
    units_oth_11 $
    freq_11
    freq_oth_11 $
    route_11
    route_oth_11 $
    recent_start_date_11
    start_date_11
    recent_end_date_11
    end_date_11
    meds_12
    med_oth_12 $
    dose_12
    comb_dose_12
    units_12
    units_oth_12 $
    freq_12
    freq_oth_12 $
    route_12
    route_oth_12 $
    recent_start_date_12
    start_date_12
    recent_end_date_12
    end_date_12
    meds_13
    med_oth_13 $
    dose_13
    comb_dose_13
    units_13
    units_oth_13 $
    freq_13
    freq_oth_13 $
    route_13
    route_oth_13 $
    recent_start_date_13
    start_date_13
    recent_end_date_13
    end_date_13
    meds_14
    med_oth_14 $
    dose_14
    comb_dose_14
    units_14
    units_oth_14 $
    freq_14
    freq_oth_14 $
    route_14
    route_oth_14 $
    recent_start_date_14
    start_date_14
    recent_end_date_14
    end_date_14
    meds_15
    med_oth_15 $
    dose_15
    comb_dose_15
    units_15
    units_oth_15 $
    freq_15
    freq_oth_15 $
    route_15
    route_oth_15 $
    recent_start_date_15
    start_date_15
    recent_end_date_15
    end_date_15
    meds_16
    med_oth_16 $
    dose_16
    comb_dose_16
    units_16
    units_oth_16 $
    freq_16
    freq_oth_16 $
    route_16
    route_oth_16 $
    recent_start_date_16
    start_date_16
    recent_end_date_16
    end_date_16
    meds_17
    med_oth_17 $
    dose_17
    comb_dose_17
    units_17
    units_oth_17 $
    freq_17
    freq_oth_17 $
    route_17
    route_oth_17 $
    recent_start_date_17
    start_date_17
    recent_end_date_17
    end_date_17
    meds_18
    med_oth_18 $
    dose_18
    comb_dose_18
    units_18
    units_oth_18 $
    freq_18
    freq_oth_18 $
    route_18
    route_oth_18 $
    recent_start_date_18
    start_date_18
    recent_end_date_18
    end_date_18
    meds_19
    med_oth_19 $
    dose_19
    comb_dose_19
    units_19
    units_oth_19 $
    freq_19
    freq_oth_19 $
    route_19
    route_oth_19 $
    recent_start_date_19
    start_date_19
    recent_end_date_19
    end_date_19
    meds_20
    med_oth_20 $
    dose_20
    comb_dose_20
    units_20
    units_oth_20 $
    freq_20
    freq_oth_20 $
    route_20
    route_oth_20 $
    recent_start_date_20
    start_date_20
    recent_end_date_20
    end_date_20
    meds_21
    med_oth_21 $
    dose_21
    comb_dose_21
    units_21
    units_oth_21 $
    freq_21
    freq_oth_21 $
    route_21
    route_oth_21 $
    recent_start_date_21
    start_date_21
    recent_end_date_21
    end_date_21
    meds_22
    med_oth_22 $
    dose_22
    comb_dose_22
    units_22
    units_oth_22 $
    freq_22
    freq_oth_22 $
    route_22
    route_oth_22 $
    recent_start_date_22
    start_date_22
    recent_end_date_22
    end_date_22
    meds_23
    med_oth_23 $
    dose_23
    comb_dose_23
    units_23
    units_oth_23 $
    freq_23
    freq_oth_23 $
    route_23
    route_oth_23 $
    recent_start_date_23
    start_date_23
    recent_end_date_23
    end_date_23
    meds_24
    med_oth_24 $
    dose_24
    comb_dose_24
    units_24
    units_oth_24 $
    freq_24
    freq_oth_24 $
    route_24
    route_oth_24 $
    recent_start_date_24
    start_date_24
    recent_end_date_24
    end_date_24
    meds_25
    med_oth_25 $
    dose_25
    comb_dose_25
    units_25
    units_oth_25 $
    freq_25
    freq_oth_25 $
    route_25
    route_oth_25 $
    recent_start_date_25
    start_date_25
    recent_end_date_25
    end_date_25
    meds_26
    med_oth_26 $
    dose_26
    comb_dose_26
    units_26
    units_oth_26 $
    freq_26
    freq_oth_26 $
    route_26
    route_oth_26 $
    recent_start_date_26
    start_date_26
    recent_end_date_26
    end_date_26
    meds_27
    med_oth_27 $
    dose_27
    comb_dose_27
    units_27
    units_oth_27 $
    freq_27
    freq_oth_27 $
    route_27
    route_oth_27 $
    recent_start_date_27
    start_date_27
    recent_end_date_27
    end_date_27
    meds_28
    med_oth_28 $
    dose_28
    comb_dose_28
    units_28
    units_oth_28 $
    freq_28
    freq_oth_28 $
    route_28
    route_oth_28 $
    recent_start_date_28
    start_date_28
    recent_end_date_28
    end_date_28
    meds_29
    med_oth_29 $
    dose_29
    comb_dose_29
    units_29
    units_oth_29 $
    freq_29
    freq_oth_29 $
    route_29
    route_oth_29 $
    recent_start_date_29
    start_date_29
    recent_end_date_29
    end_date_29
    meds_30
    med_oth_30 $
    dose_30
    comb_dose_30
    units_30
    units_oth_30 $
    freq_30
    freq_oth_30 $
    route_30
    route_oth_30 $
    recent_start_date_30
    start_date_30
    recent_end_date_30
    end_date_30
    data_epic_med
    med_comments $
    medications_complete
    na_cognitive_testing
    shopping_test_yn
    gorton_test_yn
    detection_test_yn
    identification_test_yn
    card_test_yn
    one_back_test_yn
    delayed_recall_test_yn
    data_backed_up_yn
    cognitive_comments $
    form_ct_name $
    form_ct_date
    signature_cog_test $
    cognitive_testing_complete
    na_form_vp
    ult_sd_perf_1 $
    sternal_angle_to_carotid_1
    ster_carotid_1
    sternal_angle_to_femoral_1
    ster_femoral_1
    sternal_angle_to_radial_1
    ster_radial_1
    sternal_length
    bp_collected_yn
    bp_study_id
    pb_plus_systolic $
    bp_plus_diastolic
    pre_bike_systolic_1
    pre_bike_diastolic_1
    time_1
    hr_1
    map
    initials_1 $
    carotid_1
    carotid_tonometry $
    carotid_vasc
    femora_1
    femoral_tonometry $
    femora_vasc
    radial_1
    radial_tonometry $
    radial_vasc
    lvot_flow
    comment_1 $
    form_vp_name $
    form_vp_date
    form_vp_complete
    na_form_6mwt
    checklist_bl_6mwt___1
    checklist_bl_6mwt___2
    checklist_bl_6mwt___3
    checklist_bl_6mwt___4
    checklist_bl_6mwt___5
    checklist_bl_6mwt___6
    dyspnea_borg_score
    fatigue_borg_score
    heart_rate
    pulse_oximetry
    systolic_bf
    diastolic_bf
    pretest_instruction___1
    pretest_instruction___2
    post_dyspnea_borg
    post_fatigue_borg
    post_bpm
    post_pulse_oximetry
    systolic_af
    diastolic_af
    test_start_time
    total_meters_walked
    notes $
    perform_date
    perform_sig $
    complete_6mwt
    form_6mwt_complete
    na_form_6wk_ex
    bicyc_1
    initial_1 $
    stage_1_yn
    stage_1_systolic_1
    stage_1_diastolic_1
    stage_1_hr_1
    stage_1_o2_1
    stage_1_ultras_1
    stage_2_yn
    stage_2_systolic_1
    stage_2_diastolic_1
    stage_2_hr_1
    stage_2_o2_1
    stage_2_ultras_1
    stage_3_yn
    stage_3_systolic_1
    stage_3_diastolic_1
    stage_3_hr_1
    stage_3_o2_1
    stage_3_ultras_1
    stage_4_yn
    stage_4_systolic_1
    stage_4_diastolic_1
    stage_4_hr_1
    stage_4_o2_1
    stage_4_ultras_1
    stage_5_yn
    stage_5_systolic_1
    stage_5_diastolic_1
    stage_5_hr_1
    stage_5_o2_1
    stage_5_ultras_1
    stage_6_yn
    stage_6_systolic_1
    stage_6_diastolic_1
    stage_6_hr_1
    stage_6_o2_1
    stage_6_ults_1
    stage_7_yn
    stage_7_systolic_1
    stage_7_diastolic_1
    stage_7_hr_1
    stage_7_o2_1
    stage_7_ultras_1
    stage_8_yn
    stage_8_systolic_1
    stage_8_diastolic_1
    stage_8_hr_1
    stage_8_o2_1
    stage_8_ultras_1
    stage_9_yn
    stage_9_systolic_1
    stage_9_diastolic_1
    stage_9_hr_1
    stage_9_o2_1
    stage_9_ultras_1
    stage_10_yn
    stage_10_systolic_1
    stage_10_diastolic_1
    stage_10_hr_1
    stage_10_o2_1
    stage_10_ultras_1
    peak_bld_systolic_1
    peak_bld_diastolic_1
    peak_hr_1
    peak_o2_sat_1
    peak_ultras_1
    recov_bld_systolic_1
    recov_bld_diastolic_1
    recov_hr_1
    recov_o2_1
    recov_ultras_1
    exerc_time_1
    peak_exerc_1
    peak_borg_1
    dyspnea_1 $
    fatique_1 $
    nirs_completed_yn
    notes_6wkex $
    perf_by_ex $
    date_ex
    complet_ex
    form_6wk_ex_complete
    na_end_phase_dosing
    administered_by $
    epd_date
    epd_time
    end_phase_dosing_complete
    na_counseling
    diet_complete
    counsel_diet $
    complete_by_diet $
    date_diet
    form_cns_complete
    na_ekg_interpretation
    ekg_interpretation $
    ekg_interpretation_complete
    na_kccq
    activity_dressing
    activity_showering
    activity_walking
    activity_work
    activity_climbing
    activity_run
    heart_failure_chage
    frequency_swelling
    swelling_bother
    fatigue_limit
    fatigue_bother
    breath_limited
    shortness_bother
    sleep_sittingup
    heartfail_contact
    heart_fail_worse
    enjoyment_limit
    heartfail_life
    discouraged_heartfail
    hobbies
    working
    family_visit
    intimate_relationships
    kccq_complete
    na_visit_lab_results
    hemoglobin_vlr
    methemoglobin_
    nt_pro_bnp_vlr
    white_blood_cells
    red_blood_cells
    hemoglobin_vlr2
    hematocrit
    rdw
    mch
    mchc
    mcv
    platelets
    glucose
    urea_nitrogen
    creatinine
    sodium
    potassium
    chloride
    calcium
    protein_total
    albumin
    biblirubin_total
    alkaline_phosphatase
    ast_vlr
    alt_vlr
    egfr_non_aa
    non_aa_oth
    egfr_aa
    aa_oth
    g6pd_vlr_yn
    g6pd_result
    result_oth $
    oxyhemoglobin $
    o2_ct $
    carboxyhemoglobin
    carbon_dioxide
    anion_gap
    visit_lab_results_complete
    na_form_files
    file1 $
    file2 $
    file3 $
    file4 $
    file5 $
    file6 $
    file7 $
    file8 $
    bike_ex_yn
    file9 $
    aurora_export
    placed_in_jlab
    uploaded_to_redcap
    transmittal_sheet
    aurora_watch_transaction
    actigraph_transaction
    placed_calendar_reminder
    labs_signed
    g6pd
    completion
    notes_calendar $
    date99
    signature77 $
    form_files
    form_files_complete
    na_path_and_files_2
    echo_path_bl $
    tonometry_path_bl $
    aurora_file_path_bl $
    pth_fil_com_bl
    path_and_files_2_complete
    na_path_and_files
    echo_path $
    tonometry_path $
    tonometry_file1 $
    tonometry_file_1_na
    tonometry_file2 $
    tonometry_file2_na
    tonometry_file3 $
    tonometry_file3_na
    tonometry_file4 $
    tonometry_file4_na
    cardiopulmonary_file_1 $
    aurora_file_path $
    actigraph_file_path $
    cardiopulmonary_file_path $
    plantar_flexor_file_path $
    pth_fil_com
    path_and_files_complete
    na_form_med_ver_p1
    medicaton_verification_p1
    med_ver_num_of_days_p1
    date_of_call_p1
    time_of_call_p1
    med_dispensed
    date_of_med_p1
    time_num_p1
    form_med_ver_p1
    form_med_ver_p1_complete
    na_form_med_ver_p2
    medicaton_verification
    num_days_after_bl
    date_of_call
    time_of_call
    date_of_med
    time_num
    form_med_ver
    form_med_ver_complete
    na_wk_call
    mouthwash
    compliant_with_mouthwash
    reviewed_no_viagra
    dietary_restrictions
    headache
    dizziness
    lightheadedness
    low_blood_pressure_90
    stomach_ache_diarrhea
    increased_shortness
    flushing
    rash
    changes_in_blood_pressure
    swelling
    fatigue
    oth_symps
    presence
    if_yes_subject_needs_to $
    amount_of_meds
    date_uptitrated_fmh
    date_remn_fmh
    date0934
    signature564 $
    form_p1
    wk_call_complete
    na_se_assessment_form
    side_efft_asst_yn
    heart_rate_2_se
    o2_saturation_2_se
    systolic_2_se
    diastolic_2_se
    systolic_2_se2
    diastolic_2_se2
    orthostat_se
    orthostat_se_dscr $
    bp_drop_comments $
    orthostatic_pb1 $
    orthostatic_sig $
    orthostatic_date $
    heart_comments $
    lung_comments $
    abd_comments $
    extrem_comments $
    se_assessment_notes $
    performed_by776_se2_c7c $
    signature564_se2_0f0 $
    date0934_se2_0b2
    mouthwash_se
    compliant_with_mouthwash_se
    reviewed_no_viagra_se
    dietary_restrictions_se
    headache_se
    dizziness_se
    lightheadedness_se
    low_blood_pressure_90_se
    stomach_ache_diarrhea_se
    increased_shortness_se
    flushing_se
    rash_se
    changes_in_blood_pressure_se
    swelling_se
    fatigue_se
    other_symptoms_se
    comments_se $
    performed_by776_se $
    date0934_se
    med_regimen_change
    med_regimen_change_dscr $
    phys_by_se $
    phys_date_se
    form_p1_se
    side_effect_assessme_v_3
    na_form_devices
    device_given
    device_given_date
    device_given_time
    aurora_id $
    actigraph_id $
    devices_mailed
    aurora_mailed $
    actigraph_mailed $
    date_device_mailed
    device_mailed
    date_device_receiv
    time_reciev
    date_aurora_on
    time_aurora_on
    date_aurora_off
    time_aurora_off
    date_actigraph_on
    time_actigraph_on
    date_actigraph_off
    time_actigraph_off
    date_returned
    device_notes $
    perf_by_dev $
    dev_date
    form_devices_complete
    obs_notes_yn
    obs_notes $
    observationsnotes_complete
;
if _ERROR_ then call symput('_EFIERR_',"1");
run;

proc contents;run;

data redcap;
    set redcap;
    label study_id='Study ID';
    label redcap_event_name='Event Name';
    label na_form_el='Not Applicable';
    label data_obtained_yn='Data were obtained directly from patient or from EPIC unless otherwise specified.';
    label heart_failure='A diagnosis of heart failure with NYHA Class II-III symptoms';
    label nyha_class='NYHA Class';
    label lv_ejection='LV ejection fraction >50% during baseline echocardiography';
    label lvef='LVEF';
    label study_type='Type of study';
    label date1='Date';
    label medical_therapy='Stable medical therapy: no addition/removal/changes in antihypertensive medications, or beta-blockers in the preceding 30 days';
    label filling_pressures='Elevated filling pressures as evidenced by at least 1 of the following';
    label mitral_ratio='Mitral E/e'' ratio > 8 (either lateral or septal), with low e'' velocity (septal e''< 7 cm/sec or lateral e''< 10 cm/sec), in addition to one of the following:  ';
    label left_atrium='Enlarged left atrium (LA volume index >34 ml/m2)';
    label index='Index';
    label date2='Date';
    label chronic_loop='Chronic loop diuretic use for control of symptoms';
    label drug_dose='Drug and dose';
    label natriuretic_peptides='Elevated natriuretic peptides (BNP levels >100 ng/L or NT-proBNP levels >300 ng/L)';
    label bnp_level='BNP or NT-pro-BNP Level';
    label date3='Date';
    label either_lateral='Mitral E/e'' ratio > 14 (either lateral or septal)';
    label capillary_wedge='Elevated invasively-determined filling pressures previously (resting LVEDP>16 mmHg or mean pulmonary capillary wedge pressure > 12 mmHg or PCWP/LVEDP > 25 mmHg with exercise).';
    label value='Value';
    label date4='Date';
    label iv_diuretics='Acute heart failure decompensation requiring IV diuretics ';
    label date5='Date';
    label location='LOCATION';
    label verified_by='Verified by';
    label date6='Date';
    label supine_systolic='Supine systolic blood pressure < 100 mm Hg ';
    label supine_sys1='Systolic';
    label supine_dia1='Diastolic';
    label pregnancy='Pregnancy. Women of childbearing potential will undergo a pregnancy test during the screening visit';
    label orthostatic_hypotension='Orthostatic hypotension defined as >20 mm Hg decrease in systolic blood pressure 3-5 minutes following the transition from the supine to standing position';
    label supine_sys2='Systolic';
    label supine_dia2='Diastolic';
    label standing_sys1='Systolic';
    label standing_dia1='Diastolic';
    label native_conduction='Any rhythm other than sinus with native conduction at the time of screening, based on a 12-lead ECG. Patients with paroxysmal atrial fibrillation can be enrolled as long as their rhythm is sinus at the time of enrollment. ';
    label hemoglobin='Hemoglobin < 10 g/dL';
    label baseline_labs='(Hemoglobin from baseline labs)';
    label inability_exercise='Inability/unwillingness to exercise';
    label valvular_disease='Moderate or greater left sided valvular disease (mitral regurgitation, aortic stenosis, aortic regurgitation), any degree of mitral stenosis, severe right-sided valvular disease, or presence of a prosthetic valve.';
    label hypertrophic='Hypertrophic, infiltrative, or inflammatory cardiomyopathy';
    label pericardial_disease='Pericardial disease';
    label current_angina='Current angina';
    label coronary_syndrome='Acute coronary syndrome or coronary intervention within the past 2 months';
    label primary_pulmonary='Primary pulmonary arteriopathy';
    label chronic_obstructive='Clinically significant lung disease as defined by: Chronic Obstructive pulmonary disease meeting Stage III or greater GOLD criteria, treatment with oral steroids within the past 6 months for an exacerbation of obstructive lung disease, or the use of daytime supplemental oxygen';
    label stress_testing='Ischemia on stress testing without subsequent revascularization';
    label ventricular_ejection='Left ventricular ejection fraction < 45% in any prior echocardiogram or cardiac MRI.';
    label phosphodiesterase='Treatment with phosphodiesterase inhibitors that cannot be withheld';
    label organic_nitrates='Treatment with organic nitrates';
    label liver_disease='Significant liver disease impacting synthetic function or volume control (ALT/AST > 3x ULN, Albumin < 3.0 g/dL)';
    label alt='ALT';
    label ast='AST';
    label alb='ALB';
    label egfr='eGFR < 30 mL/min/1.73m2  ';
    label baseline_egfr='eGFR (baseline labs)';
    label g6pd_deficiency='G6PD deficiency. In males of African, Asian or Mediterranean decent, this will be formally excluded prior to enrollment.';
    label methemoglobinemia='Methemoglobinemia - baseline methemoglobin level >5%  ';
    label methemoglobin='% methemoglobin';
    label hyperkalemia_serum='Hyperkalemia (serum K>5.0 mEq/L).   ';
    label hyperkalemia='Hyperkalemia (serum K>5.0 mEq/L).   ';
    label ventricular_dysfunction='Severe right ventricular dysfunction';
    label medical_condition='Any medical condition that, in the opinion of the investigator, will interfere with the safe completion of the study.';
    label contraindications_to_mri='Contraindications to MRI, including the presence of a pacemaker, metal implants, claustrophobia, have worked around a metal grinder or a construction site, or that have known medical conditions which can be exacerbated by stress such as anxiety or panic attacks. Inability to lie flat in the MRI scanner for 90 minutes is also an exclusion criterion';
    label intra_luminal_implant='ANY intra-luminal implant, filter, stent or valve replacement';
    label life_assist_device='ANY type of life assist device, pump, or prosthetic';
    label vascular_clip='ANY vascular clip or clamp';
    label visceral_organs='ANY surgically placed clips or clamps or bands on visceral organs';
    label intracranial_implants='ANY intracranial implants of any type other than dental fillings';
    label non_removable_piercings='ANY non-removable piercings, jewelry, or medicinal patch';
    label personal_history='ANY personal history of intraocular injury or fragment in or around the orbit that cannot be cleared through radiologic examination.';
    label radiologic_evaluation='ANY personal history of bullet, shrapnel, or stabbing wounds that cannot be cleared through radiologic evaluation.';
    label comments_form_el='Comments';
    label verified_by1='Verified by';
    label date7='date';
    label form_el_complete='Complete?';
    label na_form_bl_cl='Not Applicable';
    label consent_yn='Consent';
    label consent_ini='Initials ';
    label urine_yn='Urine Pregnancy Test';
    label urine_radio='Urine Pregnancy Test';
    label urine_ini='Initials ';
    label diet_yn='Dietary Restrictions Reviewed';
    label diet_ini='Initials ';
    label vital_yn='Physical exam and Vital Signs';
    label vital_ini='Initials ';
    label mw6_yn='6MW test';
    label mw6_ini='Initials ';
    label quality_yn='Quality of Life Questionnaire';
    label quality_ini='Initials ';
    label cognitive_test_yn='Cognitive Testing ';
    label cognitive_test_ini='Initials';
    label blood_yn='Blood Draw, saliva and urine samples';
    label blood_ini='Initials ';
    label g6pd_yn='G6PD deficiency screening required';
    label g6pd_ini='Initials ';
    label art_tono_yn='Arterial Tonometry';
    label art_tono_ini='Initials ';
    label echo_yn='Doppler Echocardiogram';
    label echo_ini='Initials ';
    label ekg_bl='EKG';
    label ekg_initials_bl='Initials';
    label labs_yn='Baseline labs reviewed ';
    label hemo_yn='Hemoglobin';
    label hemo_value='Value';
    label hemo_ini='Initials ';
    label creati_yn='Creatinine';
    label creati_value='Value';
    label creati_ini='Initials ';
    label egfr_yn='EGFR';
    label egfr_value='Value';
    label egfr_ini='Initials ';
    label meth_yn='Methemoglobin';
    label meth_value='Value';
    label meth_ini='Initials ';
    label potas_yn='Potassium';
    label potas_value='Value';
    label potas_ini='Initials ';
    label ntpro_yn='NTproBNP';
    label ntpro_value='Value';
    label ntpro_initials='Initials';
    label med_dis_yn='Medication dispensed';
    label med_dis_ini='Initials ';
    label bl_ch_name='Name ';
    label bl_ch_date='Date';
    label form_bl_cl_complete='Complete?';
    label na_form_6wk_cl='Not Applicable ';
    label urine_pregnancy_test='Urine Pregnancy Test';
    label urine_pregnancy_results='Results';
    label urine_pregnancy_ini='Initials';
    label dietary_questionnaire='Dietary Restrictions Reviewed ';
    label dietary_questionnaire_ini='Initials';
    label physical_exam='Physical Exam';
    label physical_exam_ini='Initials';
    label orthostatics='Orthostatics';
    label orthostatics_ini='Initials';
    label vital_signs='Vital Signs';
    label vital_signs_ini='Initials';
    label questionnaires_kccq='Questionnaires KCCQ';
    label questionnaires_kccq_ini='Initials';
    label potential_side_effects='Potential side effects ';
    label potential_side_effects_ini='Initials';
    label cognitive_test2_yn='Cognitive Testing';
    label congitive_test2_ini='Initials';
    label blood_draws_before='Blood Draws from IV and saliva and urine samples before meds';
    label blood_draws_before_ini='Initials';
    label light_breakfast='Light breakfast with study medication';
    label light_breakfast_ini='Initials';
    label blood_draws_after='Blood Draws from IV and saliva and urine samples 2hr after meds';
    label blood_draws_after_ini='Initials';
    label arterial_tonometry='Arterial Tonometry';
    label arterial_tonometry_ini='Initials';
    label doppler_echocardiogram='Doppler Echocardiogram';
    label doppler_echocardiogram_ini='Initials';
    label ekg_p1='EKG';
    label ekg_initials_p1='Initials';
    label bicycle_exercise_test='Bicycle Exercise Test';
    label bicycle_exercise_test_ini='Inititals';
    label muscle_mri='Muscle MRI with leg exercise';
    label muscle_mri_ini='Initials';
    label medication_dispensed='Time medication was dispensed';
    label stage_2_meds_ini='Initials';
    label stage_2_meds='Stage 2 meds given';
    label stage_1_meds_ini='Initials';
    label stage_1_meds='Stage 1 meds collected';
    label pill_count_ini='Initials';
    label pill_count_yn='Pill count';
    label pill_count_ini2_d9f='Initials';
    label cardiac_mri_performed_p1='Cardiac MRI performed ';
    label cardiac_mri_initials_p1='Initials';
    label date_6wk_cl_p1='Date';
    label signature_6wk_cl_p1='Signature';
    label form_6wk_cl_complete='Complete?';
    label na_form_6wk_cl_p2='Not Applicable';
    label urine_pregnancy_test_p2='Urine Pregnancy Test';
    label urine_pregnancy_results_p2='Results';
    label urine_pregnancy_ini_p2='Initials';
    label dietary_questionnaire_p2='Dietary Restrictions Reviewed ';
    label dietary_questionnaire_ini_p2='Initials';
    label physical_exam_p2='Physical Exam';
    label physical_exam_ini_p2='Initials';
    label orthostatics_p2='Orthostatics';
    label orthostatics_ini_p2='Initials';
    label vital_signs_p2='Vital Signs';
    label vital_signs_ini_p2='Initials';
    label questionnaires_kccq_p2='Questionnaires KCCQ';
    label questionnaires_kccq_ini_p2='Initials';
    label potential_side_effects_p2='Potential side effects ';
    label potential_side_effects_ini_p2='Initials';
    label cognitive_test3_yn='Cognitive Testing';
    label cognitive_test3_ini='Initials';
    label blood_draws_before_p2='Blood Draws from IV and saliva and urine samples before meds';
    label blood_draws_before_ini_p2='Initials';
    label light_breakfast_p2='Light breakfast with study medication';
    label light_breakfast_ini_p2='Initials';
    label blood_draws_after_p2='Blood Draws from IV and saliva and urine samples 2hr after meds';
    label blood_draws_after_ini_p2='Initials';
    label arterial_tonometry_p2='Arterial Tonometry';
    label arterial_tonometry_ini_p2='Initials';
    label doppler_echocardiogram_p2='Doppler Echocardiogram';
    label doppler_echocardiogram_ini_p2='Initials';
    label ekg_p2='EKG';
    label ekg_initials_p2='Initials';
    label bicycle_exercise_test_p2='Bicycle Exercise Test';
    label bicycle_exercise_test_ini_p2='Inititals';
    label muscle_mri_p2='Muscle MRI with leg exercise';
    label muscle_mri_ini_p2='Initials';
    label stage_1_meds_p2='Stage 2 meds collected';
    label pill_count_ini_p2='Initials';
    label pill_count_yn_p2='Pill count';
    label pill_count_ini2_d9f_p2='Initials';
    label cardiac_mri_initials_p2='Cardiac MRI performed';
    label cardiac_mri_initials_phase_2='Initials';
    label form_bl_cl_cmplt_p2='FORM 6WK_CL Complete';
    label medication_dispensed_p2='Time medication was dispensed ';
    label stage_2_meds_ini_p2='Initials';
    label name_6wk_cl_p2='Name';
    label date_6wk_cl_p2='Date ';
    label signature_6wk_cl_p2='Signature';
    label form_6wk_cl_p2_complete='Complete?';
    label na_form_6wk_mri='Not Applicable';
    label mri_safety_checklist='MRI safety checklist reviewed (page 7)';
    label initials='MRI scan performed by (initials)';
    label field_strength1='Field Strength';
    label load_used1='Load Used (PSI)';
    label number_of_repetitions='Number of repetitions ';
    label repetitions_oth='If other, please specify';
    label load_used_psi='Load Used (PSI)';
    label number_of_repetitions1='Number of repetitions';
    label other_asl='If other, please specify';
    label comments='Comments';
    label data_exported='Data exported and placed in Box Shared Drive';
    label sig='Signature';
    label date98='Date';
    label complete_mri='Is form MRI complete?';
    label form_6wk_mri_complete='Complete?';
    label na_form_cardiac_mri='Not Applicable';
    label form_mri_enrolled='Is this subject enrolled on Cardiac MRI Sub-study? ';
    label form_mri_reviewed='MRI safety checklist reviewed by MRI technician';
    label form_mri_performed='MRI scan performed by :';
    label form_mri_time='Time (24: hr)';
    label form_mri_hr='HR';
    label form_mri_systolic='Systolic';
    label form_mri_diastolic='Diastolic';
    label form_mri_weight='Weight';
    label form_mri_weight_units='Weight Units';
    label mri_form_weight_other='If Weight Units is other, please specify';
    label form_mri_basis1='Contraindications to regadenoson stress testing reviewed and are absent, including: unstable CAD or heart failure, BP < 90/50 or >180/100 mm Hg, 2nd or 3rd degree AV block, hypersensitivity to drug';
    label form_mri_basis2='No contraindications to gadolinium based contrast agent are present, including: GFR < 30 ml/min,  acute Kidney injury, hypersensitivity to contrast agent';
    label form_mri_meds='Medication reviewed: no caffeine, aminophylline, theophylline within 24 hours; no dipyridamole or erectile dysfunction medication within 48 hours';
    label form_mri_stable='Subject stable at rest';
    label form_mri_beta_blockers='Beta blockers taken within 24 hours ';
    label form_mri_nitrates='Nitrates taken within 24 hours ';
    label form_mri_base_ecg='Baseline ECG findings: ';
    label form_mri_comment='Comments: ';
    label form_mri_post_time='Time (24: hr)';
    label form_mri_post_hr='HR';
    label form_mri_post_systolic='Systolic';
    label form_mri_post_diastolic='Diastolic';
    label form_mri_post_ecg='Post-regadenoson ECG findings: ';
    label form_mri_post_reported='Subject reported ';
    label form_mri_post_symptoms='If Subject reported is Following symptom(s), please specify';
    label form_mri_post_discharge='Subject stable for discharge';
    label form_cardiac_mri_complete='Complete?';
    label na_form_mh='Not Applicable';
    label penn_chart='Data were obtained directly from patient or from EPIC unless otherwise specified.';
    label age='Age';
    label gender='Gender';
    label race___1='Race (choice=White)';
    label race___2='Race (choice=African American)';
    label race___3='Race (choice=Asian)';
    label race___4='Race (choice=Native Hawaiian/Pacific Islander)';
    label race___5='Race (choice=Native American)';
    label race___6='Race (choice=Other)';
    label race_oth='If Race is other, Please specify';
    label type_decent='Male of African, Asian or Mediterranean decent';
    label acutecoronary='Acute coronary syndrome/MI';
    label acutecoronary_ai='Additional information';
    label prior_angina='Prior angina';
    label prior_angina_ai='Additional Information';
    label any_arrhythmia='Any Arrhythmia';
    label any_arrhythmia_ai='Additional Information';
    label valv_disease_surgery='Significant Valvular disease/Valve surgery in past';
    label valv_disease_surgery_ai='Additional Information';
    label htn='HTN';
    label htn_ai='Additional Information';
    label high_cholesterol='High Cholesterol';
    label high_cholesterol_ai='Additional Information';
    label peripheral_vascular='Peripheral vascular disease (carotid/aortic/femoral stenosis or hx of claudications) ';
    label peripheral_vascular_ai='Additional Information';
    label diabetes='Diabetes ';
    label diabetes_ai='Additional Information';
    label insulin='On insulin?';
    label insulin_ai='Additional Information';
    label cva_tia='CVA/TIA';
    label cva_tia_ai='Additional Information';
    label pulmonary_embolism_dvt='Pulmonary embolism/DVT';
    label pulmonary_embolism_dvt_ai='Additional Information';
    label osa='OSA';
    label osa_ai='Additional Information';
    label cpap='CPAP';
    label cpap_ai='Additional Information';
    label copd_asthma='COPD/Asthma';
    label copd_asthma_ai='Additional Information';
    label osteoarthritis='Osteoarthritis';
    label osteoarthritis_ai='Additional Information';
    label other_conditions='Other Conditions';
    label other_conditions_ai='Additional Information';
    label cabg='CABG';
    label cabg_ai='Additional Information';
    label peripheral='Peripheral vascular surgery';
    label peripheral_ai='Additional Information';
    label valvular_surgery='Valvular surgery';
    label valvular_ai='Additional Information';
    label congenital_surgery='Congenital surgery';
    label congenital_surgery_ai='Additional Information';
    label trauma_requiring_surgery='Trauma requiring surgery';
    label trauma_req_surgery_ai='Additional Information';
    label other_surgeries='Other surgeries';
    label current_smoker='Current Smoker';
    label pack_years='If yes, # of packs/year';
    label prior_smoker='Prior Smoker';
    label prior_smoker_ai='Additional Information';
    label current_alcohol='Current Alcohol';
    label drinks_day='If yes, #drinks/day';
    label drinks_add_info='Additional Information';
    label prior_alcohol='Prior Alcohol';
    label prior_alcohol_ai='Additional Information';
    label recreational_drug_use='Recreational Drug Use';
    label recreational_drug_usead='If yes, list:';
    label occupation_yn='Occupation';
    label occupation='Additional Information';
    label signature='Signature';
    label date9='Date';
    label nyhaclass='Current NYHA Class';
    label orthopnea='Orthopnea - unable to lie flat without shortness of breath';
    label paroxysmal_nocturnal='Paroxysmal Nocturnal Dyspnea - wake up in the middle of night with shortness of breath ';
    label lower_extremity_edema='Lower Extremity Edema - swelling in the ankles and/or legs ';
    label num_of_stairs='Number of flights of stairs that can be climbed before needing to stop  ';
    label reason_for_stopping='Reason for stopping?';
    label distance='Distance that can be walked on flat surface before needing to stop   ';
    label block_miles='Distance Units (generally number of blocks or distance in miles)';
    label distance_other='If other, Please Specify';
    label stop_walk='Reason for stopping?';
    label crvalue='Value';
    label crdate='Date';
    label egfr_value2='Value';
    label egfr_date='Date';
    label nt_pro_bnp_value='Value';
    label nt_pro_bnp_date='Date';
    label hemoglobin_value='Value';
    label hemoglobin_date='Date';
    label hematocrit_value='Value';
    label hematocrit_date='Date';
    label hemoglobin_a1c_value='Value';
    label hemoglobin_a1c_date='Date';
    label other_lab_data='Other';
    label cholesterol_total='Value';
    label cholesterol_total_date='Date';
    label triglycerides_value='Value';
    label triglycerides_date='Date';
    label hdl_cholesterol='Value';
    label hdl_cholesterol_date='Date';
    label ldl='Value';
    label ldl_date='Date';
    label vldl='Value';
    label vldl_date='Date';
    label non_hdl='Value';
    label non_hdl_date='Date';
    label prev_hrt_catheter='Performed?';
    label pcwp_12='PCWP>12?';
    label lvedp_16='LVEDP>16?';
    label hrt_catheter_date='Date';
    label pcwp_value='PCWP Value';
    label lvedp_value='LVEDP Value';
    label prior_stress_test='Performed?';
    label stress_test_date='Date';
    label stress_test_result='Results: (positive/negative)';
    label comments_stress_test='Comments';
    label allergies='Allergies';
    label performed_by_date='Date';
    label performed_by_signature='Signature';
    label form_mh_complete='Complete?';
    label datetime_seconds1='This field is used for branching logic across events in a longitudinal project and does not appear in the survey';
    label na_form_lab_pre_medication='Not Applicable';
    label iv_line_required_1='        ';
    label iv_time_1='Time (24: hr): ';
    label gauge_1='Gauge';
    label site_1='Site';
    label preg_test='Pregnancy test (WOCBP) - urine';
    label cmp_gold='Comprehensive Metabolic panel- gold tube';
    label pax_gene='PAX gene';
    label nt_pro='NTproBNP - gold tube';
    label form_lab_methemoglobin='Methemoglobin - green tube';
    label form_lab_cbc='CBC - purple tube';
    label g6pd_test='G6PD deficiency screening (males of African, Asian, or Mediterranean descent) - gold tube';
    label urine_cc='Urine (~50 cc)';
    label plasma_purp='Plasma (Purple top)';
    label serum_red='Serum (Red top)';
    label saliva_tube='Saliva';
    label notes_pm='Notes';
    label perf_by_lab='Name';
    label date_lab='Date';
    label form_lab_6412_complete='Complete?';
    label na_form_lab_peak_bike='Not Applicable ';
    label iv_time_1_v3='Time (24: hr): ';
    label complete_lab_v3='Is form lab complete?';
    label plasma_bike='Plasma - Purple top';
    label serum_bike='Serum - Red Top';
    label notes_pb='Notes';
    label form_lab_pre_medicat_v_0='Complete?';
    label na_form_lab_post_med=' Not Applicable ';
    label iv_time_1_v2='Time (24: hr): ';
    label complete_lab_v2='Is form lab complete?';
    label urine_post='1. Urine (~50 cc)';
    label plasma_post='2. Plasma - purple top';
    label serum_post='3. Serum- Red Top';
    label saliva_post='4. Saliva';
    label notes_2hr='Notes';
    label form_lab_pre_medicat_v_1='Complete?';
    label na_physical_exam='Not Applicable ';
    label form_pe_obtained='Data were obtained directly from patient or from Penn Chart unless otherwise specified.';
    label height_2='Height';
    label height_2_units='Height Units';
    label weight_2='Weight';
    label weight_2_units='Weight Units';
    label systolic_2='Systolic';
    label diastolic_2='Diastolic';
    label blood_pressure_arm_2='Blood Pressure site';
    label heart_rate_2='Heart Rate:';
    label o2_saturation_2='O2 Saturation:';
    label hr='HR:';
    label rr_2='RR:';
    label jvp_2='JVP:';
    label jvp_category='JVP:';
    label ekg='EKG Performed';
    label heart_2='Heart:';
    label lungs_2='Lungs:';
    label abd_2='Abd:';
    label extremities_2='Extremities:';
    label additional_notes_pe='Additional Notes:';
    label extrem_performed='Name';
    label extremities_date='Date:';
    label extremities_signature='Signature: ';
    label sup_systolic_2='Systolic';
    label sup_diastolic_2='Diastolic';
    label stan_systolic_2='Systolic';
    label stan_diastolic_2='Diastolic';
    label orthostatic_symptoms_yn='Orthostatic symptoms present? ';
    label ortho_sympt_descr='If orthostatic symptoms are present, please describe the symptoms: ';
    label comments_phy='Comments:';
    label sars_yn='Did the patient receive a vaccination against SARS CoV 2?';
    label sars_vaccine='Specific vaccine ';
    label sars_dose_date='Number of doses and approximate date(s) ';
    label sars_notes='Other Notes: ';
    label phys_by='Name';
    label phys_date='Date';
    label form_pe_complete='Complete?';
    label na_end_phase_se_review='Not Applicable';
    label mouthwash_se_ep='Reviewed need to avoid mouthwash during participation in the study.';
    label compliant_with_mouthwash_se_ep='Compliant with mouthwash.';
    label reviewed_no_viagra_se_ep='Reviewed NO Viagra, Levitra or Cialis allowed during participation in the study.';
    label dietary_restrictions_se_ep='Reviewed dietary restrictions during participation in the study.';
    label headache_se_ep='Headache';
    label dizziness_se_ep='Dizziness';
    label lightheadedness_se_ep='Lightheadedness';
    label low_blood_pressure_90_se_ep='Low blood pressure (< 90)';
    label stomach_ache_diarrhea_se_ep='Stomach Ache, diarrhea, nausea, or vomiting';
    label increased_shortness_se_ep='Increased Shortness of breath';
    label flushing_se_ep='Flushing';
    label rash_se_ep='Rash';
    label ch_in_blood_pressure_se_ep='Drop in blood pressure when standing up';
    label swelling_se_ep='Swelling';
    label fatigue_se_assess='Fatigue';
    label other_symps_se='Other symptom(s)';
    label orthostat_se_ep='Presence of orthostatic symptoms? ';
    label orthostat_se_dscr_ep='If yes to any side effects please explain';
    label performed_by776_se_ep='Performed by';
    label phys_date_se_ep='Date';
    label form_p1_se_ep='Form End Phase Side Effect Review Complete?';
    label end_phase_side_effec_v_2='Complete?';
    label na_form_mh_p1_p2='Not Applicable';
    label penn_chart_6p='Have there been any changes in the subject''s medical history since the baseline visit?';
    label age_6p='Age';
    label gender_6p='Gender';
    label race_6p___1='Race (choice=White)';
    label race_6p___2='Race (choice=African American)';
    label race_6p___3='Race (choice=Asian)';
    label race_6p___4='Race (choice=Native Hawaiian/Pacific Islander)';
    label race_6p___5='Race (choice=Native American)';
    label race_6p___6='Race (choice=Other)';
    label race_oth_6p='If Race is other, Please specify';
    label type_decent_6p='Male of African, Asian or Mediterranean decent';
    label acutecoronary_6p='Acute coronary syndrome/MI';
    label acutecoronary_ai_6p='Additional information';
    label prior_angina_6p='Prior angina';
    label prior_angina_ai_6p='Additional Information';
    label any_arrhythmia_6p='Any Arrhythmia';
    label any_arrhythmia_ai_6p='Additional Information';
    label valv_disease_surgery_6p='Significant Valvular disease/Valve surgery in past';
    label valv_disease_surgery_ai_6p='Additional Information';
    label htn_6p='HTN';
    label htn_ai_6p='Additional Information';
    label high_cholesterol_6p='High Cholesterol';
    label high_cholesterol_ai_6p='Additional Information';
    label peripheral_vascular_6p='Peripheral vascular disease  (carotid/aortic/femoral stenosis or hx of claudications) ';
    label peripheral_vascular_ai_6p='Additional Information';
    label diabetes_6p='Diabetes ';
    label diabetes_ai_6p='Additional Information';
    label insulin_6p='On insulin?';
    label insulin_ai_6p='Additional Information';
    label cva_tia_6p='CVA/TIA';
    label cva_tia_ai_6p='Additional Information';
    label pulmonary_embolism_dvt_6p='Pulmonary embolism/DVT';
    label pulmonary_embolism_dvt_ai_6p='Additional Information';
    label osa_6p='OSA';
    label osa_ai_6p='Additional Information';
    label cpap_6p='CPAP';
    label cpap_ai_6p='Additional Information';
    label copd_asthma_6p='COPD/Asthma';
    label copd_asthma_ai_6p='Additional Information';
    label osteoarthritis_6p='Osteoarthritis';
    label osteoarthritis_ai_6p='Additional Information';
    label other_conditions_6p='Other Conditions';
    label other_conditions_ai_6p='Additional Information';
    label cabg_6p='CABG';
    label cabg_ai_6p='Additional Information';
    label peripheral_6p='Peripheral vascular surgery';
    label peripheral_ai_6p='Additional Information';
    label valvular_surgery_6p='Valvular surgery';
    label valvular_ai_6p='Additional Information';
    label congenital_surgery_6p='Congenital surgery';
    label congenital_surgery_ai_6p='Additional Information';
    label trauma_requiring_surgery_6p='Trauma requiring surgery';
    label trauma_req_surgery_ai_6p='Additional Information';
    label other_surgeries_6p='Other surgeries';
    label current_smoker_6p='Current Smoker';
    label pack_years_6p='If yes, # of packs/year';
    label prior_smoker_6p='Prior Smoker';
    label prior_smoker_ai_6p='Additional Information';
    label current_alcohol_6p='Current Alcohol';
    label drinks_day_6p='If yes, #drinks/day';
    label prior_alcohol_6p='Prior Alcohol';
    label prior_alcohol_ai_6p='Additional Information';
    label recreational_drug_use_6p='Recreational Drug Use';
    label recreational_drug_usead_6p='If yes, list:';
    label occupation_6p='Occupation';
    label signature_6p='Signature';
    label date9_6p='Date';
    label nyhaclass_6p='Current NYHA Class';
    label orthopnea_6p='Orthopnea - unable to lie flat without shortness of breath';
    label paroxysmal_nocturnal_6p='Paroxysmal Nocturnal Dyspnea - wake up in the middle of night with shortness of breath ';
    label lower_extremity_edema_6p='Lower Extremity Edema - swelling in the ankles and/or legs ';
    label num_of_stairs_6p='Number of flights of stairs that can be climbed before needing to stop  ';
    label reason_for_stopping_6p='Reason for stopping?';
    label distance_6p='Distance that can be walked on flat surface before needing to stop  (generally number of blocks or distance in miles) ';
    label block_miles_6p='Blocks or Miles';
    label stop_walk_6p='Reason for stopping?';
    label crvalue_6p='Cr Value';
    label crdate_6p='Cr Date';
    label egfr_value2_6p='eGFR Value';
    label egfr_date_6p='eGFR date';
    label nt_pro_bnp_value_6p='NT-pro-BNP value';
    label nt_pro_bnp_date_6p='NT-pro-BNP date';
    label hemoglobin_value_6p='Hemoglobin value';
    label hemoglobin_date_6p='Hemoglobin date';
    label hematocrit_value_6p='Hematocrit Value';
    label hematocrit_date_6p='Hematocrit Date';
    label hemoglobin_a1c_value_6p='Hemoglobin A1C value';
    label hemoglobin_a1c_date_6p='Hemoglobin A1C date';
    label other_lab_data_6p='other';
    label prev_hrt_catheter_6p='Previous Invasively Measured Filling Pressures';
    label hrt_catheter_date_6p='Date of Invasively Measured Filling Pressures';
    label pcwp_12_6p='PCWP>12?';
    label pcwp_value_6p='PCWP Value';
    label lvedp_16_6p='LVEDP>16?';
    label lvedp_value_6p='LVEDP Value';
    label prior_stress_test_6p='Prior Stress Test? ';
    label stress_test_date_6p='If yes, date of stress test';
    label stress_test_result_6p='If yes, result of stress testing (positive/negative)?';
    label comments_stress_test_6p='Comments';
    label allergies_6p='Allergies';
    label performed_by_date_6p='Date';
    label performed_by_signature_6p='Signature';
    label bl_mh_cmplt_6p='Is FORM BL_MH complete?';
    label form_mh_8174_complete='Complete?';
    label na_medications='Not Applicable ';
    label date_med='Date';
    label num_med='Number of Medications';
    label meds_1='Medication 1';
    label med_oth_1='If Medication is Other, Please Specify';
    label dose_1='Dose';
    label comb_dose_1='Dose';
    label units_1='Specify Units';
    label units_oth_1='If Units is Other, Please Specify';
    label freq_1='Frequency';
    label freq_oth_1='If Frequency is OTHER, Please specify';
    label route_1='ROUTE';
    label route_oth_1='If ROUTE is Other, Please specify';
    label recent_start_date_1='Has the medication been initiated since the last visit?';
    label start_date_1='Start Date';
    label recent_end_date_1='Was this medication started and stopped since the last visit?';
    label end_date_1='End Date';
    label meds_2='Medication 2';
    label med_oth_2='If Medication is Other, Please Specify';
    label dose_2='Dose';
    label comb_dose_2='Dose';
    label units_2='Specify Units';
    label units_oth_2='If Units is Other, Please Specify';
    label freq_2='Frequency';
    label freq_oth_2='If Frequency is OTHER, Please specify';
    label route_2='ROUTE';
    label route_oth_2='If ROUTE is Other, Please specify';
    label recent_start_date_2='Has the medication been initiated since the last visit?';
    label start_date_2='Start Date';
    label recent_end_date_2='Was this medication started and stopped since the last visit?';
    label end_date_2='End Date';
    label meds_3='Medication 3';
    label med_oth_3='If Medication is Other, Please Specify';
    label dose_3='Dose';
    label comb_dose_3='Dose';
    label units_3='Specify Units';
    label units_oth_3='If Units is Other, Please Specify';
    label freq_3='Frequency';
    label freq_oth_3='If Frequency is OTHER, Please specify';
    label route_3='ROUTE';
    label route_oth_3='If ROUTE is Other, Please specify';
    label recent_start_date_3='Has the medication been initiated since the last visit?';
    label start_date_3='Start Date';
    label recent_end_date_3='Was this medication started and stopped since the last visit?';
    label end_date_3='End Date';
    label meds_4='Medication 4';
    label med_oth_4='If Medication is Other, Please Specify';
    label dose_4='Dose';
    label comb_dose_4='Dose';
    label units_4='Specify Units';
    label units_oth_4='If Units is Other, Please Specify';
    label freq_4='Frequency';
    label freq_oth_4='If Frequency is OTHER, Please specify';
    label route_4='ROUTE';
    label route_oth_4='If ROUTE is Other, Please specify';
    label recent_start_date_4='Has the medication been initiated since the last visit?';
    label start_date_4='Start Date';
    label recent_end_date_4='Was this medication started and stopped since the last visit?';
    label end_date_4='End Date';
    label meds_5='Medication 5';
    label med_oth_5='If Medication is Other, Please Specify';
    label dose_5='Dose';
    label comb_dose_5='Dose';
    label units_5='Specify Units';
    label units_oth_5='If Units is Other, Please Specify';
    label freq_5='Frequency';
    label freq_oth_5='If Frequency is OTHER, Please specify';
    label route_5='ROUTE';
    label route_oth_5='If ROUTE is Other, Please specify';
    label recent_start_date_5='Has the medication been initiated since the last visit?';
    label start_date_5='Start Date';
    label recent_end_date_5='Was this medication started and stopped since the last visit?';
    label end_date_5='End Date';
    label meds_6='Medication 6';
    label med_oth_6='If Medication is Other, Please Specify';
    label dose_6='Dose';
    label comb_dose_6='Dose';
    label units_6='Specify Units';
    label units_oth_6='If Units is Other, Please Specify';
    label freq_6='Frequency';
    label freq_oth_6='If Frequency is OTHER, Please specify';
    label route_6='ROUTE';
    label route_oth_6='If ROUTE is Other, Please specify';
    label recent_start_date_6='Has the medication been initiated since the last visit?';
    label start_date_6='Start Date';
    label recent_end_date_6='Was this medication started and stopped since the last visit?';
    label end_date_6='End Date';
    label meds_7='Medication 7';
    label med_oth_7='If Medication is Other, Please Specify';
    label dose_7='Dose';
    label comb_dose_7='Dose';
    label units_7='Specify Units';
    label units_oth_7='If Units is Other, Please Specify';
    label freq_7='Frequency';
    label freq_oth_7='If Frequency is OTHER, Please specify';
    label route_7='ROUTE';
    label route_oth_7='If ROUTE is Other, Please specify';
    label recent_start_date_7='Has the medication been initiated since the last visit?';
    label start_date_7='Start Date';
    label recent_end_date_7='Was this medication started and stopped since the last visit?';
    label end_date_7='End Date';
    label meds_8='Medication 8';
    label med_oth_8='If Medication is Other, Please Specify';
    label dose_8='Dose';
    label comb_dose_8='Dose';
    label units_8='Specify Units';
    label units_oth_8='If Units is Other, Please Specify';
    label freq_8='Frequency';
    label freq_oth_8='If Frequency is OTHER, Please specify';
    label route_8='ROUTE';
    label route_oth_8='If ROUTE is Other, Please specify';
    label recent_start_date_8='Has the medication been initiated since the last visit?';
    label start_date_8='Start Date';
    label recent_end_date_8='Was this medication started and stopped since the last visit?';
    label end_date_8='End Date';
    label meds_9='Medication 9';
    label med_oth_9='If Medication is Other, Please Specify';
    label dose_9='Dose';
    label comb_dose_9='Dose';
    label units_9='Specify Units';
    label units_oth_9='If Units is Other, Please Specify';
    label freq_9='Frequency';
    label freq_oth_9='If Frequency is OTHER, Please specify';
    label route_9='ROUTE';
    label route_oth_9='If ROUTE is Other, Please specify';
    label recent_start_date_9='Has the medication been initiated since the last visit?';
    label start_date_9='Start Date';
    label recent_end_date_9='Was this medication started and stopped since the last visit?';
    label end_date_9='End Date';
    label meds_10='Medication 10';
    label med_oth_10='If Medication is Other, Please Specify';
    label dose_10='Dose';
    label comb_dose_10='Dose';
    label units_10='Specify Units';
    label units_oth_10='If Units is Other, Please Specify';
    label freq_10='Frequency';
    label freq_oth_10='If Frequency is OTHER, Please specify';
    label route_10='ROUTE';
    label route_oth_10='If ROUTE is Other, Please specify';
    label recent_start_date_10='Has the medication been initiated since the last visit?';
    label start_date_10='Start Date';
    label recent_end_date_10='Was this medication started and stopped since the last visit?';
    label end_date_10='End Date';
    label meds_11='Medication 11';
    label med_oth_11='If Medication is Other, Please Specify';
    label dose_11='Dose';
    label comb_dose_11='Dose';
    label units_11='Specify Units';
    label units_oth_11='If Units is Other, Please Specify';
    label freq_11='Frequency';
    label freq_oth_11='If Frequency is OTHER, Please specify';
    label route_11='ROUTE';
    label route_oth_11='If ROUTE is Other, Please specify';
    label recent_start_date_11='Has the medication been initiated since the last visit?';
    label start_date_11='Start Date';
    label recent_end_date_11='Was this medication started and stopped since the last visit?';
    label end_date_11='End Date';
    label meds_12='Medication 12';
    label med_oth_12='If Medication is Other, Please Specify';
    label dose_12='Dose';
    label comb_dose_12='Dose';
    label units_12='Specify Units';
    label units_oth_12='If Units is Other, Please Specify';
    label freq_12='Frequency';
    label freq_oth_12='If Frequency is OTHER, Please specify';
    label route_12='ROUTE';
    label route_oth_12='If ROUTE is Other, Please specify';
    label recent_start_date_12='Has the medication been initiated since the last visit?';
    label start_date_12='Start Date';
    label recent_end_date_12='Was this medication started and stopped since the last visit?';
    label end_date_12='End Date';
    label meds_13='Medication 13';
    label med_oth_13='If Medication is Other, Please Specify';
    label dose_13='Dose';
    label comb_dose_13='Dose';
    label units_13='Specify Units';
    label units_oth_13='If Units is Other, Please Specify';
    label freq_13='Frequency';
    label freq_oth_13='If Frequency is OTHER, Please specify';
    label route_13='ROUTE';
    label route_oth_13='If ROUTE is Other, Please specify';
    label recent_start_date_13='Has the medication been initiated since the last visit?';
    label start_date_13='Start Date';
    label recent_end_date_13='Was this medication started and stopped since the last visit?';
    label end_date_13='End Date';
    label meds_14='Medication 14';
    label med_oth_14='If Medication is Other, Please Specify';
    label dose_14='Dose';
    label comb_dose_14='Dose';
    label units_14='Specify Units';
    label units_oth_14='If Units is Other, Please Specify';
    label freq_14='Frequency';
    label freq_oth_14='If Frequency is OTHER, Please specify';
    label route_14='ROUTE';
    label route_oth_14='If ROUTE is Other, Please specify';
    label recent_start_date_14='Has the medication been initiated since the last visit?';
    label start_date_14='Start Date';
    label recent_end_date_14='Was this medication started and stopped since the last visit?';
    label end_date_14='End Date';
    label meds_15='Medication 15';
    label med_oth_15='If Medication is Other, Please Specify';
    label dose_15='Dose';
    label comb_dose_15='Dose';
    label units_15='Specify Units';
    label units_oth_15='If Units is Other, Please Specify';
    label freq_15='Frequency';
    label freq_oth_15='If Frequency is OTHER, Please specify';
    label route_15='ROUTE';
    label route_oth_15='If ROUTE is Other, Please specify';
    label recent_start_date_15='Has the medication been initiated since the last visit?';
    label start_date_15='Start Date';
    label recent_end_date_15='Was this medication started and stopped since the last visit?';
    label end_date_15='End Date';
    label meds_16='Medication 16';
    label med_oth_16='If Medication is Other, Please Specify';
    label dose_16='Dose';
    label comb_dose_16='Dose';
    label units_16='Specify Units';
    label units_oth_16='If Units is Other, Please Specify';
    label freq_16='Frequency';
    label freq_oth_16='If Frequency is OTHER, Please specify';
    label route_16='ROUTE';
    label route_oth_16='If ROUTE is Other, Please specify';
    label recent_start_date_16='Has the medication been initiated since the last visit?';
    label start_date_16='Start Date';
    label recent_end_date_16='Was this medication started and stopped since the last visit?';
    label end_date_16='End Date';
    label meds_17='Medication 17';
    label med_oth_17='If Medication is Other, Please Specify';
    label dose_17='Dose';
    label comb_dose_17='Dose';
    label units_17='Specify Units';
    label units_oth_17='If Units is Other, Please Specify';
    label freq_17='Frequency';
    label freq_oth_17='If Frequency is OTHER, Please specify';
    label route_17='ROUTE';
    label route_oth_17='If ROUTE is Other, Please specify';
    label recent_start_date_17='Has the medication been initiated since the last visit?';
    label start_date_17='Start Date';
    label recent_end_date_17='Was this medication started and stopped since the last visit?';
    label end_date_17='End Date';
    label meds_18='Medication 18';
    label med_oth_18='If Medication is Other, Please Specify';
    label dose_18='Dose';
    label comb_dose_18='Dose';
    label units_18='Specify Units';
    label units_oth_18='If Units is Other, Please Specify';
    label freq_18='Frequency';
    label freq_oth_18='If Frequency is OTHER, Please specify';
    label route_18='ROUTE';
    label route_oth_18='If ROUTE is Other, Please specify';
    label recent_start_date_18='Has the medication been initiated since the last visit?';
    label start_date_18='Start Date';
    label recent_end_date_18='Was this medication started and stopped since the last visit?';
    label end_date_18='End Date';
    label meds_19='Medication 19';
    label med_oth_19='If Medication is Other, Please Specify';
    label dose_19='Dose';
    label comb_dose_19='Dose';
    label units_19='Specify Units';
    label units_oth_19='If Units is Other, Please Specify';
    label freq_19='Frequency';
    label freq_oth_19='If Frequency is OTHER, Please specify';
    label route_19='ROUTE';
    label route_oth_19='If ROUTE is Other, Please specify';
    label recent_start_date_19='Has the medication been initiated since the last visit?';
    label start_date_19='Start Date';
    label recent_end_date_19='Was this medication started and stopped since the last visit?';
    label end_date_19='End Date';
    label meds_20='Medication 20';
    label med_oth_20='If Medication is Other, Please Specify';
    label dose_20='Dose';
    label comb_dose_20='Dose';
    label units_20='Specify Units';
    label units_oth_20='If Units is Other, Please Specify';
    label freq_20='Frequency';
    label freq_oth_20='If Frequency is OTHER, Please specify';
    label route_20='ROUTE';
    label route_oth_20='If ROUTE is Other, Please specify';
    label recent_start_date_20='Has the medication been initiated since the last visit?';
    label start_date_20='Start Date';
    label recent_end_date_20='Was this medication started and stopped since the last visit?';
    label end_date_20='End Date';
    label meds_21='Medication 21';
    label med_oth_21='If Medication is Other, Please Specify';
    label dose_21='Dose';
    label comb_dose_21='Dose';
    label units_21='Specify Units';
    label units_oth_21='If Units is Other, Please Specify';
    label freq_21='Frequency';
    label freq_oth_21='If Frequency is OTHER, Please specify';
    label route_21='ROUTE';
    label route_oth_21='If ROUTE is Other, Please specify';
    label recent_start_date_21='Has the medication been initiated since the last visit?';
    label start_date_21='Start Date';
    label recent_end_date_21='Was this medication started and stopped since the last visit?';
    label end_date_21='End Date';
    label meds_22='Medication 22';
    label med_oth_22='If Medication is Other, Please Specify';
    label dose_22='Dose';
    label comb_dose_22='Dose';
    label units_22='Specify Units';
    label units_oth_22='If Units is Other, Please Specify';
    label freq_22='Frequency';
    label freq_oth_22='If Frequency is OTHER, Please specify';
    label route_22='ROUTE';
    label route_oth_22='If ROUTE is Other, Please specify';
    label recent_start_date_22='Has the medication been initiated since the last visit?';
    label start_date_22='Start Date';
    label recent_end_date_22='Was this medication started and stopped since the last visit?';
    label end_date_22='End Date';
    label meds_23='Medication 23';
    label med_oth_23='If Medication is Other, Please Specify';
    label dose_23='Dose';
    label comb_dose_23='Dose';
    label units_23='Specify Units';
    label units_oth_23='If Units is Other, Please Specify';
    label freq_23='Frequency';
    label freq_oth_23='If Frequency is OTHER, Please specify';
    label route_23='ROUTE';
    label route_oth_23='If ROUTE is Other, Please specify';
    label recent_start_date_23='Has the medication been initiated since the last visit?';
    label start_date_23='Start Date';
    label recent_end_date_23='Was this medication started and stopped since the last visit?';
    label end_date_23='End Date';
    label meds_24='Medication 24';
    label med_oth_24='If Medication is Other, Please Specify';
    label dose_24='Dose';
    label comb_dose_24='Dose';
    label units_24='Specify Units';
    label units_oth_24='If Units is Other, Please Specify';
    label freq_24='Frequency';
    label freq_oth_24='If Frequency is OTHER, Please specify';
    label route_24='ROUTE';
    label route_oth_24='If ROUTE is Other, Please specify';
    label recent_start_date_24='Has the medication been initiated since the last visit?';
    label start_date_24='Start Date';
    label recent_end_date_24='Was this medication started and stopped since the last visit?';
    label end_date_24='End Date';
    label meds_25='Medication 25';
    label med_oth_25='If Medication is Other, Please Specify';
    label dose_25='Dose';
    label comb_dose_25='Dose';
    label units_25='Specify Units';
    label units_oth_25='If Units is Other, Please Specify';
    label freq_25='Frequency';
    label freq_oth_25='If Frequency is OTHER, Please specify';
    label route_25='ROUTE';
    label route_oth_25='If ROUTE is Other, Please specify';
    label recent_start_date_25='Has the medication been initiated since the last visit?';
    label start_date_25='Start Date';
    label recent_end_date_25='Was this medication started and stopped since the last visit?';
    label end_date_25='End Date';
    label meds_26='Medication 26';
    label med_oth_26='If Medication is Other, Please Specify';
    label dose_26='Dose';
    label comb_dose_26='Dose';
    label units_26='Specify Units';
    label units_oth_26='If Units is Other, Please Specify';
    label freq_26='Frequency';
    label freq_oth_26='If Frequency is OTHER, Please specify';
    label route_26='ROUTE';
    label route_oth_26='If ROUTE is Other, Please specify';
    label recent_start_date_26='Has the medication been initiated since the last visit?';
    label start_date_26='Start Date';
    label recent_end_date_26='Was this medication started and stopped since the last visit?';
    label end_date_26='End Date';
    label meds_27='Medication 27';
    label med_oth_27='If Medication is Other, Please Specify';
    label dose_27='Dose';
    label comb_dose_27='Dose';
    label units_27='Specify Units';
    label units_oth_27='If Units is Other, Please Specify';
    label freq_27='Frequency';
    label freq_oth_27='If Frequency is OTHER, Please specify';
    label route_27='ROUTE';
    label route_oth_27='If ROUTE is Other, Please specify';
    label recent_start_date_27='Has the medication been initiated since the last visit?';
    label start_date_27='Start Date';
    label recent_end_date_27='Was this medication started and stopped since the last visit?';
    label end_date_27='End Date';
    label meds_28='Medication 28';
    label med_oth_28='If Medication is Other, Please Specify';
    label dose_28='Dose';
    label comb_dose_28='Dose';
    label units_28='Specify Units';
    label units_oth_28='If Units is Other, Please Specify';
    label freq_28='Frequency';
    label freq_oth_28='If Frequency is OTHER, Please specify';
    label route_28='ROUTE';
    label route_oth_28='If ROUTE is Other, Please specify';
    label recent_start_date_28='Has the medication been initiated since the last visit?';
    label start_date_28='Start Date';
    label recent_end_date_28='Was this medication started and stopped since the last visit?';
    label end_date_28='End Date';
    label meds_29='Medication 29';
    label med_oth_29='If Medication is Other, Please Specify';
    label dose_29='Dose';
    label comb_dose_29='Dose';
    label units_29='Specify Units';
    label units_oth_29='If Units is Other, Please Specify';
    label freq_29='Frequency';
    label freq_oth_29='If Frequency is OTHER, Please specify';
    label route_29='ROUTE';
    label route_oth_29='If ROUTE is Other, Please specify';
    label recent_start_date_29='Has the medication been initiated since the last visit?';
    label start_date_29='Start Date';
    label recent_end_date_29='Was this medication started and stopped since the last visit?';
    label end_date_29='End Date';
    label meds_30='Medication 30';
    label med_oth_30='If Medication is Other, Please Specify';
    label dose_30='Dose';
    label comb_dose_30='Dose';
    label units_30='Specify Units';
    label units_oth_30='If Units is Other, Please Specify';
    label freq_30='Frequency';
    label freq_oth_30='If Frequency is OTHER, Please specify';
    label route_30='ROUTE';
    label route_oth_30='If ROUTE is Other, Please specify';
    label recent_start_date_30='Has the medication been initiated since the last visit?';
    label start_date_30='Start Date';
    label recent_end_date_30='Was this medication started and stopped since the last visit?';
    label end_date_30='End Date';
    label data_epic_med='Data were obtained directly from patient or from Epic unless otherwise specified.';
    label med_comments='Comments';
    label medications_complete='Complete?';
    label na_cognitive_testing='Not Applicable';
    label shopping_test_yn='International shopping list test completed';
    label gorton_test_yn='Gorton maze learning test completed';
    label detection_test_yn='Detection test completed';
    label identification_test_yn='Identification test completed';
    label card_test_yn='One card learning test completed';
    label one_back_test_yn=' One back test completed';
    label delayed_recall_test_yn='International shopping list test- Delayed recall completed';
    label data_backed_up_yn='Data backed up to the COGSTATE central server';
    label cognitive_comments='Comments';
    label form_ct_name='Name';
    label form_ct_date='Date';
    label signature_cog_test='Signature';
    label cognitive_testing_complete='Complete?';
    label na_form_vp='Not Applicable';
    label ult_sd_perf_1='Ultrasound of Heart and Peripheral Vessels Echo Performed by';
    label sternal_angle_to_carotid_1='cm';
    label ster_carotid_1='Right / Left - Carotid';
    label sternal_angle_to_femoral_1='cm';
    label ster_femoral_1='Right / Left - Femoral';
    label sternal_angle_to_radial_1='cm';
    label ster_radial_1='Right / Left - Radial ';
    label sternal_length='cm';
    label bp_collected_yn='BP+ Collected';
    label bp_study_id='BP+ subject ID:';
    label pb_plus_systolic='Systolic';
    label bp_plus_diastolic='Diastolic';
    label pre_bike_systolic_1='Systolic';
    label pre_bike_diastolic_1='Diastolic';
    label time_1='Time (24:hr)';
    label hr_1='HR';
    label map='MAP (Mean Arterial Pressure)';
    label initials_1='Initials';
    label carotid_1='Side (R vs L)';
    label carotid_tonometry='Tonometry';
    label carotid_vasc='Vascular Flow (Pulsed Wave Doppler) - only at Penn';
    label femora_1='Side (R vs L)';
    label femoral_tonometry='Tonometry';
    label femora_vasc='Vascular Flow (Pulsed Wave Doppler) - only at Penn';
    label radial_1='Side (R vs L)';
    label radial_tonometry='Tonometry';
    label radial_vasc='Vascular Flow (Pulsed Wave Doppler) - only at Penn';
    label lvot_flow='LVOT flow done and labeled by echo tech as follows: Flow for tono (insert text in DICOM image)';
    label comment_1='Comments';
    label form_vp_name='Name';
    label form_vp_date='Date';
    label form_vp_complete='Complete?';
    label na_form_6mwt='Not Applicable ';
    label checklist_bl_6mwt___1='Checklist (choice=Subject took usual medications the morning of the test)';
    label checklist_bl_6mwt___2='Checklist (choice=Confirm area for walk test is set up correctly (cleared space, cones, measured distances))';
    label checklist_bl_6mwt___3='Checklist (choice=Confirm the stopwatch and lap counter applications are working well)';
    label checklist_bl_6mwt___4='Checklist (choice=Make sure that the patient is wearing comfortable footgear)';
    label checklist_bl_6mwt___5='Checklist (choice=Make sure a chair is available)';
    label checklist_bl_6mwt___6='Checklist (choice=The patient should sit at rest in a chair, located near the starting position, for at least 10 minutes before the test starts.)';
    label dyspnea_borg_score='Dyspnea Borg score (0-10)';
    label fatigue_borg_score='Fatigue Borg score (0-10)';
    label heart_rate='Heart Rate (beats per minutes)';
    label pulse_oximetry='Pulse Oximetry';
    label systolic_bf='Systolic (mmHg)';
    label diastolic_bf='Diastolic (mmHg)';
    label pretest_instruction___1='pretest instruction (choice=Conduct 6 minute walk test (Important: Repeat testing should be performed about the same time of day to minimize variability))';
    label pretest_instruction___2='pretest instruction (choice=Mark the spot where they stopped by placing a bean bag or a piece of tape on the floor)';
    label post_dyspnea_borg='Dyspnea Borg score: ';
    label post_fatigue_borg='Fatigue Borg score:';
    label post_bpm='Heart Rate (beats per minute)';
    label post_pulse_oximetry='Pulse Oximetry';
    label systolic_af='Systolic (mmHg)';
    label diastolic_af='Diastolic (mmHg)';
    label test_start_time='Exact time at which test started';
    label total_meters_walked='Total meters walked';
    label notes='Notes';
    label perform_date='Date:';
    label perform_sig='Signature:';
    label complete_6mwt='Is form 6mwt complete?';
    label form_6mwt_complete='Complete?';
    label na_form_6wk_ex='Not Applicable';
    label bicyc_1='Bicycling begins: Time (24: hr):';
    label initial_1='Initials';
    label stage_1_yn='Stage I';
    label stage_1_systolic_1='Systolic';
    label stage_1_diastolic_1='Diastolic';
    label stage_1_hr_1='HR ';
    label stage_1_o2_1='O2Sat';
    label stage_1_ultras_1='Ultrasound';
    label stage_2_yn='Stage II';
    label stage_2_systolic_1='Systolic';
    label stage_2_diastolic_1='Diastolic';
    label stage_2_hr_1='HR ';
    label stage_2_o2_1='O2Sat';
    label stage_2_ultras_1='Ultrasound';
    label stage_3_yn='Stage III';
    label stage_3_systolic_1='Systolic';
    label stage_3_diastolic_1='Diastolic';
    label stage_3_hr_1='HR ';
    label stage_3_o2_1='O2Sat';
    label stage_3_ultras_1='Ultrasound';
    label stage_4_yn='Stage IV';
    label stage_4_systolic_1='Systolic';
    label stage_4_diastolic_1='Diastolic';
    label stage_4_hr_1='HR ';
    label stage_4_o2_1='O2Sat';
    label stage_4_ultras_1='Ultrasound';
    label stage_5_yn='Stage V';
    label stage_5_systolic_1='Systolic';
    label stage_5_diastolic_1='Diastolic';
    label stage_5_hr_1='HR ';
    label stage_5_o2_1='O2Sat';
    label stage_5_ultras_1='Ultrasound';
    label stage_6_yn='Stage VI';
    label stage_6_systolic_1='Systolic';
    label stage_6_diastolic_1='Diastolic';
    label stage_6_hr_1='HR ';
    label stage_6_o2_1='O2Sat';
    label stage_6_ults_1='Ultrasound';
    label stage_7_yn='Stage VII';
    label stage_7_systolic_1='Systolic';
    label stage_7_diastolic_1='Diastolic';
    label stage_7_hr_1='HR ';
    label stage_7_o2_1='O2Sat';
    label stage_7_ultras_1='Ultrasound';
    label stage_8_yn='Stage VIII';
    label stage_8_systolic_1='Systolic';
    label stage_8_diastolic_1='Diastolic';
    label stage_8_hr_1='HR ';
    label stage_8_o2_1='O2Sat';
    label stage_8_ultras_1='Ultrasound';
    label stage_9_yn='Stage IX';
    label stage_9_systolic_1='Systolic';
    label stage_9_diastolic_1='Diastolic';
    label stage_9_hr_1='HR ';
    label stage_9_o2_1='O2Sat';
    label stage_9_ultras_1='Ultrasound';
    label stage_10_yn='Stage X';
    label stage_10_systolic_1='Systolic';
    label stage_10_diastolic_1='Diastolic';
    label stage_10_hr_1='HR ';
    label stage_10_o2_1='O2Sat';
    label stage_10_ultras_1='Ultrasound';
    label peak_bld_systolic_1='Systolic';
    label peak_bld_diastolic_1='Diastolic';
    label peak_hr_1='HR ';
    label peak_o2_sat_1='O2Sat';
    label peak_ultras_1='Ultrasound';
    label recov_bld_systolic_1='Systolic';
    label recov_bld_diastolic_1='Diastolic';
    label recov_hr_1='HR ';
    label recov_o2_1='O2Sat';
    label recov_ultras_1='Ultrasound';
    label exerc_time_1='Total Exercise Time';
    label peak_exerc_1='Peak Exercise Watts';
    label peak_borg_1='Peak Borg Score: (0-10) ';
    label dyspnea_1='Dyspnea';
    label fatique_1='Fatigue';
    label nirs_completed_yn='NIRS completed during Bike test ';
    label notes_6wkex='Notes/Comments';
    label perf_by_ex='Performed By';
    label date_ex='Date';
    label complet_ex='Is form EX complete';
    label form_6wk_ex_complete='Complete?';
    label na_end_phase_dosing='Not Applicable';
    label administered_by='Administered By';
    label epd_date='Date';
    label epd_time='Time';
    label end_phase_dosing_complete='Complete?';
    label na_counseling='Not Applicable';
    label diet_complete='Dietary counseling Completed.';
    label counsel_diet='Person doing counseling: ';
    label complete_by_diet='Completed by:';
    label date_diet='Date Completed: ';
    label form_cns_complete='Complete?';
    label na_ekg_interpretation='Not Applicable';
    label ekg_interpretation='Please enter reading physician''s EKG interpretation/comments. ';
    label ekg_interpretation_complete='Complete?';
    label na_kccq='Not Applicable';
    label activity_dressing='Dressing Yourself';
    label activity_showering='Showering/Bathing';
    label activity_walking='Walking 1 block on level ground';
    label activity_work='Doing yardwork, housework, or carrying groceries';
    label activity_climbing='Climbing a flight of stairs without stopping';
    label activity_run='Hurrying or jogging (as if to catch a bus)';
    label heart_failure_chage='2. Compared with 2 weeks ago, have your symptoms of heart failure (shortness of breath, fatigue or anke swelling) changed? My symptoms of heart failure have become...';
    label frequency_swelling='3. Over the past 2 weeks, how many times did you have swelling in your feet, ankles or legs when you woke up in the morning?';
    label swelling_bother='4. Over the past 2 weeks, how much has swelling in your feet, ankles or legs bothered you?';
    label fatigue_limit='5. Over the past 2 weeks, on average, how many times has fatigue limited your ability to do what you want?';
    label fatigue_bother='6. Over the past 2 weeks, how much has your fatigue bothered you? It has been. . .';
    label breath_limited='7. Over the past 2 weeks, on average, how any times has shortness of breath limited your ability to do what you wanted?';
    label shortness_bother='8. Over the past 2 weeks,how much has your shortness of breath bothered you? It has been ...';
    label sleep_sittingup='9. Over the past 2 weeks, on average, how many times have you been forced to sleep sitting up in a chair or with at least 3 pillows to prop you up because of shortness of breath?';
    label heartfail_contact='10. Heart failure symptoms can worsen for a number of reasons. How sure are you that you know what to do, or whom to call, if your heart failure gets worse?';
    label heart_fail_worse='11. How well do you understand what things you are able to do to keep your heart failure symptoms from getting worse? (for example, weighing yourself, eating a low salt diet, etc)';
    label enjoyment_limit='12. Over the past 2 weeks, how much has your heart failure limited your enjoyment of life?';
    label heartfail_life='13. If you had to spend the rest of your life with heart failure the way it is right now, how would you feel about this?';
    label discouraged_heartfail='14. Over the past 2 weeks, how often have you felt discouraged or down in the dumps because of your heart failure?';
    label hobbies='Hobbies, recreational activities ';
    label working='Working or doing household chores ';
    label family_visit='Visiting family or friends out of your home';
    label intimate_relationships='Intimate relationships with loved ones ';
    label kccq_complete='Complete?';
    label na_visit_lab_results='Not Applicable';
    label hemoglobin_vlr='Hemoglobin';
    label methemoglobin_='Methemoglobin ';
    label nt_pro_bnp_vlr='NT Pro-BNP ';
    label white_blood_cells='White blood cells';
    label red_blood_cells='Red blood cells';
    label hemoglobin_vlr2='Hemoglobin';
    label hematocrit='Hematocrit';
    label rdw='RDW';
    label mch='MCH';
    label mchc='MCHC';
    label mcv='MCV';
    label platelets='Platelets';
    label glucose='Glucose';
    label urea_nitrogen='Urea nitrogen';
    label creatinine='Creatinine';
    label sodium='Sodium';
    label potassium='Potassium';
    label chloride='Chloride';
    label calcium='Calcium';
    label protein_total='Protein, total';
    label albumin='Albumin';
    label biblirubin_total='Biblirubin, total';
    label alkaline_phosphatase='Alkaline phosphatase';
    label ast_vlr='AST';
    label alt_vlr='ALT';
    label egfr_non_aa='eGFR, non-AA';
    label non_aa_oth='If eGFR, non-AA is Other, Please Specify';
    label egfr_aa='eGFR, AA';
    label aa_oth='If eGFR, AA is Other, Please Specify';
    label g6pd_vlr_yn='Did this subject require a G6PD screening?';
    label g6pd_result='Result';
    label result_oth='If Result is Other, Please Specify';
    label oxyhemoglobin='Oxyhemoglobin';
    label o2_ct='O2 CT';
    label carboxyhemoglobin='Carboxyhemoglobin';
    label carbon_dioxide='Carbon dioxide';
    label anion_gap='Anion gap';
    label visit_lab_results_complete='Complete?';
    label na_form_files='Not Applicable';
    label file1='Radial PWA JPEG';
    label file2='Radial PWA TXT';
    label file3='Carotid PWA JPEG ';
    label file4='Carotid PWA TXT ';
    label file5='Carotid-Radial PWV JPEG';
    label file6='Carotid-Radial PWV TXT ';
    label file7='Carotid-Femoral PWV JPEG ';
    label file8='Carotid-Femoral PWV TXT';
    label bike_ex_yn='Was this an bike exercise test visit? ';
    label file9='File uploaded';
    label aurora_export='Aurora export File Uploaded to Box Shared Drive';
    label placed_in_jlab='Tonometry files exported and placed in Box Shared Drive';
    label uploaded_to_redcap=' Tonometry files uploaded to RedCap';
    label transmittal_sheet='Echo copied into Box Shared Drive along with transmittal sheet';
    label aurora_watch_transaction='Aurora watch transaction logged in device log';
    label actigraph_transaction='Actigraph transaction logged in device log';
    label placed_calendar_reminder='(If applicable) Placed calendar reminder to call subject in 3 days to verify that the study medication was delivered and that he/she started taking it.';
    label labs_signed='Labs reviewed and signed by PI';
    label g6pd='(If applicable): G6PD results reviewed';
    label completion='Completion';
    label notes_calendar='Notes/Comments';
    label date99='Date';
    label signature77='Signature';
    label form_files='FORM FILES Complete';
    label form_files_complete='Complete?';
    label na_path_and_files_2='Not Applicable';
    label echo_path_bl='File Path';
    label tonometry_path_bl='File Path';
    label aurora_file_path_bl='File Path';
    label pth_fil_com_bl='Path and Files completed?';
    label path_and_files_2_complete='Complete?';
    label na_path_and_files='Not Applicable';
    label echo_path='File Path';
    label tonometry_path='File Path';
    label tonometry_file1='H3Carotid PWA';
    label tonometry_file_1_na='H3Carotid PWA Not Available';
    label tonometry_file2='Radial PWA';
    label tonometry_file2_na='Radial PWA Not Available';
    label tonometry_file3='Carotid-Femoral PWV';
    label tonometry_file3_na='Carotid-Femoral PWV Not Available';
    label tonometry_file4='Carotid-Radial PWV';
    label tonometry_file4_na='Carotid-Radial PWV Not Available';
    label cardiopulmonary_file_1='Cardiopulmonary File 1';
    label aurora_file_path='File Path';
    label actigraph_file_path='File Path';
    label cardiopulmonary_file_path='File Path';
    label plantar_flexor_file_path='File Path';
    label pth_fil_com='Path and Files completed?';
    label path_and_files_complete='Complete?';
    label na_form_med_ver_p1='Not Applicable ';
    label medicaton_verification_p1='Call _______ days after the baseline visit to verify that the study medication was delivered and that he /she started taking it.';
    label med_ver_num_of_days_p1='Call _______ days after the baseline visit to verify that the study medication was delivered and that he /she started taking it.';
    label date_of_call_p1='Date of call ';
    label time_of_call_p1='Time of call ';
    label med_dispensed='Medication was dispensed at the end of the baseline visit';
    label date_of_med_p1='Date that subject started taking medication';
    label time_num_p1='Time that subject started taking medication';
    label form_med_ver_p1='FORM MED_VER Complete';
    label form_med_ver_p1_complete='Complete?';
    label na_form_med_ver_p2='Not Applicable ';
    label medicaton_verification='Call ______ days after the baseline visit to verify that the study medication was delivered and that he/she started taking it .';
    label num_days_after_bl='Call ______ days after the baseline visit to verify that the study medication was delivered and that he/she started taking it .';
    label date_of_call='Date of call ';
    label time_of_call='Time of call ';
    label date_of_med='Date that subject started taking medication';
    label time_num='Time that subject started taking medication';
    label form_med_ver='FORM MED_VER Complete';
    label form_med_ver_complete='Complete?';
    label na_wk_call='Not Applicable';
    label mouthwash='Reviewed need to avoid mouthwash during participation in the study.';
    label compliant_with_mouthwash='Compliant with mouthwash.';
    label reviewed_no_viagra='Reviewed NO Viagra, Levitra or Cialis allowed during participation in the study.';
    label dietary_restrictions='Reviewed dietary restrictions during participation in the study.';
    label headache='Headache';
    label dizziness='Dizziness';
    label lightheadedness='Lightheadedness';
    label low_blood_pressure_90='Low blood pressure (< 90)';
    label stomach_ache_diarrhea='Stomach Ache, diarrhea, nausea, or vomiting';
    label increased_shortness='Increased Shortness of breath';
    label flushing='Flushing';
    label rash='Rash';
    label changes_in_blood_pressure='Drop in blood pressure when standing up';
    label swelling='Swelling';
    label fatigue='Fatigue';
    label oth_symps='Other symptom(s)';
    label presence='Presence of orthostatic symptoms (If yes, subject needs to be brought in for visit).';
    label if_yes_subject_needs_to='Comments/symptom description(s) ';
    label amount_of_meds='Will the subject be uptitrated to meds three times a day';
    label date_uptitrated_fmh='Date that subject was uptitrated to 3 times per day';
    label date_remn_fmh='Date that subject remained on medications 2 times per day';
    label date0934='Date';
    label signature564='Signature';
    label form_p1='Form P1 Completed';
    label wk_call_complete='Complete?';
    label na_se_assessment_form='Not Applicable';
    label side_efft_asst_yn='Did subject have a side effect assessment visit? ';
    label heart_rate_2_se='Heart Rate';
    label o2_saturation_2_se='O2 Saturation';
    label systolic_2_se='Systolic';
    label diastolic_2_se='Diastolic';
    label systolic_2_se2='Systolic';
    label diastolic_2_se2='Diastolic';
    label orthostat_se='Orthostatic symptoms present? ';
    label orthostat_se_dscr='If yes, please describe symptoms: ';
    label bp_drop_comments='Comments: ';
    label orthostatic_pb1='Performed by';
    label orthostatic_sig='Signature';
    label orthostatic_date='Date';
    label heart_comments='Heart Comments: ';
    label lung_comments='Lung Comments: ';
    label abd_comments='Abd Comments: ';
    label extrem_comments='Extremities Comments: ';
    label se_assessment_notes='Additional Notes';
    label performed_by776_se2_c7c='Performed by';
    label signature564_se2_0f0='Signature';
    label date0934_se2_0b2='Date';
    label mouthwash_se='Reviewed need to avoid mouthwash during participation in the study.';
    label compliant_with_mouthwash_se='Compliant with mouthwash.';
    label reviewed_no_viagra_se='Reviewed NO Viagra, Levitra or Cialis allowed during participation in the study.';
    label dietary_restrictions_se='Reviewed dietary restrictions during participation in the study.';
    label headache_se='Headache';
    label dizziness_se='Dizziness';
    label lightheadedness_se='Lightheadedness';
    label low_blood_pressure_90_se='Low blood pressure (< 90)';
    label stomach_ache_diarrhea_se='Stomach Ache, diarrhea, nausea, or vomiting';
    label increased_shortness_se='Increased Shortness of breath';
    label flushing_se='Flushing';
    label rash_se='Rash';
    label changes_in_blood_pressure_se='Drop in blood pressure when standing up';
    label swelling_se='Swelling';
    label fatigue_se='Fatigue';
    label other_symptoms_se='Other Symptoms';
    label comments_se='Comments: ';
    label performed_by776_se='Performed by';
    label date0934_se='Date';
    label med_regimen_change='Will subject''s medication regimen be changed in any way? ';
    label med_regimen_change_dscr='If yes, please describe: ';
    label phys_by_se='Performed by:';
    label phys_date_se='Date';
    label form_p1_se='Form Side Effect Assessment Visit Completed';
    label side_effect_assessme_v_3='Complete?';
    label na_form_devices='Not Applicable';
    label device_given='Devices were mailed to the subject at MRI';
    label device_given_date='Date';
    label device_given_time='Time';
    label aurora_id='Aurora ID#';
    label actigraph_id='Actigraph ID#';
    label devices_mailed='Devices were mailed to the subject';
    label aurora_mailed='Aurora ID#';
    label actigraph_mailed='Actigraph ID#';
    label date_device_mailed='Date that devices were mailed:';
    label device_mailed='Time that devices were mailed';
    label date_device_receiv='Date that devices were received:';
    label time_reciev='Time that devices were received:';
    label date_aurora_on='Date that aurora was put on:';
    label time_aurora_on='Time that aurora was put on:';
    label date_aurora_off='Date that aurora was taken off:';
    label time_aurora_off='Time that aurora was taken off:';
    label date_actigraph_on='Date that actigraph was put on:';
    label time_actigraph_on='Time that actigraph was put on:';
    label date_actigraph_off='Date that actigraph was taken off:';
    label time_actigraph_off='Time that actigraph was taken off:';
    label date_returned='Date that devices will be returned:';
    label device_notes='Notes';
    label perf_by_dev='Preformed by';
    label dev_date='Date';
    label form_devices_complete='Complete?';
    label obs_notes_yn='Are there any observations or notes relevant to this visit?';
    label obs_notes='Please add any relevant observations/notes for this visit.';
    label observationsnotes_complete='Complete?';
    format redcap_event_name redcap_event_name_.;
    format na_form_el na_form_el_.;
    format data_obtained_yn data_obtained_yn_.;
    format heart_failure heart_failure_.;
    format lv_ejection lv_ejection_.;
    format medical_therapy medical_therapy_.;
    format filling_pressures filling_pressures_.;
    format mitral_ratio mitral_ratio_.;
    format left_atrium left_atrium_.;
    format chronic_loop chronic_loop_.;
    format natriuretic_peptides natriuretic_peptides_.;
    format either_lateral either_lateral_.;
    format capillary_wedge capillary_wedge_.;
    format iv_diuretics iv_diuretics_.;
    format supine_systolic supine_systolic_.;
    format pregnancy pregnancy_.;
    format orthostatic_hypotension orthostatic_hypotension_.;
    format native_conduction native_conduction_.;
    format hemoglobin hemoglobin_.;
    format inability_exercise inability_exercise_.;
    format valvular_disease valvular_disease_.;
    format hypertrophic hypertrophic_.;
    format pericardial_disease pericardial_disease_.;
    format current_angina current_angina_.;
    format coronary_syndrome coronary_syndrome_.;
    format primary_pulmonary primary_pulmonary_.;
    format chronic_obstructive chronic_obstructive_.;
    format stress_testing stress_testing_.;
    format ventricular_ejection ventricular_ejection_.;
    format phosphodiesterase phosphodiesterase_.;
    format organic_nitrates organic_nitrates_.;
    format liver_disease liver_disease_.;
    format egfr egfr_.;
    format g6pd_deficiency g6pd_deficiency_.;
    format methemoglobinemia methemoglobinemia_.;
    format hyperkalemia_serum hyperkalemia_serum_.;
    format ventricular_dysfunction ventricular_dysfunction_.;
    format medical_condition medical_condition_.;
    format contraindications_to_mri contraindications_to_mri_.;
    format intra_luminal_implant intra_luminal_implant_.;
    format life_assist_device life_assist_device_.;
    format vascular_clip vascular_clip_.;
    format visceral_organs visceral_organs_.;
    format intracranial_implants intracranial_implants_.;
    format non_removable_piercings non_removable_piercings_.;
    format personal_history personal_history_.;
    format radiologic_evaluation radiologic_evaluation_.;
    format form_el_complete form_el_complete_.;
    format na_form_bl_cl na_form_bl_cl_.;
    format consent_yn consent_yn_.;
    format urine_yn urine_yn_.;
    format urine_radio urine_radio_.;
    format diet_yn diet_yn_.;
    format vital_yn vital_yn_.;
    format mw6_yn mw6_yn_.;
    format quality_yn quality_yn_.;
    format cognitive_test_yn cognitive_test_yn_.;
    format blood_yn blood_yn_.;
    format g6pd_yn g6pd_yn_.;
    format art_tono_yn art_tono_yn_.;
    format echo_yn echo_yn_.;
    format ekg_bl ekg_bl_.;
    format labs_yn labs_yn_.;
    format hemo_yn hemo_yn_.;
    format creati_yn creati_yn_.;
    format egfr_yn egfr_yn_.;
    format meth_yn meth_yn_.;
    format potas_yn potas_yn_.;
    format ntpro_yn ntpro_yn_.;
    format med_dis_yn med_dis_yn_.;
    format form_bl_cl_complete form_bl_cl_complete_.;
    format na_form_6wk_cl na_form_6wk_cl_.;
    format urine_pregnancy_test urine_pregnancy_test_.;
    format urine_pregnancy_results urine_pregnancy_results_.;
    format dietary_questionnaire dietary_questionnaire_.;
    format physical_exam physical_exam_.;
    format orthostatics orthostatics_.;
    format vital_signs vital_signs_.;
    format questionnaires_kccq questionnaires_kccq_.;
    format potential_side_effects potential_side_effects_.;
    format cognitive_test2_yn cognitive_test2_yn_.;
    format blood_draws_before blood_draws_before_.;
    format light_breakfast light_breakfast_.;
    format blood_draws_after blood_draws_after_.;
    format arterial_tonometry arterial_tonometry_.;
    format doppler_echocardiogram doppler_echocardiogram_.;
    format ekg_p1 ekg_p1_.;
    format bicycle_exercise_test bicycle_exercise_test_.;
    format muscle_mri muscle_mri_.;
    format medication_dispensed medication_dispensed_.;
    format stage_2_meds stage_2_meds_.;
    format stage_1_meds stage_1_meds_.;
    format pill_count_yn pill_count_yn_.;
    format cardiac_mri_performed_p1 cardiac_mri_performed_p1_.;
    format form_6wk_cl_complete form_6wk_cl_complete_.;
    format na_form_6wk_cl_p2 na_form_6wk_cl_p2_.;
    format urine_pregnancy_test_p2 urine_pregnancy_test_p2_.;
    format urine_pregnancy_results_p2 urine_pregnancy_results_p2_.;
    format dietary_questionnaire_p2 dietary_questionnaire_p2_.;
    format physical_exam_p2 physical_exam_p2_.;
    format orthostatics_p2 orthostatics_p2_.;
    format vital_signs_p2 vital_signs_p2_.;
    format questionnaires_kccq_p2 questionnaires_kccq_p2_.;
    format potential_side_effects_p2 potential_side_effects_p2_.;
    format cognitive_test3_yn cognitive_test3_yn_.;
    format blood_draws_before_p2 blood_draws_before_p2_.;
    format light_breakfast_p2 light_breakfast_p2_.;
    format blood_draws_after_p2 blood_draws_after_p2_.;
    format arterial_tonometry_p2 arterial_tonometry_p2_.;
    format doppler_echocardiogram_p2 doppler_echocardiogram_p2_.;
    format ekg_p2 ekg_p2_.;
    format bicycle_exercise_test_p2 bicycle_exercise_test_p2_.;
    format muscle_mri_p2 muscle_mri_p2_.;
    format stage_1_meds_p2 stage_1_meds_p2_.;
    format pill_count_yn_p2 pill_count_yn_p2_.;
    format cardiac_mri_initials_p2 cardiac_mri_initials_p2_.;
    format form_bl_cl_cmplt_p2 form_bl_cl_cmplt_p2_.;
    format medication_dispensed_p2 medication_dispensed_p2_.;
    format form_6wk_cl_p2_complete form_6wk_cl_p2_complete_.;
    format na_form_6wk_mri na_form_6wk_mri_.;
    format mri_safety_checklist mri_safety_checklist_.;
    format field_strength1 field_strength1_.;
    format number_of_repetitions number_of_repetitions_.;
    format number_of_repetitions1 number_of_repetitions1_.;
    format data_exported data_exported_.;
    format complete_mri complete_mri_.;
    format form_6wk_mri_complete form_6wk_mri_complete_.;
    format na_form_cardiac_mri na_form_cardiac_mri_.;
    format form_mri_enrolled form_mri_enrolled_.;
    format form_mri_reviewed form_mri_reviewed_.;
    format form_mri_weight_units form_mri_weight_units_.;
    format form_mri_basis1 form_mri_basis1_.;
    format form_mri_basis2 form_mri_basis2_.;
    format form_mri_meds form_mri_meds_.;
    format form_mri_stable form_mri_stable_.;
    format form_mri_beta_blockers form_mri_beta_blockers_.;
    format form_mri_nitrates form_mri_nitrates_.;
    format form_mri_post_reported form_mri_post_reported_.;
    format form_mri_post_discharge form_mri_post_discharge_.;
    format form_cardiac_mri_complete form_cardiac_mri_complete_.;
    format na_form_mh na_form_mh_.;
    format penn_chart penn_chart_.;
    format gender gender_.;
    format race___1 race___1_.;
    format race___2 race___2_.;
    format race___3 race___3_.;
    format race___4 race___4_.;
    format race___5 race___5_.;
    format race___6 race___6_.;
    format type_decent type_decent_.;
    format acutecoronary acutecoronary_.;
    format prior_angina prior_angina_.;
    format any_arrhythmia any_arrhythmia_.;
    format valv_disease_surgery valv_disease_surgery_.;
    format htn htn_.;
    format high_cholesterol high_cholesterol_.;
    format peripheral_vascular peripheral_vascular_.;
    format diabetes diabetes_.;
    format insulin insulin_.;
    format cva_tia cva_tia_.;
    format pulmonary_embolism_dvt pulmonary_embolism_dvt_.;
    format osa osa_.;
    format cpap cpap_.;
    format copd_asthma copd_asthma_.;
    format osteoarthritis osteoarthritis_.;
    format cabg cabg_.;
    format peripheral peripheral_.;
    format valvular_surgery valvular_surgery_.;
    format congenital_surgery congenital_surgery_.;
    format trauma_requiring_surgery trauma_requiring_surgery_.;
    format current_smoker current_smoker_.;
    format prior_smoker prior_smoker_.;
    format current_alcohol current_alcohol_.;
    format prior_alcohol prior_alcohol_.;
    format recreational_drug_use recreational_drug_use_.;
    format occupation_yn occupation_yn_.;
    format nyhaclass nyhaclass_.;
    format orthopnea orthopnea_.;
    format paroxysmal_nocturnal paroxysmal_nocturnal_.;
    format lower_extremity_edema lower_extremity_edema_.;
    format block_miles block_miles_.;
    format prev_hrt_catheter prev_hrt_catheter_.;
    format pcwp_12 pcwp_12_.;
    format lvedp_16 lvedp_16_.;
    format prior_stress_test prior_stress_test_.;
    format form_mh_complete form_mh_complete_.;
    format na_form_lab_pre_medication na_form_lab_pre_medication_.;
    format iv_line_required_1 iv_line_required_1_.;
    format preg_test preg_test_.;
    format cmp_gold cmp_gold_.;
    format pax_gene pax_gene_.;
    format nt_pro nt_pro_.;
    format form_lab_methemoglobin form_lab_methemoglobin_.;
    format form_lab_cbc form_lab_cbc_.;
    format g6pd_test g6pd_test_.;
    format urine_cc urine_cc_.;
    format plasma_purp plasma_purp_.;
    format serum_red serum_red_.;
    format saliva_tube saliva_tube_.;
    format form_lab_6412_complete form_lab_6412_complete_.;
    format na_form_lab_peak_bike na_form_lab_peak_bike_.;
    format complete_lab_v3 complete_lab_v3_.;
    format plasma_bike plasma_bike_.;
    format serum_bike serum_bike_.;
    format form_lab_pre_medicat_v_0 form_lab_pre_medicat_v_0_.;
    format na_form_lab_post_med na_form_lab_post_med_.;
    format complete_lab_v2 complete_lab_v2_.;
    format urine_post urine_post_.;
    format plasma_post plasma_post_.;
    format serum_post serum_post_.;
    format saliva_post saliva_post_.;
    format form_lab_pre_medicat_v_1 form_lab_pre_medicat_v_1_.;
    format na_physical_exam na_physical_exam_.;
    format form_pe_obtained form_pe_obtained_.;
    format height_2_units height_2_units_.;
    format weight_2_units weight_2_units_.;
    format blood_pressure_arm_2 blood_pressure_arm_2_.;
    format ekg ekg_.;
    format orthostatic_symptoms_yn orthostatic_symptoms_yn_.;
    format sars_yn sars_yn_.;
    format form_pe_complete form_pe_complete_.;
    format na_end_phase_se_review na_end_phase_se_review_.;
    format mouthwash_se_ep mouthwash_se_ep_.;
    format compliant_with_mouthwash_se_ep compliant_with_mouthwash_se_ep_.;
    format reviewed_no_viagra_se_ep reviewed_no_viagra_se_ep_.;
    format dietary_restrictions_se_ep dietary_restrictions_se_ep_.;
    format headache_se_ep headache_se_ep_.;
    format dizziness_se_ep dizziness_se_ep_.;
    format lightheadedness_se_ep lightheadedness_se_ep_.;
    format low_blood_pressure_90_se_ep low_blood_pressure_90_se_ep_.;
    format stomach_ache_diarrhea_se_ep stomach_ache_diarrhea_se_ep_.;
    format increased_shortness_se_ep increased_shortness_se_ep_.;
    format flushing_se_ep flushing_se_ep_.;
    format rash_se_ep rash_se_ep_.;
    format ch_in_blood_pressure_se_ep ch_in_blood_pressure_se_ep_.;
    format swelling_se_ep swelling_se_ep_.;
    format fatigue_se_assess fatigue_se_assess_.;
    format other_symps_se other_symps_se_.;
    format orthostat_se_ep orthostat_se_ep_.;
    format form_p1_se_ep form_p1_se_ep_.;
    format end_phase_side_effec_v_2 end_phase_side_effec_v_2_.;
    format na_form_mh_p1_p2 na_form_mh_p1_p2_.;
    format penn_chart_6p penn_chart_6p_.;
    format gender_6p gender_6p_.;
    format race_6p___1 race_6p___1_.;
    format race_6p___2 race_6p___2_.;
    format race_6p___3 race_6p___3_.;
    format race_6p___4 race_6p___4_.;
    format race_6p___5 race_6p___5_.;
    format race_6p___6 race_6p___6_.;
    format type_decent_6p type_decent_6p_.;
    format acutecoronary_6p acutecoronary_6p_.;
    format prior_angina_6p prior_angina_6p_.;
    format any_arrhythmia_6p any_arrhythmia_6p_.;
    format valv_disease_surgery_6p valv_disease_surgery_6p_.;
    format htn_6p htn_6p_.;
    format high_cholesterol_6p high_cholesterol_6p_.;
    format peripheral_vascular_6p peripheral_vascular_6p_.;
    format diabetes_6p diabetes_6p_.;
    format insulin_6p insulin_6p_.;
    format cva_tia_6p cva_tia_6p_.;
    format pulmonary_embolism_dvt_6p pulmonary_embolism_dvt_6p_.;
    format osa_6p osa_6p_.;
    format cpap_6p cpap_6p_.;
    format copd_asthma_6p copd_asthma_6p_.;
    format osteoarthritis_6p osteoarthritis_6p_.;
    format cabg_6p cabg_6p_.;
    format peripheral_6p peripheral_6p_.;
    format valvular_surgery_6p valvular_surgery_6p_.;
    format congenital_surgery_6p congenital_surgery_6p_.;
    format trauma_requiring_surgery_6p trauma_requiring_surgery_6p_.;
    format current_smoker_6p current_smoker_6p_.;
    format prior_smoker_6p prior_smoker_6p_.;
    format current_alcohol_6p current_alcohol_6p_.;
    format prior_alcohol_6p prior_alcohol_6p_.;
    format recreational_drug_use_6p recreational_drug_use_6p_.;
    format nyhaclass_6p nyhaclass_6p_.;
    format orthopnea_6p orthopnea_6p_.;
    format paroxysmal_nocturnal_6p paroxysmal_nocturnal_6p_.;
    format lower_extremity_edema_6p lower_extremity_edema_6p_.;
    format block_miles_6p block_miles_6p_.;
    format prev_hrt_catheter_6p prev_hrt_catheter_6p_.;
    format pcwp_12_6p pcwp_12_6p_.;
    format lvedp_16_6p lvedp_16_6p_.;
    format prior_stress_test_6p prior_stress_test_6p_.;
    format bl_mh_cmplt_6p bl_mh_cmplt_6p_.;
    format form_mh_8174_complete form_mh_8174_complete_.;
    format na_medications na_medications_.;
    format num_med num_med_.;
    format meds_1 meds_1_.;
    format units_1 units_1_.;
    format freq_1 freq_1_.;
    format route_1 route_1_.;
    format recent_start_date_1 recent_start_date_1_.;
    format recent_end_date_1 recent_end_date_1_.;
    format meds_2 meds_2_.;
    format units_2 units_2_.;
    format freq_2 freq_2_.;
    format route_2 route_2_.;
    format recent_start_date_2 recent_start_date_2_.;
    format recent_end_date_2 recent_end_date_2_.;
    format meds_3 meds_3_.;
    format units_3 units_3_.;
    format freq_3 freq_3_.;
    format route_3 route_3_.;
    format recent_start_date_3 recent_start_date_3_.;
    format recent_end_date_3 recent_end_date_3_.;
    format meds_4 meds_4_.;
    format units_4 units_4_.;
    format freq_4 freq_4_.;
    format route_4 route_4_.;
    format recent_start_date_4 recent_start_date_4_.;
    format recent_end_date_4 recent_end_date_4_.;
    format meds_5 meds_5_.;
    format units_5 units_5_.;
    format freq_5 freq_5_.;
    format route_5 route_5_.;
    format recent_start_date_5 recent_start_date_5_.;
    format recent_end_date_5 recent_end_date_5_.;
    format meds_6 meds_6_.;
    format units_6 units_6_.;
    format freq_6 freq_6_.;
    format route_6 route_6_.;
    format recent_start_date_6 recent_start_date_6_.;
    format recent_end_date_6 recent_end_date_6_.;
    format meds_7 meds_7_.;
    format units_7 units_7_.;
    format freq_7 freq_7_.;
    format route_7 route_7_.;
    format recent_start_date_7 recent_start_date_7_.;
    format recent_end_date_7 recent_end_date_7_.;
    format meds_8 meds_8_.;
    format units_8 units_8_.;
    format freq_8 freq_8_.;
    format route_8 route_8_.;
    format recent_start_date_8 recent_start_date_8_.;
    format recent_end_date_8 recent_end_date_8_.;
    format meds_9 meds_9_.;
    format units_9 units_9_.;
    format freq_9 freq_9_.;
    format route_9 route_9_.;
    format recent_start_date_9 recent_start_date_9_.;
    format recent_end_date_9 recent_end_date_9_.;
    format meds_10 meds_10_.;
    format units_10 units_10_.;
    format freq_10 freq_10_.;
    format route_10 route_10_.;
    format recent_start_date_10 recent_start_date_10_.;
    format recent_end_date_10 recent_end_date_10_.;
    format meds_11 meds_11_.;
    format units_11 units_11_.;
    format freq_11 freq_11_.;
    format route_11 route_11_.;
    format recent_start_date_11 recent_start_date_11_.;
    format recent_end_date_11 recent_end_date_11_.;
    format meds_12 meds_12_.;
    format units_12 units_12_.;
    format freq_12 freq_12_.;
    format route_12 route_12_.;
    format recent_start_date_12 recent_start_date_12_.;
    format recent_end_date_12 recent_end_date_12_.;
    format meds_13 meds_13_.;
    format units_13 units_13_.;
    format freq_13 freq_13_.;
    format route_13 route_13_.;
    format recent_start_date_13 recent_start_date_13_.;
    format recent_end_date_13 recent_end_date_13_.;
    format meds_14 meds_14_.;
    format units_14 units_14_.;
    format freq_14 freq_14_.;
    format route_14 route_14_.;
    format recent_start_date_14 recent_start_date_14_.;
    format recent_end_date_14 recent_end_date_14_.;
    format meds_15 meds_15_.;
    format units_15 units_15_.;
    format freq_15 freq_15_.;
    format route_15 route_15_.;
    format recent_start_date_15 recent_start_date_15_.;
    format recent_end_date_15 recent_end_date_15_.;
    format meds_16 meds_16_.;
    format units_16 units_16_.;
    format freq_16 freq_16_.;
    format route_16 route_16_.;
    format recent_start_date_16 recent_start_date_16_.;
    format recent_end_date_16 recent_end_date_16_.;
    format meds_17 meds_17_.;
    format units_17 units_17_.;
    format freq_17 freq_17_.;
    format route_17 route_17_.;
    format recent_start_date_17 recent_start_date_17_.;
    format recent_end_date_17 recent_end_date_17_.;
    format meds_18 meds_18_.;
    format units_18 units_18_.;
    format freq_18 freq_18_.;
    format route_18 route_18_.;
    format recent_start_date_18 recent_start_date_18_.;
    format recent_end_date_18 recent_end_date_18_.;
    format meds_19 meds_19_.;
    format units_19 units_19_.;
    format freq_19 freq_19_.;
    format route_19 route_19_.;
    format recent_start_date_19 recent_start_date_19_.;
    format recent_end_date_19 recent_end_date_19_.;
    format meds_20 meds_20_.;
    format units_20 units_20_.;
    format freq_20 freq_20_.;
    format route_20 route_20_.;
    format recent_start_date_20 recent_start_date_20_.;
    format recent_end_date_20 recent_end_date_20_.;
    format meds_21 meds_21_.;
    format units_21 units_21_.;
    format freq_21 freq_21_.;
    format route_21 route_21_.;
    format recent_start_date_21 recent_start_date_21_.;
    format recent_end_date_21 recent_end_date_21_.;
    format meds_22 meds_22_.;
    format units_22 units_22_.;
    format freq_22 freq_22_.;
    format route_22 route_22_.;
    format recent_start_date_22 recent_start_date_22_.;
    format recent_end_date_22 recent_end_date_22_.;
    format meds_23 meds_23_.;
    format units_23 units_23_.;
    format freq_23 freq_23_.;
    format route_23 route_23_.;
    format recent_start_date_23 recent_start_date_23_.;
    format recent_end_date_23 recent_end_date_23_.;
    format meds_24 meds_24_.;
    format units_24 units_24_.;
    format freq_24 freq_24_.;
    format route_24 route_24_.;
    format recent_start_date_24 recent_start_date_24_.;
    format recent_end_date_24 recent_end_date_24_.;
    format meds_25 meds_25_.;
    format units_25 units_25_.;
    format freq_25 freq_25_.;
    format route_25 route_25_.;
    format recent_start_date_25 recent_start_date_25_.;
    format recent_end_date_25 recent_end_date_25_.;
    format meds_26 meds_26_.;
    format units_26 units_26_.;
    format freq_26 freq_26_.;
    format route_26 route_26_.;
    format recent_start_date_26 recent_start_date_26_.;
    format recent_end_date_26 recent_end_date_26_.;
    format meds_27 meds_27_.;
    format units_27 units_27_.;
    format freq_27 freq_27_.;
    format route_27 route_27_.;
    format recent_start_date_27 recent_start_date_27_.;
    format recent_end_date_27 recent_end_date_27_.;
    format meds_28 meds_28_.;
    format units_28 units_28_.;
    format freq_28 freq_28_.;
    format route_28 route_28_.;
    format recent_start_date_28 recent_start_date_28_.;
    format recent_end_date_28 recent_end_date_28_.;
    format meds_29 meds_29_.;
    format units_29 units_29_.;
    format freq_29 freq_29_.;
    format route_29 route_29_.;
    format recent_start_date_29 recent_start_date_29_.;
    format recent_end_date_29 recent_end_date_29_.;
    format meds_30 meds_30_.;
    format units_30 units_30_.;
    format freq_30 freq_30_.;
    format route_30 route_30_.;
    format recent_start_date_30 recent_start_date_30_.;
    format recent_end_date_30 recent_end_date_30_.;
    format data_epic_med data_epic_med_.;
    format medications_complete medications_complete_.;
    format na_cognitive_testing na_cognitive_testing_.;
    format shopping_test_yn shopping_test_yn_.;
    format gorton_test_yn gorton_test_yn_.;
    format detection_test_yn detection_test_yn_.;
    format identification_test_yn identification_test_yn_.;
    format card_test_yn card_test_yn_.;
    format one_back_test_yn one_back_test_yn_.;
    format delayed_recall_test_yn delayed_recall_test_yn_.;
    format data_backed_up_yn data_backed_up_yn_.;
    format cognitive_testing_complete cognitive_testing_complete_.;
    format na_form_vp na_form_vp_.;
    format ster_carotid_1 ster_carotid_1_.;
    format ster_femoral_1 ster_femoral_1_.;
    format ster_radial_1 ster_radial_1_.;
    format bp_collected_yn bp_collected_yn_.;
    format carotid_1 carotid_1_.;
    format carotid_vasc carotid_vasc_.;
    format femora_1 femora_1_.;
    format femora_vasc femora_vasc_.;
    format radial_1 radial_1_.;
    format radial_vasc radial_vasc_.;
    format lvot_flow lvot_flow_.;
    format form_vp_complete form_vp_complete_.;
    format na_form_6mwt na_form_6mwt_.;
    format checklist_bl_6mwt___1 checklist_bl_6mwt___1_.;
    format checklist_bl_6mwt___2 checklist_bl_6mwt___2_.;
    format checklist_bl_6mwt___3 checklist_bl_6mwt___3_.;
    format checklist_bl_6mwt___4 checklist_bl_6mwt___4_.;
    format checklist_bl_6mwt___5 checklist_bl_6mwt___5_.;
    format checklist_bl_6mwt___6 checklist_bl_6mwt___6_.;
    format pretest_instruction___1 pretest_instruction___1_.;
    format pretest_instruction___2 pretest_instruction___2_.;
    format complete_6mwt complete_6mwt_.;
    format form_6mwt_complete form_6mwt_complete_.;
    format na_form_6wk_ex na_form_6wk_ex_.;
    format stage_1_yn stage_1_yn_.;
    format stage_1_ultras_1 stage_1_ultras_1_.;
    format stage_2_yn stage_2_yn_.;
    format stage_2_ultras_1 stage_2_ultras_1_.;
    format stage_3_yn stage_3_yn_.;
    format stage_3_ultras_1 stage_3_ultras_1_.;
    format stage_4_yn stage_4_yn_.;
    format stage_4_ultras_1 stage_4_ultras_1_.;
    format stage_5_yn stage_5_yn_.;
    format stage_5_ultras_1 stage_5_ultras_1_.;
    format stage_6_yn stage_6_yn_.;
    format stage_6_ults_1 stage_6_ults_1_.;
    format stage_7_yn stage_7_yn_.;
    format stage_7_ultras_1 stage_7_ultras_1_.;
    format stage_8_yn stage_8_yn_.;
    format stage_8_ultras_1 stage_8_ultras_1_.;
    format stage_9_yn stage_9_yn_.;
    format stage_9_ultras_1 stage_9_ultras_1_.;
    format stage_10_yn stage_10_yn_.;
    format stage_10_ultras_1 stage_10_ultras_1_.;
    format peak_ultras_1 peak_ultras_1_.;
    format recov_ultras_1 recov_ultras_1_.;
    format nirs_completed_yn nirs_completed_yn_.;
    format complet_ex complet_ex_.;
    format form_6wk_ex_complete form_6wk_ex_complete_.;
    format na_end_phase_dosing na_end_phase_dosing_.;
    format end_phase_dosing_complete end_phase_dosing_complete_.;
    format na_counseling na_counseling_.;
    format diet_complete diet_complete_.;
    format form_cns_complete form_cns_complete_.;
    format na_ekg_interpretation na_ekg_interpretation_.;
    format ekg_interpretation_complete ekg_interpretation_complete_.;
    format na_kccq na_kccq_.;
    format activity_dressing activity_dressing_.;
    format activity_showering activity_showering_.;
    format activity_walking activity_walking_.;
    format activity_work activity_work_.;
    format activity_climbing activity_climbing_.;
    format activity_run activity_run_.;
    format heart_failure_chage heart_failure_chage_.;
    format frequency_swelling frequency_swelling_.;
    format swelling_bother swelling_bother_.;
    format fatigue_limit fatigue_limit_.;
    format fatigue_bother fatigue_bother_.;
    format breath_limited breath_limited_.;
    format shortness_bother shortness_bother_.;
    format sleep_sittingup sleep_sittingup_.;
    format heartfail_contact heartfail_contact_.;
    format heart_fail_worse heart_fail_worse_.;
    format enjoyment_limit enjoyment_limit_.;
    format heartfail_life heartfail_life_.;
    format discouraged_heartfail discouraged_heartfail_.;
    format hobbies hobbies_.;
    format working working_.;
    format family_visit family_visit_.;
    format intimate_relationships intimate_relationships_.;
    format kccq_complete kccq_complete_.;
    format na_visit_lab_results na_visit_lab_results_.;
    format egfr_non_aa egfr_non_aa_.;
    format egfr_aa egfr_aa_.;
    format g6pd_vlr_yn g6pd_vlr_yn_.;
    format g6pd_result g6pd_result_.;
    format visit_lab_results_complete visit_lab_results_complete_.;
    format na_form_files na_form_files_.;
    format bike_ex_yn bike_ex_yn_.;
    format aurora_export aurora_export_.;
    format placed_in_jlab placed_in_jlab_.;
    format uploaded_to_redcap uploaded_to_redcap_.;
    format transmittal_sheet transmittal_sheet_.;
    format aurora_watch_transaction aurora_watch_transaction_.;
    format actigraph_transaction actigraph_transaction_.;
    format placed_calendar_reminder placed_calendar_reminder_.;
    format labs_signed labs_signed_.;
    format g6pd g6pd_.;
    format completion completion_.;
    format form_files form_files_.;
    format form_files_complete form_files_complete_.;
    format na_path_and_files_2 na_path_and_files_2_.;
    format pth_fil_com_bl pth_fil_com_bl_.;
    format path_and_files_2_complete path_and_files_2_complete_.;
    format na_path_and_files na_path_and_files_.;
    format tonometry_file_1_na tonometry_file_1_na_.;
    format tonometry_file2_na tonometry_file2_na_.;
    format tonometry_file3_na tonometry_file3_na_.;
    format tonometry_file4_na tonometry_file4_na_.;
    format pth_fil_com pth_fil_com_.;
    format path_and_files_complete path_and_files_complete_.;
    format na_form_med_ver_p1 na_form_med_ver_p1_.;
    format medicaton_verification_p1 medicaton_verification_p1_.;
    format med_dispensed med_dispensed_.;
    format form_med_ver_p1 form_med_ver_p1_.;
    format form_med_ver_p1_complete form_med_ver_p1_complete_.;
    format na_form_med_ver_p2 na_form_med_ver_p2_.;
    format medicaton_verification medicaton_verification_.;
    format form_med_ver form_med_ver_.;
    format form_med_ver_complete form_med_ver_complete_.;
    format na_wk_call na_wk_call_.;
    format mouthwash mouthwash_.;
    format compliant_with_mouthwash compliant_with_mouthwash_.;
    format reviewed_no_viagra reviewed_no_viagra_.;
    format dietary_restrictions dietary_restrictions_.;
    format headache headache_.;
    format dizziness dizziness_.;
    format lightheadedness lightheadedness_.;
    format low_blood_pressure_90 low_blood_pressure_90_.;
    format stomach_ache_diarrhea stomach_ache_diarrhea_.;
    format increased_shortness increased_shortness_.;
    format flushing flushing_.;
    format rash rash_.;
    format changes_in_blood_pressure changes_in_blood_pressure_.;
    format swelling swelling_.;
    format fatigue fatigue_.;
    format oth_symps oth_symps_.;
    format presence presence_.;
    format amount_of_meds amount_of_meds_.;
    format form_p1 form_p1_.;
    format wk_call_complete wk_call_complete_.;
    format na_se_assessment_form na_se_assessment_form_.;
    format side_efft_asst_yn side_efft_asst_yn_.;
    format orthostat_se orthostat_se_.;
    format mouthwash_se mouthwash_se_.;
    format compliant_with_mouthwash_se compliant_with_mouthwash_se_.;
    format reviewed_no_viagra_se reviewed_no_viagra_se_.;
    format dietary_restrictions_se dietary_restrictions_se_.;
    format headache_se headache_se_.;
    format dizziness_se dizziness_se_.;
    format lightheadedness_se lightheadedness_se_.;
    format low_blood_pressure_90_se low_blood_pressure_90_se_.;
    format stomach_ache_diarrhea_se stomach_ache_diarrhea_se_.;
    format increased_shortness_se increased_shortness_se_.;
    format flushing_se flushing_se_.;
    format rash_se rash_se_.;
    format changes_in_blood_pressure_se changes_in_blood_pressure_se_.;
    format swelling_se swelling_se_.;
    format fatigue_se fatigue_se_.;
    format other_symptoms_se other_symptoms_se_.;
    format med_regimen_change med_regimen_change_.;
    format form_p1_se form_p1_se_.;
    format side_effect_assessme_v_3 side_effect_assessme_v_3_.;
    format na_form_devices na_form_devices_.;
    format device_given device_given_.;
    format devices_mailed devices_mailed_.;
    format form_devices_complete form_devices_complete_.;
    format obs_notes_yn obs_notes_yn_.;
    format observationsnotes_complete observationsnotes_complete_.;
run;

proc contents data=redcap; run;

data raw.ko_nw;
set redcap;
run;




/*IMPORT DICTIONARIES*/

%MACRO IMPORT(dsn, filename, GUESSINGROWS);

PROC IMPORT OUT= &dsn
            DATAFILE= "&path\REDCap Downloads\archive%sysfunc( today(), YYMMDDn8 ) export data to SAS\&filename..csv"
            DBMS=CSV REPLACE;
            &GUESSINGROWS
            GETNAMES=no;
            DATAROW=1;
RUN;

%MEND;

%IMPORT(raw.ko_ae_nw_dictionary, ko_ae_nw_dictionary, %str());
%IMPORT(raw.ko_nw_dictionary, ko_nw_dictionary, %str(GUESSINGROWS = 1400;));
%IMPORT(raw.nw_et_dictionary, nw_et_dictionary, %str(GUESSINGROWS = 70;));
%IMPORT(raw.NW_med_dictionary, NW_med_dictionary, %str());














/*raw.NW_medication_compliance REPORT*/

/*Log with macro debugging options turned on */
/*options mprint mlogic symbolgen; */


/*FORMATS*/
options fmtsearch=(raw.NW_med_formats);
options nofmterr;

/*Preview Data*/
proc contents data=raw.NW_medication_compliance varnum; run;
proc print data= raw.NW_medication_compliance (obs=5) label noobs; run;



/*GOAL REPEAT THE FOLLOWING PROC PRINT FOR ALL VARIABLES IN THE MAIN SURVEY*/
*proc print data= &dsn label noobs;
*    where study_id = "KT-2-02" and missing(adverse_event_category) /*and adverse_events_complete not in (. , 0)*/;
*    var study_id /*redcap_event_name*/ redcap_repeat_instrument redcap_repeat_instance adverse_event_category;
/*    title1 "KT-2-02";*/
/*    title2 "Adverse Events";*/
/*    title3 "adverse_event_category";*/
*run;

proc contents data=raw.NW_med_dictionary varnum; run;
proc print data=raw.NW_med_dictionary (obs=20); run;

data work.dictionary;
    set raw.NW_med_dictionary 
    (keep=VAR1 
          VAR2 
          VAR4 
          VAR8
          VAR12
    );
    where (VAR4 = "text" and VAR8 ne "")
        or VAR4 in("yesno","radio","file","dropdown", "field_type",)
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
    end;
    if VAR1 in("na_phase_a" "na_phase_b") then delete;
    /*    HARDCODE CASES*/
/*    if branching_logic_clean="acetyl-l-carnitine | 7" then delete;*/
run;

/*QA branching_logic_clean*/
/*QA FOLLOWING CHARACTERS ARE STRIPPED FROM branching_logic_clean*/
/*[   ] "" '*/
/*[visit][datetime_seconds]=[datetime_seconds] is replaced with redcap_event_name="visit"*/
proc freq data=work.dictionary;
    tables branching_logic_clean * VAR12 / list missing;
run;
/*proc contents data= work.dictionary; run;*/

/*QA FIELD TYPES ARE "text" "yesno","radio","checkbox","file","dropdown"*/
proc freq data=work.dictionary;
    tables VAR4;
run;


proc print data=work.dictionary (obs=20); run;
proc contents data=work.dictionary; run;



/*GENERATES A LIST OF ALL study_ids*/
proc freq data= raw.NW_medication_compliance;
    table study_id /out= IDS (keep=study_id);
run;

proc print data= IDS (obs=50); run;
proc contents data= IDS; run;

/*CARTESIAN PRODUCT BETWEEN IDS AND VARIABLES*/
/*N*M OBS*/
/*10 OBS * 9 OBS = 90 OBS TOTAL*/

/*proc sql;*/
/*   create table CartSQL as*/
/*   select test1.*,*/
/*          test2.var2*/
/*   from test1, test2;*/
/*quit;*/
/**/
/*data CartDataStep;*/
/*   set test1;*/
/*   do i=1 to n;*/
/*      set test2 point=i nobs=n;*/
/*      output;*/
/*   end;*/
/*run;*/


data CartDataStep;
   set work.dictionary;
   do i=1 to n;
      set work.IDS point=i nobs=n;
      output;
   end;
run;
proc contents data= work.CartDataStep; run;
/*proc print data=work.CartDataStep;run;*/

proc sort data=work.CartDataStep;
    by study_id;
run;


%macro missing(ID, variable, logic, title);

data id_i;
    set raw.NW_medication_compliance ;
    where study_id = "&ID" and study_id ne "field_name" ;
run;

proc print data= id_i label noobs;
    where missing(&variable) &logic;
    var study_id  /*redcap_event_name redcap_repeat_instrument redcap_repeat_instance*/ &variable;
    title1 "&ID";
    title2 "&title";
    title3 "&variable";
run;

%mend;

/*QA missing() on R-001*/
/*%missing(KT-2-02, adverse_event_category, %str( and serious=1), Adverse Events);*/

/*options mprint;*/

/*CREATE EXCEL FILE*/
/*ods Excel file="&path\documents\output\ NW - Medication Compliance Missing Data Report &sysdate..xlsx" ;*/

/*MISSING REPORT R-001*/
/*data _null_;*/
data work.temp;
    length macro_call $700;
    set work.CartDataStep;
/*    where study_id in('KT-2-02' '10002' '10003');*/
/*    macro_call = catx( '%sample(', var1, ',' var2, ')' );*/
    if VAR12 = "" then macro_call = cat('%missing(',study_id,',', VAR1, ',', '%str(', branching_logic_clean, ')', ',', VAR2,')');
    else macro_call = cat('%missing(',study_id,',', VAR1, ',', '%str( and ', branching_logic_clean, ')', ',', VAR2,')');

    if VAR1 = 'field_name' then macro_call = cat( 'ods Excel OPTIONS(SHEET_INTERVAL="now" SHEET_NAME="', study_id,'" EMBEDDED_TITLES="yes");' );
    if VAR1 = 'field_name' and study_id = 'KT-2-02' then macro_call = cat( 'ods Excel OPTIONS(SHEET_INTERVAL="none" SHEET_NAME="', study_id,'" EMBEDDED_TITLES="yes");' );
    call execute(macro_call);
run;
 

 
/*SAS LOG*/
/*ods Excel OPTIONS(SHEET_INTERVAL="now" SHEET_NAME="log" EMBEDDED_TITLES="yes");*/
/*proc printto;run;*/
/*proc document name=mydoc(write);*/
/*                import textfile=test to logfile;run;*/
/*                replay;run;*/
/*quit;*/
/* */

/*ods Excel close;*/

/*NO MISSING DATA FOR NW STUDY MEDS KNOCK OUT(Medication Compliance)*/












/*raw.ko_ae_nw REPORT*/



/*FORMATS*/
options fmtsearch=(raw.ko_ae_nw_formats );
options nofmterr;

/*Preview Data*/
proc contents data=raw.ko_ae_nw varnum; run;
proc print data= raw.ko_ae_nw (obs=5) noobs; run;



/*GOAL REPEAT THE FOLLOWING PROC PRINT FOR ALL VARIABLES IN THE MAIN SURVEY*/
*proc print data= &dsn label noobs;
*    where study_id = "KT-2-02" and missing(adverse_event_category) /*and adverse_events_complete not in (. , 0)*/;
*    var study_id /*redcap_event_name*/ redcap_repeat_instrument redcap_repeat_instance adverse_event_category;
/*    title1 "KT-2-02";*/
/*    title2 "Adverse Events";*/
/*    title3 "adverse_event_category";*/
*run;

proc contents data=raw.ko_ae_nw_dictionary varnum; run;
proc print data=raw.ko_ae_nw_dictionary (obs=20); run;

data work.dictionary;
    set raw.ko_ae_nw_dictionary 
    (keep=VAR1 
          VAR2 
          VAR4 
          VAR8
          VAR12
    );
    where (VAR4 = "text" and VAR8 ne "")
        or VAR4 in("yesno","radio","file","dropdown", "field_type",)
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
    end;
    if VAR1 in("na_phase_a" "na_phase_b") then delete;
    /*    HARDCODE CASES*/
/*    if branching_logic_clean="acetyl-l-carnitine | 7" then delete;*/
run;

/*QA branching_logic_clean*/
/*QA FOLLOWING CHARACTERS ARE STRIPPED FROM branching_logic_clean*/
/*[   ] "" '*/
/*[visit][datetime_seconds]=[datetime_seconds] is replaced with redcap_event_name="visit"*/
proc freq data=work.dictionary;
    tables branching_logic_clean * VAR12 / list missing;
run;
/*proc contents data= work.dictionary; run;*/

/*QA FIELD TYPES ARE "text" "yesno","radio","checkbox","file","dropdown"*/
proc freq data=work.dictionary;
    tables VAR4;
run;


proc print data=work.dictionary (obs=20); run;
proc contents data=work.dictionary; run;



/*GENERATES A LIST OF ALL study_ids*/
proc freq data= raw.ko_ae_nw;
    table subject_id /out= IDS (keep=subject_id);
run;

proc print data= IDS (obs=50); run;
proc contents data= IDS; run;

/*CARTESIAN PRODUCT BETWEEN IDS AND VARIABLES*/
/*N*M OBS*/
/*10 OBS * 9 OBS = 90 OBS TOTAL*/

/*proc sql;*/
/*   create table CartSQL as*/
/*   select test1.*,*/
/*          test2.var2*/
/*   from test1, test2;*/
/*quit;*/
/**/
/*data CartDataStep;*/
/*   set test1;*/
/*   do i=1 to n;*/
/*      set test2 point=i nobs=n;*/
/*      output;*/
/*   end;*/
/*run;*/


data CartDataStep;
   set work.dictionary;
   do i=1 to n;
      set work.IDS point=i nobs=n;
      output;
   end;
run;
proc contents data= work.CartDataStep; run;
/*proc print data=work.CartDataStep;run;*/

proc sort data=work.CartDataStep;
    by subject_id;
run;


%macro missing(ID, variable, logic, title);

data id_i;
    set raw.ko_ae_nw ;
    where subject_id = "&ID" and subject_id ne "field_name" ;
run;

proc print data= id_i label noobs;
    where missing(&variable) &logic;
    var subject_id  /*redcap_event_name*/ redcap_repeat_instrument redcap_repeat_instance &variable;
    title1 "&ID";
    title2 "&title";
    title3 "&variable";
run;

%mend;

/*QA missing() on R-001*/
/*%missing(KT-2-02, adverse_event_category, %str( and serious=1), Adverse Events);*/

/*options mprint;*/

/*CREATE EXCEL FILE*/
/*ods Excel file="&path\documents\output\ NW - Adverse Events Missing Data Report &sysdate..xlsx" ;*/

/*MISSING REPORT R-001*/
/*data _null_;*/
data work.temp;
    length macro_call $700;
    set work.CartDataStep;
/*    where study_id in('KT-2-02' '10002' '10003');*/
/*    macro_call = catx( '%sample(', var1, ',' var2, ')' );*/
    if VAR12 = "" then macro_call = cat('%missing(',subject_id,',', VAR1, ',', '%str(', branching_logic_clean, ')', ',', VAR2,')');
    else macro_call = cat('%missing(',subject_id,',', VAR1, ',', '%str( and ', branching_logic_clean, ')', ',', VAR2,')');

    if VAR1 = 'field_name' then macro_call = cat( 'ods Excel OPTIONS(SHEET_INTERVAL="now" SHEET_NAME="', subject_id,'" EMBEDDED_TITLES="yes");' );
    if VAR1 = 'field_name' and subject_id = 'KT-2-02' then macro_call = cat( 'ods Excel OPTIONS(SHEET_INTERVAL="none" SHEET_NAME="', subject_id,'" EMBEDDED_TITLES="yes");' );
    call execute(macro_call);
run;
 

 
/*SAS LOG*/
/*ods Excel OPTIONS(SHEET_INTERVAL="now" SHEET_NAME="log" EMBEDDED_TITLES="yes");*/
/*proc printto;run;*/
/*proc document name=mydoc(write);*/
/*                import textfile=test to logfile;run;*/
/*                replay;run;*/
/*quit;*/
/* */

/*ods Excel close;*/

/*KT-2-10 AE 1 WAS DELETED*/
/*EMAIL AND CONFIRM*/

/*NO OTHER AES*/









/*raw.ko_ae_nw REPORT*/



/*FORMATS*/
options fmtsearch=(raw.nw_early_term_formats );
options nofmterr;

/*Preview Data*/
proc contents data=raw.nw_early_termination varnum; run;
proc print data= raw.nw_early_termination (obs=5) noobs; run;



/*GOAL REPEAT THE FOLLOWING PROC PRINT FOR ALL VARIABLES IN THE MAIN SURVEY*/
*proc print data= &dsn label noobs;
*    where study_id = "KT-2-02" and missing(adverse_event_category) /*and adverse_events_complete not in (. , 0)*/;
*    var study_id /*redcap_event_name*/ redcap_repeat_instrument redcap_repeat_instance adverse_event_category;
/*    title1 "KT-2-02";*/
/*    title2 "Adverse Events";*/
/*    title3 "adverse_event_category";*/
*run;

proc contents data=raw.nw_et_dictionary varnum; run;
proc print data=raw.nw_et_dictionary (obs=20); run;

data work.dictionary;
    set raw.nw_et_dictionary 
    (keep=VAR1 
          VAR2 
          VAR4 
          VAR8
          VAR12
    );
    where (VAR4 = "text" and VAR8 ne "")
        or VAR4 in("yesno","radio","file","dropdown", "field_type",)
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
    end;
    if VAR1 in("na_phase_a" "na_phase_b") then delete;
    /*    HARDCODE CASES*/
/*    if branching_logic_clean="acetyl-l-carnitine | 7" then delete;*/
run;

/*QA branching_logic_clean*/
/*QA FOLLOWING CHARACTERS ARE STRIPPED FROM branching_logic_clean*/
/*[   ] "" '*/
/*[visit][datetime_seconds]=[datetime_seconds] is replaced with redcap_event_name="visit"*/
proc freq data=work.dictionary;
    tables branching_logic_clean * VAR12 / list missing;
run;
/*proc contents data= work.dictionary; run;*/

/*QA FIELD TYPES ARE "text" "yesno","radio","checkbox","file","dropdown"*/
proc freq data=work.dictionary;
    tables VAR4;
run;


proc print data=work.dictionary (obs=20); run;
proc contents data=work.dictionary; run;



/*GENERATES A LIST OF ALL study_ids*/
proc freq data= raw.nw_early_termination;
    table study_id /out= IDS (keep=study_id);
run;

proc print data= IDS (obs=50); run;
proc contents data= IDS; run;


/*NO MISSING DATA UNTIL KT-2-05*/
data IDS;
set IDS;
if study_id in('KT-2-01' 'KT-2-02' 'KT-2-03' 'KT-2-04') then delete;
run;


/*CARTESIAN PRODUCT BETWEEN IDS AND VARIABLES*/
/*N*M OBS*/
/*10 OBS * 9 OBS = 90 OBS TOTAL*/

/*proc sql;*/
/*   create table CartSQL as*/
/*   select test1.*,*/
/*          test2.var2*/
/*   from test1, test2;*/
/*quit;*/
/**/
/*data CartDataStep;*/
/*   set test1;*/
/*   do i=1 to n;*/
/*      set test2 point=i nobs=n;*/
/*      output;*/
/*   end;*/
/*run;*/


data CartDataStep;
   set work.dictionary;
   do i=1 to n;
      set work.IDS point=i nobs=n;
      output;
   end;
run;
proc contents data= work.CartDataStep; run;
/*proc print data=work.CartDataStep;run;*/

proc sort data=work.CartDataStep;
    by study_id;
run;


%macro missing(ID, variable, logic, title);

data id_i;
    set raw.nw_early_termination ;
    where study_id = "&ID" and study_id ne "field_name" ;
run;

proc print data= id_i label noobs;
    where missing(&variable) &logic;
    var study_id  /*redcap_event_name redcap_repeat_instrument redcap_repeat_instance*/ &variable;
    title1 "&ID";
    title2 "&title";
    title3 "&variable";
run;

%mend;

/*QA missing() on R-001*/
/*%missing(KT-2-02, adverse_event_category, %str( and serious=1), Adverse Events);*/

/*options mprint;*/

/*CREATE EXCEL FILE*/
ods Excel file="&path\documents\output\ NW - Early Termination Missing Data Report &sysdate..xlsx" ;

/*MISSING REPORT R-001*/
/*data _null_;*/
data work.temp;
    length macro_call $700;
    set work.CartDataStep;
/*    where study_id in('KT-2-02' '10002' '10003');*/
/*    macro_call = catx( '%sample(', var1, ',' var2, ')' );*/
    if VAR12 = "" then macro_call = cat('%missing(',study_id,',', VAR1, ',', '%str(', branching_logic_clean, ')', ',', VAR2,')');
    else macro_call = cat('%missing(',study_id,',', VAR1, ',', '%str( and ', branching_logic_clean, ')', ',', VAR2,')');

    if VAR1 = 'field_name' then macro_call = cats( 'ods Excel OPTIONS(SHEET_INTERVAL="now" SHEET_NAME="', study_id,'" EMBEDDED_TITLES="yes");' );
    if VAR1 = 'field_name' and study_id = 'KT-2-05' then macro_call = cats( 'ods Excel OPTIONS(SHEET_INTERVAL="none" SHEET_NAME="', study_id,'" EMBEDDED_TITLES="yes");' );
    call execute(macro_call);
run;
 

 
/*SAS LOG*/
/*ods Excel OPTIONS(SHEET_INTERVAL="now" SHEET_NAME="log" EMBEDDED_TITLES="yes");*/
/*proc printto;run;*/
/*proc document name=mydoc(write);*/
/*                import textfile=test to logfile;run;*/
/*                replay;run;*/
/*quit;*/
/* */

ods Excel close;


/*proc print data=work.temp (obs=100); run;*/
/*KT-2-10 AE 1 WAS DELETED*/
/*EMAIL AND CONFIRM*/

/*NO OTHER AES*/














