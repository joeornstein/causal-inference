*****************************************************************************************************
************** PROJECT: Can Online Civic Education Induce Democratic Citizenship? ///
				* Experimental Evidence from a New Democracy 
************** AIM: This do-file replicates Figures A.1, A.2 and A.3 of appendix 
************** AJPS -- Finkel, Neundorf, Rascon-Ramirez 2022
************** Created by: Ericka Rascon 
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
global 	    figures 		"${main}figures"
global 		logs			"${main}logs/TunisiaDemocracy_appendix_figures.log"


cd "${main}data/"



***** INSTALL THE FOLLOWING ADO IF YOU DON'T HAVE IT IN YOUR COMPUTER

*ssc install blindschemes 
set scheme plotplain


***********************************
***** Figure A.1 of Appendix
***********************************

*** Extra do-file to create macro data
*** do "EXTRA_GenMacroData"

/* The macro data used is based on three separte datasets"

DATASET 1: GEDDES ET AL. 2014 - TRANSITIONS

Transitions - used in Figure A.1 - were classified using the data by Geddes, Wright and Frantz (2014). The data can be downloaded from https://sites.psu.edu/dictators/ (dataset “Autocratic Regimes”) and more information about the variables is available here: https://xmarquez.github.io/democracyData/reference/gwf_all.html.

Citation: Barbara Geddes, Joseph Wright, and Erica Frantz. 2014. "Autocratic Breakdown and Regime Transitions: A New Data Set." Perspectives on Politics 12(2): 313-331.https://doi.org/10.1017/S1537592714000851.

DATASET 2: Varieties of Democracy (V-Dem) - country macro indicators 

The data displayed in Figure A.1 is taken from V-Dem, version 10 "Country-Year: V-Dem Full+Others". The data can be downloaded here: https://v-dem.net/dsarchive.html. 

The codebook with exact definitions of each variable used here is available in the data folder as well when downloading the data via the link above.  


Citation: Coppedge, Michael, John Gerring, Carl Henrik Knutsen, Staffan I. Lindberg, Jan Teorell, David Altman, Michael Bernhard, M. Steven Fish, Adam Glynn, Allen Hicken, Anna Luhrmann, Kyle L. Marquardt, Kelly McMann, Pamela Paxton, Daniel Pemstein, Brigitte Seim, Rachel Sigman, Svend-Erik Skaaning, Jeffrey Staton, Steven Wilson, Agnes Cornell, Nazifa Alizada, Lisa Gastaldi, Haakon Gjerløw, Garry Hindle, Nina Ilchenko, Laura Maxwell, Valeriya Mechkova, Juraj Medzihorsky, Johannes von Römer, Aksel Sundström, Eitan Tzelgov, Yi-ting Wang, Tore Wig, and Daniel Ziblatt. 2020. ”V-Dem [Country–Year/Country–Date] Dataset v10”. Varieties of Democracy (V-Dem) Project. https://doi.org/10.23696/vdemds20.Project. https://doi.org/10.23696/vdemds21.

DATASET 3: CLAASSEN (2019) and CLAASSEN AND MAGALHAES (2022) - democratic support and satisfaction 

Data for both datasets (in csv format) used, can be downloaded here: http://chrisclaassen.com/data.html. The page also includes information on the variable descriptions. For more information on the method used to create the smooth country-year estimates, please check Claassen (2019) "Estimating smooth country‐year panels of public opinion." Political Analysis.


Citations:  Claassen, Christopher, 2019. Estimating smooth country–year panels of public opinion. Political Analysis, 27(1), pp.1-20. doi:10.1017/pan.2018.32

Claassen, Christopher, and Pedro C. Magalhães. 2022. Effective government and evaluations of democracy. Comparative Political Studies, 55(5), pp.869-894.. https://doi.org/10.1177/00104140211036042


*/





use "macro_data.dta", clear


tab country_name if yr_since_trans>28 & trans_year>0
tab trans_cat

*bys trans_cat: sum diff5_v2x_civlib diff5_v2x_corr diff5_e_migdpgro diff5_e_migdppcln diff5_lencmps

drop if country_name=="Tunisia"


collapse e_migdpgr v2x_corr v2x_civlib, by(yr_since_trans trans_cat)
sort yr_since_trans
save "macro_data_trans_cat.dta", replace


use "macro_data.dta", clear
replace yr_since_trans = year-2011 if country_name=="Tunisia"

keep if country_name=="Tunisia"
keep  e_migdpgr v2x_corr v2x_civlib yr_since_trans

append using "macro_data_trans_cat.dta"

twoway(line e_migdpgr yr_since_trans if trans_cat==. & yr_since_trans>-51 & yr_since_trans<21) (line e_migdpgr yr_since_trans if trans_cat==1 & yr_since_trans>-51 & yr_since_trans<21), xline(0) title("GDP Growth", size(medlarge))  yline(0) ytitle(,size(medium)) xtitle( " ") name(growth, replace) legend(off) xlabel(-50(10)20) xtitle( "Years to/since transition",size(medium)) 

twoway(line v2x_corr yr_since_trans if trans_cat==. & yr_since_trans>-51 & yr_since_trans<21) (line v2x_corr yr_since_trans if trans_cat==1 & yr_since_trans>-51 & yr_since_trans<21), xline(0) title("Corruption", size(medlarge))  ytitle(,size(medium)) xtitle( "Years to/since transition",size(medium)) name(corr, replace) legend(off) xlabel(-50(10)20) ylabel(0(.2)1) 

twoway(line v2x_civlib yr_since_trans if trans_cat==. & yr_since_trans>-51 & yr_since_trans<21) (line v2x_civlib yr_since_trans if trans_cat==1 & yr_since_trans>-51 & yr_since_trans<21), xline(0) title("Civil Liberties", size(medlarge))  ytitle(,size(medium)) xtitle( " ") name(civil, replace) xlabel(-50(10)20) ylabel(0(.2)1) legend(lab(1 "Tunisia") lab(2 "Other citizens-led transitions") size(tiny) order(1 2) row(2) region(lcolor(white)) pos(5) ring(0)) xtitle( "Years to/since transition",size(medium)) 


graph combine  growth corr civil
graph export  "$figures/Tunisia_macro.pdf", as(pdf) replace



***********************************
***** Figure A.2 of Appendix
***********************************

use macro_data.dta, clear

drop if democ_dum!=1
drop if year<2011

drop if country=="Tunisia"
collapse supdem satis, by(year)

gen sample = 0
keep year supdem satis sample
save "FigA2_Democ.dta", replace


* Reduce sample to Tunisia only

use macro_data.dta, clear

keep if country=="Tunisia"
tab year

drop if year<2011
append using "FigA2_Democ.dta"

erase "FigA2_Democ.dta"

* Democracy variables

twoway(line supdem year if sample==. )(line supdem year if sample==0 ), scheme(plotplain) legend(off) ylabel(-1.2(0.4)0.8) yline(0) ytitle("Democracy attitudes", size(medlarge)) xtitle(" ") title("Support for democracy", size(large)) name(dem, replace) ylabel(,labsize(medium)) xlabel(,labsize(medium))

twoway(line satis year if sample==. )(line satis year if sample==0 ), scheme(plotplain) legend(lab(1 "Tunisia") lab(2 "Other democracies") size(medlarge) order(1 2) row(2) region(lcolor(white)) pos(5) ring(0))  ylabel(-1.2(0.4)0.8) yline(0) ytitle("Democracy attitudes", size(medlarge)) xtitle(" ") title("Satisfaction with democracy", size(large)) name(demsat, replace) ylabel(,labsize(medium)) xlabel(,labsize(medium))

graph combine dem demsat, xsize(9) ysize(4)

graph export  "$figures/Tunisia_demsupport.pdf", as(pdf) replace



***********************************
***** Figure A.3 of Appendix
***********************************

** log using "$logs", replace

/* Data was taken from World Value Survey and the AfroBarometer. Replication files on how to create the file for this data can be accessed here: https://globalcitizenpolitics.net/data/. 
*/

* Micro data
use "Micro_Tunisia.dta", clear


bys year: sum democbest demsat trust_gov leader  polint
tab age

recode age (18/35=1 "Aged 18-35") (36/55=2 "Aged 36-55") (56/93=3 "Aged 56+"), gen(age_cat)

collapse demsat trust_gov leader  polint, by(year age_cat)


* Demsat
twoway(line demsat year if age_cat==1)(line demsat year if age_cat==2)(line demsat year if age_cat==3), scheme(plotplain) legend(lab(1 "Aged 18-35") lab(2 "Aged 36-55") lab(3 "Aged 56+") size(medium) order(3 2 1) row(3) region(lcolor(white)) pos(2) ring(0)) ytitle("Average satisfaction with democracy", size(medium)) xtitle(" ") title("Satisfaction with democracy", size(medlarge)) name(demsat, replace)

* Trust in gov
twoway(line trust_gov year if age_cat==1)(line trust_gov year if age_cat==2)(line trust_gov year if age_cat==3), scheme(plotplain) legend(lab(1 "Aged 18-35") lab(2 "Aged 36-55") lab(3 "Aged 56+") size(medium) order(3 2 1) row(3) region(lcolor(white)) pos(2) ring(0)) ytitle("Average trust in government", size(medium)) xtitle(" ") title("Trust in government", size(medlarge)) name(trust, replace)


* Pol int
twoway(line polint year if age_cat==1)(line polint year if age_cat==2)(line polint year if age_cat==3), scheme(plotplain) legend(lab(1 "Aged 18-35") lab(2 "Aged 36-55") lab(3 "Aged 56+") size(medium) order(3 2 1) row(3) region(lcolor(white)) pos(2) ring(0)) ytitle("Average political interest", size(medium)) xtitle(" ") title("Political interest", size(medlarge)) name(polint, replace)



graph combine demsat trust polint

graph export  "$figures/Tunisia_demsupport_age.pdf", as(pdf) replace

**log close
