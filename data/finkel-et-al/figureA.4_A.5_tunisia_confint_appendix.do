*****************************************************************************************************
************** PROJECT: Can Online Civic Education Induce Democratic Citizenship? ///
				* Experimental Evidence from a New Democracy 
************** AIM: This do-file replicates Figure A.4 and A.5 of Appendix
************** AJPS -- Finkel, Neundorf, Rascon-Ramirez 2022
************** Created by: Ericka Rascon (erickarascon@gmail.com)
************** Date: 28.04.2022
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



		global		main			"/Users/TunisiaDemocracy/"			
		global 		data 			"${main}data/tunisia_democracy_replication.dta"
		global 		tables 			"${main}tables"
		global 		prep 			"${main}do_prep_explore.do"
		global 		graphs 			"${main}graphs"
		global 		logs			"${main}logs/TunisiaDemocracy_appendix_figures.log"
		
		global 		rawtest			"${main}tables/Bal_tallvs0_withDIFF_allobs.xlsx"
		global 		rawtest0	    "${main}tables/Bal__withDIFF_model_vs_attrition"

								



** log using "$logs", append

************************************************************
******* GRAPHIC 1
******* ALL OBSERVATIONS WITHOUT RESTRICTING THE SAMPLE
******* TO ONLY THOSE OBSERVATIONS THAT WE USE IN THE MODELS
************************************************************

use "$data", clear

	gl listing female age educ_new_1 educ_new_2 educ_new_3 ///
	educ_new_4 educ_new_5 regis_no regis_yes ///
	regis_dnw employed housewife student otherunemp ///
	 unemp_looking polint_new_1 polint_new_2 polint_new_3 ///
	 polint_new_4  dem_pref autoc_pref  ///
	animalint_new_1 animalint_new_2 animalint_new_3 ///
	animalint_new_4  animalint_new_5 
	
	sum $listing

***************************************
**** Balance tests: Tj vs Control
***************************************		


version 13
* T-Tests
foreach j of varlist t1vs0 t2vs0 t3vs0 tallvs0 {

eststo: estpost ttest $listing , by(`j') unequal

		  
mat drop _all
   foreach	k in $listing {
	qui ttest	`k' , by(`j') unequal
	mat		mat1=r(mu_1)
	mat		mat2=r(mu_2)
	mat		mat3=r(sd_1)
	mat 	mat4=r(sd_2)
	mat		mat5=r(p)
	mat 	mat6=r(N_1)
	mat     mat7=r(N_2)
	mat 	mat8=r(se)
	mat		mat9=mat1, mat2, mat3, mat4, mat5, mat6, mat7, mat8
	mat  	rownames mat9= `k'
	mat		matvar=nullmat(matvar)\mat9
   } 
	
	mat 	colnames matvar = MeanC MeanT sdC sdT p-value obsC obsT sediff
	mat list matvar
	


putexcel D1=("T test Final") D3=mat(matvar, names) using "$tables/Bal_`j'_withDIFF_allobs", ///
       sheet("`j'") replace	
		
}




clear
set more off
*cap log close
import excel  "$rawtest", sheet("tallvs0") cellrange(D3:L29) firstrow

* ATTENTION!!!!

* PLEASE CHECK BEFORE IMPORTING THAT YOUR $rawtest effectively starts with valid columns and rows in D3 and end in L29

save "$tables/tallvs0_forGraphic", replace


******************************************
***** For running only graphic
******************************************

use "$tables/tallvs0_forGraphic", clear

   gen diff = MeanC-MeanT
   gen ci_lower= diff -1.96*sediff
   gen ci_upper= diff + 1.96*sediff
   ren D variable
   gen id=_n
   
   twoway rcap ci_lower ci_upper id, xlabel(1 "Female = 1" 2 "Age" ///
3 "No education/Elementary" ///
4 "Secondary Edu"   ///
5 "Upper Sec. Edu"  ///
6 "Bachelor Edu"   ///
7 "More than Bachelor"   ///
8 "Not registered to vote in 2019"  ///
9 "Registered to vote in 2019"   ///
10 "Do not know - registered"  ///
11 "Employed"  ///
12 "Housewife"   ///
13 "Student"   ///
14 "Other Unemp."   ///
15 "Unemp. Looking"  ///
16 "Political interest: V. Uninterested"   ///
17 "Political interest: Somewhat Unint."   ///
18 "Political interest: Somewhat Int."   ///
19 "Political interest: V. Interested"  ///
20 "Preference for democracy"  ///
21 "Preference for autocracy"   ///
22 "Animal interest: V. Uninterested"  ///
23 "Animal interest: Somewhat uninterested"  ///
24 "Animal interest: Neither"  ///
25 "Animal Interest: Somewhat interested"   ///
26 "Animal Interest: V. interested", ///
labsize(tiny) angle(90))	///
yscale(range(-0.35 0.35)) ///
ylabel(-0.35(.05)0.35, labsize(tiny)) ///
 xtitle("") ///
 ytitle("Placebo versus Treatment at Baseline", size(small)) ///
   yline(0, lstyle(foreground)) ///
xscale(noline) ///
yscale(noline)  ///
scheme(s1mono) col(2) scale(1) saving("$graphs/figureA.5_balance_tests", replace) 

 graph export "$graphs/figureA.5_balance_tests.pdf", as(pdf) name("Graph") replace


log close

************************************************************
******* FIGURE A.4 of APPENDIX
******* RESTRICTING TO OBSERVATIONS THAT WE USE IN THE MODELS
************************************************************

clear
version 13
set more off
*cap log close


use "$data", clear
count



log using "$logs", append


	
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
* TABLE 2 -- OLS, robust with full set of covariates
*********************************************************** 
*********************************************************** 

* LAST RUN  17.01.2022
* LAST RUN FOR REPLICATION 26.04.2022


**** Aggregated treatment dummies

		cap drop treat	
		gen treat=1 	if treat4_1==1 | treat4_2==1 | treat4_3==1
		replace treat=0 if treat4_0==1



* variable with the largest number of observations in main analysis

	reg demrate_01 treat $fullset3, robust


gen modelobs=1 if e(sample)==1
replace modelobs=0 if e(sample)!=1 & attrition==1

ren ani_2 animalint_new_2
ren ani_3 animalint_new_3
ren ani_4 animalint_new_4
ren ani_5 animalint_new_5

	gl listing female age educ_new_1 educ_new_2 educ_new_3 ///
	educ_new_4 educ_new_5 regis_no regis_yes ///
	regis_dnw employed housewife student otherunemp ///
	 unemp_looking polint_new_1 polint_new_2 polint_new_3 ///
	 polint_new_4  dem_pref autoc_pref  ///
	animalint_new_1 animalint_new_2 animalint_new_3 ///
	animalint_new_4  animalint_new_5 
	
	sum $listing

**************************************************
**** Balance tests: Attrited vs Non-Attrited
**************************************************		


version 13

* T-Tests






eststo: estpost ttest $listing , by(modelobs) unequal

		  
mat drop _all
   foreach	k in $listing {
	qui ttest	`k' , by(modelobs) unequal
	mat		mat1=r(mu_1)
	mat		mat2=r(mu_2)
	mat		mat3=r(sd_1)
	mat 	mat4=r(sd_2)
	mat		mat5=r(p)
	mat 	mat6=r(N_1)
	mat     mat7=r(N_2)
	mat 	mat8=r(se)
	mat		mat9=mat1, mat2, mat3, mat4, mat5, mat6, mat7, mat8
	mat  	rownames mat9= `k'
	mat		matvar=nullmat(matvar)\mat9
   } 
	
	mat 	colnames matvar = MeanC MeanT sdC sdT p-value obsC obsT sediff
	mat list matvar
	


putexcel D1=("T test Final") D3=mat(matvar, names) using "$tables/Bal_`j'_withDIFF_model_vs_attrition.xls", ///
       sheet(modelobs) replace	
		






clear
set more off
*cap log close
import excel  "$rawtest0", sheet("modelobs") cellrange(D3:L29) firstrow
save "$tables/tallvs0_forGraphic_ATTRITION", replace


******************************************
***** For running only graphic
******************************************

use "$tables/tallvs0_forGraphic_ATTRITION", clear

   gen diff = MeanC-MeanT
   gen ci_lower= diff -1.96*sediff
   gen ci_upper= diff + 1.96*sediff
   ren D variable
   gen id=_n
   
   twoway rcap ci_lower ci_upper id, xlabel(1 "Female = 1" 2 "Age" ///
3 "No education/Elementary" ///
4 "Secondary Edu"   ///
5 "Upper Sec. Edu"  ///
6 "Bachelor Edu"   ///
7 "More than Bachelor"   ///
8 "Not registered to vote in 2019"  ///
9 "Registered to vote in 2019"   ///
10 "Do not know - registered"  ///
11 "Employed"  ///
12 "Housewife"   ///
13 "Student"   ///
14 "Other Unemp."   ///
15 "Unemp. Looking"  ///
16 "Political interest: V. Uninterested"   ///
17 "Political interest: Somewhat Unint."   ///
18 "Political interest: Somewhat Int."   ///
19 "Political interest: V. Interested"  ///
20 "Preference for democracy"  ///
21 "Preference for autocracy"   ///
22 "Animal interest: V. Uninterested"  ///
23 "Animal interest: Somewhat uninterested"  ///
24 "Animal interest: Neither"  ///
25 "Animal Interest: Somewhat interested"   ///
26 "Animal Interest: V. interested", ///
labsize(tiny) angle(90))	///
yscale(range(-0.75 0.75)) ///
ylabel(-0.75(.10)0.75, labsize(tiny)) ///
 xtitle("") ///
 ytitle("Attrited vs Non-Attrited at Baseline", size(small)) ///
   yline(0, lstyle(foreground)) ///
xscale(noline) ///
yscale(noline)  ///
scheme(s1mono) col(2) scale(1) saving("$graphs/figureA.4_lAttried_vs_Non_Attrited", replace) 
   
   
 graph export "$graphs/figureA.4_Attrited_vs_Non_Attrited.pdf", as(pdf) name("Graph") replace


   
 **  log close

   
   
