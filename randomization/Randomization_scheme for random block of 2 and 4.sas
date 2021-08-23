libname derived "Q:...\Randomization\data\Raw";

footnote "SAS Program Stored in Q:...\Randomization\programs\Draft\African American\Randomization_scheme for Whites.sas";

/***************************************************

CREATING RANDOMIZATION SCHEME FOR ...

****************************************************/


%macro random(site,name,id,ran1,ran2,ran3);

/*Randomization scheme for 140 participants: block of 2*/

DATA A;
        DO BLOCK = 1 TO 30; /* after 1 block is filled we want all 2 of the treat groups to be filled*/
			DO TREATMENT=0 TO 1;
         			 OUTPUT A;
		 	 END;
 		 END;
RUN;

PROC PRINT DATA=A; RUN;

DATA AA;
  SET A; 
 	U=&ran1; 
RUN;

PROC SORT DATA=AA;
	BY BLOCK U ;/*sorting by block makes the groups even*/
RUN;  

DATA AB;
  SET AA;
/*	BY BLOCK U ;*/
  	RANDOMIZATION_ID=_N_;
RUN;

PROC PRINT DATA=AB;
	TITLE 'RANDOMIZATION SCHEME FOR BLOCK OF 2';
RUN;

/*DATA RAW.RANDOMIZE_M;*/
/*	SET AB;*/
/*RUN;*/



/*Randomization scheme for 220 participants: block of 4*/

DATA CA;
        DO BLOCK = 1 TO 20; /* after 1 block is filled we want all 4 of the treat groups to be filled*/
			DO REP=0 TO 1;
				DO TREATMENT= 0 TO 1;
         			OUTPUT CA;
    		  	END;
		 	 END;
 		 END;
RUN;

DATA CAA;
  SET CA; 
 	U=&ran2; 
RUN;

PROC SORT DATA=CAA;
	BY BLOCK U ;/*sorting by block makes the groups even*/
RUN;

DATA CAB;
  SET CAA;
/*	BY BLOCK U ;*/
  	RANDOMIZATION_ID=_N_ + 140;
	BLOCK = BLOCK + 30;
RUN;

/*PROC PRINT DATA=CAB;*/
/*	TITLE 'RANDOMIZATION SCHEME FOR BLOCKS OF 4';*/
/*RUN;*/


/*combining and scrabling both randomization schemes*/

* The purpose of this dataset is to eventually scramble our blocks;
DATA D;
	DO BLOCK = 1 TO 50;
/*  	R=RANNOR(14654965);*/
 	r=&ran3;
		OUTPUT D;
	END;
RUN;
proc sort data=d; by block; run;

/*PROC PRINT DATA=D; RUN;*/

DATA ALLBLOCKS;
 	SET AB CAB;
	DROP U;
RUN;

/*proc print data=allblocks; run;*/

PROC SORT DATA=ALLBLOCKS; 
	BY BLOCK;
RUN;

DATA &site ;
	MERGE ALLBLOCKS D;
	BY BLOCK;
	length group $ 20.; 
	if treatment = 0 then group = "Treatment A"; /*Health Information*/
	else if treatment = 1 then group ="Treatment B"; /*Coaching*/
RUN;

/*proc print data=&site; run;*/

PROC SORT DATA= &site;
	 BY r;
 RUN;

data derived.RANDOMIZE_&site ;
	set &site;
	drop RANDOMIZATION_ID REP R ;
	id = _n_;
run;

/* PROC contents DATA=derived.strata2; RUN;*/

 Ods rtf file ="Q:...\&site &name &sysdate..doc";
 	PROC print DATA=derived.RANDOMIZE_&site;
		title "&site &name &sysdate";
	RUN;
 ods rtf close;

%mend random;


%random(Box1,random_blocks_of_2_and_4,1,RANNOR(235142198),RANNOR(258474159),RANNOR(123048525)); 
/******************* RANDOMIZATION CODE ENDS HERE *************************/ 
