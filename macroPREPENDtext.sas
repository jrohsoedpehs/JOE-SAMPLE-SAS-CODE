/*How to use a macro to prepend text in code*/

proc contents data= sashelp.cars varnum;
run;


%macro rename(name);
data test;
set sashelp.cars;
&name._rename = make;
run;
%mend;

%rename(joe);
proc contents data= test varnum;
run;




%macro prepend(name);
&name._rename = make;
%mend;


data test;
set sashelp.cars;
%prepend(jesse);
run;

/*%str() lets us use commas within a parameter*/
%SUMscore(visit1_role,8,%str(separatedbaby_pre1, regularcare_pre1, alonewithbaby_pre1, sharefamfriends_pre1, protectpain_pre1, comfort_pre1, staffcloserbaby_pre1, holdbaby_pre1));
