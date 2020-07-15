libname raw "Q:\George Demiris\PISCES\data\Raw";
libname derived "Q:\George Demiris\PISCES\data\Derived";
footnote "SAS Program Stored in: Q:\George Demiris\PISCES\programs\Draft\Missing_Data_Report.sas";

options fmtsearch=(raw.pisces_formats);
options nofmterr;

%include "Q:\George Demiris\PISCES\programs\Draft\macro_outlier_and_missing_data.sas";

/*ACTION ITEM FOR JENNIFER*/
/*Use VARIABLE NAMES FROM THE FOLLOWING CODEBOOK TO CREATE A MISSING DATA AND ROUGH MEANS REPORT*/
/*https://redcap.nursing.upenn.edu/redcap_v8.6.5/Design/data_dictionary_codebook.php?pid=1093*/

/*PISCES Missing Data Report*/
/*ExcelXP Output*/
ods _all_ close;                                          /*File name*/
ods ExcelXP file="Q:\George Demiris\PISCES\documents\output\PISCES Missing Data Report for PISCES &sysdate..xlsx";

/*demog*/                                               /*use prefix as Worksheet Name*/
ods ExcelXP OPTIONS(SHEET_INTERVAL="proc" SHEET_NAME="Survey - Demographics");        
%summary(derived.pisces, demog_care1 -- demog_work_support, demog);
       /*dataset name  , 1st var -- last var                 ,use prefix as instrument name*/

/*all variables with prefix psi*/
ods ExcelXP OPTIONS(SHEET_INTERVAL="proc" SHEET_NAME="Survey - PSI");        
%summary(derived.pisces, psi1 -- psi_positive, psi);

/*all variables with prefix phq9*/
ods ExcelXP OPTIONS(SHEET_INTERVAL="proc" SHEET_NAME="Survey - PHQ9");        
%summary(derived.pisces, phq9_q01 -- phq9_q10, phq9);

/*all variables with prefix gad*/
ods ExcelXP OPTIONS(SHEET_INTERVAL="proc" SHEET_NAME="Survey - GAD");        
%summary(derived.pisces, gad1 -- gad_7_total, gad);

/*all variables with prefix qol*/
ods ExcelXP OPTIONS(SHEET_INTERVAL="proc" SHEET_NAME="Survey - CQLI-R");        
%summary(derived.pisces, qolemot -- qol_total, qol);

/*all variables with prefix cccq*/
ods ExcelXP OPTIONS(SHEET_INTERVAL="proc" SHEET_NAME="Survey - CCCQ");        
%summary(derived.pisces, cccq_01 -- cccq_30, cccq);

/*all variables with prefix problm_clist*/
ods ExcelXP OPTIONS(SHEET_INTERVAL="proc" SHEET_NAME="Problem/Concern Checklist");        
%summary(derived.pisces,  problm_clist_family  -- problm_clist_other, problm_clist);

/*all variables with prefix vid_call*/
ods ExcelXP OPTIONS(SHEET_INTERVAL="proc" SHEET_NAME="Technical Quality");        
%summary(derived.pisces, vid_call_occur_yn -- vid_call_useful, vid_call);

ods ExcelXP close;




