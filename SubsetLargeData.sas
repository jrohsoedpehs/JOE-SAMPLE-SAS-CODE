data raw.Telet_test;
	set raw.telehealth;
	obs = _n_;  **creates variable named "obs" which counts the row number;
	if obs < 100; **tells SAS to take the first 100 rows of data
	keep ESSI01--ESSI07, PTSDDNGR—PTSDDAT, PSI001-PSI120;   **this will keep any variable listed between the two, ADD THE SUBJECTID VARIABLE;
run;
