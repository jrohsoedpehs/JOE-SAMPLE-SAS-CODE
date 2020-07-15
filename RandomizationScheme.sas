libname raw 'Q:\Tanja Kral\Randomization20170619\data\raw';
libname derived 'Q:\Tanja Kral\Randomization20170619\data\Derived';

footnote 'SAS program stored: Q:\Tanja Kral\Randomization20170619\programs\Draft\Randomization_MealCombinations';



/***************************************************

CREATING RANDOMIZATION SCHEME FOR GROUPS

****************************************************/

/*RANDOMIZATION FOR EACH GROUP*/
DATA A;
        DO BLOCK = 1 TO 5; /* 4 TREATMENTS FOR 20 SUBJECTS*/
			DO TREATMENT=0 TO 3;
         			 OUTPUT A;
		 	 END;
 		 END;
RUN;

PROC PRINT DATA=A; RUN;

DATA AA;
  SET A;
/*  U=RANNOR(349656193);*/
  U=RANNOR(248513296);
/*   U=RANNOR(149561093);*/
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

DATA RANDOMIZE_SITE1 ;
	SET AB;
	DROP U;
		do DUMMY = 1 to 4;    /*CREATING THE SUBJECT ID WITHIN EACH GROUP*/
			output RANDOMIZE_SITE1;
		end;
RUN;


proc print DATA =RANDOMIZE_SITE1;
run;


Data Randomize_final (drop=randomization_id block treatment dummy); 
	set randomize_site1;
	
/*CREATING TEH VARIABLES FOR THE FINAL DATA SET*/
GROUP = randomization_id; 
PHASE1_TRT = treatment;
ScreenID = ' ' ;
ScreenDate = ' ';
RandomizationDate = ' ';

IF PHASE1_TRT = 0 THEN PHASE1_TRT = 4;

IF PHASE1_TRT = 2 then PHASE2_TRT = 3;
ELSE IF PHASE1_TRT = 3 THEN PHASE2_TRT = 2;
ELSE IF PHASE1_TRT = 1 THEN PHASE2_TRT = 4;
ELSE IF PHASE1_TRT = 4 THEN PHASE2_TRT = 1;

/*ADDING ON TO THE GROUPS ALREADY CREATED*/
GROUP=GROUP+88;

subjid = cats(of group,dummy);
run;


proc print DATA =randomize_final;
run;

/*CREATING THE PERMANENT DATA SET WITH THE OBSERVATIONS IN THE DESIRED ORDER*/
data raw.randomize_final;
	retain screenID screendate randomizationdate group subjid phase1_trt phase2_trt;
	set randomize_final;
run;

proc print data = raw.randomize_final;
run;


/******************************************************************************************************************
****************************FOR MORE COMPLEX RANDOMIZATION*****************************************************************
*******************************************************************************************************************/



/*DATA RAW.RANDOMIZE_M;*/
/*	SET AB;*/
/*RUN;*/

/*RANDOMIZATION FOR A BLOCK OF 4*/

DATA CA;
        DO BLOCK = 1 TO 5; /* after 1 block is filled we want all 4 of the treat groups to be filled*/
			DO REP=0 TO 1;
				DO TREATMENT= 0 TO 1;/*2 doses: 60 and 120 mg*/
         			OUTPUT CA;
    		  	END;
		 	 END;
 		 END;
RUN;

PROC PRINT DATA=CA; RUN;


DATA CAA;
  SET CA;
  U=RANNOR(423990886);
RUN;

PROC SORT DATA=CAA;
	BY BLOCK U ;/*sorting by block makes the groups even*/
RUN;

/*CHANGED THE ID NUMBERS TO 21-40 IN ORDER TO COMBINE THE TWO DATA SETS*/
DATA CAB;
  SET CAA;
/*	BY BLOCK U ;*/
  	RANDOMIZATION_ID=_N_ + 20;
	BLOCK = BLOCK + 10;
RUN;

PROC PRINT DATA=CAB;
	TITLE 'RANDOMIZATION SCHEME FOR BLOCKS OF 4';
RUN;


/*RANDOMIZE THE BLOCK SIZES*/
DATA D;
	DO BLOCK = 1 TO 15;
  R=RANNOR(40399081);
		OUTPUT D;
	END;
RUN;

PROC PRINT DATA=D; RUN;

/*COMBINE THE DATA SETS WITH BLOCK SIZES 4 AND 2*/
DATA ALLBLOCKS;
 	SET AB CAB;
	DROP U;
RUN;

PROC SORT DATA=ALLBLOCKS; 
BY BLOCK;
RUN;

/*MERGE THE NEW DATA SET WITH THE RANDOMIZATION BETWEEN BLOCKS DATA SET*/
DATA SITE1 (drop=treatment) ;
	MERGE ALLBLOCKS D;
	BY BLOCK;
	if treatment = 0 then ctreatment = "A";
	else if treatment = 1 then ctreatment ="B";
RUN;

/*SORT THE DATA SET BY THE RANDOMIZATION VARIABLE*/
PROC SORT DATA= SITE1;
 BY r;
 RUN;

 PROC contents DATA=SITE1; RUN;

/*CREATE THE PERMANENT DATA SET*/
DATA RAW.RANDOMIZE_SITE1;
	SET SITE1;
	TREATMENT = ctreatment;

	facility="name";
	facility_ID="id";
RUN;

proc contents data = raw.randomize_site1;
run;

proc print data = raw.randomize_site1;
run;



/*Females import code*/
/*PROC EXPORT DATA= SITE1 
            OUTFILE= "Q:\Kathy Richards\NARLS_2017\randomization\data\Raw\Randomization_for_sites.xls" 
            DBMS=EXCEL REPLACE;
     SHEET="SITE1_Randomized_Scheme"; 
RUN;
*/




/*CREATES A MACRO TO RANDOMIZE THE VARIABLES AT EACH SITE*/
%macro random(site,name,id,ran1,ran2,ran3);

DATA A;
        DO BLOCK = 1 TO 10; /* after 1 block is filled we want all 2 of the treat groups to be filled*/
			DO TREATMENT=0 TO 1;
         			 OUTPUT A;
		 	 END;
 		 END;
RUN;

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

DATA CA;
        DO BLOCK = 1 TO 5; /* after 1 block is filled we want all 4 of the treat groups to be filled*/
			DO REP=0 TO 1;
				DO TREATMENT= 0 TO 1;/*2 doses: 60 and 120 mg*/
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
  	RANDOMIZATION_ID=_N_ + 20;
	BLOCK = BLOCK + 10;
RUN;

DATA D;
	DO BLOCK = 1 TO 15;
  R= &ran3;
		OUTPUT D;
	END;
RUN;

DATA ALLBLOCKS;
 	SET AB CAB;
	DROP U;
RUN;

PROC SORT DATA=ALLBLOCKS; 
BY BLOCK;
RUN;

DATA &site (drop=treatment) ;
	MERGE ALLBLOCKS D;
	BY BLOCK;
	if treatment = 0 then ctreatment = "A";
	else if treatment = 1 then ctreatment = "B";
RUN;

PROC SORT DATA= &site;
 BY r;
 RUN;

DATA RAW.RANDOMIZE_&site ;
	SET &site ;
	SUBJECT_ID = " ";
	TREATMENT = ctreatment ;
	facility="&name";
	facility_ID="&id";
	keep SUBJECT_ID TREATMENT facility facility_ID;
	
RUN;

title"Randomization Scheme for &site";
proc print data = RAW.RANDOMIZE_&site ;

run;
%mend random;


/*CALLS THE MACRO TO CREATE THE DATA FOR THE SITES*/
%random(Site1,Hearthstone,157,RANNOR(235142198),RANNOR(258474159),RANNOR(865948525));
%random(Site2,Wyoming_Springs,159,RANNOR(349614200),RANNOR(304872693),RANNOR(472411270));
%random(Site3,Brookdale,156,RANNOR(775012412),RANNOR(957584014),RANNOR(666047132));
%random(Site4,Heatherwilde,142,RANNOR(524796155),RANNOR(365215943),RANNOR(315476928));
%random(Site5,Cedar_Ridge,163,RANNOR(078674520),RANNOR(116243512),RANNOR(049836650));
%random(Site6,San_Gabriel,227,RANNOR(336218786),RANNOR(012983218),RANNOR(552391458));
%random(Site7,University_Village,170,RANNOR(291758462),RANNOR(921232701),RANNOR(659218435));
%random(Site8,Sagebrook,228,RANNOR(326148579),RANNOR(652874747),RANNOR(965825469));
%random(Site9,Trinity,160,RANNOR(897035471),RANNOR(058327740),RANNOR(101029432));
%random(Site10,Bel_Air,167,RANNOR(963457281),RANNOR(365256284),RANNOR(325157465));
%random(Site11,Stonebridge,151,RANNOR(153247580),RANNOR(965874789),RANNOR(215145784));
%random(Site12,Westminster,109,RANNOR(654747623),RANNOR(825405412),RANNOR(021058470));
