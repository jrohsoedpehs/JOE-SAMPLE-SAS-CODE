***
cr00_macro_library.sas

THE PURPOSE OF THIS PROGRAM IS TO:

1) CREATE MACRO FUNCTIONS FOR REPETITIVE ACTIONS SUCH AS 
    CHECKING FOR DUPLICATES
    SORTING DATA
    CREATING PDF AND CSV
***;


/*CHECK FOR DUPLICATE DATA*/

    /*
    FOR A GIVEN subject_id

	first.subject_id = 1 IF THE CURRENT ROW IS THE 1ST ROW
	first.subject_id = 0 IF THE CURRENT ROW IS NOT THE 1ST ROW

	last.subject_id = 1 IF THE CURRENT ROW IS THE LAST ROW
	last.subject_id = 0 IF THE CURRENT ROW IS NOT THE LAST ROW


	subject_id | first.subject_id | last.subject_id | STATUS
	         1 |                1 |               0 | DUPLICATE
	         1 |                0 |               0 | DUPLICATE
	         1 |                0 |               1 | DUPLICATE
	         2 |                1 |               1 | UNIQUE

	DUPLICATES EXIST IF ANY OF THE FOLLOWING IS TRUE

	    1) first.subject_id IS NOT EQUAL TO last.subject_id
        2) first.subject_id = 0 and last.subject_id = 0
    */
/*START DEFINITION*/
%macro duplicates(dsn, var1, var2, dups, title);

proc sort data = &dsn;
    by &var1 &var2;
run;

data &dups;
    set &dsn;
    by &var1 &var2;
    if first.&var2 ne last.&var2 or first.&var2 = 0 and last.&var2 = 0;
run;

/*PRINT DUPLICATES*/
proc print data = &dups noobs;
    title "&title";
run;
title;

/*END DEFINITION*/
%mend duplicates;

/*INSTRUCTIONS*/
*%include "Q:\SAMPLE_SAS_PROGRAM\JOE-SAMPLE-SAS-CODE\Macro Library\macro_duplicates.sas";

/*dsn = dataset*/
/*var1 = 1st - penultimate key fields (if there is only one key field leave this blank)*/
/*var2 = last key field*/
/*dups = name of dataset containing duplicates*/
/*title = title*/
*%duplicates(dsn, var1, var2, dups, title);




/*SORT DATASET*/

/*MUST SORT DATASET WHENEVER A BY STAMENT IS USED*/

/*START DEFINITION*/
%macro sort(dsn, vars);

proc sort data = &dsn;
    by &vars;
run;

/*END DEFINITION*/
%mend sort;

/*INSTRUCTIONS*/
*%sort(dsn, vars);
/*dsn = dataset*/
/*vars = variables to sort the dataset by*/
