/*QA age_category*/
proc freq data=dsn ;
    tables var1 * var2 / list missing;
run;
