/*Create a plot and decide on axis scale*/

/*see min max values for appropriate axis scales*/
proc means data= derived.DFH_Data_Fall_2018_anal maxdec=2 n nmiss min median max mean std;
var postpedometerreadingwk midheartratewk;
run;

/*Create scatterplot*/
proc gplot data=derived.DFH_Data_Fall_2018_anal; 
   plot midheartratewk*postpedometerreadingwk/haxis=axis1 vaxis=axis2; 
   axis1 label=("Pedometer Steps Taken During Dance Sessions" justify=center) order=(0 to 7000 by 1000);                                                                                                                  
   axis2 label=(a=90 "Mid-Dance HR") order=(220 to 600 by 100);                                                                                                              
   symbol1 value=dot interpol=none color=blue line=1 width=2;
   where agegp=1;
   title;
run;
quit; 
