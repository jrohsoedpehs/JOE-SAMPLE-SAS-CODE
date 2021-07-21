
/*Allow gaps between visits*/
/*Use retain to remember a value by id and week*/
proc sort data=derived.DFH_Data_Fall_2018_anal;
by id week;
run;

data temp;
	set derived.DFH_Data_Fall_2018_anal;
	by id week;
	retain blv;
	if first.id then blv = week -1;
	adj_visit = week - blv;
run;

proc print data=temp (obs = 200);
var id week adj_visit blv;
run;

/*Output*/
proc print data= temp;
/*where adj_visit = 8;*/
/*where id in (1,9,10,11,13,14,17,18);*/
where id in (10);
var id date week visit adj_visit weightkgwk agegp;
run;

