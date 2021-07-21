/***************************************************

CREATING RANDOMIZATION SCHEME FOR GROUPS

****************************************************/

/*RANDOMIZATION FOR EACH GROUP*/
/* 4 TREATMENTS FOR 20 SUBJECTS*/
DATA A;
    DO BLOCK = 1 TO 5; 
        DO TREATMENT=0 TO 3;
            OUTPUT A;
        END;
    END;
RUN;

PROC PRINT DATA=A; 
RUN;



DATA AA;
    SET A;
/*	SET RANDOM SEED*/
    U=RANNOR(248513296);

/*    U=RANNOR(349656193);*/
/*    U=RANNOR(149561093);*/

RUN;

/*VIEW RANDOM SEED IN DATASET*/
PROC PRINT DATA=AA; 
RUN;

/*sorting by block makes the groups even*/
/*RANDOMIZES TREATMENT WITHIN EACH BLOCK*/
PROC SORT DATA=AA;
    BY BLOCK U ;
RUN;  


DATA AB;
  SET AA;
/*	BY BLOCK U ;*/

/*    CREATE RANDOMIZATION ID*/
  	RANDOMIZATION_ID=_N_;
RUN;

PROC PRINT DATA=AB;
/*	TITLE 'RANDOMIZATION SCHEME FOR BLOCK OF 2';*/
	TITLE 'RANDOMIZATION SCHEME FOR BLOCK OF 5';
RUN;

/*CREATING THE SUBJECT ID WITHIN EACH GROUP*/
DATA RANDOMIZE_SITE1;
	SET AB;
	DROP U;
		do DUMMY = 1 to 4;    
			output RANDOMIZE_SITE1;
		end;
RUN;


proc print DATA =RANDOMIZE_SITE1;
run;


Data Randomize_final (drop=randomization_id block treatment dummy); 
	set randomize_site1;
	
/*CREATING THE VARIABLES FOR THE FINAL DATA SET*/
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

/*    ADDING ON TO THE GROUPS ALREADY CREATED*/
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
