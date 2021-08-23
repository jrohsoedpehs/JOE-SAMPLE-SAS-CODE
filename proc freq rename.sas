proc freq data=demo /*noprint*/;
where exit_interview_flag=1;                                 /*original = new*/
table trt * exit_interview_flag / out = work.numerator (rename = (COUNT = numerator));
run;
