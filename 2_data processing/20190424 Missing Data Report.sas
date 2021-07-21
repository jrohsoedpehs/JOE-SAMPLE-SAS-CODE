/*Simple Missing Data Report*/
title "var";
proc print data= dsn label;
    var study_id redcap_event_name /*redcap_repeat_form redcap_repeat_instance*/ var;
    where missing(var); 
run;



/*Missing Data Report Macro*/
%macro print(var);
title "&var";
proc print data= dsn label;
    var study_id redcap_event_name /*redcap_repeat_form redcap_repeat_instance*/ &var;
    where missing(&var); 
run;
%mend;


/*Missing Data Report For all variables in the project*/
proc contents data=dsn noprint varnum out=temp;run;
/*PUT THE VARIABLES IN TEMP IN THE ORDER OF THE DATASET*/
proc sort data=temp;by VARNUM;run;

proc sql noprint;   
    select name   
    into : all_vars   
    separated by '", "'   
    from temp  
/*    where 3 <= varnum <= 79;*/
/*	where type = 1;*/
quit; 
/*VIEW VARIABLES IN &numlist*/
%put &all_vars;


%macro print(var);
title "&var";
proc print data= dsn label;
    var study_id redcap_event_name /*redcap_repeat_form redcap_repeat_instance*/ &var;
    where missing(&var); 
run;
%mend;

data macro_call2;
do var= &all_vars;
    str=catt('%print(var=', var, ')');
    call execute(str);
end;
run;


data macro_call2;
do var= "var1", ... "varn";
    str=catt('%print(var=', var, ')');
    call execute(str);
end;
run;

%print(var=);


"%print("     var=      ");"

str=catt( "%print(",  var=  ,  ");" );


