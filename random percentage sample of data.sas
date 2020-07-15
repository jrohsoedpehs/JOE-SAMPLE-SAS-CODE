libname raw "Q:\Nalaka Gooneratne\Memories2\data\Raw";
libname derived "Q:\Nalaka Gooneratne\Memories2\data\Raw";

footnote "SAS Program Stored In: Q:\Nalaka Gooneratne\Memories2\programs\Draft\Moelter_logical_memory_iia_file.sas";

options fmtsearch=(raw.np_formats);
options nofmterr;

proc contents data=SampleSRS  varnum;run;
/*logical_memory_iia_file*/
proc freq data= raw.np;
tables logical_memory_iia_file;
run;

data derived.np;
set raw.np;
where logical_memory_iia_file ne "";
run;

proc print data=derived.np  (obs=10);
var subject_id redcap_event_name logical_memory_iia_file logical_memory_iia_complete;
run;

proc contents data=raw.np varnum;run; 




**************************************************************************
**************************************************************************
From: Rhodes, Joseph M <josephrh@nursing.upenn.edu> 
Sent: Monday, June 1, 2020 6:43 PM
To: Chittams, Jesse L. <chittams@nursing.upenn.edu>
Subject: Steve Moelter

Hi Jesse,

The imported data with no missing on logical_memory_iia_file is saved as derived.np
and is available in "Q:\Nalaka Gooneratne\Memories2\programs\Draft\Moelter_logical_memory_iia_file.sas".
Steve wants a list of subject id that is a random sample of 25% of this data.
I’ll forward his email.

Thank you,
Joseph

Sent from Mail for Windows 10
**************************************************************************
**************************************************************************;
title2 'Simple Random Sampling';
proc surveyselect data=raw.np  SEED=1892370417
   method=srs n=56 out=derived.random56_NP;
run;
*QA check on the random sample;

data temp;
	set derived.random56_NP;
checkrs = 1;
run;

data temp2;
	merge derived.NP temp;
	by subject_id;
run;

proc print data=temp2;
var subject_id checkrs redcap_event_name logical_memory_iia_file logical_memory_iia_complete;
run;
