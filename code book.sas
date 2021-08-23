libname codebook 'U:\Jesse Chittams\admin\Joseph Rhodes\Library\SAS';
footnote "SAS program stored: U:\Jesse Chittams\admin\Joseph Rhodes\Library\SAS\code book";
*
SAS Code book - Developing a Dataset
Recipe for Success
•	Document
•	Know the end result
•	Check your log
•	QA

Preparatory Work
If you walk into a project and there is no SOP (standard operating procedures ie. The standard subdirectory) then add yours (give it structure)

Create a header using PI’s instructions to get oriented
Run the library
*;

libname name 'directory path';

*
Create a footnote
*;

footnote "SAS program stored: directory path\title.sas";

*
Import the data into library

From REDCap

Download (place in appropriate directory and run the 1st two in the following order)
•	SAS mapper
•	REDCap code
•	Excel CSV

This code needs to be run to create a temporary dataset in SAS
*;

%macro removeOldFile(bye); %if %sysfunc(exist(&bye.)) %then %do; proc delete data=&bye.; run; %end; %mend removeOldFile; 
libname redcap 'prepared directory'
libname lib 'directory'; 
%removeOldFile(redcap.redcap);

*
Note: 
you can add as many libraries as needed 
don’t delete the redcap library

Next, make dataset permanent using a data step
(near the end of the program you’ll see)
*;

data lib.dsn; 
set REDCAP; 
run;

*
note:
lib.dsn is the name of the new data set
the data comes from the old data set REDCAP

Finally include this import code in your new program using
*;

%include "directory\title.sas";

*
Note:
Some formats will not work without this code
This allows you to import any program in to the current one

From Excel
*;

*
Summary Stats

used for macro calls
I;

%include "U:\SAMPLE_SAS_PROGRAM\macros\Summary_stats_template.sas";

*
Contents
proc contents data=lib.dsn; run;
Note: lib = library name (makes it permanent)
dsn = data set name
if lib is omitted then it will be treated as work (temporary)
proc contents data=dsn short; run;
Note: short …
/*finds char variables*/
*********************************************************************************************************************
USING PROC CONTENTS
The output to proc contents can be stored in SAS datasets. This output has some additional information about both 
variables and datasets that can be used. The following code creates an output dataset called cont_out from the 
dataset science_data.
********************************************************************************************************************;

proc contents
 data = science_data
 out = cont_out 
 noprint;
run;

***********************************************************************************************************************
USING OUTPUT FROM PROC CONTENTS TO BUILD A VARIABLE LIST 
Once we know which variables we want to include in our analysis, a macro variable is built using PROC SQL with the 
into clause. Here is some sample code using proc contents to build a variable list from of all the character variables 
in the dataset called science_data:
***********************************************************************************************************************;

proc sql noprint;
 select name
 into : varlist
 separated by ' '
 from cont_out
 where type = 2;
quit;
%put &varlist;

Frequency
proc freq data=dsn;
tables var;
run;
note: When do we convert to Num?
Use the following code within a data step.
Below is sas syntax to convert character variables to numeric using ‘compress’ (I forgot to send this yesterday):
 
*replace the ‘originalvar’ with the actual variable that need to be convert to numeric;
newvar = compress(lowcase(originalvar),'abcdefghijklmnopqrstuvwxyz !@#$%^&*()?');
newvar2 = newvar * 1;
drop newvar;
rename newvar2=newvar;

Means
options nolabel; (hides labels/optional)
proc means data=dsn maxdec=2;
var var;
run;

proc means data=dsn noprint;               
	by vars; where var ne .;
	var var;
	output out=var
	mean= var;

run;

Data Entry QA
Double data entry
/*prepare dsn1 and dsn2 for proc compare by sorting the variable that we’ll compare by*/
proc sort data=dsn1;
         by var;
run;

proc sort data=dsn2;
         by clinid;
run;

proc compare base=dsn1 compare=dsn2;
            id var;
run;


/* list the mismatched vars here */
/* correct in both and repeat until there are no errors */

*
Sharing results
Create RTF for each proc seperately
*;

ods rtf file="directory\title &sysdate..rtf" style=journal;
/*code*/
ods rtf close;

/*note:*/
/*distorted boxplots can be corrected by deleting style=journal*/
/*Save RTF as a word document (so Macs can see header/footers)*/
/*Or*/

%let ph=directory path;

/*Note: ph = place holder*/

Titles
Run title ; after every proc to clear title memory
********************************************************************************************************************;
 
ods rtf file="ph\title &sysdate..rtf" style=journal;
code
ods rtf close;
note:
If there are blank or cut off tables use
ods pdf file="ph\title &sysdate..pdf" style=journal;
code
ods pdf close;
this forces all values to appear
Macros
*****************************************************************************
Useful macros that we can call into other programs
****************************************************************************;

*generate contents on dataset;
%macro getcont();
    proc contents data=lib.dsn;
/*	title4 font=Calibri j=left height=14pt color=&color "Proc cont: &var. variable"*/
	quit;
%mend getcont;

*generate frequency on categorical variables;
%macro getfreq(var,color);
      proc freq data=lib.dsn;
      table &var;
      title4 font=Calibri j=left height=14pt color=&color "Proc freq: &var. variable"
      quit;
%mend getfreq;
 
 
*generate means on continuous variables;
%macro getmeans(var,color);
      proc means data=dsn n nmiss mean std min p25 median p75 max maxdec=2;
      var &var;
      title4 font=Calibri j=left height=14pt color=&color "Proc means: &var. variable"
      quit;
%mend getmeans;
 
 
*generate box plots on continuous variables, please note there is a ‘vnum’ variable you may need to change it to the name of visit variable in your dataset;
%macro getbox (var,color);
      proc boxplot data=CHECK ;
            plot (&var)*vnum/boxstyle=schematic;
            title4 font=Calibri j=left height=14pt color=&color "Box Plot: &var. (for each time point)";
      quit;
%mend getbox;
 
 
*generate scatter plots on continuous variables that need to be compare to each other;
%macro getscatter(var1, var2, color, title);
title4 font=Calibri j=left height=14pt color=&color "Scatter Plot: &title.";
proc gplot data=check;
      where &var1 ne . and &var2 ne .;
      symbol value=dot color=black height=1;
      plot &var1 * &var2;
run; quit;
%mend getscatter;
 
 
/**IMPORTANT: here are the macro calls, be sure to use the actual variable name where you see the word ‘var’ (the variable name should not have any spaces);*/
%getcont();
%getfreq(var,blue);
%getmeans(var,darkred);
%getbox(var,green);
%getscatter(var1,var2,purple,var1 vs var2 over all timepoints);

 
Below is sas syntax to convert character variables to numeric using ‘compress’ (I forgot to send this yesterday):
 
*replace the ‘originalvar’ with the actual variable that need to be convert to numeric;
newvar = compress(lowcase(originalvar),'abcdefghijklmnopqrstuvwxyz !@#$%^&*()?');
newvar2 = newvar * 1;
drop newvar;
rename newvar2=newvar;

array do loop
data derived.survey_collection (keep=q1 q2 database q4_1 q4_2); 
*(keep=q1 q2 database q4_1-q4_19 q5_1-q5_9 q6_1-q6_10 q7_1-q7_16 q8_1-q8_9 q9_1-q9_13 q10_1-q10_12
                                q11_1-q11_8 q12_1-q12_11 q13_1-q13_7 q14_1-q14_12);
     set raw.survey_collection (drop=Name_Code);
	 array qu4_1(*) q4_1_1-q4_1_20 q4_1_22-q4_1_26;
	 array qu4_2(*) q4_2_1-q4_2_20 q4_2_22-q4_2_26;
	 ***...... list out all of our keep = variables***;
	 *array qu14_12(*) q14_20_1-q14_20_26;
     subject=q1;
     do i=1 to dim(qu4_1);
	     if i<=20 then do;
         database=i; q4_1=qu4_1(i); q4_2=qu4_2(i); 
		 output derived.survey_collection;
		 end;
		 else if i>20 then do;
		 database=i+1;q4_1=qu4_1(i); q4_2=qu4_2(i); 
		 output derived.survey_collection;
		 end;
	 end;
run;


/*QA*/

data one;
     set raw.survey_collection (drop=Name_Code);
run;

proc print data=one;
     var q1 q2 q4_2_2;
run;

Example Array
data derived.survey_collection 
(keep=q1 q2 database 
/*q4 19 choices*/
q4_1 q4_2 q4_3 q4_4 q4_5 q4_6 q4_7 q4_8 q4_9 q4_10 q4_11 q4_12 q4_13 q4_14 q4_15 q4_16 q4_17 q4_18 q4_19 
/*q5 9 choices*/
q5_1 q5_2 q5_3 q5_4 q5_5 q5_6 q5_7 q5_8 q5_9 
/*q6 10 choices*/
q6_1 q6_2 q6_3 q6_4 q6_5 q6_6 q6_7 q6_8 q6_9 q6_10 
/*q7 16 choices*/
q7_1 q7_2 q7_3 q7_4 q7_5 q7_6 q7_7 q7_8 q7_9 q7_10 q7_11 q7_12 q7_13 q7_14 q7_15 q7_16 
/*q8 9 choices*/
q8_1 q8_2 q8_3 q8_4 q8_5 q8_6 q8_7 q8_8 q8_9 
/*q9 13 choices*/
q9_1 q9_2 q9_3 q9_4 q9_5 q9_6 q9_7 q9_8 q9_9 q9_10 q9_11 q9_12 q9_13 
/*q10 12 choices*/
q10_1 q10_2 q10_3 q10_4 q10_5 q10_6 q10_7 q10_8 q10_9 q10_10 q10_11 q10_12 
/*q11 8 choices*/
q11_1 q11_2 q11_3 q11_4 q11_5 q11_6 q11_7 q11_8 
/*q12 11 choices*/
q12_1 q12_2 q12_3 q12_4 q12_5 q12_6 q12_7 q12_8 q12_9 q12_10 q12_11
/*q13 7 choices*/
q13_1 q13_2 q13_3 q13_4 q13_5 q13_6 q13_7 
/*q14 12 choices*/
q14_1 q14_2 q14_3 q14_4 q14_5 q14_6 q14_7 q14_8 q14_9 q14_10 q14_11 q14_12); 

     set raw.survey_collection (drop=Name_Code);
	
	 ***...... list out all of our keep = variables***;
	 *array var(*) obs;
	 
     array q4_1(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26; 
	 array q4_2(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26;
	 array q4_3(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26;
	 array q4_4(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26;  
	 array q4_5(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26;  
	 array q4_6(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26;  
	 array q4_7(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26;  
	 array q4_8(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26; 
	 array q4_9(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26; 
	 array q4_10(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26;
	 array q4_11(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26;
	 array q4_12(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26; 
	 array q4_13(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26;
	 array q4_14(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26;
	 array q4_15(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26;  
	 array q4_16(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26; 
	 array q4_17(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26;  
	 array q4_18(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26; 
	 array q4_19(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26;

     array q5_1(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26; 
	 array q5_2(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26; 
	 array q5_3(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26;  
	 array q5_4(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26; 
	 array q5_5(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26; 
	 array q5_6(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26; 
	 array q5_7(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26; 
	 array q5_8(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26; 
	 array q5_9(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26; 

     array q6_1(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26; 
	 array q6_2(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26;  
	 array q6_3(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26; 
	 array q6_4(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26;  
	 array q6_5(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26; 
	 array q6_6(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26;  
	 array q6_7(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26;  
	 array q6_8(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26; 
	 array q6_9(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26; 
	 array q6_10(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26;  

     array q7_1(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26; 
	 array q7_2(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26; 
	 array q7_3(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26;  
     array q7_4(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26; 
     array q7_5(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26; 
	 array q7_6(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26; 
	 array q7_7(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26;  
	 array q7_8(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26; 
	 array q7_9(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26;  
	 array q7_10(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26;  
	 array q7_11(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26;  
	 array q7_12(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26; 
	 array q7_13(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26;  
	 array q7_14(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26;  
	 array q7_15(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26;  
	 array q7_16(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26;  

     array q8_1 q7_16(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26; 
	 array q8_2 q7_16(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26; 
	 array q8_3 q7_16(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26;  
	 array q8_4 q7_16(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26; 
	 array q8_5 q7_16(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26; 
	 array q8_6 q7_16(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26; 
	 array q8_7 q7_16(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26; 
	 array q8_8 q7_16(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26; 
	 array q8_9 q7_16(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26; 
     array q9_1 q7_16(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26;  
	 array q9_2 q7_16(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26;  
	 array q9_3 q7_16(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26; 
	 array q9_4 q7_16(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26;  
	 array q9_5 q7_16(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26; 
	 array q9_6 q7_16(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26; 
	 array q9_7 q7_16(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26; 
	 array q9_8 q7_16(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26; 
	 array q9_9 q7_16(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26; 
	 array q9_10 q7_16(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26; 
	 array q9_11 q7_16(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26; 
	 array q9_12 q7_16(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26; 
	 array q9_13 q7_16(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26; 

     array q10_1 q7_16(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26;  
	 array q10_2 q7_16(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26;  
	 array q10_3 q7_16(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26; 
	 array q10_4 q7_16(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26;  
	 array q10_5 q7_16(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26; 
	 array q10_6 q7_16(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26; 
	 array q10_7 q7_16(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26; 
	 array q10_8 q7_16(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26; 
	 array q10_9 q7_16(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26; 
	 array q10_10 q7_16(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26; 
	 array q10_11 q7_16(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26; 
	 array q10_12 q7_16(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26; 

     array q11_1 q7_16(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26;  
	 array q11_2 q7_16(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26; 
	 array q11_3 q7_16(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26;  
	 array q11_4 q7_16(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26;  
	 array q11_5 q7_16(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26; 
	 array q11_6 q7_16(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26; 
	 array q11_7 q7_16(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26; 
	 array q11_8 q7_16(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26;  

     array q12_1 q7_16(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26; 
	 array q12_2 q7_16(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26;  
	 array q12_3 q7_16(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26; 
	 array q12_4 q7_16(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26; 
	 array q12_5 q7_16(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26; 
	 array q12_6 q7_16(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26;  
	 array q12_7 q7_16(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26;  
	 array q12_8 q7_16(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26; 
	 array q12_9 q7_16(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26;  
	 array q12_10 q7_16(*) qq4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26; 
	 array q12_11 q7_16(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26;  

     array q13_1 q7_16(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26; 
	 array q13_2 q7_16(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26;  
	 array q13_3 q7_16(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26;  
	 array q13_4 q7_16(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26; 
	 array q13_5 q7_16(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26;  
	 array q13_6 q7_16(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26;  
	 array q13_7 q7_16(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26; 
     array q14_1 q7_16(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26; 
	 array q14_2 q7_16(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26; 
	 array q14_3 q7_16(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26;  
	 array q14_4 q7_16(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26; 
	 array q14_5 q7_16(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26; 
	 array q14_6 q7_16(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26;  
	 array q14_7 q7_16(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26; 
	 array q14_8 q7_16(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26; 
	 array q14_9 q7_16(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26;  
	 array q14_10 q7_16(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26; 
	 array q14_11 q7_16(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26; 
	 array q14_12 q7_16(*) q4_1_1 q4_1_2 q4_1_3 q4_1_4 q4_1_5 q4_1_6 q4_1_7 q4_1_8 q4_1_9 q4_1_10 q4_1_11 q4_1_12 q4_1_13 q4_1_14 q4_1_15 q4_1_16 q4_1_17 q4_1_18 q4_1_19 q4_1_20 q4_1_22 q4_1_23 q4_1_24 q4_1_25 q4_1_26; 
	 
     subject=q1;
     do i=1 to dim(qu4_1);

	 ***skip database 21 b/c it's missing***;

	     if i<=20 then do;
         database=i; 

    ***create column variables***;

    q4_1=qu4_1(i); 
	q4_2=qu4_2(i);
	q4_3=qu4_3(i);
	q4_4=qu4_4(i);  
	q4_5=qu4_5(i);
	q4_6=qu4_6(i);
	q4_7=qu4_7(i);  
	q4_8=qu4_8(i);  
	q4_9=qu4_9(i); 
	q4_10=qu4_10(i); 
	q4_11=qu4_11(i);
	q4_12=qu4_12(i); 
	q4_13=qu4_13(i); 
	q4_14=qu4_14(i);
	q4_15=qu4_15(i);
	q4_16=qu4_16(i);
	q4_17=qu4_17(i); 
	q4_18=qu4_18(i);
	q4_19=qu4_19(i);

    q5_1=qu5_1(i);
	q5_2=qu5_2(i);
	q5_3=qu5_3(i);
	q5_4=qu5_4(i);
	q5_5=qu5_5(i);
	q5_6=qu5_6(i);
	q5_7=qu5_7(i); 
	q5_8=qu5_8(i);
	q5_9=qu5_9(i); 

    q6_1=qu6_1(i);
	q6_2=qu6_2(i);
	q6_3=qu6_3(i);
	q6_4=qu6_4(i);
	q6_5=qu6_5(i);
	q6_6=qu6_6(i);
	q6_7=qu6_7(i);
	q6_8=qu6_8(i); 
	q6_9=qu6_9(i); 
	q6_10=qu6_10(i);

    q7_1=qu7_1(i);
	q7_2=qu7_2(i);
	q7_3=qu7_3(i);
    q7_4=qu7_4(i);
    q7_5=qu7_5(i);
	q7_6=qu7_6(i);
	q7_7=qu7_7(i);
	q7_8=qu7_8(i);
	q7_9=qu7_9(i);
	q7_10=qu7_10(i);
	q7_11=qu7_11(i);
	q7_12=qu7_12(i);
	q7_13=qu7_13(i);
	q7_14=qu7_14(i);
	q7_15=qu7_15(i);
	q7_16=qu7_16(i);

    q8_1=qu8_1(i);
	q8_2=qu8_2(i);
	q8_3=qu8_3(i);
	q8_4=qu8_4(i);
	q8_5=qu8_5(i);
	q8_6=qu8_6(i);
	q8_7=qu8_7(i);
	q8_8=qu8_8(i);
	q8_9=qu8_9(i);

    q9_1=qu9_1(i);
	q9_2=qu9_2(i);
	q9_3=qu9_3(i);
	q9_4=qu9_4(i); 
	q9_5=qu9_5(i);
	q9_6=qu9_6(i); 
	q9_7=qu9_7(i); 
	q9_8=qu9_8(i); 
	q9_9=qu9_9(i);
	q9_10=qu9_10(i);
	q9_11=qu9_11(i);
	q9_12=qu9_12(i); 
	q9_13=qu9_13(i);

    q10_1=qu10_1(i); 
	q10_2=qu10_2(i); 
	q10_3=qu10_3(i); 
	q10_4=qu10_4(i); 
	q10_5=qu10_5(i);
	q10_6=qu10_6(i);
	q10_7=qu10_7(i); 
	q10_8=qu10_8(i);
	q10_9=qu10_9(i); 
	q10_10=qu10_10(i);
	q10_11=qu10_11(i);
	q10_12=qu10_12(i);

    q11_1=qu11_1(i);
	q11_2=qu11_2(i);
	q11_3=qu11_3(i);
	q11_4=qu11_4(i); 
	q11_5=qu11_5(i); 
	q11_6=qu11_6(i); 
	q11_7=qu11_7(i);
	q11_8=qu11_8(i);

    q12_1=qu12_1(i);
	q12_2=qu12_2(i);
	q12_3=qu12_3(i); 
	q12_4=qu12_4(i); 
	q12_5=qu12_5(i);
	q12_6=qu12_6(i); 
	q12_7=qu12_7(i); 
	q12_8=qu12_8(i);
	q12_9=qu12_9(i); 
	q12_10=qu12_10(i);
	q12_11=qu12_11(i); 

    q13_1=qu13_1(i);
	q13_2=qu13_2(i);
	q13_3=qu13_3(i);
	q13_4=qu13_4(i);
	q13_5=qu13_5(i); 
	q13_6=qu13_6(i); 
	q13_7=qu13_7(i);

    q14_1=qu14_1(i);
	q14_2=qu14_2(i); 
	q14_3=qu14_3(i);
	q14_4=qu14_4(i); 
	q14_5=qu14_5(i);
	q14_6=qu14_6(i);
	q14_7=qu14_7(i);
	q14_8=qu14_8(i);
	q14_9=qu14_9(i);
	q14_10=qu14_10(i);
	q14_11=qu14_11(i); 
	q14_12=qu14_12(i);

	***skip database 21 b/c it's missing***;

		 output derived.survey_collection;
		 end;
		 else if i>20 then do;
		 database=i+1;

    q4_1=qu4_1(i); 
	q4_2=qu4_2(i);
	q4_3=qu4_3(i);
	q4_4=qu4_4(i);  
	q4_5=qu4_5(i);
	q4_6=qu4_6(i);
	q4_7=qu4_7(i);  
	q4_8=qu4_8(i);  
	q4_9=qu4_9(i); 
	q4_10=qu4_10(i); 
	q4_11=qu4_11(i);
	q4_12=qu4_12(i); 
	q4_13=qu4_13(i); 
	q4_14=qu4_14(i);
	q4_15=qu4_15(i);
	q4_16=qu4_16(i);
	q4_17=qu4_17(i); 
	q4_18=qu4_18(i);
	q4_19=qu4_19(i);

    q5_1=qu5_1(i);
	q5_2=qu5_2(i);
	q5_3=qu5_3(i);
	q5_4=qu5_4(i);
	q5_5=qu5_5(i);
	q5_6=qu5_6(i);
	q5_7=qu5_7(i); 
	q5_8=qu5_8(i);
	q5_9=qu5_9(i); 

    q6_1=qu6_1(i);
	q6_2=qu6_2(i);
	q6_3=qu6_3(i);
	q6_4=qu6_4(i);
	q6_5=qu6_5(i);
	q6_6=qu6_6(i);
	q6_7=qu6_7(i);
	q6_8=qu6_8(i); 
	q6_9=qu6_9(i); 
	q6_10=qu6_10(i);

    q7_1=qu7_1(i);
	q7_2=qu7_2(i);
	q7_3=qu7_3(i);
    q7_4=qu7_4(i);
    q7_5=qu7_5(i);
	q7_6=qu7_6(i);
	q7_7=qu7_7(i);
	q7_8=qu7_8(i);
	q7_9=qu7_9(i);
	q7_10=qu7_10(i);
	q7_11=qu7_11(i);
	q7_12=qu7_12(i);
	q7_13=qu7_13(i);
	q7_14=qu7_14(i);
	q7_15=qu7_15(i);
	q7_16=qu7_16(i);

    q8_1=qu8_1(i);
	q8_2=qu8_2(i);
	q8_3=qu8_3(i);
	q8_4=qu8_4(i);
	q8_5=qu8_5(i);
	q8_6=qu8_6(i);
	q8_7=qu8_7(i);
	q8_8=qu8_8(i);
	q8_9=qu8_9(i);

    q9_1=qu9_1(i);
	q9_2=qu9_2(i);
	q9_3=qu9_3(i);
	q9_4=qu9_4(i); 
	q9_5=qu9_5(i);
	q9_6=qu9_6(i); 
	q9_7=qu9_7(i); 
	q9_8=qu9_8(i); 
	q9_9=qu9_9(i);
	q9_10=qu9_10(i);
	q9_11=qu9_11(i);
	q9_12=qu9_12(i); 
	q9_13=qu9_13(i);

    q10_1=qu10_1(i); 
	q10_2=qu10_2(i); 
	q10_3=qu10_3(i); 
	q10_4=qu10_4(i); 
	q10_5=qu10_5(i);
	q10_6=qu10_6(i);
	q10_7=qu10_7(i); 
	q10_8=qu10_8(i);
	q10_9=qu10_9(i); 
	q10_10=qu10_10(i);
	q10_11=qu10_11(i);
	q10_12=qu10_12(i);

    q11_1=qu11_1(i);
	q11_2=qu11_2(i);
	q11_3=qu11_3(i);
	q11_4=qu11_4(i); 
	q11_5=qu11_5(i); 
	q11_6=qu11_6(i); 
	q11_7=qu11_7(i);
	q11_8=qu11_8(i);

    q12_1=qu12_1(i);
	q12_2=qu12_2(i);
	q12_3=qu12_3(i); 
	q12_4=qu12_4(i); 
	q12_5=qu12_5(i);
	q12_6=qu12_6(i); 
	q12_7=qu12_7(i); 
	q12_8=qu12_8(i);
	q12_9=qu12_9(i); 
	q12_10=qu12_10(i);
	q12_11=qu12_11(i); 

    q13_1=qu13_1(i);
	q13_2=qu13_2(i);
	q13_3=qu13_3(i);
	q13_4=qu13_4(i);
	q13_5=qu13_5(i); 
	q13_6=qu13_6(i); 
	q13_7=qu13_7(i);

    q14_1=qu14_1(i);
	q14_2=qu14_2(i); 
	q14_3=qu14_3(i);
	q14_4=qu14_4(i); 
	q14_5=qu14_5(i);
	q14_6=qu14_6(i);
	q14_7=qu14_7(i);
	q14_8=qu14_8(i);
	q14_9=qu14_9(i);
	q14_10=qu14_10(i);
	q14_11=qu14_11(i); 
	q14_12=qu14_12(i); 

		 output derived.survey_collection;
		 end;
	 end;
run;


/*QA*/

/*data one;*/
/*     set raw.survey_collection (drop=Name_Code);*/
/*run;*/
/**/
/*proc print data=one;*/
/*     var q1 q2 q4_2_3;*/
/*run;*/

/*note that database 21 is missing. Maybe no one is using it?*/
/*databases 22-25 are other. We need to think of a way to deal with them*/

***(drop=Name_Code) b/c Log ERROR: Format NAME_CO not found or couldn't be loaded for variable Name_Code.***;

proc print data=raw.survey_collection(drop=Name_Code);
run;



FAQ
Q:
U:\SAMPLE_SAS_PROGRAM\macros\Summary_stats_template.sas
68   %Let datas=raw.survey_collection
69
70   %getcont();
WARNING: Apparent symbolic reference DATAS not resolved.
ERROR: The text expression RAW.SURVEY_COLLECTION  PROC CONTENTS DATA=&DATAS contains a
       recursive reference to the macro variable DATAS.  The macro variable will be assigned
       the null value.
A:
It means that some variable names were truncated (cut off) in a way that caused two variables to have the same name.
Q: How Do I loop through variables for proc freq
Example: footnote "SAS program stored: U:\STUDENT Su Kim\HPV dataset_20140902\programs\Draft\bl_survey_1.sas";
A:

PROC FREQ automatically shows two decimal places in its presentation of percentages and cumulative percentages. PROC TEMPLATE can be used to override this.
