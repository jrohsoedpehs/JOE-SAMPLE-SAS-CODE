/*************************************************************************************************************
You can use excel to quickly group variables using filter under the home ribbon. 
Once the variables are filtered copy them onto a new excel page and paste using transpose (except checkboxes).
Now the variables are ready to be pasted into excel.
For checkboxes, uses the =A1&A2&... etc and autocomplete to quickly add the necessary suffix
checkbox variable format
(data dictionary var name)___(data dictionary choice value) this reiterates for all values of a variable
*************************************************************************************************************/
%let num = ; /*field type = text, validation = number or integer*/
%let char = ; /*field type = radio, yesno, truefalse, dropdown*/
%let checkboxes = ; /*field type = checkboxes, var name = var _ _ _ (value) i.e. race___4*/
%let miscl = ;/*Too many categories to be useful for analysis, field type=text and validation=none or date */
%let useless = ;/*Not useful for analysis field type = descriptive, file*/

proc contents data= raw.Neurodev varnum;
run;

proc means data= raw.Neurodev maxdec=2 n nmiss min max mean std;
   var &num;
run;

proc freq data= raw.Neurodev;
   tables &char &checkboxes ;
run;



