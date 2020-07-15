/*Interval Functions INTNX and INTCK*/

/*The SAS interval functions INTNX and INTCK perform calculations with date values, datetime values, and time intervals. */

/*They can be used for calendar calculations with SAS */
/*1. date values to increment date values */
/*2. datetime values by intervals */
/*3. to count time intervals between dates. */


/*The INTNX function increments dates by intervals. INTNX computes the date or datetime of the */
/*start of the interval a specified number of intervals from the interval that contains a given */
/*date or datetime value. */

/*The form of the INTNX function is */

INTNX( interval, from, n < , alignment > ) ;

/*The arguments to the INTNX function are as follows: */

/*interval  */
/*is a character constant or variable that contains an interval name */

/*from  */
/*is a SAS date value (for date intervals) or datetime value (for datetime intervals) */

/*n  */
/*is the number of intervals to increment from the interval that contains the from value */

/*alignment  */
/*controls the alignment of SAS dates, within the interval, used to identify output observations. */
/*Allowed values are BEGINNING, MIDDLE, END, and SAMEDAY. */

/*The number of intervals to increment, n, can be positive, negative, or zero. */

/*For example, the statement NEXTMON=INTNX(’MONTH’,DATE,1) assigns to the variable NEXTMON the date of the first */
/*day of the month following the month that contains the value of DATE. Thus INTNX(’MONTH’,’21OCT2007’D,1) */
/*returns the date 1 November 2007. */






/*The INTCK function counts the number of interval boundaries between two date values or between two datetime values. */

/*The form of the INTCK function is */

INTCK ( interval, from, to ) ;

/*The arguments of the INTCK function are as follows: */

/*interval  */
/*is a character constant or variable that contains an interval name */

/*from  */
/*is the starting date value (for date intervals) or datetime value (for datetime intervals) */

/*to  */
/*is the ending date value (for date intervals) or datetime value (for datetime intervals) */

/*For example, the statement NEWYEARS=INTCK(’YEAR’,DATE1,DATE2) assigns to the variable NEWYEARS the number of */
/*New Year’s Days between the two dates. */



/*intake_week_start=1*(intnx('WEEK', date_intake,0,'beginning')) ;*/


intnx('WEEK', date_intake,0,'BEGINNING');

interval = 'WEEK'
from = date_intake
n = 0
alignment = 'BEGINNING' 
/*consider 'SAMEDAY'*/

