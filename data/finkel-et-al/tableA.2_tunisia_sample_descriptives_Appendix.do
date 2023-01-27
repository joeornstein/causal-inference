*****************************************************************************************************
************** PROJECT: Can Online Civic Education Induce Democratic Citizenship? ///
				* Experimental Evidence from a New Democracy 
************** AIM: Table of Appendix: This creates stats for Table A.2 in Appendix "Our Sample columns" 
************** Finkel, Neundorf, Rascon-Ramirez 2022
************** Objective: Comparison between Sample and Arabarometer
************** Created by: Ericka Rascon (erickarascon@gmail.com)
************** Date: 26.04.2022
*****************************************************************************************************

	


*** Install the ado-files before running the set of do-files
*** Once they are installed, there is not need to reinstall them again.

*ssc install blindschemes 
*ssc install estout, all replace
*ssc install estwrite
*ssc install sumstats
*ssc install outreg2

* Definition of all dependent variables used in Table 2 and Table 3 can be found in Table 1 of manuscript
* Description of pre-treatment variables can be found in Table A.2 of Appendix 


* Change the path in global "main" to your own folder. 
* This file was created in Mac, hence, paths use  "/" to identify sub-folders.

	clear 
	

		global		main			"/Users/TunisiaDemocracy/"		
		global 		data 			"${main}data/tunisia_democracy_replication.dta"
		global 		logs			"${main}logs/TunisiaDemocracy_appendix.log"
		global 		tables 			"${main}tables"
	
		


	

	
clear
version 13
set more off
cap log close


use "$data", clear
count



log using "$logs", append

******************************************
*** Table A.2 of Appendix (sample)
******************************************

	
	global dep0 animalsprotect_01 mpartyrate_01 benalirate_01 ///
			authoritarian_01 demrate_01 willvote19_01 willreg_01 ///
			nonvotepar_01 eff1_01 
			
			
	
	global tall treat4_1 treat4_2 treat4_3 
	

	 
	 ren animalint_new_2 ani_2
	 ren animalint_new_3 ani_3
	 ren animalint_new_4 ani_4
	 ren animalint_new_5 ani_5

	 
	gl fullset female age  educ_new_2 educ_new_3 ///
	educ_new_4 educ_new_5 regis_no  ///
	regis_dnw employed   polint_new_2 polint_new_3 ///
	 polint_new_4  dem_pref autoc_pref  ///
	 ani_2 ani_3 ani_4  ani_5 
	 
	
	foreach var of varlist $fullset {
		gen `var'_app=`var'
		}


			
			
	global dep1 mpartyrate_01 benalirate_01 ///
			authoritarian_01 demrate_01 willvote19_01 willreg_01 ///
			nonvotepar_01 eff1_01 		
			
**************************************
**** Imputation of Discrete Variables
**************************************	 
	*******
 	gl fullset2 female educ_new_2 educ_new_3 ///
	educ_new_4 educ_new_5 regis_no  ///
	regis_dnw employed   polint_new_2 polint_new_3 ///
	 polint_new_4  dem_pref autoc_pref  ///
	 ani_2 ani_3 ani_4  ani_5 

	sum $fullset2
	
	foreach var of varlist $fullset2 {
		gen f_`var'=1 if `var'==.
		replace f_`var'=0 if f_`var'==.
		replace `var'=0 if `var'==.
		
	}
	
	* no missing value for female
	
	gl fullset3 female age  educ_new_2 educ_new_3 ///
	educ_new_4 educ_new_5 regis_no  ///
	regis_dnw employed   polint_new_2 polint_new_3 ///
	 polint_new_4  dem_pref autoc_pref  ///
	 ani_2 ani_3 ani_4  ani_5 f_regis_no ///
	 f_polint_new_2 f_employed ///
	 f_educ_new_2 f_dem_pref f_ani_2
	 
	 sum $fullset3
	 
 
 	  			
************************************************************************************* 			
************************************************************************************* 
* TABLE of Appendix: This creates stats for Table 4 in Appendix "Our Sample columns"
* Using the sample with the largest number of observations
************************************************************************ 
************************************************************************************* 

		cap drop treat	
		gen treat=1 	if treat4_1==1 | treat4_2==1 | treat4_3==1
		replace treat=0 if treat4_0==1
		
		
reg demrate_01  treat $fullset3, robust
gen sam_appendix=1 if e(sample)


sum female_app age_app if sam_appendix==1
sum educ_new_1  edu*_app if sam_appendix==1
sum employed_app housewife student otherunemp unemp_looking if sam_appendix==1
sum polint polint_new_1 polint_new_2_app polint_new_3_app polint_new_4_app  if sam_appendix==1
quietly tab dematt, gen(dematt_)
sum dem_pref_app autoc_pref_app  dematt_2 if sam_appendix==1

log close
