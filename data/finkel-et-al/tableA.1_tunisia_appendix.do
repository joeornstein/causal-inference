*****************************************************************************************************
************** PROJECT: Can Online Civic Education Induce Democratic Citizenship? ///
				* Experimental Evidence from a New Democracy 
************** AIM: This do-file replicates Table A.1 of Appendix
************** AJPS -- Finkel, Neundorf, Rascon-Ramirez 2022
************** Created by: Ericka Rascon 
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



log using "$logs", replace


******************************
*** Table A.1 of Appendix
******************************

	
	global dep0 mpartyrate_01 demrate_01 benalirate_01 ///
			authoritarian_01 willvote19_01 willreg_01 ///
			nonvotepar_01 eff1_01 animalsprotect_01
	
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



************************************************************
* OLS, robust without and w/full set of covariates
************************************************************



reg attrition $tall, robust
	outreg2 using "$tables/tableA1_tunisia_appendix.xls", ///
 dec(3) ctitle("Attrition without")  tex label nocons keep($tall) replace
 
 
reg attrition $tall $fullset, robust
	outreg2 using "$tables/tableA1_tunisia_appendix.xls", ///
 dec(3) ctitle("Attrition with")  tex label nocons keep($tall) append
 
 
log close
 

 
 
