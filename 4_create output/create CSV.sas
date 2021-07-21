/*Create CSV*/

ods ExcelXP file="dir\output\title &sysdate..xlsx";
                                     
ods ExcelXP OPTIONS(SHEET_INTERVAL="proc" SHEET_NAME="title");        

/*code*/

ods ExcelXP close;
