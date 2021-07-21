

* If using SON directory;
libname raw 'U:\Lucy Faulconbridge\TODI\data\Raw';
libname derived 'U:\Lucy Faulconbridge\TODI\data\derived';
%let path= U:\Lucy Faulconbridge\TODI;

footnote "&path\programs\Draft\analysis13012015.SAS";
options nofmterr;

*****************************************************************************************************************************************************************************************;
*converting dataset to long format;
proc contents data=derived.todi short; run;

/*Alphabetic List of Variables for DERIVED.TODI 
AV20_BDI_noapp AV20_BDItot AV20_BMI AV20_BMI_scrht AV20_BPdiast AV20_BPsys AV20_CRP AV20_Chol_HDLC AV20_FBG AV20_HDL AV20_HamD AV20_Insulin AV20_LDL AV20_PCE10 AV20_PCEL AV20_RxChange 
AV20_RxChangeNotes AV20_Smoke AV20_SmokeChange AV20_SmokeChangeNotes AV20_TotCholest AV20_Tri AV20_date AV20_waistcirc AV20_wt_kg AV20_wt_lb AV46_BDI_noapp AV46_BDItot AV46_BMI 
AV46_BMI_scrht AV46_BPdiast AV46_BPsys AV46_CRP AV46_Chol_HDLC AV46_FBG AV46_HDL AV46_HamD AV46_Insulin AV46_LDL AV46_PCE10 AV46_PCEL AV46_RxChange AV46_RxChangeNotes AV46_Smoke 
AV46_SmokeChange AV46_SmokeChangeNotes AV46_TotCholest AV46_Tri AV46_date AV46_waistcirc AV46_wt_kg AV46_wt_lb AV8_BDI_noapp AV8_BDItot AV8_BMI AV8_BMI_scrht AV8_BPdiast AV8_BPsys 
AV8_CRP AV8_Chol_HDLC AV8_FBG AV8_HDL AV8_HamD AV8_Insulin AV8_LDL AV8_PCE10 AV8_PCEL AV8_RxChange AV8_RxChangeNotes AV8_Smoke AV8_SmokeChange AV8_SmokeChangeNotes AV8_TotCholest 
AV8_Tri AV8_date AV8_waistcirc AV8_wt_kg AV8_wt_lb CensorWK4 CensorWK8 CensorWK11 CensorWK16 Cohort DOB EOT_Age EdLevel Ethnicity Gender Ht_cm Ht_in Intervention Interventionist 
Notes NumSessions PPA PxID RV_BMI RV_BMI_scrht RV_Date RV_HamD RV_waistcirc RV_wt_kg RV_wt_lb Race SV_ADM SV_Age SV_BDI_noapp SV_BDI_tot SV_BMI SV_BPdiast SV_BPsys SV_CRP SV_CVDrisks 
SV_Chol_HDLC SV_Date SV_FBG SV_GAF SV_HDL SV_HamD SV_LDL SV_PCE10 SV_PCEL SV_Rx SV_SCID SV_SCIDDx1 SV_SCIDDx2 SV_TotCholest SV_Tri SV_insulin SV_waistcirc SV_wt_kg SV_wt_lb Smoker 
StudyComplete Sx10_BDInoapp Sx10_BDItot Sx10_HS Sx10_date Sx10_wt Sx11_BDInoapp Sx11_BDItot Sx11_HS Sx11_date Sx11_wt Sx12_BDInoap Sx12_BDItot Sx12_HS Sx12_date Sx12_wt Sx13_BDInoapp 
Sx13_BDItot Sx13_HS Sx13_date Sx13_wt Sx14_BDInoapp Sx14_BDItot Sx14_HS Sx14_date Sx14_wt Sx15_BDInoapp Sx15_BDItot Sx15_HS Sx15_date Sx15_wt Sx16_BDInoapp Sx16_BDItot Sx16_HS Sx16_date 
Sx16_wt Sx17_BDInoapp Sx17_BDItot Sx17_HS Sx17_date Sx17_wt Sx18BDInoapp Sx18_BDItot Sx18_HS Sx18_date Sx18_wt Sx1_BDInoapp Sx1_BDItot Sx1_HS Sx1_date Sx1_wt Sx2_BDInoapp Sx2_BDItot 
Sx2_HS Sx2_date Sx2_wt Sx3_BDInoapp Sx3_BDItot Sx3_HS Sx3_date Sx3_wt Sx4_BDInoapp Sx4_BDItot Sx4_HS Sx4_date Sx4_wt Sx5_BDInoapp Sx5_BDItot Sx5_HS Sx5_date Sx5_wt Sx6_BDInoapp 
Sx6_BDItot Sx6_HS Sx6_date Sx6_wt Sx7_BDInoapp Sx7_BDItot Sx7_HS Sx7_date Sx7_wt Sx8_BDInoapp Sx8_BDItot Sx8_HS Sx8_date Sx8_wt Sx9_BDInoapp Sx9_BDItot Sx9_HS Sx9_date Sx9_wt */


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
