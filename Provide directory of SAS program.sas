%macro curdir();
%local fr rc curdir;

%let rc = %sysfunc(filename(fr,.));
%let curdir = %sysfunc(pathname(&fr));
%let rc = %sysfunc(filename(fr));

&curdir

%mend curdir;

%put Current path is %curdir;
