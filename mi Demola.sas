/*IMPUTE EMOTIONAL_M12*/

proc mi data=derived.derimp out=mis seed=37851 mu0=94.55  NIMPUTe=1 simple  maximum = 120.00 minimum = 60.00;
		where visit = 2;
	  /* CATEGORICAL VARIABLES WITH LITTLE OR NO MISSING IN ORDER OF LEAST TO MOST MISSING*/
      class sick_healthy physposta inftgndc rachs;
	  /* LAST VARIABLE MUST BE THE VARIABLE FOR IMPUTATION */
      var   sick_healthy physposta inftgndc rachs mdi_m6; 
     monotone reg(mdi_m6 = sick_healthy physposta inftgndc rachs);
run;


proc mi data=derived.derimp out=mis seed=37851 mu0=33.086  NIMPUTe=1 simple  maximum = 44.00 minimum = 24.00;
		where visit = 2;
	  /* CATEGORICAL VARIABLES WITH LITTLE OR NO MISSING IN ORDER OF LEAST TO MOST MISSING*/
      class sick_healthy physposta inftgndc rachs;
	  /* LAST VARIABLE MUST BE THE VARIABLE FOR IMPUTATION */
      var   sick_healthy physposta inftgndc rachs  EMOTIONAL_M12;
     monotone reg( EMOTIONAL_M12= sick_healthy physposta inftgndc rachs);
run;

proc means data =derived.derimp;
var EMOTIONAL_M12;run;

proc print data=mis (obs=30) ;var EMOTIONAL_M12;
run;

proc print data = derived.derimp(obs=30);var EMOTIONAL_M12;
run;

proc means data =;
var EMOTIONAL_M12;run;
