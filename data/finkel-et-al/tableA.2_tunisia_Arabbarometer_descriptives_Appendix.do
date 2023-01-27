*****************************************************************************************************
************** PROJECT: Can Online Civic Education Induce Democratic Citizenship? ///
				* Experimental Evidence from a New Democracy 
************** AIM: This do-file replicates Table A.2 sample statistics from ArabBarometer
************** Finkel, Neundorf, Rascon-Ramirez 2022
************** Created by: Ericka Rascon 
************** Date: 26.04.2022
*****************************************************************************************************


		global		main			"/Users/TunisiaDemocracy/"		
		global 		logs			"${main}logs/TunisiaDemocracy_appendix.log"
			


log using "$logs", append 

******************************
*** Table A.2 of Appendix
******************************


/* The data used for this table was taken from the 4th wave of the Arab Barometer and can be downloaded here: https://www.arabbarometer.org/surveys/arab-barometer-wave-iv/.

Citation: Arab Barometer. Arab Barometer Wave IV (2016-2017). https://www.arabbarometer.org/surveys/arab-barometer-wave-iv/.
[No DOI available for this dataset.]


The originally downloaded dataset was first reduced to the working file needed to produce Table A.2 of the appendix. The code used to produce the working file is included here: 

**********************************************
*** Preparing ArabBarometer working file
**********************************************

use  "$main/data/ABIV_English.dta", clear
keep country wt q1001 q4113 q4116 q1002 t1003 q1004 q1005 q404 q516a

lab var country "Country"
lab var wt "weight"
lab var q1001 "Age"
lab var q4113 "Has Facebook account"
lab var q4116 "Has Instagram account"
lab var q1002 "Gender"
lab var t1003 "Education level"
lab var q1004 "Work status - yes/no"
lab var q1005 "Work status - occupation"
lab var q404 "Political interest" 
lab var q516a "Support for democracy"


*** Restricting sample to youth in Tunisia

tab country
keep if country==21 // Tunisia
keep if q1001<=35   // Youth 


saveold  "$main/data/ABIV_English_recoded.dta", replace version(13)
*/



use "$main/data/ABIV_English_recoded.dta", clear


*** Social Media Users
gen fbint=(q4113==1|q4116==1)
tab fbint
lab var fbint "Social media user" 

***GENDER
*tab q1002 [aweight=wt]
*tab q1002 if fbint==1 [aweight=wt]

gen fem=1 if q1002==2
replace fem=0 if q1002==1

sum fem [aweight=wt]
sum fem if fbint==1 [aweight=wt]

***AGE (AMONG THOSE LESS THAN 35)

sum q1001 [aweight=wt]
sum q1001  if fbint==1 [aweight=wt]


**EDUCATION
*tab t1003 [aweight=wt]
*tab t1003 if fbint==1 [aweight=wt]

tab t1003, gen(edu_)
sum edu_* [aweight=wt]

    * None/Elementary
	display  .0219166 +  .1890093
	
	
sum edu_* if fbint==1 [aweight=wt]

	* None/Elementary
	display  .0219166 +  .1890093


**EMPLOYMENT and ECON ACTIVITY
replace q1004 =. if q1004>2
*tab q1004 [aweight=wt]
*tab q1004 if fbint==1 [aweight=wt]

gen emp=1 if q1004==1
replace emp=0 if q1004==2

sum emp [aweight=wt]
sum emp if fbint==1 [aweight=wt]



replace q1005 =. if q1005>5
*tab q1005 [aweight=wt]
*tab q1005 if fbint==1 [aweight=wt]

ta  q1005, gen(act_)

sum act_* [aweight=wt]
sum act_* if fbint==1 [aweight=wt]



***POLITICAL INTEREST

*tab q404

* q404 = 1 "Very interested"
* q404 = 2 "Somewhat interested"
* q404 = 3 "Somewhat uninterested"
* q404 = 4 "Very uninterested"




recode q404 (1=4)(2=3)(3=2)(4=1)

/*
quietly tab q404 [aweight=wt]
quietly tab q404 if fbint==1 [aweight=wt]
*/

quietly tab q404, gen(polint_)



label var polint_1 "Very uninterested"
label var polint_2 "Somewhat uninterested"
label var polint_3 "Somewhat interested"
label var polint_4 "Very interested"


sum q404 [aweight=wt]
sum q404 if fbint==1 [aweight=wt]


sum polint_*  [aweight=wt]
sum polint_*  if fbint==1 [aweight=wt]




***DEMOCRACY PREFERABLE
replace q516a=. if q516a>3
*tab q516a [aweight=wt]

*tab q516a if fbint==1 [aweight=wt]

tab q516a , gen(regpref_)

sum regpref_1 regpref_2 regpref_3 [aweight=wt]
sum regpref_1 regpref_2 regpref_3 if fbint==1 [aweight=wt]


log close
