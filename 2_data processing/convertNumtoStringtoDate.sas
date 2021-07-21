/*convert string to num to date*/
data test;
   set derived.F1_F4_F13RA_MERGE;
   CONSENT_DT_n=CONSENT_DT*1;
   consent_date_f = input(put(CONSENT_DT_n,8.),yymmdd8.);
   format consent_date_f date10.;
/*proc print noobs;*/
run;

/*QA*/
proc freq data= test;
tables CONSENT_DT*CONSENT_DT_n*consent_date_f/list missing;
run;
