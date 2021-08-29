***
cr00_macro_library.sas

THE PURPOSE OF THIS PROGRAM IS TO:

1) CREATE MACRO FUNCTIONS FOR REPETITIVE ACTIONS SUCH AS 
    CHECKING FOR DUPLICATES
    SORTING DATA
    CREATING PDF AND CSV
***;


/*CHECK FOR DUPLICATE DATA

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

proc sort data = dsn;
    by id ;
run;

data dups;
    set dsn;
    by id ;
    if first.id ne last.id or first.id = 0 and last.id = 0;
run;

/*PRINT DUPLICATES*/
proc print data = dups noobs;
    title "&title";
run;

