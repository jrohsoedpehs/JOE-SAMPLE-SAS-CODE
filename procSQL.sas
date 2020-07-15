proc contents data=&title varnum out=cont_out noprint;run;

proc sql noprint;  /*proc means variables*/ 
    select name into : means separated by ' ' from cont_out   
    where type = 1 and format in ('BEST'); /*    type=1 and format = 'BEST' is numeric, BEST IS THE DEFAULT NUM FORMAT*/
quit; 
%put &means;
