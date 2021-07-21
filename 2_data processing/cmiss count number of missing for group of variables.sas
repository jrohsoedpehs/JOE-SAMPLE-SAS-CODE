data test;
    infile datalines delimiter='|';
    input var1 var2 var3;
    datalines;  
1|1|1
2| | 
;
run;
/*CHECK THAT THE DATASET HAS 3 FIELDS*/
proc contents data= test;
run;

proc print data=test noobs;
run;

data test_cmiss;
    set test;
    num_miss = cmiss(of var1 -- var3);
    num_miss2 = cmiss(var1, var2, var3);
run;

proc print data=test_cmiss noobs;
run;
