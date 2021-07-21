/*Before we can view the 3d grid plot, we need to actually create the grid data. This is done using proc g3grid. 
Then we can plot using proc g3d just like we did for the scatter plot.*/


/* Create the grid data */
proc g3grid data=hsb2 out=a;
  grid write*read = math / 
    axis1=30 to 80 by 5
    axis2=30 to 80 by 5;
run;

/* Plot the Surface */
proc g3d data=a;
  plot write*read = math;
run;

/*We moved in increments of 5 for the prior grid and SAS did a linear interpolation between points. 
Using a different increment can give a more fine-tuned view. This may or may not be helpful, but it 
is useful to know what the differences are and how to try different ways.*/


/* We can adjust the detail in the grid */
proc g3grid data=hsb2 out=b;
  grid write*read=math / 
  axis1=30 to 80 by 1
  axis2=30 to 80 by 1;
run;
proc g3d data=b;
  plot write*read=math;
run;

/* It can be helpful to view at different angles */
proc g3d data=b;
  plot write*read=math /
  rotate=45 tilt=80;
run;
