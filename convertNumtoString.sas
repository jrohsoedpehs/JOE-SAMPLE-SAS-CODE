
/*CONVERT A NUMERIC VAR TO A STRING VAR*/
data derived.Qch_pmer (drop = gender VAR76 VAR77 VAR78);
   set raw.Qch_p;

ID_S = put(ID, 20.); 

drop ID;

rename ID_S= ID;
run; 
