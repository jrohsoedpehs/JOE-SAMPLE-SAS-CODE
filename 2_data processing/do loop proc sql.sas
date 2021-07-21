/*Do Loop with Proc SQL*/

%macro sqlloop(start,end); 
   PROC SQL; 
     %DO year=&start. %TO &end.; 
       CREATE TABLE NewTable&year. as 
       SELECT * FROM MyDataSet WHERE anno=&year.; 
     %END; 
   QUIT;
%mend; 

%sqlloop(start=1949, end=1999)


 
/* This is just to show another approach, where data is only read 2 times (instead of 50 times)*/
 
%macro sqlloop(data,byvar);
   proc sql NOPRINT;
     select distinct &byvar. into :_values SEPARATED by ' _'
     from &data.;
   quit; 
   data _&_values.;
     set &data.;
      select (&byvar);
       %do i=1 %to %sysfunc(count(_&_values.,_));
          %let var = %sysfunc(scan(_&_values.,&i.)); 
          when ("%substr(&var.,2)") output &var.;
       %end;
       end;
   run;
%mend;

%sqlloop(data=sashelp.class, byvar=age)
%sqlloop(data=sashelp.class, byvar=sex)
%sqlloop(data=MyDataSet, byvar=anno)
