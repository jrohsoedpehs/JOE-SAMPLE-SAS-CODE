/*CALL EXECUTE*/

data _null_;
    set work.dsn;
/*    var1 and var2 are fields from work.dsn*/
/*    var1 and var2 must be type = char*/
/*    cats() is the concatenate function for strings and/or char fields*/
    macro_call = cats( '%sample(', var1, ',' var2, ')' );

/*yields %sample(var1, var2) */
/*call execute runs the above as sas code*/
/*implied semicolon after )*/
    call execute(macro);
run;
