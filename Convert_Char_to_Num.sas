/*Compress Function*/
/*How to use the compress function to recover missing data when converting from char to num*/
data derived.dde;
   set raw.dde;
   array char {*}$ recept_vocab_wppsi	information_wppsi	similarities_wppsi	block_design_wppsi	obj_assem_wppsi	matrix_reas_wppsi	pic_concepts_wppsi	pic_memor_wppsi	zoo_loc_wppsi	bug_search_wppsi	cancellation_wppsi	verb_compr_wppsi	visu_spati_wppsi	fluid_reason_wppsi	work_memor_wppsi	process_speed_wppsi	full_scale_wppsi	similarities_wisc	vocabulary_wisc	block_design_wisc	visual_puzzles_wisc	matrix_reas_wisc	fig_weights_wisc	digit_span_wisc	pic_span_wisc	coding_wisc	symbol_search_wisc	verb_compr_wisc	visu_spati_wisc	fluid_reason_wisc	work_memor_wisc	process_speed_wisc	full_scale_wisc	lett_word_id_wjiv	app_prob_wjiv	pas_comp_wjiv	calc_wjiv	sent_reading_fl_wjiv	math_facts_fl_wjiv	aud_compr_pls5	exp_comm_pls5	sent_compre_celf5	word_struct_celf5	word_classes_celf6	sem_rel_celf5	form_sent_celf5	recall_sent_celf5	und_spoken_para_celf5	beery_vmi	age_adjusted_pic	unadjusted_pic	imm_recall_rcft	delayed_recall_rcft	recog_rcft	age_adjusted_flanker	unadjusted_flanker	age_adjusted_dimen	unadjusted_dimen	age_adjusted_dext	unadjusted_dext	dom_hand_dext	nondom_hand_dext	age_adjusted_grip	unadjusted_grip	dom_hand_grip	nondom_hand_grip	age_adjusted_end	unadjusted_end	gait_score	mf_nepsy	mfd_nepsy	mfvsmfd_nepsy	aware_vsrs	cognition_srs	commd_srs	motivation_srs	rirb_srs	total_srs	dsm_sci_srs	dsm_rrb_srs	social_skills_ssis	prob_behavior_ssis	top10_ssis	total_comp_cbcl	activities_cbcl	social_cbcl	school_cbcl	internalizing_cbcl	externalizing_cbcl	total_prob_cbcl	affective_cbcl	anxiety_cbcl	somatic_prob_cbcl	attention_deficit_cbcl	opposition_cbcl	conduct_cbcl	anxious_cbcl	withdrawn_cbcl	somatic_comp_cbcl	social_prob_cbcl	thought_cbcl	attention_prob_cbcl	rule_breaking_cbcl	aggressive_cbcl	communication_abas3	communityd_abas3	functional_abas3	home_living_abas3	health_abas3	leisure_abas3	selfcare_abas3	selfdirection_abas3	social_sc_abas3	work_abas3	gen_adapt_abas3	concept_abas3	social_st_abas3	practical_abas3
; /* $ defines the group of variables as char*/
   array compressed {*} recept_vocab_wppsi_n	information_wppsi_n	similarities_wppsi_n	block_design_wppsi_n	obj_assem_wppsi_n	matrix_reas_wppsi_n	pic_concepts_wppsi_n	pic_memor_wppsi_n	zoo_loc_wppsi_n	bug_search_wppsi_n	cancellation_wppsi_n	verb_compr_wppsi_n	visu_spati_wppsi_n	fluid_reason_wppsi_n	work_memor_wppsi_n	process_speed_wppsi_n	full_scale_wppsi_n	similarities_wisc_n	vocabulary_wisc_n	block_design_wisc_n	visual_puzzles_wisc_n	matrix_reas_wisc_n	fig_weights_wisc_n	digit_span_wisc_n	pic_span_wisc_n	coding_wisc_n	symbol_search_wisc_n	verb_compr_wisc_n	visu_spati_wisc_n	fluid_reason_wisc_n	work_memor_wisc_n	process_speed_wisc_n	full_scale_wisc_n	lett_word_id_wjiv_n	app_prob_wjiv_n	pas_comp_wjiv_n	calc_wjiv_n	sent_reading_fl_wjiv_n	math_facts_fl_wjiv_n	aud_compr_pls5_n	exp_comm_pls5_n	sent_compre_celf5_n	word_struct_celf5_n	word_classes_celf6_n	sem_rel_celf5_n	form_sent_celf5_n	recall_sent_celf5_n	und_spoken_para_celf5_n	beery_vmi_n	age_adjusted_pic_n	unadjusted_pic_n	imm_recall_rcft_n	delayed_recall_rcft_n	recog_rcft_n	age_adjusted_flanker_n	unadjusted_flanker_n	age_adjusted_dimen_n	unadjusted_dimen_n	age_adjusted_dext_n	unadjusted_dext_n	dom_hand_dext_n	nondom_hand_dext_n	age_adjusted_grip_n	unadjusted_grip_n	dom_hand_grip_n	nondom_hand_grip_n	age_adjusted_end_n	unadjusted_end_n	gait_score_n	mf_nepsy_n	mfd_nepsy_n	mfvsmfd_nepsy_n	aware_vsrs_n	cognition_srs_n	commd_srs_n	motivation_srs_n	rirb_srs_n	total_srs_n	dsm_sci_srs_n	dsm_rrb_srs_n	social_skills_ssis_n	prob_behavior_ssis_n	top10_ssis_n	total_comp_cbcl_n	activities_cbcl_n	social_cbcl_n	school_cbcl_n	internalizing_cbcl_n	externalizing_cbcl_n	total_prob_cbcl_n	affective_cbcl_n	anxiety_cbcl_n	somatic_prob_cbcl_n	attention_deficit_cbcl_n	opposition_cbcl_n	conduct_cbcl_n	anxious_cbcl_n	withdrawn_cbcl_n	somatic_comp_cbcl_n	social_prob_cbcl_n	thought_cbcl_n	attention_prob_cbcl_n	rule_breaking_cbcl_n	aggressive_cbcl_n	communication_abas3_n	communityd_abas3_n	functional_abas3_n	home_living_abas3_n	health_abas3_n	leisure_abas3_n	selfcare_abas3_n	selfdirection_abas3_n	social_sc_abas3_n	work_abas3_n	gen_adapt_abas3_n	concept_abas3_n	social_st_abas3_n	practical_abas3_n
; /* defines the group of variables as numeric*/
   do i=1 to dim(char);
     compressed[i]= COMPRESS(UPCASE(char[i]),"-ABCDEFGHIJKLMNOPQRSTUVWXYZ<>%",)*1;
   end;
run;


data dsn4;
	infile datalines delimiter=','; 
	input id  height $ height_n $12.;   
	datalines;                      
	1,21,17 1/2
	2,20-ab,21.8 3/   4 
	3,99,99
	4,99NR,99NR
	5,IL,15 3/4 - 3
	6,1.32,25 - 10
;


proc print data=dsn4;run;


data dsn4_clean;
   set dsn4;
    height_clean=height*1;
run;

data dsn4_clean2;
   set dsn4;
    height_clean=compress(upcase(height),"R",);
run;

data dsn4_clean3;
   set dsn4;
   array character {*}$ height;
   array numeric {*} height_clean;
   do i = 1 to dim(character);
    numeric[i] =compress(upcase(character[i]),"-ABCDEFGHIJKLMNOPQRSTUVWXYZ<>%",)*1;
   end;
run;

proc print data=dsn4_clean3;run;


proc print data=dsn4_clean2;run;

proc print data=dsn4_clean;run;
