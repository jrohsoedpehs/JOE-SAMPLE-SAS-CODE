******************************************************************************************************************
SAS Code book - Developing a Dataset 
Recipe for Success                   
•	Document                         
•	Know the end result              
•	Check your log                   
•	QA                               

******************************************************************************************************************
Preparatory Work                                                                                                
1. If you walk into a project and there is no SOP (standard operating procedures ie. The standard subdirectory) 
   then add yours (give it structure).                                                                          
2. Create a header using PI’s instructions to get oriented.                                                     
******************************************************************************************************************
Hi Maddie,
Let's followup and create the variables discussed in today's meeting in SAS. When is a convenient time for us to meet?

Best Regards,

Joseph

******************************************************************************************************************
Run the library 
*****************************************************************************************************************;
libname raw 'directory path';


******************************************************************************************************************
Create a footnote 
*****************************************************************************************************************;
footnote "SAS program stored: directory path / title of program";

******************************************************************************************************************
Some fake data to test the following code 
******************************************************************************************************************;
data test;
	input id var1 var2 var3 var4 var5 var6 var7;  *var $ = character,   var = numeric,   columns correspond to variables respectively;
	cards;                  
1 23 45 64 71 11 20 3 
2 31 20 15 74 86 22 34
3 44 15 21 64 23 21 12
	;
run;
******************************************************************************************************************
See what the data looks like
*****************************************************************************************************************;
proc print data=test;     
run;

******************************************************************************************************************
Check variable types
*****************************************************************************************************************;
proc contents data=test;  
run;


******************************************************************************************************************
Here, we'll create composite variables. That is variables derived from other variables. Creating new variables 
changes the data set. Changes to the data set are done within the datastep.
******************************************************************************************************************;
data madytest;
	set test;

******************************************************************************************************************
getting the number of variables missing for global score
var = ...
n = the total number of variables
******************************************************************************************************************;

	global_score_nmiss = nmiss(var1, var2, var3, var4, var5, var6, var7);       *the max value here is n;

    label global_score_nmiss = "Number of variables missing for global score";

 
******************************************************************************************************************
getting the percentage of missing questions
*****************************************************************************************************************;
     global_score_pctmiss=(global_score_nmiss*100)/7;

     label global_score_pctmiss = "Percent of the variables missing global score variable";

 
******************************************************************************************************************
 getting the percentage of missing questions
*****************************************************************************************************************;

     global_score_pctmiss_round=round(global_score_pctmiss);

     label global_score_pctmiss_round = "Percent missing global score round variable";

******************************************************************************************************************
Summing variables - 3 options
*****************************************************************************************************************;
     sumvar = var1+var2+var3; /*conservative, but not flawed - if a var is missing, then the entire sum is missing*/

     sumtest = sum(var1, var2, var3, var4, var5, var6, var7);  /*flawed - if any item is missing, that item is treated as zero*/

	 global_score = 7*mean(var1, var2, var3, var4, var5, var6, var7);  *Most accute for with least missing data - Sums while imputing a mean for missing data use 20% cut off rule for missing;
                                                                       * the 20% cut off prevents imputation from having significant impact on standard error
	                                                                   *missing is not included in the mean;
	                                                                  /*assigning the average of the available data to the missing data |type of imputation (handle missing data)*/

	 label sumtest = supersum;
 
******************************************************************************************************************
 global score
*****************************************************************************************************************;

     global_score = 7*mean(var1, var2, var3, var4, var5, var6, var7);  *missing is not included in the mean;
	                                                                   /*assigning the average of the available data to the missing data |type of imputation (handle missing data)*/

     label global_score = "Global score";

 
******************************************************************************************************************
 if subject is missing more than 20% of the subscales then the Global score variable will be converted to missing
*****************************************************************************************************************;
     if global_score_pctmiss_round gt 20 then global_score = .;  /*proc univariate on var w/ missing gives a distribution for missing data;

run;

proc print data=madytest;run;


******************************************************************************************************************
Some fake data to test the following code 
******************************************************************************************************************;
data test2;
	input id var1 var2 var3 var4 var5 var6 var7;  *var $ = character,   var = numeric,   columns correspond to variables respectively;
	cards;                  
1 23 45 64 71 . 20 3 
2 31 20 . . 86 22 34
3 44 15 21 . 23 21 12
	;
run;

******************************************************************************************************************
See what the data looks like
*****************************************************************************************************************;
proc print data=test2;     
run;

******************************************************************************************************************
Check variable types
*****************************************************************************************************************;
proc contents data=test2;  
run;


******************************************************************************************************************
Here, we'll create composite variables. That is variables derived from other variables. Creating new variables 
changes the data set. Changes to the data set are done within the datastep.
******************************************************************************************************************;
data madytest2;
	set test2;

******************************************************************************************************************
getting the number of variables missing for global score
var = ...
n = the total number of variables
******************************************************************************************************************;

	global_score_nmiss = nmiss(var1, var2, var3, var4, var5, var6, var7);       *the max value here is n;

    label global_score_nmiss = "Number of variables missing for global score";

 
******************************************************************************************************************
getting the percentage of missing questions
*****************************************************************************************************************;
     global_score_pctmiss=(global_score_nmiss*100)/7;

     label global_score_pctmiss = "Percent of the variables missing global score variable";

 
******************************************************************************************************************
 getting the percentage of missing questions
*****************************************************************************************************************;

     global_score_pctmiss_round=round(global_score_pctmiss);

     label global_score_pctmiss_round = "Percent missing global score round variable";

******************************************************************************************************************
Sum test
*****************************************************************************************************************;
	 sumtest = sum(var1, var2, var3, var4, var5, var6, var7);
	 label sumtest = supersum;
 
******************************************************************************************************************
 global score
*****************************************************************************************************************;

     global_score = 7*mean(var1, var2, var3, var4, var5, var6, var7);  *missing is not included in the mean;

     label global_score = "Global score";

 
******************************************************************************************************************
 if subject is missing more than 20% of the subscales then the Global score variable will be converted to missing
*****************************************************************************************************************;
     if global_score_pctmiss_round gt 20 then global_score = .;
run;

proc print data=madytest2;run;
