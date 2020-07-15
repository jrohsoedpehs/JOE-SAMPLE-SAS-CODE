/*OUTPUT TO EXCEL XML*/
ods _all_ close;
ods tagsets.ExcelXP file="path\title.xml" ;
/*REPEAT THE FOLLOWING OPTION FOR EACH SHEET IN EXCEL*/
/*                          GROUP ON SAME SHEET  |NAME SHEET*/
ods tagsetsExcelXP OPTIONS(SHEET_INTERVAL="none" SHEET_NAME="Tab Name");
/*code*/
ods tagsets.ExcelXP close;


/*OUTPUT TO EXCEL AS XLS*/
ods _all_ close;
ods Excel file="path\title.xls" ;
/*REPEAT THE FOLLOWING OPTION FOR EACH SHEET IN EXCEL*/
/*                          GROUP ON SAME SHEET  |NAME SHEET*/
ods Excel OPTIONS(SHEET_INTERVAL="none" SHEET_NAME="Tab Name");
/*code*/
ods Excel close;
