/***************
PREPARE DATA FOR MACHINE LEARNING
CREATE TRAINING DATA
VALIDATION DATA
TEST DATA
***************/

/**** Randomly Select Data for Training ****/
proc sort data=derived.drc3;
run;

/**Randomly select 60% of data**/
proc surveyselect data=derived.drc3 
			method = srs rate = .5
			seed = 12345678 out = derived.training;
run;


proc contents data=derived.training;
run;

/**Sorts for merge**/
proc sort data= derived.drc3;
	by idnumr;
run;

proc sort data= derived.training;
	by idnumr;
run;

/**Take data that isn't in the training and seperate**/
data derived.remain;
	merge derived.training(in=a) derived.drc3;
	by idnumr;
	group = 1;
	if not a;
run;


/**Drop ID**/
data derived.training;
	set derived.training;
	group = 0;
	drop idnumr;
run;


/**Set the training and validation data**/
data derived.dtreedrc3;
	set derived.training derived.remain;
run;
