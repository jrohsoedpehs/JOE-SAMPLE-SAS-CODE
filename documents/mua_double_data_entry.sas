/*Access through U drive*/
/*libname muaraw 'U:\Jesse Chittams\Retail Clinic Data\data\Raw\';*/

/* Access through H drive */
libname raw 'H:\Secured Folders\Research Statistics\Jesse Chittams\Retail Clinic Data\data\Raw\';


/* footnote 'U:\Jesse Chittams\Retail Clinic Data\programs\Draft\mua_double_data_entry.sas'; */
footnote 'H:\Secured Folders\Research Statistics\Jesse Chittams\Retail Clinic Data\programs\Draft\mua_double_data_entry.sas';
proc print data=raw.mua_infojoe;
run;

/*prepare clinid for proc compare*/
proc sort data=raw.mua_infojoe;
         by clinid;
run;

proc sort data=raw.mua_infoaaron;
         by clinid;
run;

proc compare base=raw.mua_infojoe compare=raw.mua_infoaaron;
            id clinid;
run;


/* there are 10 mismatched obs. Let's spot them below */
/* clinid 19115 18068  19175  19476  19521  19581  19611  19726  19864  19924  */


proc print data=raw.mua_infoaaron;
run;

*proc compare for new states;
/*prepare clinid for proc compare*/
proc sort data=raw.mua_new_states_a;
         by clinid;
run;

proc sort data=raw.mua_new_states_j;
         by clinid;
run;

proc compare base=raw.mua_new_states_a compare=raw.mua_new_states_j;
            id clinid;
run;

* there is 1 mismatched obs.
clinid 19718;
