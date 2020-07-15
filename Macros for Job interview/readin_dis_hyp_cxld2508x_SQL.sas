**********************************************************************************
** Program name : readin_dis_Hyp_exld2508x.sas		  	  			 						  	
** input dataset :  /project/shennessy2/disdva/biostats/rawdata/MEDICAID/
**					in_ca1999-in_ca2008.sas7dbat ot_ca1999-ot_ca2008.sas7dbat
					in_pa1999-in_pa2008.sas7dbat ot_pa1999-ot_pa2008.sas7dbat
					in_fl1999-in_fl2008.sas7dbat ot_fl1999-ot_fl2008.sas7dbat
					in_ny1999-in_ny2008.sas7dbat ot_ny1999-ot_ny2008.sas7dbat
					in_oh1999-in_oh2008.sas7dbat ot_oh1999-ot_oh2008.sas7dbat
					lt_ca1999-lt_ca2008.sas7dbat lt_pa1999-lt_pa2008.sas7dbat 
					lt_fl1999-lt_fl2008.sas7dbat lt_ny1999-lt_ny2008.sas7dbat 
					lt_oh1999-lt_oh2008.sas7dbat 
					/project/shennessy2/disdva/biostats/rawdata/MEDICARE/
 					Raw_medpar1999-2012 
 					op1999.sas7dbat-op2002.sas7dbat  Bcarclms2003.sas7dbat-Bcarclms2008.sas7dbat 
 					pb1999.sas7dbat-bp2003.sas7dbat  Otptclms2003.sas7dbat-Otptclms2008.sas7dbat  
					/project/drugdrug_inter/biostats/Clopidogrel_PPI/data/code/
 					Hyp_exld2508x_code.sas7dbat
** Output dataset :	/project/drugdrug_inter/biostats/Clopidogrel_PPI/data/raw/
					 Dis_Hyp_exld2508x.sas7dbat 
** Date Started  : 10/26/2012                                         
** Last Revised  : 8/20/2013                                          			
** Written by    :  Jean                                 		
** Purpose       :  1) Pull the severe hypoglycemia records found in the “Severe Hypoglycemia” 
					worksheet of file “Appendix 3 ICD9_Codes_hypoglycemia and exclusion codes for 
					events coded as 250.8.xls*”.  Search all available diagnosis fields in outpatient, ED, 
					or inpatient records.  Create two flags for each record pulled
					a)	primary vs. secondary code
					b)	inpatient vs. ED vs. outpatient record

					2) Pull all hypoglycemia co-diagnosis ICD-9 codes found in the
					“250.8X exclude follow codes” worksheet of file “Appendix 3 
					ICD9_Codes_hypoglycemia and exclusion codes for events coded as 250.8.xls*”.
					Search all available diagnosis fields in outpatient, ED, or inpatient records.
					Create two flags for each record pulled
					a)	primary vs. secondary code
					b)	inpatient vs. ED vs. outpatient record

**********************************************************************************;

%let sh=t;** Rawmed Rawmcare drive letter **;
%let p=x;** Statin drive letter **;
%macro plat;
	%if &sysscp = WIN %then %do; 
		%include  "&p.:\biostats\OAD_SCAVA_0443\SU\programs\lib_name.sas";
	%end;
	%else %if &sysscp = SUN 4 or &sysscp = SUN 64 or (&sysscp = LIN X64) %then %do; 
		%include  '/project/drugdrug_inter/biostats/OAD_SCAVA_0443/programs/lib_name.sas'; 
	%end;
%mend;
%plat;
data code;
length medcode $ 8;
 	set  code.Hyp_exld2508x_code (keep=medcode class  rename=(medcode=code));	
    medcode=strip(code); 
run;
%macro find_VA_Mcaid_in(dataset);
%let varlist = ca*oh*pa*ny*fl;
%let varnum=5;
		%do a=1 %to 5;*&varnum;
		%let state = %scan(&varlist,&a, '*');
data temp1;
   length  %do i=1 %to 9;  DIAG_&i._&dataset $ 8 %end;;
	set	 %DO d=1999 %TO 2012;
	rawmed.&dataset._&state.&d (/*obs=10000*/ keep=state msis dt_beg_&dataset. dt_admt_&dataset. DT_END_&dataset. diag_: )
	%end;;
	if dt_admt_&dataset. = . then diag_date=dt_beg_&dataset.;
	else diag_date=dt_admt_&dataset.;
	DISCHARGEDT=DT_END_&dataset.;
	if 	diag_date ne .;
	placeflag ='in'; 
	drop  DT_END_&dataset. dt_beg_&dataset. dt_admt_&dataset. ;
	format diag_date DISCHARGEDT mmddyy10.;
run;
data &dataset.&state;
 if _n_ = 1 then do;
   if 0 then set code;**The dataset containing the CHF codes;
   declare hash lookup(dataset:"code (keep=medcode class)");**The dataset containing the CHF codes;
   lookup.definekey("medcode");*Key is medcode;
   lookup.definedata("medcode","class");
   lookup.definedone();
 end;
 set temp1;**Use the new THIN; 
	%do i=1 %to 9;
	if lookup.find(key:strip(DIAG_&i._&dataset ))=0 then do; dnum = &i; output; end;
	%end;
	run; 
proc sort data=	&dataset.&state (keep=state msis DISCHARGEDT placeflag diag_date dnum medcode class ) nodup;
    by state msis  diag_date;
run; 
%end;
%mend; 
%find_VA_Mcaid_in(in);
 
%macro find_VA_Mcaid_lt(dataset);
%let varlist = oh*ca*pa*ny*fl;
%let varnum=5;
		%do a=1 %to &varnum;
		%let state = %scan(&varlist,&a, '*');
data temp1;
   length  %do i=1 %to 5;  DIAG_&i._&dataset $ 8 %end;;
	set	 %DO d=1999 %TO 2012;
	rawmed.&dataset._&state.&d (/*obs=10000*/ keep=state msis dt_beg_&dataset. dt_admt_&dataset. DT_END_&dataset.  diag_: )
	%end;;
	if dt_admt_&dataset. = . then diag_date=dt_beg_&dataset.;
	else diag_date=dt_admt_&dataset.;
	DISCHARGEDT=DT_END_&dataset.;
	if 	diag_date ne .;
	placeflag='out';	
	drop  DT_END_&dataset. dt_beg_&dataset. dt_admt_&dataset. ;
	format DISCHARGEDT diag_date mmddyy10.;
run;
data &dataset.&state;
 if _n_ = 1 then do;
   if 0 then set code;**The dataset containing the CHF codes;
   declare hash lookup(dataset:"code (keep=medcode class)");**The dataset containing the CHF codes;
   lookup.definekey("medcode");*Key is medcode;
   lookup.definedata("medcode","class");
   lookup.definedone();
 end;
 set temp1;**Use the new THIN; 
	%do i=1 %to 5;
	if lookup.find(key:strip(DIAG_&i._&dataset ))=0 then do; dnum = &i; output; end;
	%end;
	run;
proc sort data=	&dataset.&state (keep=state msis dnum diag_date medcode class placeflag DISCHARGEDT) nodup;
    by state msis  diag_date;
run; 
%end;
%mend; 
%find_VA_Mcaid_lt(lt);


%macro find_VA_Mcaid_ot(state,ed);
data temp1;
   length PROC1_OT $ 12 placeflag $ 5 %do i=1 %to 2;  DIAG_&i._ot $ 8 %end;;
	set	 %DO d=1999 %TO 2012;
	rawmed.ot_&state.&d (/*obs=10000*/ keep= state msis dt_beg_ot diag_:  DT_END_ot SMRF_TOS_OT UB_REV place PROC1_OT B_PROVID_OT) %end;;
	diag_date=dt_beg_ot;
	if 	diag_date ne .;
	if ((place=23)  &ed  ) then placeflag='ed';
	else placeflag='out';  
	DISCHARGEDT=DT_END_ot;
	drop  DT_END_ot dt_beg_ot place PROC1_OT;
	format diag_date DISCHARGEDT mmddyy10.;
run;
data ot&state;
 if _n_ = 1 then do;
   if 0 then set code;**The dataset containing the CHF codes;
   declare hash lookup(dataset:"code (keep=medcode class)");**The dataset containing the CHF codes;
   lookup.definekey("medcode");*Key is medcode;
   lookup.definedata("medcode","class");
   lookup.definedone();
 end;
 set temp1;**Use the new THIN;
	if (lookup.find(key:strip(DIAG_1_ot)) = 0) then do; dnum = 1; output; end;
	if lookup.find(key:strip(DIAG_2_ot) )=0 then do;dnum = 2; output; end;
	run;
	
proc sort data=	ot&state (keep=state msis dnum placeflag diag_date medcode class DISCHARGEDT) nodup;
     by state msis  diag_date;
run; 
%mend;
%find_VA_Mcaid_ot(ca, %str(or PROC1_OT in ('99281','99282','99283','99284','99285','99288','99291','99292',
				 'G0380','G0381','G0382','G0383','G0384','G8354')));
%find_VA_Mcaid_ot(pa, %str(or PROC1_OT in ('99281','99282','99283','99284','99285','99288','99291','99292',
				 'G0380','G0381','G0382','G0383','G0384','G8354')));
%find_VA_Mcaid_ot(ny,); 
%find_VA_Mcaid_ot(oh, %str(or (SMRF_TOS_OT=11 and UB_REV in (450,451,452,456,459,981)) or 
				 (PROC1_OT in ('99281','99282','99283','99284','99285','99288','99291','99292',
				 'G0380','G0381','G0382','G0383','G0384','G8354'))));
%find_VA_Mcaid_ot(fl,%str(or (SMRF_TOS_OT=11 and UB_REV in (450,451,452,456,459,981)) or
				 (PROC1_OT in ('99281','99282','99283','99284','99285','99288','99291','99292',
				 'G0380','G0381','G0382','G0383','G0384','G8354'))));

%macro medicare(dataset);
data temp;
length %do i=1 %to 9; DGNS_CD0&i $ 8 %end;%do i=10 %to 25; DGNS_CD&i  $ 8 %end; placeflag $ 5;
	set %DO I=1999 %TO 2012;
		rawmcare.Raw_medpar&I (/*obs=10000*/ keep= state msis AdmissionDt DGNS_: SSLSSNF DISCHARGEDT )
		%END;;
	diag_Date = AdmissionDt;
	if 	diag_Date ne .;
	if SSLSSNF in ('S','L') then placeflag ='in'; 
	else placeflag ='out';  
	format DISCHARGEDT diag_date mmddyy10.;
	drop AdmissionDt ;
run; 
data medpar;
 if _n_ = 1 then do;
   if 0 then set code;**The dataset containing the CHF codes;
   declare hash lookup(dataset:"code (keep=medcode class)");**The dataset containing the CHF codes;
   lookup.definekey("medcode");*Key is medcode;
   lookup.definedata("medcode","class");
   lookup.definedone();
 end;
 set temp;**Use the new THIN; 
	%do i=1 %to 9;
	if lookup.find(key:strip(DGNS_CD0&i) )=0 then do; dnum = &i; output;  end;
	%end;
    %do i=10 %to 25;
	if lookup.find(key:strip(DGNS_CD&i) )=0 then do; dnum = &i; output;  end;
	%end; 
run;

proc sort data=	medpar (keep=state msis dnum placeflag diag_date medcode class DISCHARGEDT) nodup;
     by state msis  diag_date;
run; 
%mend;
%medicare(mpar);

%macro find_VA_Car(dataset);
data tempCA tempPA tempNY tempFL tempOH; 
   length   placeflag PlaceFlag_new $5 PDGNS_CD $ 8  %do i=2 %to 4;  DGNS_CD&i. $ 8 %end;;
	set %DO I=1999 %TO 2003;
		rawmcare.pb&I (/*obs=10000*/ keep=state msis FROMDT PDGNS_CD DGNS_CD2-DGNS_CD4 BETOS: PLCRVC: HCPSCD: THRUDT)
		%END;;
	diag_date = FROMDT;
	DISCHARGEDT=THRUDT;
	if diag_date ne .;
/*	IF (year(FROMDT) not in (2003) and (%DO A=1 %TO 9; PLCRVC0&A in ('03' ,'21') OR %END; */
/*	%DO B=10 %TO 12; PLCRVC&b in ('03' ,'21') OR %END; PLCRVC13 in ('03' ,'21'))) or*/
/*	(year(FROMDT) in (2003) and (%DO A=1 %TO 9; PLCRVC0&A in ('21')    OR %END; */
/*	%DO B=10 %TO 12; PLCRVC&b in ('21') OR %END; PLCRVC13 in ('21'))) then placeflag_new='in_c';*/
/*    else IF (%DO A=1 %TO 9; PLCRVC0&A='23' OR*/
/*	HCPSCD0&A IN ('99281','99282','99283','99284','99285','99288','99291','99292',*/
/*	'G0380','G0381','G0382','G0383','G0384','G8354') OR	BETOS0&A IN ('M3')  OR %END; */
/*	%DO B=10 %TO 12; PLCRVC&b='23' OR HCPSCD&b IN */
/*	('99281','99282','99283','99284','99285','99288','99291','99292',*/
/*	'G0380','G0381','G0382','G0383','G0384','G8354') OR */
/*	BETOS&b  IN ('M3')  OR %END; PLCRVC13='23' OR HCPSCD13 IN */
/*	('99281','99282','99283','99284','99285','99288','99291','99292','G0380',*/
/*	'G0381','G0382','G0383','G0384','G8354') OR BETOS13 IN ('M3')) then placeflag_new='ed';	*/
/*	else placeflag_new='out';*/


	IF (%DO A=1 %TO 9; PLCRVC0&A='23' OR
	HCPSCD0&A IN ('99281','99282','99283','99284','99285','99288','99291','99292',
	'G0380','G0381','G0382','G0383','G0384','G8354') OR	BETOS0&A IN ('M3')  OR %END; 
	%DO B=10 %TO 12; PLCRVC&b='23' OR HCPSCD&b IN 
	('99281','99282','99283','99284','99285','99288','99291','99292',
	'G0380','G0381','G0382','G0383','G0384','G8354') OR 
	BETOS&b  IN ('M3')  OR %END; PLCRVC13='23' OR HCPSCD13 IN 
	('99281','99282','99283','99284','99285','99288','99291','99292','G0380',
	'G0381','G0382','G0383','G0384','G8354') OR BETOS13 IN ('M3')) then placeflag='ed';	
	else placeflag='out';

	format DISCHARGEDT diag_date   mmddyy10.;
   if  strip(State)='CA' then output tempCA;
   if  strip(State)='PA' then output tempPA;
   if  strip(State)='NY' then output tempNY;
   if  strip(State)='FL' then output tempFL;
   if  strip(State)='OH' then output tempOH;
	drop FROMDT  BETOS: PLCRVC: HCPSCD: THRUDT;
run;
%let varlist = ca*pa*ny*oh*fl;
		%do a=1 %to 5;
		%let state = %scan(&varlist,&a, '*');
data t1&dataset.&state;
 if _n_ = 1 then do;
   if 0 then set code;**The dataset containing the CHF codes;
   declare hash lookup(dataset:"code (keep=medcode class)");**The dataset containing the CHF codes;
   lookup.definekey("medcode");*Key is medcode;
   lookup.definedata("medcode","class");
   lookup.definedone();
 end;
 set temp&state;**Use the new THIN;
   if (lookup.find(key:strip(PDGNS_CD)) = 0) then do; dnum = 1; output; end;
	%do i=2 %to 4;
	if lookup.find(key:strip(DGNS_CD&i ))=0 then do; dnum = &i; output; end;
	%end;
run;
%end;

***********2004 to 2007;
data tempCA tempPA tempNY tempFL tempOH;
	length %do i=1 %to 8;  DGNS_CD&i. $ 8 %end;  ;
	set %DO I=2004 %TO 2007;
		rawmcare.Bcarclms&I (/*obs=10000*/ keep= state msis FROMDT DGNS_CD: THRUDT CLM_ID)
		%END;;
		diag_date = FROMDT;
	format diag_date   mmddyy10.;
   if  strip(State)='CA' then output tempCA;
   if  strip(State)='PA' then output tempPA;
   if  strip(State)='NY' then output tempNY;
   if  strip(State)='FL' then output tempFL;
   if  strip(State)='OH' then output tempOH;
	drop FROMDT;
run;
%let varlist = ca*pa*ny*oh*fl;
		%do a=1 %to 5;
		%let state = %scan(&varlist,&a, '*');
data t2&dataset.&state(keep=state msis diag_date medcode class dnum THRUDT CLM_ID );
 if _n_ = 1 then do;
   if 0 then set code;**The dataset containing the CHF codes;
   declare hash lookup(dataset:"code (keep=medcode class)");**The dataset containing the CHF codes;
   lookup.definekey("medcode");*Key is medcode;
   lookup.definedata("medcode","class");
   lookup.definedone();
 end;
 set temp&state;**Use the new THIN;
	%do i=1 %to 8;
	if lookup.find(key:strip(DGNS_CD&i) )=0 then do; dnum=&i; output; end;
	%end;
run;
%end;
 
data tempCA tempPA tempNY tempFL tempOH;  
    length placeflag PlaceFlag_new $5 ;
	set %DO I=2004 %TO 2007;
		rawmcare.Bcarline&I (/*obs=10000*/ keep= state msis THRU_DT BETOS HCPCS_CD CLM_ID PLCSRVC 
		rename=THRU_DT=THRUDT )
		%END;;
/*	 if PLCSRVC in ('21') then PlaceFlag_new='in'; */
/*	 else if PLCSRVC='23' OR HCPCS_CD IN */
/*		('99281','99282','99283','99284','99285','99288','99291','99292','G0380',*/
/*		'G0381','G0382','G0383','G0384','G8354') OR BETOS IN ('M3') then PlaceFlag_new='ed';*/
/*	else PlaceFlag_new='out';*/

    if PLCSRVC='23' OR HCPCS_CD IN 
		('99281','99282','99283','99284','99285','99288','99291','99292','G0380',
		'G0381','G0382','G0383','G0384','G8354') OR BETOS IN ('M3')   then PlaceFlag='ed';
	else PlaceFlag='out';
   if THRUDT ne .;
   if  strip(State)='CA' then output tempCA;
   if  strip(State)='PA' then output tempPA;
   if  strip(State)='NY' then output tempNY;
   if  strip(State)='FL' then output tempFL;
   if  strip(State)='OH' then output tempOH;
	keep state msis THRUDT placeflag CLM_ID;
run;
%do f=1 %to 5;
%let state = %scan(&varlist,&f, '*'); 
/*proc sort data=temp&state nodupkey;*/
/*by  state msis  THRUDT CLM_ID;*/
/*run;*/
/*proc sort data=t2&dataset.&state nodup;*/
/*by  state msis  THRUDT CLM_ID;*/
/*run;*/
/*data t2&dataset.&state;*/
/*    merge t2&dataset.&state (in=a) temp&state (in=b) ;*/
/*	by  state msis  THRUDT CLM_ID;*/
/*	if a; */
/*	if PlaceFlag=' ' then PlaceFlag='out';*/
/*	DISCHARGEDT=THRUDT;*/
/*	keep state msis PlaceFlag: medcode diag_date dnum class DISCHARGEDT;*/
/*run;*/

proc sql;
  create table t2&dataset.&state.a as
  select distinct a.state, a.msis, PlaceFlag, medcode, diag_date, dnum, class, a.THRUDT as DISCHARGEDT
  from t2&dataset.&state as a left join temp&state as b
  on a.state = b.state and a.msis = b.msis and a.THRUDT = b.THRUDT and a.CLM_ID = b.CLM_ID;
quit;

data t2&dataset.&state;
  set t2&dataset.&state.a;
  if PlaceFlag=' ' then PlaceFlag='out';
run;

%end;   

***********2012;

data tempCA tempPA tempNY tempFL tempOH;
	length %do i=1 %to 12;  DGNS_CD&i. $ 8 %end; ;
	set %DO I=2008 %TO 2012;
		rawmcare.Bcarclms&I (/*obs=10000*/ keep= state msis FROMDT DGNS_CD: THRUDT CLM_ID)
		%END;;
		diag_date = FROMDT;
	format diag_date mmddyy10.;
   if  strip(State)='CA' then output tempCA;
   if  strip(State)='PA' then output tempPA;
   if  strip(State)='NY' then output tempNY;
   if  strip(State)='FL' then output tempFL;
   if  strip(State)='OH' then output tempOH;
	drop FROMDT;
run;
%let varlist = ca*pa*ny*oh*fl;
		%do a=1 %to 5;
		%let state = %scan(&varlist,&a, '*');
data t3&dataset.&state(keep=state msis  diag_date medcode class dnum THRUDT CLM_ID);
 if _n_ = 1 then do;
   if 0 then set code;**The dataset containing the CHF codes;
   declare hash lookup(dataset:"code (keep=medcode class)");**The dataset containing the CHF codes;
   lookup.definekey("medcode");*Key is medcode;
   lookup.definedata("medcode","class");
   lookup.definedone();
 end;
 set temp&state;**Use the new THIN;

 /*Qing change from 10 to 12*/
	%do i=1 %to 12;
	if lookup.find(key:strip(DGNS_CD&i) )=0 then do; dnum=&i; output; end;
	%end;
run;
%end;
 
data tempCA tempPA tempNY tempFL tempOH;  
    length placeflag PlaceFlag_new $5 ;
	set %DO I=2008 %TO 2012;
		rawmcare.Bcarline&I (/*obs=10000*/ keep= state msis THRU_DT BETOS HCPCS_CD CLM_ID PLCSRVC 
		rename=THRU_DT=THRUDT )
		%END;;
/*	 if PLCSRVC in ('21') then PlaceFlag_new='in_c'; */
/*	 else if PLCSRVC='23' OR HCPCS_CD IN */
/*		('99281','99282','99283','99284','99285','99288','99291','99292','G0380',*/
/*		'G0381','G0382','G0383','G0384','G8354') OR BETOS IN ('M3')   then PlaceFlag_new='ed';*/
/*	else PlaceFlag_new='out';*/

	
	if PLCSRVC='23' OR HCPCS_CD IN 
		('99281','99282','99283','99284','99285','99288','99291','99292','G0380',
		'G0381','G0382','G0383','G0384','G8354') OR BETOS IN ('M3')   then PlaceFlag='ed';
	else PlaceFlag='out';
   if THRUDT ne .;

   if  strip(State)='CA' then output tempCA;
   if  strip(State)='PA' then output tempPA;
   if  strip(State)='NY' then output tempNY;
   if  strip(State)='FL' then output tempFL;
   if  strip(State)='OH' then output tempOH;
	keep state msis THRUDT placeflag: CLM_ID;
run;
%do f=1 %to 5;
%let state = %scan(&varlist,&f, '*'); 
/*proc sort data=temp&state nodupkey;*/
/*by  state msis  THRUDT CLM_ID;*/
/*run;*/
/*proc sort data=t3&dataset.&state nodup;*/
/*by  state msis  THRUDT CLM_ID;*/
/*run;*/
/*data t3&dataset.&state;*/
/*length placeflag PlaceFlag_new $5 ;*/
/*    merge t3&dataset.&state (in=a) temp&state (in=b) ;*/
/*	by  state msis  THRUDT CLM_ID;*/
/*	if a; */
/*	if PlaceFlag=' ' then PlaceFlag='out';*/
/*	DISCHARGEDT=THRUDT;*/
/*	keep state msis PlaceFlag: medcode diag_date dnum class DISCHARGEDT;*/
/*run;*/

proc sql;
  create table t3&dataset.&state as
  select distinct a.state, a.msis, PlaceFlag, medcode, diag_date, dnum, class, a.THRUDT as DISCHARGEDT
  from t3&dataset.&state as a left join temp&state as b
  on a.state = b.state and a.msis = b.msis and a.THRUDT = b.THRUDT and a.CLM_ID = b.CLM_ID;
 quit;

data t3&dataset.&state;
  length placeflag $5;
  set t3&dataset.&state;
  if PlaceFlag=' ' then PlaceFlag='out';
run;

%end;   
data &dataset;
length placeflag $ 5;
    set %do f=1 %to 5; 
	%let state = %scan(&varlist,&f, '*'); 
	t1&dataset.&state t2&dataset.&state t3&dataset.&state %end;;
	keep state msis dnum diag_date medcode placeflag: class DISCHARGEDT;
run;

proc sort data=	&dataset  nodup;
    by state msis  diag_date;
run; 
%mend;
%find_VA_Car(carrier);

%macro find_VA_SAF(dataset);
data tempCA tempPA tempNY tempFL tempOH;
    length placeflag $5   PDGNS_CD DGNSCD10 $ 8 %do i=2 %to 9;  DGNSCD0&i. $ 8 %end;;
	set %DO I=1999 %TO 2003;
		rawmcare.op&I (/*obs=10000*/ keep=state msis FROMDT THRUDT PDGNS_CD DGNSCD02-DGNSCD10 RVCNTR: HCPSCD:)
		%END;;
		diag_date = FROMDT;
	if diag_date ne .;

	IF (%DO A=1 %TO 9; 
			RVCNTR0&A IN ('0450','0451','0452','0456','0459','0981') OR
			HCPSCD0&A IN ('99281','99282','99283','99284','99285','99288','99291','99292',
			'G0380','G0381','G0382','G0383','G0384','G8354') 		OR 
		%END;
	    %DO B=10 %TO 44; 
			RVCNTR&B IN ('0450','0451','0452','0456','0459','0981') OR
			HCPSCD&b IN ('99281','99282','99283','99284','99285','99288','99291','99292',
			'G0380','G0381','G0382','G0383','G0384','G8354') 		OR 
		%END;
	    RVCNTR45 IN ('0450','0451','0452','0456','0459','0981')) 	OR
	    HCPSCD45 IN ('99281','99282','99283','99284','99285','99288','99291','99292',
		'G0380','G0381','G0382','G0383','G0384','G8354') then placeflag='ed'; 
	else placeflag='out';  
	DISCHARGEDT=THRUDT;
	format diag_date mmddyy10.;
   if  strip(State)='CA' then output tempCA;
   if  strip(State)='PA' then output tempPA;
   if  strip(State)='NY' then output tempNY;
   if  strip(State)='FL' then output tempFL;
   if  strip(State)='OH' then output tempOH;
	drop FROMDT RVCNTR: HCPSCD: THRUDT ;
run;
%let varlist = ca*pa*ny*oh*fl;
		%do a=1 %to 5;
		%let state = %scan(&varlist,&a, '*');
data t1&dataset.&state(keep=state msis placeflag diag_date dnum medcode class DISCHARGEDT);
 if _n_ = 1 then do;
   if 0 then set code;**The dataset containing the CHF codes;
   declare hash lookup(dataset:"code (keep=medcode class)");**The dataset containing the CHF codes;
   lookup.definekey("medcode");*Key is medcode;
   lookup.definedata("medcode","class");
   lookup.definedone();
 end;
 set temp&state;**Use the new THIN;
 	dataname=2;
   if (lookup.find(key:strip(PDGNS_CD)) = 0) then do;  dnum = 1; output; end;
 	%do i=2 %to 9;
	if lookup.find(key:strip(DGNSCD0&i ))=0 then do; dnum = &i; output; end;
	%end;
	if lookup.find(key:strip(DGNSCD10 ))=0 then do; dnum = 10; output; end;
run;
%end;

******************2004 to 2007;
data tempCA tempPA tempNY tempFL tempOH;
	length placeflag $5 DGNSCD10 $ 8 %do i=1 %to 9;  DGNSCD0&i. $ 8 %end;;
	set %DO I=2004 %TO 2007;
		rawmcare.Otptclms&I (/*obs=10000*/ keep= state msis FROMDT DGNSCD: THRU_DT CLM_ID  )
		%END;;
	diag_date = FROMDT;
	if diag_date ne .;
    placeflag='out';
	format diag_date mmddyy10.;
   if  strip(State)='CA' then output tempCA;
   if  strip(State)='PA' then output tempPA;
   if  strip(State)='NY' then output tempNY;
   if  strip(State)='FL' then output tempFL;
   if  strip(State)='OH' then output tempOH;
	drop FROMDT;
run;
%let varlist = ca*pa*ny*oh*fl;
		%do a=1 %to 5;
		%let state = %scan(&varlist,&a, '*');
data t2&dataset.&state(keep=state msis THRU_DT CLM_ID diag_date medcode class placeflag DISCHARGEDT dnum );
 if _n_ = 1 then do;
   if 0 then set code;**The dataset containing the CHF codes;
   declare hash lookup(dataset:"code (keep=medcode class)");**The dataset containing the CHF codes;
   lookup.definekey("medcode");*Key is medcode;
   lookup.definedata("medcode","class");
   lookup.definedone();
 end;
 set temp&state;**Use the new THIN;
 	%do i=1 %to 9;
	if lookup.find(key:strip(DGNSCD0&i ))=0 then do;  dnum = &i; output; end;
	%end;
	if lookup.find(key:strip(DGNSCD10 ))=0 then do;  dnum = 10; output; end;
run;
%end;
data tempCA tempPA tempNY tempFL tempOH; 
	set %DO I=2004 %TO 2007;
		rawmcare.OTPTREV&I (/*obs=10000*/ keep= state msis THRUDT CLM_ID REV_CNTR HCPCS_CD rename=THRUDT=THRU_DT)
		%END;;
	where  REV_CNTR IN ('0450','0451','0452','0456','0459','0981')  or HCPCS_CD IN 
		('99281','99282','99283','99284','99285','99288','99291','99292','G0380',
		'G0381','G0382','G0383','G0384','G8354') and THRU_DT ne .  ;
   if  strip(State)='CA' then output tempCA;
   if  strip(State)='PA' then output tempPA;
   if  strip(State)='NY' then output tempNY;
   if  strip(State)='FL' then output tempFL;
   if  strip(State)='OH' then output tempOH;
	keep state msis THRU_DT  CLM_ID  ;
run;  
%let varlist = ca*pa*ny*oh*fl;
%do f=1 %to 5;
%let state = %scan(&varlist,&f, '*'); 
/*proc sort data=temp&state nodupkey;*/
/*by  state msis  THRU_DT CLM_ID;*/
/*run;*/
/*proc sort data=t2&dataset.&state nodup ;*/
/*by  state msis  THRU_DT CLM_ID;*/
/*run;  */
/*data t2&dataset.&state;*/
/*    length   placeflag $5;*/
/*    merge t2&dataset.&state(in=a) temp&state(in=b) ;*/
/*	by  state msis  THRU_DT CLM_ID; */
/*	if a;*/
/*	DISCHARGEDT=THRU_DT;*/
/*	if b then placeflag='ed';*/
/*	else if a and not b then placeflag='out';*/
/*	keep state msis diag_date medcode class placeflag dnum DISCHARGEDT;*/
/*run; */

proc sql;
  create table t2&dataset.&state as
  select distinct a.state, a.msis, b.msis as b_msis, PlaceFlag, medcode, diag_date, dnum, class, a.THRU_DT as DISCHARGEDT
  from t2&dataset.&state as a left join temp&state as b
  on a.state = b.state and a.msis = b.msis and a.THRU_DT = b.THRU_DT and a.CLM_ID = b.CLM_ID;
quit;

data t2&dataset.&state;
  length placeflag $5;
  set t2&dataset.&state;
  if b_msis ^= '' then PlaceFlag='ed';
   else placeflag='out';
  drop b_msis;
run;

%end;  
******************2012;
data tempCA tempPA tempNY tempFL tempOH;
	length %do i=1 %to 9;  DGNSCD0&i. $ 8 %end; %do i=10 %to 25;  DGNSCD&i. $ 8 %end;;
	set %DO I=2008 %TO 2012;
		rawmcare.Otptclms&I (/*obs=10000*/ keep= state msis FROMDT DGNSCD: THRU_DT CLM_ID)
		%END;;
	diag_date = FROMDT;
	if diag_date ne .;
	format diag_date mmddyy10.;
   if  strip(State)='CA' then output tempCA;
   if  strip(State)='PA' then output tempPA;
   if  strip(State)='NY' then output tempNY;
   if  strip(State)='FL' then output tempFL;
   if  strip(State)='OH' then output tempOH;
	drop FROMDT;
run;
%let varlist = ca*pa*ny*oh*fl;
		%do a=1 %to 5;
		%let state = %scan(&varlist,&a, '*');
data t3&dataset.&state;
 if _n_ = 1 then do;
   if 0 then set code;**The dataset containing the CHF codes;
   declare hash lookup(dataset:"code (keep=medcode class)");**The dataset containing the CHF codes;
   lookup.definekey("medcode");*Key is medcode;
   lookup.definedata("medcode","class");
   lookup.definedone();
 end;
 set temp&state;**Use the new THIN;
 	%do i=1 %to 9;
	if lookup.find(key:strip(DGNSCD0&i ))=0 then do; dnum = &i; output; end;
	%end;
    %do i=10 %to 25;
	if lookup.find(key:strip(DGNSCD&i ))=0 then do;  dnum = &i;  output; end;
	%end; 
run;
%end;
data tempCA tempPA tempNY tempFL tempOH; 
	set %DO I=2008 %TO 2012;
		rawmcare.OTPTREV&I (/*obs=10000*/ keep= state msis THRUDT CLM_ID REV_CNTR HCPCS_CD rename=THRUDT=THRU_DT)
		%END;;
	where  REV_CNTR IN ('0450','0451','0452','0456','0459','0981')  or HCPCS_CD IN 
		('99281','99282','99283','99284','99285','99288','99291','99292','G0380',
		'G0381','G0382','G0383','G0384','G8354') and THRU_DT ne .; 
   if  strip(State)='CA' then output tempCA;
   if  strip(State)='PA' then output tempPA;
   if  strip(State)='NY' then output tempNY;
   if  strip(State)='FL' then output tempFL;
   if  strip(State)='OH' then output tempOH;
	keep state msis THRU_DT  CLM_ID;
run;   
%let varlist = ca*pa*ny*oh*fl;
%do f=1 %to 5;
%let state = %scan(&varlist,&f, '*'); 
/*proc sort data=temp&state nodupkey;*/
/*by  state msis  THRU_DT CLM_ID;*/
/*run;*/
/*proc sort data=t3&dataset.&state nodup;*/
/*by  state msis  THRU_DT CLM_ID;*/
/*run;  */
/*data t3&dataset.&state;*/
/*    length   placeflag $5;*/
/*    merge t3&dataset.&state(in=a) temp&state(in=b) ;*/
/*	by  state msis  THRU_DT CLM_ID; */
/*	if a;*/
/*	*/
/*	DISCHARGEDT=THRU_DT;*/
/*	if b then placeflag='ed';*/
/*	else if a and not b then placeflag='out';*/
/*	keep state msis dnum diag_date  medcode class DISCHARGEDT placeflag;*/
/*run; */

proc sql;
  create table t3&dataset.&state.a as
  select distinct a.state, a.msis, b.msis as b_msis, medcode, diag_date, dnum, class, a.THRU_DT as DISCHARGEDT
  from t3&dataset.&state as a left join temp&state as b
  on a.state = b.state and a.msis = b.msis and a.THRU_DT = b.THRU_DT and a.CLM_ID = b.CLM_ID;
quit;

data t3&dataset.&state;
  length placeflag $5;
  set t3&dataset.&state.a;
  if b_msis ^= '' then PlaceFlag='ed';
   else placeflag='out';
/*   drop b_msis;*/
run;

%end;  
data &dataset;
    set %do f=1 %to 5; 
	%let state = %scan(&varlist,&f, '*'); 
	t1&dataset.&state(keep=state msis dnum diag_date medcode class placeflag DISCHARGEDT)
	t2&dataset.&state(keep=state msis dnum diag_date medcode class placeflag DISCHARGEDT)
	t3&dataset.&state(keep=state msis dnum diag_date medcode class placeflag DISCHARGEDT)
	%end;;
	format DISCHARGEDT mmddyy10.;
run;

proc sort data=	&dataset  nodup;
      by state msis  diag_date;
run; 
%mend;
%find_VA_SAF(outsnf);

%macro set_rx();
%let statelist = ca fl ny oh pa;
data dis_confounders;
	set outsnf carrier 	medpar
		%do b=1 %to 5;	%let state = %scan(&statelist,&b);
		lt&state ot&state in&state
		%end;;
	keep state msis diag_date dnum medcode placeflag: class DISCHARGEDT;
run; 
proc sql;
	create table raw.Dis_Hyp_exld2508x_sql as
	select state, msis, diag_date,  a.medcode,b.class ,dnum,placeflag,PlaceFlag_new,DISCHARGEDT
	from work.dis_confounders   as a , work.code  as b
	where trim(left(a.medcode))=trim(left(b.medcode))  ;
quit; 
%mend;
%set_rx(); 
 
