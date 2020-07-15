/*Eligibility Checklist occurs during visit 2 only*/

/*We need the Eligibility Checklist to appear with the other consent visit data*/
/*Use a merge to accomplish this*/

/*visit 2 data*/
data derived.visit2_data;
set derived.adrd_m2main (keep= dyad_id site_code redcap_event_name mmse cdr);
where redcap_event_name="visit_2_baseline_m_arm_1";
drop redcap_event_name;
run;

/*visit 1 data*/
data derived.visit1_data;
set derived.adrd_m2main (drop= mmse cdr);
where redcap_event_name="visit_1_consent_arm_1";
drop redcap_event_name;
run;


/*proc sort data=derived.elig_checklst_vars;*/
/*by redcap_event_name;*/
/*run;*/

/*merge*/
proc sort data= derived.visit1_data ;
by dyad_id site_code;
run;
proc sort data= derived.visit2_data;
by dyad_id site_code;
run;

/*combined data*/
data derived.table1;
merge derived.visit2_data derived.visit1_data;
/*by dyad_id site_code;*/
run;

/*QA*/
proc freq data= derived.table1;
tables mmse cdr;
run;
/*proc print data=derived.table1;run;*/
proc contents data=derived.table1;
run;
