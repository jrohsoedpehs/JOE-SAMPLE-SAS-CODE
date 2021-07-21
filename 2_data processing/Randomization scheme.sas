libname raw 'Q:\Amy Sawyer\Claustrophobia PAP Survey Study\data\Raw';
libname derived 'Q:\Amy Sawyer\Claustrophobia PAP Survey Study\data\Derived';

footnote 'SAS program stored: Q:\Amy Sawyer\Claustrophobia PAP Survey Study\programs\Draft\simple randomization scheme.sas';


/***************************************************

CREATING RANDOMIZATION SCHEME FOR GROUPS

****************************************************/

/*RANDOMIZATION FOR EACH GROUP*/
DATA A;
        DO BLOCK = 1 TO 125; /* 4 PROJECTS FOR 20 SUBJECTS*/
			DO PROJECT=0 TO 3;
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
	TITLE 'RANDOMIZATION SCHEME';
RUN;
