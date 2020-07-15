data a;
input id sex;
label sex = "What is your sex?";
format sex sex.;
cards;
1 0
2 1
;
run;
