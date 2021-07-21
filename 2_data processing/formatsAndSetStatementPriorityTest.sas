/*testing format and setting data*/
label sex = "What is your sex?";

proc format;
value  sex  1= "Male    "
            0 = "Female";
value	  gender 1="Female"
	        0 = "Male";
run;


data a;
input id sex;
label sex = "What is your sex?";
format sex sex.;
cards;
1 0
2 1
;
run;


data b;
input id sex;
label sex = "What is your gender?";
format sex gender.;
cards;
3 0
4 1
;
run;

data c;
set a b;
run;

data c;
set b a;
run;

proc print data = work.c label;
run;

proc contents data = work.c;
run;
