*********************************************************************************************************
************** PROJECT: Can Online Civic Education Induce Democratic Citizenship? ///
				* Experimental Evidence from a New Democracy 
************** AIM: This do-file replicates Table A.3 of Appendix -- Table 2 with display of covariates
************** AJPS -- Finkel, Neundorf, Rascon-Ramirez 2022
************** Created by: Ericka Rascon (erickarascon@gmail.com)
************** Date: 26.04.2022
*********************************************************************************************************




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

************************** 
*** Table A.3 of Appendix  
************************** 



	
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
	 
 
***************************************************************************    			
*************************************************************************** 			
*************************************************************************** 
* TABLE 2 -- OLS, robust with full set of covariates and display in appendix
****************************************************************************   
****************************************************************************   

* LAST RUN  17.01.2022
* LAST RUN FOR REPLICATION 26.04.2022


**** Aggregated treatment dummies

		cap drop treat	
		gen treat=1 	if treat4_1==1 | treat4_2==1 | treat4_3==1
		replace treat=0 if treat4_0==1

	
		
		reg animalsprotect_01  treat $fullset3, robust
		sum animalsprotect_01 if treat==0
		local m =r(mean)
			outreg2 using "$tables/table2_with_covariates_appendix.xls", ///
			dec(3) ctitle("animal")  tex label ///
			addstat(Control Mean, `m') ///
			nocons keep(treat $fullset3) bracket replace	 
			
		gl dep1part1 mpartyrate_01 benalirate_01 ///
			authoritarian_01 demrate_01
			
 
			 foreach var of varlist $dep1part1 {
			  reg `var' treat $fullset3, robust
			  sum `var' if treat==0
			  local m =r(mean)
				outreg2 using "$tables/table2_with_covariates_appendix.xls", ///
					dec(3) ctitle("`var'")  tex label ///
					addstat(Control Mean, `m') ///
					nocons keep(treat $fullset3) bracket append 	
		
						}
						
	
						
		
		reg willvote19_01 treat $fullset3, robust
		sum willvote19_01 if treat==0
		local m =r(mean)
			outreg2 using "$tables/table2_with_covariates_appendix.xls", ///
			dec(3) ctitle("willvote19_01")  tex label ///
			addstat(Control Mean, `m') ///
			nocons keep(treat $fullset3) bracket append
			
			
		reg willvote19_01 treat $fullset3 if regis_dnw==1 | regis_no==1, robust
		sum willvote19_01 if treat==0 & regis_dnw==1 | regis_no==1
		local m =r(mean)
			outreg2 using "$tables/table2_with_covariates_appendix.xls", ///
			dec(3) ctitle("willvote19_01_sub")  tex label ///
			addstat(Control Mean, `m') ///
			nocons keep(treat  $fullset3) bracket append 	
			
		reg willreg_01 treat $fullset3, robust
		sum willreg_01 if treat==0 
		local m =r(mean)
			outreg2 using "$tables/table2_with_covariates_appendix.xls", ///
			dec(3) ctitle("willreg_01")  tex label ///
			addstat(Control Mean, `m') ///
			nocons keep(treat  $fullset3) bracket append 			
			
		reg willreg_01 treat $fullset3 if regis_dnw==1 | regis_no==1, robust
		sum willreg_01 if treat==0 & regis_dnw==1 | regis_no==1
		local m =r(mean)
			outreg2 using "$tables/table2_with_covariates_appendix.xls", ///
			dec(3) ctitle("willreg_01_sub")  tex label ///
			addstat(Control Mean, `m') ///
			nocons keep(treat  $fullset3) bracket append 		

		
		reg nonvotepar_01 treat $fullset3, robust
		sum nonvotepar_01 if treat==0 
		local m =r(mean)
			outreg2 using "$tables/table2_with_covariates_appendix.xls", ///
			dec(3) ctitle("nonvotepar_01")  tex label ///
			addstat(Control Mean, `m') ///
			nocons keep(treat  $fullset3) bracket append 		
		
		reg eff1_01 treat $fullset3, robust
		sum eff1_01 if treat==0 
		local m =r(mean)
			outreg2 using "$tables/table2_with_covariates_appendix.xls", ///
			dec(3) ctitle("eff1_01")  tex label ///
			addstat(Control Mean, `m') ///
			nocons keep(treat  $fullset3) bracket append 		
			

log close
