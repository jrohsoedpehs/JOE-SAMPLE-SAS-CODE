data demo;
set raw.pisces ;
/*make caregiver id numeric*/
caregiver_id_n = 1*caregiver_id;
/*Create TRT*/
trt = (caregiver_id_n > 1007)+1;
/*Convert demog_date to years only*/
year_demog_date = year(demog_date);
/*Create age*/
age = year_demog_date-demog_dob;
where redcap_event_name = "consent_visit_arm_1";/*Baseline*/
/* 	format race race. sex sex. ;*/
run;

/*QA Variable types*/
proc contents data= demo varnum;run;

/*QA Age*/
proc freq data= demo;
tables age*demog_date*year_demog_date*demog_dob/list missing;
run;


/*Create age from dob*/
data _null_;
  x = round(yrdif('29JUN2010'd,today(),'AGE'),1);
  y = yrdif('09MAY2011'd,today(),'AGE');
  z = yrdif('27SEP2007'd,today(),'AGE');
  put x= y= z=;
run;
