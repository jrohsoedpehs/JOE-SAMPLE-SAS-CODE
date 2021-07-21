/*Log with macro debugging options turned on  */
options mprint mlogic symbolgen; 

/*LIBRARIES*/
libname raw "Q:\Julio Chirinos\Knock_out_Summer_2016\data\Raw";
libname derived "Q:\Julio Chirinos\Knock_out_Summer_2016\data\Derived";
footnote "SAS Program Stored in: Q:\Julio Chirinos\Knock_out_Summer_2016\programs\Draft\missing_data_VA_Knockout.sas";

/*FORMATS*/
options fmtsearch=(raw.ko_va_formats);
options nofmterr;

/*QA THE DATA SET*/
proc contents data=raw.ko_va varnum;run;


/*REPORT FOR ALL STUDY_IDS*/
proc print data= raw.ko_va label;
/*where missing(tonometry_file3) and  path_and_files_complete  not in (.,0)   and  na_path_and_files  ne  1;*/
where path_and_files_complete  not in (.);
var study_id  REDCAP_EVENT_NAME na_path_and_files tonometry_file3;
title "tonometry_file3";
run;



/*GOAL*/
/*CREATE A REPORT FOR EVERY PATIENT IN THE DATASET raw.ko_v*/
/**/
/*LOOP A CODE (THAT MAKES A REPORT) ON STUDY_ID*/

/*REPORT FOR KT-3-01*/
proc print data= raw.ko_va label;
/*where missing(tonometry_file3) and  path_and_files_complete  not in (.,0)   and  na_path_and_files  ne  1;*/
where study_id = "KT-3-01" and path_and_files_complete  not in (.);
var study_id  REDCAP_EVENT_NAME na_path_and_files tonometry_file3;
title "tonometry_file3";
run;

/*REPORT FOR KT-3-02*/
proc print data= raw.ko_va label;
/*where missing(tonometry_file3) and  path_and_files_complete  not in (.,0)   and  na_path_and_files  ne  1;*/
where study_id = "KT-3-02" and path_and_files_complete  not in (.);
var study_id  REDCAP_EVENT_NAME na_path_and_files tonometry_file3;
title "tonometry_file3";
run;

/*REPORT FOR KT-3-03*/
proc print data= raw.ko_va label;
/*where missing(tonometry_file3) and  path_and_files_complete  not in (.,0)   and  na_path_and_files  ne  1;*/
where study_id = "KT-3-03" and path_and_files_complete  not in (.);
var study_id  REDCAP_EVENT_NAME na_path_and_files tonometry_file3;
title "tonometry_file3";
run;



/*CREATE MACRO (FUNCTION) FOR THE REPORT*/
%macro missing(next_name);

proc print data= raw.ko_va label;
/*where missing(tonometry_file3) and  path_and_files_complete  not in (.,0)   and  na_path_and_files  ne  1;*/
where study_id = "&next_name" and path_and_files_complete  not in (.);
var study_id  REDCAP_EVENT_NAME na_path_and_files tonometry_file3;
title "tonometry_file3";
run;
%mend;
/*QA*/
%missing(KT-3-01);
%missing(KT-3-02);
%missing(KT-3-03);



/*STEP 1*/
/*CREATE A LIST THAT WE CAN LOOP ON*/

/*MANUAL*/
/*%let name_list1 = KT-3-01 KT-3-02 KT-3-03;*/
/*%put &name_list1;*/

/*LOOP*/
proc sql noprint; 
select distinct study_id 
into : name_list separated by " " from raw.ko_va; 
quit;
/*VIEW THE LIST IN THE LOG*/
%put &name_list;


/*preview data*/
proc print data= raw.ko_va noobs;
var study_id redcap_event_name;
run;


/*TROUBLESHOOT SCAN()*/
data test;
string = "KT-3-01 KT-3-02 KT-3-03";
delimited = SCAN(string, 1," ");
delimited2 = SCAN(string, 1);
count = countw(string, " ");
run;
/*VIEW THE SCAN*/
proc print data=test;run;



/*LOOP*/

%macro loop(list);
%local i next_name;
%do i=1 %to %sysfunc(countw(&list, " "));
%let next_name = %scan(&list, &i," ");
%missing(&next_name);
%end;
%mend;
%loop(&name_list);




/*KT-3-01 KT-3-02 KT-3-03*/

data raw.new_dsn;
set redcap;
/*edits*/
run;


