/*do loop and if then with multiple statements*/

data keepvalid10000;
	set derived.keep10000;
	array FLAG {*} bivszBMI_0607 ;

	array BMI {*}          BMI_0607;
    array PCT {*}          BMIPCT_0607;
	array PCT95 {*}          BMIPCT95_0607;
	array MZ {*}          BMImz_0607;
	array SZ {*}          BMIsz_0607;


    do i=1 to dim(FLAG);
        if FLAG [i] in (-1,1) then do; /*allows multiple statements for if*/
            BMI [i]=. ;
            PCT [i]=. ;
            PCT95 [i]=. ;
            MZ [i]=. ;
            SZ [i]=. ;
        end;

	end;
	run;



	data keepvalid10000;
	set derived.keep10000;
	array FLAG {*} bivszBMI_0607 ;

	array BMI {*}          BMI_0607;
    array PCT {*}          BMIPCT_0607;
	array PCT95 {*}          BMIPCT95_0607;
	array MZ {*}          BMImz_0607;
	array SZ {*}          BMIsz_0607;


    do i=1 to dim(FLAG);
        if FLAG [i] in (-1,1) then  BMI [i]=. ; /*allows single statement for if*/
  	end;
	run;
