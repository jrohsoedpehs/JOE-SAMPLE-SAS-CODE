/*CHECK FOR DUPLICATES*/
/*DUPOUT SHOWS WHAT WAS DELETED*/
/*OUT SHOWS WHAT WAS KEPT*/
proc sort data=raw.cuidalos_joe dupout=temp4 nodupkey out=temp1; 
	by staff_id year month day;
run;
