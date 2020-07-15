/*Best Practices for creating new variables*/
data dsn;
set dsn2;
if oldvar ne . then newvar = 1;
run;

/*QA How does the new variable handle missing data*/
proc freq data= dsn;
table newvar*oldvar /list missing;
run;
