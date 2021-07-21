/*Outputs the mean of each variable as a dataset with vars assigned to each respective mean*/

proc means data=derived.combined_subscales;
	by Hospital;
	var support RNMD_relation sup_staff staff_dev career participation mistakes time enough_RN good_NM Visible_CNO enough_staff Praise standards power teamwork advancement Philosophy competent backs_up admin_listen assurance governance collaboration preceptor nur_model committees consult care_plans continuity nur_diagnosis ;
	output out = test mean = support_m RNMD_relation_m sup_staff_m staff_dev_m career_m participation_m mistakes_m time_m enough_RN_m good_NM_m Visible_CNO_m enough_staff_m Praise_m standards_m power_m teamwork_m advancement_m Philosophy_m competent_m backs_up_m admin_listen_m assurance_m governance_m collaboration_m preceptor_m nur_model_m committees_m consult_m care_plans_m continuity_m nur_diagnosis_m ;
run;
 



/*Outputs the mean of each variable as a dataset with vars assigned to each respective mean*/
proc sort data=dsn;
	by key /*any other vars to appear in dataset*/;
run;
proc means data=dsn;
	by key /*any other vars to appear in dataset*/;
	var var1 var2 var3;
	output out = test mean = var1_m var2_m var3_m;
run;
