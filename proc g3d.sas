/*ADD TO GRAPHS SUBDIRECTORY*/

proc print data=sashelp.lake (obs=50);
run;

proc means data= sashelp.lake maxdec=2;
run;

/*EXAMPLE 1*/
goptions reset=all border;
title "Surface Plot";
proc g3d data=sashelp.lake;
   plot length*width=depth;
run;
quit;

/*EXAMPLE 2*/
/*proc sort data=sashelp.cars out=temp;*/
/*	by Length Weight;*/
/*run;*/
/*proc print data=sashelp.cars;*/
/*run;*/
/**/
/*proc contents data=sashelp.cars;*/
/*run;*/
/**/
/*proc means data= sashelp.cars maxdec=2;*/
/*run;*/
/*goptions reset=all border;*/
/*title "Surface Plot";*/
/*proc g3d data=temp;*/
/*   plot Length*Weight=EngineSize;*/
/*run;*/
/*quit;*/

/*DATA*/
goptions reset=all border;
title "Surface Plot";
proc g3d data=raw.tda4prot;
   plot time*mean_AdequacyProtTot_10=survival; /*x*y=z x,y,and z are axis*/
run;
quit;

goptions reset=all border;
title "Surface Plot";
proc g3d data=raw.tda4prot;
   plot mean_AdequacyProtTot_10*survival=time;
run;
quit;

goptions reset=all border;
title "Surface Plot";
proc g3d data=raw.tda4prot;
   plot mean_AdequacyProtTot_10*time=survival;
run;
quit;

goptions reset=all border;
title "Surface Plot";
proc g3d data=raw.tda4prot;
   plot time*mean_AdequacyProtTot_10=survival;
run;
quit;

time survival mean_AdequacyProtTot_10
123
321
132

;
data a;
/*input x y z;*/
/*cards;*/
/*1    1  2*/
/*5 	5  50*/
/*10 10  200*/
/*20 20 400*/
/*;*/
do x = 10 to 20;
	do y = 10 to 20;
			z = x**2 + y**2; output a;
	end;
end; 
run;

goptions reset=all border;
title "Surface Plot";
proc g3d data=a;
   plot x*y=z;
run;
quit;
