************************************************************************************************************************
************** PROJECT: Can Online Civic Education Induce Democratic Citizenship? ///
				* Experimental Evidence from a New Democracy 
************** AIM: This do-file replicates Table 3 (bottom panel) AJPS -- Finkel, Neundorf, Rascon-Ramirez 2022
************** Created by: Ericka Rascon 
************** Date: 26.04.2022
************************************************************************************************************************



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
		global 		logs			"${main}logs/TunisiaDemocracy_main_manuscript.log"
		global 		tables 			"${main}tables"
	
		


	

	
clear
version 13
set more off
cap log close


use "$data", clear
count



**log using "$logs", append

*******************************
*** Table 3 bottom (main text)
*******************************

	
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
	 
 
**********************************************************  			
*********************************************************** 			
*********************************************************** 
* TABLE 3 -- Joint Tests for bottom panel
*********************************************************** 
*********************************************************** 

* LAST RUN 17.01.2022
* Last run 26.04.2022





**** Aggregated treatment dummies

		cap drop treat	
		gen treat=1 	if treat4_1==1 | treat4_2==1 | treat4_3==1
		replace treat=0 if treat4_0==1

		
**** Disaggregated treatment dummies

gl tall treat4_1 treat4_2 treat4_3


***************************
* TESTS - REPLICATION
**************************** 
		
* SET 1
	reg mpartyrate_01 $tall $fullset3
		est sto m1

	reg demrate_01 $tall $fullset3
		est sto m2

	reg benalirate_01 $tall $fullset3
		est sto m3

	reg authoritarian_01 $tall $fullset3
		est sto m4

	reg	willvote19_01 $tall $fullset3
		est sto m5

	reg willreg_01 $tall $fullset3
		est sto m6

	reg nonvotepar_01 $tall $fullset3
		est sto m7

	reg eff1_01 $tall $fullset3
		est sto m8

	reg animalsprotect_01 $tall $fullset3
		est sto m9
	
	suest m1 m2 m3 m4 m5 m6 m7 m8 m9 , robust
	
	
* Table 6 in Manuscript
	
	
****************************
* FIRST ROW - GAIN VS LOSS
****************************
	
	* M1-M4: Evaluation of Political Regimes
	
	
		  
		  test [m1_mean]treat4_1 - [m1_mean]treat4_2 = 0	
		  test [m2_mean]treat4_1 - [m2_mean]treat4_2 = 0, accum 
		  test [m3_mean]treat4_1 - [m3_mean]treat4_2 = 0, accum	
		  test [m4_mean]treat4_1 - [m4_mean]treat4_2 = 0, accum 	
		  
		  * chi2(  4) =    9.83
          * Prob > chi2 =    0.0433			
		
		
	* M5-M8: Political Engagement
		
		
			test [m5_mean]treat4_1 - [m5_mean]treat4_2 = 0	
			test [m6_mean]treat4_1 - [m6_mean]treat4_2 = 0, accum 	
			test [m7_mean]treat4_1 - [m7_mean]treat4_2 = 0, accum 	
			test [m8_mean]treat4_1 - [m8_mean]treat4_2 = 0, accum 	
				
			* chi2(  4) =    0.75
			* Prob > chi2 =    0.9449
			
			

		
	* All political outcomes
	
	
			test [m1_mean]treat4_1 - [m1_mean]treat4_2 = 0	
			test [m2_mean]treat4_1 - [m2_mean]treat4_2 = 0, accum 
			test [m3_mean]treat4_1 - [m3_mean]treat4_2 = 0, accum	
			test [m4_mean]treat4_1 - [m4_mean]treat4_2 = 0, accum 
			test [m5_mean]treat4_1 - [m5_mean]treat4_2 = 0, accum	
			test [m6_mean]treat4_1 - [m6_mean]treat4_2 = 0, accum 	
			test [m7_mean]treat4_1 - [m7_mean]treat4_2 = 0, accum 	
			test [m8_mean]treat4_1 - [m8_mean]treat4_2 = 0, accum 	
					
	
					
          * chi2(  8) =   10.54
         * Prob > chi2 =    0.2293
	
	
	
****************************
* 2ND ROW - GAIN VS SELF
****************************	
		
		
	* M1-M4: Evaluation of Political Regimes
		
		
		
			test [m1_mean]treat4_3 - [m1_mean]treat4_1 = 0	
			test [m2_mean]treat4_3 - [m2_mean]treat4_1 = 0, accum 
			test [m3_mean]treat4_3 - [m3_mean]treat4_1 = 0, accum	
			test [m4_mean]treat4_3 - [m4_mean]treat4_1 = 0, accum 
		
		
		
			*  chi2(  4) =    7.09
			* Prob > chi2 =    0.1313

		
		
		
	* M5-M8: Political Engagement
			
			test [m5_mean]treat4_3 - [m5_mean]treat4_1 = 0	
			test [m6_mean]treat4_3 - [m6_mean]treat4_1 = 0, accum 	
			test [m7_mean]treat4_3 - [m7_mean]treat4_1 = 0, accum 	
			test [m8_mean]treat4_3 - [m8_mean]treat4_1 = 0, accum 	
			

			* chi2(  4) =    4.53
			* Prob > chi2 =    0.3392
			
		

	
	* All political outcomes
	
	
		 
			test [m1_mean]treat4_3 - [m1_mean]treat4_1 = 0	
			test [m2_mean]treat4_3 - [m2_mean]treat4_1 = 0, accum 
			test [m3_mean]treat4_3 - [m3_mean]treat4_1 = 0, accum	
			test [m4_mean]treat4_3 - [m4_mean]treat4_1 = 0, accum 
			test [m5_mean]treat4_3 - [m5_mean]treat4_1 = 0, accum	
			test [m6_mean]treat4_3 - [m6_mean]treat4_1 = 0, accum 	
			test [m7_mean]treat4_3 - [m7_mean]treat4_1 = 0, accum 	
			test [m8_mean]treat4_3 - [m8_mean]treat4_1 = 0, accum 	
	  
	  
	    *chi2(  8) =   11.70
        * Prob > chi2 =    0.1649
	
	
	
****************************
* 3RD ROW - LOSS VS SELF
****************************	
		
		
		
			* M1-M4: Evaluation of Political Regimes
			
			
			test [m1_mean]treat4_3 - [m1_mean]treat4_2 = 0	
			test [m2_mean]treat4_3 - [m2_mean]treat4_2 = 0, accum 
			test [m3_mean]treat4_3 - [m3_mean]treat4_2 = 0, accum	
			test [m4_mean]treat4_3 - [m4_mean]treat4_2 = 0, accum
			
			* chi2(  4) =    7.76
			* Prob > chi2 =    0.1008	
			
			
			
			* M5-M8: Political Engagement
			
		
			test [m5_mean]treat4_3 - [m5_mean]treat4_2 = 0	
			test [m6_mean]treat4_3 - [m6_mean]treat4_2 = 0, accum 	
			test [m7_mean]treat4_3 - [m7_mean]treat4_2 = 0, accum 	
			test [m8_mean]treat4_3 - [m8_mean]treat4_2 = 0, accum 	
		
			*  chi2(  4) =    8.29
			* Prob > chi2 =    0.0816
		 
		

			* All political outcomes
			
			
			test [m1_mean]treat4_3 - [m1_mean]treat4_2 = 0	
			test [m2_mean]treat4_3 - [m2_mean]treat4_2 = 0, accum 
			test [m3_mean]treat4_3 - [m3_mean]treat4_2 = 0, accum	
			test [m4_mean]treat4_3 - [m4_mean]treat4_2 = 0, accum 
			test [m5_mean]treat4_3 - [m5_mean]treat4_2 = 0, accum	
			test [m6_mean]treat4_3 - [m6_mean]treat4_2 = 0, accum 	
			test [m7_mean]treat4_3 - [m7_mean]treat4_2 = 0, accum 	
			test [m8_mean]treat4_3 - [m8_mean]treat4_2 = 0, accum 	
				
			 * chi2(  8) =   15.68
			 *Prob > chi2 =    0.0472



        
			
	
	
***************************************************************
**** ANALYIS OF THIRD COLUMN -- TABLE 3 (BOTTOM PANEL)
***************************************************************
	
	****************************
	* FIRST ROW - GAIN VS LOSS
	****************************
	
	* for political engagement with M5* and M6*
	
	*SET 2

	
	reg mpartyrate_01 $tall $fullset3
		est sto m11

	reg demrate_01 $tall $fullset3
		est sto m22

	reg benalirate_01 $tall $fullset3
		est sto m33

	reg authoritarian_01 $tall $fullset3
		est sto m44
		
	reg	willvote19_01 $tall $fullset3 if regis_dnw==1 | regis_no==1
		est sto m5noreg

	reg willreg_01 $tall $fullset3 if regis_dnw==1 | regis_no==1
		est sto m6noreg

	reg nonvotepar_01 $tall $fullset3
		est sto m77

	reg eff1_01 $tall $fullset3
		est sto m88
 
		suest m11 m22 m33 m44 m5noreg m6noreg m77 m88, robust
	
	
		* M5*, M6*, M7, M8: Political Engagement		
			
			test [m5noreg_mean]treat4_1 - [m5noreg_mean]treat4_2 = 0	
			test [m6noreg_mean]treat4_1 - [m6noreg_mean]treat4_2 = 0, accum 	
			test [m77_mean]treat4_1 - [m77_mean]treat4_2 = 0, accum 	
			test [m88_mean]treat4_1 - [m88_mean]treat4_2 = 0, accum 	
			
			*  chi2(  4) =    0.93
			* Prob > chi2 =    0.9203
		
	
		
		
	****************************
	* 2ND ROW - GAIN VS SELF
	****************************	
		
		

		
		* M5*, M6*, M7, M8: Political Engagement	
		
			test [m5noreg_mean]treat4_3 - [m5noreg_mean]treat4_1 = 0	
			test [m6noreg_mean]treat4_3 - [m6noreg_mean]treat4_1 = 0, accum 	
			test [m77_mean]treat4_3 - [m77_mean]treat4_1 = 0, accum 	
			test [m88_mean]treat4_3 - [m88_mean]treat4_1 = 0, accum 	
			
			*chi2(  4) =    2.85
            *Prob > chi2 =    0.5825
		
		
	
	****************************
	* 3RD ROW - GAIN VS SELF
	****************************	
		
	
		* M5*, M6*, M7, M8: Political Engagement	
	
			test [m5noreg_mean]treat4_3 - [m5noreg_mean]treat4_2 = 0	
			test [m6noreg_mean]treat4_3 - [m6noreg_mean]treat4_2 = 0, accum 	
			test [m77_mean]treat4_3 - [m77_mean]treat4_2 = 0, accum 	
			test [m88_mean]treat4_3 - [m88_mean]treat4_2 = 0, accum 	

			
			* chi2(  4) =    6.37
            * Prob > chi2 =    0.1732
			
		
		
		
		
************************************************	 
************************************************
* PROSPECT THEORY VS OTHERS
*********************************************** 
************************************************ 
 
 
 	****************************************
	* 4th ROW - PROSPECT THEORY VS PLACEBO
	****************************************	
 
 
 
cap drop pt 
gen  pt=1 if treat4_1==1 | treat4_2==1
replace pt=0 if treat4_3==1 | treat4_0==1
tab pt

gl ptself pt treat4_3 
 
 
	* SET 1
	
	
	reg mpartyrate_01 $ptself $fullset3
		est sto m1

	reg demrate_01 $ptself $fullset3
		est sto m2

	reg benalirate_01 $ptself $fullset3
		est sto m3

	reg authoritarian_01 $ptself $fullset3
		est sto m4

	reg	willvote19_01 $ptself $fullset3
		est sto m5

	reg willreg_01 $ptself $fullset3
		est sto m6

	reg nonvotepar_01 $ptself $fullset3
		est sto m7

	reg eff1_01 $ptself $fullset3
		est sto m8

	reg animalsprotect_01 $ptself $fullset3
		est sto m9
	
	suest m1 m2 m3 m4 m5 m6 m7 m8 m9 , robust
 
 
 
 
		* PT vs Placebo -- M1-M4: Evaluation of Political Regimes
 
 		  
		  test [m1_mean]pt = 0
		  test [m2_mean]pt = 0, accum
		  test [m3_mean]pt = 0, accum
		  test [m4_mean]pt = 0, accum 	
		  
			*  chi2(  4) =   13.26
			*  Prob > chi2 =    0.0101

 
 
 
 			
		* PT vs Placebo -- * M5-M8: Political Engagement
			test [m5_mean]pt = 0	
			test [m6_mean]pt = 0, accum 	
			test [m7_mean]pt = 0, accum 	
			test [m8_mean]pt  = 0, accum 	
				
 
			* chi2(  4) =   17.05
			* Prob > chi2 =    0.0019

 
 
 		* PT vs Placebo	-- * All political outcomes
		
			test [m1_mean]pt = 0
			test [m2_mean]pt = 0, accum
			test [m3_mean]pt = 0, accum
			test [m4_mean]pt = 0, accum 
			test [m5_mean]pt = 0, accum
			test [m6_mean]pt = 0, accum 	
			test [m7_mean]pt = 0, accum 	
			test [m8_mean]pt = 0, accum 	
 
 
			* chi2(  8) =   28.33
			* Prob > chi2 =    0.0004

 
 
 
 	***************************************************
	* 4th ROW - PROSPECT THEORY VS SELF-EFFICACY
	***************************************************	
 
 
  
		* PT vs SF -- M1-M4: Evaluation of Political Regimes
 
 
 		 test  [m1_mean]pt = [m1_mean]treat4_3
		 test  [m2_mean]pt = [m2_mean]treat4_3, accum
		 test  [m3_mean]pt = [m3_mean]treat4_3, accum
		 test  [m4_mean]pt = [m4_mean]treat4_3, accum
		 
			*  chi2(  4) =    6.91
			*  Prob > chi2 =    0.1410
 
 
 
 		* PT vs SF -- Block: Political Engagement
			test  [m5_mean]pt = [m5_mean]treat4_3
			test  [m6_mean]pt = [m6_mean]treat4_3, accum
			test  [m7_mean]pt = [m7_mean]treat4_3, accum
			test  [m8_mean]pt = [m8_mean]treat4_3, accum
			
			
			* chi2(  4) =    8.28
			* Prob > chi2 =    0.0820


 
 
 		 * PT vs SF-- Blocks: ALL POLITICAL OUTCOMES M1-M8
			
			test  [m1_mean]pt = [m1_mean]treat4_3
			test  [m2_mean]pt = [m2_mean]treat4_3, accum
			test  [m3_mean]pt = [m3_mean]treat4_3, accum
			test  [m4_mean]pt = [m4_mean]treat4_3, accum
			test  [m5_mean]pt = [m5_mean]treat4_3, accum 
			test  [m6_mean]pt = [m6_mean]treat4_3, accum
			test  [m7_mean]pt = [m7_mean]treat4_3, accum
			test  [m8_mean]pt = [m8_mean]treat4_3, accum

			
			* chi2(  8) =   14.83
			* Prob > chi2 =    0.0626

 
 
		***************************************************************
		**** ANALYIS OF THIRD COLUMN -- TABLE 3 (BOTTOM PANEL)
		**** PROSPECT THEORY VS OTHERS
		***************************************************************
 
 
   	*******************************
	* 4th ROW - PROSPECT VS Placebo
	*******************************	
 
 
 
 * for political engagement with M5* and M6*
	
	*SET 2

	
		reg mpartyrate_01 $ptself $fullset3
		est sto m11

		reg demrate_01 $ptself $fullset3
		est sto m22

		reg benalirate_01 $ptself $fullset3
		est sto m33

		reg authoritarian_01 $ptself $fullset3
		est sto m44
		
		reg	willvote19_01 $ptself $fullset3 if regis_dnw==1 | regis_no==1
		est sto m5noreg

		reg willreg_01 $ptself $fullset3 if regis_dnw==1 | regis_no==1
		est sto m6noreg

		reg nonvotepar_01 $ptself $fullset3
		est sto m77

		reg eff1_01 $ptself $fullset3
		est sto m88
 

 
		suest m11 m22 m33 m44 m5noreg m6noreg m77 m88, robust
	
	
		* PT vs Placebo --- M5*, M6*, M7, M8: Political Engagement	
	
			test [m5noreg_mean]pt = 0	
			test [m6noreg_mean]pt = 0, accum 	
			test [m77_mean]pt = 0, accum 	
			test [m88_mean]pt  = 0, accum 	
			
			
			 * chi2(  4) =   19.93
			 * Prob > chi2 =    0.0005

 
 
   	****************************
	* 5th ROW - PROSPECT VS SELF
	****************************	
 
 
 		  	test  [m5noreg_mean]pt = [m5noreg_mean]treat4_3
			test  [m6noreg_mean]pt = [m6noreg_mean]treat4_3, accum
			test  [m77_mean]pt = [m77_mean]treat4_3, accum
			test  [m88_mean]pt = [m88_mean]treat4_3, accum
			
		*	chi2(  4) =    5.88
         * Prob > chi2 =    0.2085
		 
	
**log close
