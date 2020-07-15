proc sort data= raw.pisces;
by caregiver_id redcap_event_name;
run;


data ;
set raw.pisces;
by caregiver_id redcap_event_name;
retain phq9_v3;
if redcap_event_name = "session3" and phq9=. then Final_Measures = 0;
if redcap_event_name = "session3" and phq9 ne . then Final_Measures = 1;

if redcap_event_name = "session3" then phq9_v3 = phq9;
run;
