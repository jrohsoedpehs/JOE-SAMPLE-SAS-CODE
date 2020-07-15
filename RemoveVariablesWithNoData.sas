/*How to remove variables with no data*/

proc print data= sashelp.class;run;

data class;
 set sashelp.class;
 call missing(name,age);
run;

proc print data= class;run;



ods select none;
ods output nlevels=temp; /*temp is the temporary dataset*/
proc freq data=class nlevels;
tables _all_;
run;



ods select all;
proc sql noprint;
 select tablevar into : drop separated by ' ' /*drop is the group of missing vars to remove*/
  from temp                                   /*Same temporary as above*/
   where NNonMissLevels=0;
quit;


data want;
 set class(drop=&drop);
run;

proc print data= want;run;
