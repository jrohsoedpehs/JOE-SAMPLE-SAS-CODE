/* Is ORG_NPI_NUM missing? since the dataset is large this is a faster method of checking for missing than proc freq*/
proc means data=derived.testORG_NPI_NUM n nmiss;
   var ORG_NPI_NUM2;
run;
