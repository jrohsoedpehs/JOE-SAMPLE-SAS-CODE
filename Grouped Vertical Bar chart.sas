/*BASIC VERTICAL BAR CHART*/
/*https://documentation.sas.com/?docsetId=grstatgraph&docsetTarget=n1dlakkx61v72in1k3ebm8rz18qd.htm&docsetVersion=9.4&locale=en#*/
proc template;
  define statgraph barchart;
    begingraph;
      entrytitle "title";
      layout overlay;
        barchart category=type  /
          stat=freq orient=vertical;
      endlayout;
    endgraph;
  end;

proc sgrender data=sashelp.cars template=barchart;
run;
/*STAT=FREQ | PCT | SUM | MEAN | PROPORTION*/

/*Required Arguments*/
/**/
/*Specifying only CATEGORY= creates a bar chart with bars that, by default, */
/*represent frequency counts or percents of CATEGORY. */
/**/
/*Specifying both CATEGORY= and RESPONSE= creates a */
/*bar chart with bars representing summarized values of RESPONSE categorized by CATEGORY.*/




/*GROUPED VERTICAL BAR CHART*/
proc template;
define statgraph barchart;
begingraph / attrpriority=none;
entrytitle "Average MPG by Vehicle Type and Origin";
layout overlay;
barchart x=type y=mpg_highway / name="meanmpg"
stat=mean display=all
group=origin groupdisplay=cluster
barlabel=true barlabelformat=5.1;
discretelegend "meanmpg";
endlayout;
endgraph;
end;
run;

proc sgrender data=sashelp.cars template=barchart;
run;

proc contents data=sashelp.cars  ;run;
proc print data=sashelp.cars  (obs=5);run;
