/*CHECK 5 HIGHEST AND LOWEST DATES FOR OUTLIERS*/
ods rtf file="&path/COGSTATE/Output/5 highest and lowest Number of months between consecutive visits &sysdate..doc" ;
title "5 highest and lowest Number of months between consecutive visits ";
ods trace on;
ods select extremeobs;
proc univariate data=COGd.cogstate_data_new ;
    class TCode;
    var date_var;
    histogram date_var;
    id subject_id TCode date_var;
run;
ods trace off;
ods rtf close;
