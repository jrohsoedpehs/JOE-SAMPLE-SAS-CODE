data NewDataset;
   set OldDataset;
   newVar=round(oldVar);
run;


/*variables  weight    */

/*mis is the dataset with EMOTIONAL_M12 imputed*/
proc mi data=YourData out=MultipleImputedDSN seed=37851 mu0=33.086  NIMPUTe=1 simple  maximum = 44.00 minimum = 24.00;
	  *where visit = 2; /*this line can be removed if there are no visits*/

	  /* CATEGORICAL VARIABLES WITH LITTLE OR NO MISSING IN ORDER OF LEAST TO MOST MISSING*/
      class CatVar1 CatVar2 CatVar3;
	  /* CONTINUOUS VARIABLES WITH LITTLE OR NO MISSING IN ORDER OF LEAST TO MOST MISSING*/
	  /* LAST VARIABLE MUST BE THE VARIABLE FOR IMPUTATION */
      var   CatVar1 CatVar2 CatVar3 ContVar1  MIweight;
     monotone reg( MIweight= CatVar1 CatVar2 CatVar3 ContVar1);
run;

/*QA DATASET PRE AND POST IMPUTATION*/
/*pre imputation*/
proc means data =YourData N NMISS MIN MAX MEAN STD;
   var weight;
run;

/*post imputation*/
proc means data =MultipleImputedDSN N NMISS MIN MAX MEAN STD;
   var MIweight;
run;

/*Expect a small if anly change in the mean.*/
/*The min and max shouldn't change*/
/*post imputation shouldn't have missing data for the imputed variable*/


/*variables  height    */

/*mis is the dataset with EMOTIONAL_M12 imputed*/
proc mi data=YourData out=MultipleImputedDSN seed=37851 mu0=33.086  NIMPUTe=1 simple  maximum = 44.00 minimum = 24.00;
	  *where visit = 2; /*this line can be removed if there are no visits*/

	  /* CATEGORICAL VARIABLES WITH LITTLE OR NO MISSING IN ORDER OF LEAST TO MOST MISSING*/
      class CatVar1 CatVar2 CatVar3;
	  /* CONTINUOUS VARIABLES WITH LITTLE OR NO MISSING IN ORDER OF LEAST TO MOST MISSING*/
	  /* LAST VARIABLE MUST BE THE VARIABLE FOR IMPUTATION */
      var   CatVar1 CatVar2 CatVar3 ContVar1  MIheight;
     monotone reg( MIhweight= CatVar1 CatVar2 CatVar3 ContVar1);
run;

/*QA DATASET PRE AND POST IMPUTATION*/
/*pre imputation*/
proc means data =YourData N NMISS MIN MAX MEAN STD;
   var height;
run;

/*post imputation*/
proc means data =MultipleImputedDSN N NMISS MIN MAX MEAN STD;
   var MIheight;
run;

