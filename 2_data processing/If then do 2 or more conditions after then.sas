data dsn;

/*REMOVE HEIGHT AND WEIGHT OUTLIERS*/
/*2 or more conditions after then*/
if  HeightFT >= 7 and HeightIN > 0 then do; 
HeightFT = .;
HeightIN = .;
end;
run;
