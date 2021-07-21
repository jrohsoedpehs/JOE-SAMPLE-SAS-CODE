/*For Joe- Solim, comment lines 3 and 4 out*/
libname raw "U:\Caroline Peterson\Walk Study\data\Raw";                                        /*FINDS DATA*/
footnote "SAS Program Stored: U:\Caroline Peterson\Walk Study\programs\Draft\walkabout";       /*PUTS PROGRAM PATH ON OUTPUT*/
options fmtsearch=(raw);

/*QA for merge*/
proc contents data=raw.form1   varnum;
run;

proc contents data=raw.form2   varnum;
run;

/*visit variable is */
/*redcap_event_name*/


proc sort data=raw.form1 ;
   by uic;
run;


proc sort data=raw.form2 ;
   by uic;
run;


data raw.merged_form1_form2;
   merge raw.form1 (in=a)  raw.form2(in=b) ;
   by uic ;
run;

/*******************************/
proc sort data=raw.form1 ;
   by uic;
run;

proc sort data=raw.form2 ;
   by uic;
run;


data form1 form2;
	merge raw.form1(in=d) raw.form2(in=j); /*in makes d and j dummy variables. d = 1 if the data is in the indnotj (Danielle's) data set and vice versa*/
  	by uic;
	if d = 1 and j ne 1 then output form1;/*ENTERED in form1, BUT NOT in form2*/
	if j = 1 and d ne 1 then output form2; /*ENTERED in form2, BUT NOT form1*/
run;
/*ARCHIVE THE ABOVE MERGE*/

/*DATA THAT IS IN ONE SET BUT MISSING IN THE OTHER*/
proc print data=form1 noobs;
  var uic;
  title 'ENTERED in form1, BUT NOT in form2';
run;
proc print noobs data=form2;
  var uic;
  title 'ENTERED in form2, BUT NOT form1';
run;
/*******************************/


/*QA for Merge*/
proc means data = raw.form1 maxdec=2;
   var age anxiety othermp   ;
run;


proc sort data=raw.merged_form1_form2 ;
   by redcap_event_name;
run;


proc means data = raw.merged_form1_form2 maxdec=2;
   by redcap_event_name;
   var age anxiety othermp   ; 
run;

title;
proc freq data= raw.form1;
   tables  work_school trauma anxiety othermp;
run;

proc freq data= raw.merged_form1_form2 ;
   by redcap_event_name;
   tables work_school trauma anxiety othermp ;
run;

proc print data = raw.merged_form1_form2;
   where redcap_event_name = "";
   var uic redcap_event_name;
run;


proc print data = raw.merged_form1_form2;
   where redcap_event_name = "";
   var uic redcap_event_name work_school trauma anxiety othermp;
run;
