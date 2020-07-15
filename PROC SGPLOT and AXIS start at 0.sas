%macro site_plot(site_abbreviation);
PROC SGPLOT DATA = T50_graph;

   SERIES X = month_year_consent  Y = &site_abbreviation._consented / 
   MARKERS LINEATTRS = (THICKNESS = 1); 

   SERIES X = month_year_consent  Y = &site_abbreviation._consent_actual / 
   MARKERS LINEATTRS = (THICKNESS = 1); 

   XAXIS LABEL = "Month" TYPE = DISCRETE GRID ;
   YAXIS  min=0 LABEL = "Count" Type= Linear GRID ; 
/*   YAXIS  min=0 cannot be used if Type is DISCRETE or TIME*/
/*   YAXIS  min=0 cannot be used if XAXIS Type is TIME or LOG*/


   TITLE " &site_abbreviation Subjects consented by month";

  *INSET "Source: st01, T50"/ POSITION = TOPLEFT NOBORDER;
   FOOTNOTE "Source: st01, table T1 (https://upenn.app.box.com/file/332831883988)" justify=right h=1pt;
RUN; 
quit;
%mend;
/*dataset = data set name*/
/*X_axis = X axis*/
/*Y_axis = Y axis*/
/*Table_name is T1, etc*/
/*Use %site_plot(dataset, title, X_axis, Y_axis, Table_name); function to create plots for UP, UV, UT, WU, and total*/
%site_plot(UP);
%site_plot(UV);
%site_plot(UT);
%site_plot(WU);
%site_plot(Total);
