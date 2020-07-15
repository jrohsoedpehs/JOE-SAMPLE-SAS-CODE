

/*Transpose data Wide (flat) to long (repeated rows)*/

data long (keep=  pxid intervention sv_age EdLevel Ethnicity Race Gender Smoker /*variables that don't change over time*/
/*baseline versions*/ RV_BMI RV_wt_kg RV_wt_lb RV_HamD SV_ADM SV_Age SV_BDI_noapp SV_BPdiast SV_BPsys SV_CRP SV_CVDrisks 
					SV_Chol_HDLC SV_FBG SV_GAF SV_HDL SV_LDL SV_PCE10 SV_PCEL SV_TotCholest SV_Tri SV_insulin SV_waistcirc 
/*new variables*/	BMI Wt_KG Wt_lbs HAMD BDI_noapp BP_dia BP_sys CRP CVD_risk chol_hdl_ratio FBG GAF HDL_chol LDL_chol PCE_10 PCE_L Tot_chol Trigly Insulin waist_cir);

	by pxid;

	array Wt_k(*) RV_wt_kg SV_wt_kg AV8_wt_kg AV20_wt_kg AV46_wt_kg;
	array Wt_l(*) RV_wt_lb SV_wt_lb AV8_wt_lb AV20_wt_lb AV46_wt_lb;
	array BM(*)RV_BMI SV_BMI AV8_BMI AV20_BMI AV46_BMI;
	array WC(*) RV_waistcirc SV_waistcirc AV8_waistcirc AV20_waistcirc AV46_waistcirc;
	array FGlu(*) RV_fbg SV_fbg AV8_fbg AV20_fbg AV46_fbg;
	array Ham(*) RV_hamd SV_hamd AV8_hamd AV20_hamd AV46_hamd;
	array P10(*) SV_pce10 AV8_pce10 AV20_pce10 AV46_pce10;
	array Pl(*)  SV_pcel AV8_pcel AV20_pcel AV46_pcel;
	array BpS(*) SV_bpsys AV8_bpsys AV20_bpsys AV46_bpsys;
	array BpD(*) SV_bpdiast AV8_bp_diast AV20_bpdiast AV46_bpdiast;
	array Chol(*) SV_totcholest AV8_totcholest AV20_totcholest AV46_totcholest;
	array HDL(*) SV_hdl AV8_hdl AV20_hdl AV46_hdl;
	array LDL(*) SV_ldl AV8_ldl AV20_ldl AV46_ldl;
	array Tri(*) SV_tri AV8_tri AV20_tri AV46_tri;
	array CholHR(*) SV_chol_hdlc AV8_chol_hdlc AV20_chol_hdlc AV46_chol_hdlc;
	array CR(*) SV_crp AV8_crp AV20_crp AV46_crp;
	array Fb(*) SV_fbg AV8_fbg AV20_fbg AV46_fbg;
	array Ins(*) SV_insulin AV8_insulin AV20_insulin AV46_insulin;

		*condition = group;
		*subject = study_id;
		do i=1 to dim(wt_k);
			Wt_kg=Wt_k(i); Wt_lbs=Wt_l(i); BMI=BM(i); Waist_cir=WC(i); FBG=FGlu(i); HamD=Ham(i); PCE_10=P10(i); PCE_L=Pl(i); BP_sys=BpS(i); BP_dia=BpD(i); tot_chol=Chol(i); HDL_chol=HDL(i);
			LDL_Chol=LDL(i); Trigly=tri(i); Chol_HDL_ratio=cholhr(i); CRP=CR(i); FBG=Fb(i); Insulin=Ins(i); 
             Visit=I; 
			output long2;
		end;
		
run;

proc sort data=long;
       by study_id visit;
run;

proc print data=long;
     var study_id visit ci_ratio;
run;
