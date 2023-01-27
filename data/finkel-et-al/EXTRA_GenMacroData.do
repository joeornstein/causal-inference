
*****************************************************************************************************
************** PROJECT: Can Online Civic Education Induce Democratic Citizenship? ///
				* Experimental Evidence from a New Democracy 
************** AIM: This do-file prepares the macro data to replicate Figures A.1 and A.2 of appendix 
************** AJPS -- Finkel, Neundorf, Rascon-Ramirez 2022
************** Created by: Anja Neundorf  
************** Date: 05.09.2022
*****************************************************************************************************



*** Install the ado-files before running the set of do-files
*** Once they are installed, there is not need to reinstall them again.

*ssc install blindschemes 
*ssc install estout, all replace
*ssc install estwrite
*ssc install sumstats
*ssc install outreg2
*ssc install carryforward
*ssc install kountry

* Change the path in global "main" to your own folder. 
* This file was created in Mac, hence, paths use  "/" to identify sub-folders.

global		main"/Users/aneundorf/Dropbox/TunisiaDemocracyInternationalCivicEducationProject/AJPS_replication/TunisiaDemocracy_DATAVERSE 4th/"
*global		main			"/Users/TunisiaDemocracy/"	
global 	    figures 		"${main}figures"
global 		logs			"${main}logs/TunisiaDemocracy_appendix_figures.log"


cd "${main}data/"


***-----------------------------------------------------
*** DATASET 1: GEDDES ET AL. 2014 - TRANSITIONS

/* Transitions - used in Figure A.1 - were classified using the data by Geddes, Wright and Frantz (2014). The data can be downloaded from https://sites.psu.edu/dictators/ (dataset “Autocratic Regimes”) and more information about the variables is available here: https://xmarquez.github.io/democracyData/reference/gwf_all.html. 

Citation: Barbara Geddes, Joseph Wright, and Erica Frantz. 2014. "Autocratic Breakdown and Regime Transitions: A New Data Set." Perspectives on Politics 12(2): 313-331.https://doi.org/10.1017/S1537592714000851.


*/


use "GWFtscs.dta", clear
rename cow ccode

* Preparing transition variables
gen gwf_dtrans=1 if gwf_fail_subsregime==1
generate gwf_dmass_nv=1 if (gwf_dtrans==1 & gwf_fail_type==4)
generate gwf_dcivil_war=1 if (gwf_dtrans==1 & gwf_fail_type==6)
generate gwf_delite=1 if (gwf_dtrans==1 & gwf_fail_type==1)
replace gwf_delite=1 if (gwf_dtrans==1 & gwf_fail_type==5)
replace gwf_delite=1 if (gwf_dtrans==1 & gwf_fail_type==8)
generate gwf_delection=1 if (gwf_dtrans==1 & gwf_fail_type==2)
replace gwf_delection=1 if (gwf_dtrans==1 & gwf_fail_type==3)
gen gwf_democracy=0

***Code Transitions in East Germany and Russia
*tab gwf_country gwf_fail_type if gwf_fail_subsregime==3
replace gwf_dtrans=1 if ccode==265 & year==1990 /*East Germany*/
replace gwf_delection=1 if ccode==265 & year==1990 /*East Germany*/
replace gwf_dtrans=1 if ccode==365 & year==1991 /*Russia*/
replace gwf_delite=1 if ccode==365 & year==1991 /*Russia*/

**Generate year of transition
gen yr_elite=year if gwf_delite==1
gen yr_election=year if gwf_delection==1
gen yr_mass_nv=year if gwf_dmass_nv==1
gen yr_civil_war=year if gwf_dcivil_war==1


keep yr* gwf_dtrans gwf_democracy gwf_dmass_nv gwf_dcivil_war gwf_delite gwf_delection ccode gwf_country year gwf_casename gwf_startdate gwf_enddate gwf_duration 
save "gwf_transitions.dta", replace


***-----------------------------------------------------
*** DATASET 2: Varieties of Democracy (V-Dem) - version 10

/* The data displayed in Figure A.1 is taken from V-Dem, version 10 "Country-Year: V-Dem Full+Others". The data can be downloaded here: https://v-dem.net/dsarchive.html. 


Citation: Coppedge, Michael, John Gerring, Carl Henrik Knutsen, Staffan I. Lindberg, Jan Teorell, David Altman, Michael Bernhard, M. Steven Fish, Adam Glynn, Allen Hicken, Anna Luhrmann, Kyle L. Marquardt, Kelly McMann, Pamela Paxton, Daniel Pemstein, Brigitte Seim, Rachel Sigman, Svend-Erik Skaaning, Jeffrey Staton, Steven Wilson, Agnes Cornell, Nazifa Alizada, Lisa Gastaldi, Haakon Gjerløw, Garry Hindle, Nina Ilchenko, Laura Maxwell, Valeriya Mechkova, Juraj Medzihorsky, Johannes von Römer, Aksel Sundström, Eitan Tzelgov, Yi-ting Wang, Tore Wig, and Daniel Ziblatt. 2020. ”V-Dem [Country–Year/Country–Date] Dataset v10”. Varieties of Democracy (V-Dem) Project. https://doi.org/10.23696/vdemds20.Project. https://doi.org/10.23696/vdemds21.

The codebook with exact definitions of each variable used here is available in the data folder as well when downloading the data via the link above.  
*/

use "V-Dem-CY-Full+Others-v10.dta", clear
keep year country_name country_id e_migdpgro v2x_corr v2x_civlib COWcode v2x_regime v2x_polyarchy v2x_polyarchy_codelow v2x_polyarchy_codehigh
		
drop if COWcode==.
rename COWcode ccode

**Create final sample & save
drop if year<1945

**------------------------------------------------------------------------
**Combine GWF and V-Dem datasets and calculate spells
** First clean countries that went through splits
merge 1:1 ccode year using "gwf_transitions.dta", keep(master match)
drop _m

**Tag autocratic years
replace gwf_democracy=1 if gwf_democracy==.
replace gwf_delection=99 if (gwf_democracy==0 & gwf_delection==.)
replace gwf_delite=99 if (gwf_democracy==0 &  gwf_delite==.)
replace gwf_dmass_nv=99 if (gwf_democracy==0 & gwf_dmass_nv==.)
replace gwf_dcivil_war=99 if (gwf_democracy==0 &  gwf_dcivil_war==.)


**Create transition spells
bysort ccode (year): carryforward gwf_delite, gen(y)
bysort ccode (year): carryforward gwf_delection, gen(y2)
bysort ccode (year): carryforward gwf_dmass_nv, gen(y3)
bysort ccode (year): carryforward gwf_dcivil_war, gen(y4)

**Tag democratic years
replace y=98 if (y==. & gwf_democracy==1)
replace y2=98 if (y2==. & gwf_democracy==1)
replace y3=98 if (y3==. & gwf_democracy==1)
replace y4=98 if (y4==. & gwf_democracy==1)

rename y elite_spell
rename y2 election_spell
rename y3 mass_nv_spell
rename y4 civil_war_spell

**Create transition year for entire spell
replace yr_elite=99 if (gwf_democracy==0 & yr_elite==.)
replace  yr_election=99 if (gwf_democracy==0 &  yr_election==.)
replace yr_mass_nv=99 if (gwf_democracy==0 & yr_mass_nv==.)
replace  yr_civil_war=99 if (gwf_democracy==0 &  yr_civil_war==.)

bysort ccode (year): carryforward yr_elite, replace
bysort ccode (year): carryforward yr_election, replace
bysort ccode (year): carryforward yr_mass_nv, replace
bysort ccode (year): carryforward yr_civil_war, replace


***Tag democratic years
replace yr_elite=98 if (yr_elite==. & gwf_democracy==1)
replace yr_election=98 if (yr_election==. & gwf_democracy==1)
replace yr_mass_nv=98 if (yr_mass_nv==. & gwf_democracy==1)
replace yr_civil_war=98 if (yr_civil_war==. & gwf_democracy==1)

**Coding Croatia
replace gwf_dtrans=1 if country_name=="Croatia" & year==1991
replace gwf_delection=1 if country_name=="Croatia" & year==1991
replace election_spell=1 if country_name=="Croatia"
replace yr_election=1991 if country_name=="Croatia" & election_spell==1 

**Coding Bosnia
replace gwf_dtrans=1 if country_name=="Slovenia" & year==1991
replace gwf_delection=1 if country_name=="Slovenia" & year==1991
replace election_spell=1 if country_name=="Slovenia"
replace yr_election=1991 if country_name=="Slovenia" & election_spell==1 


**Coding Bosnia and Herzegovina
replace gwf_dtrans=1 if country_name=="Bosnia and Herzegovina" & year==1991
replace gwf_delection=1 if country_name=="Bosnia and Herzegovina" & year==1991
replace election_spell=1 if country_name=="Bosnia and Herzegovina"
replace yr_election=1991 if country_name=="Bosnia and Herzegovina" & election_spell==1 

**Coding Ukraine
replace gwf_dtrans=1 if country_name=="Ukraine" & year==1991
replace gwf_delite=1 if country_name=="Ukraine" & year==1991
replace elite_spell=1 if country_name=="Ukraine"
replace yr_elite=1991 if country_name=="Ukraine" & elite_spell==1 

**Coding Moldova
replace gwf_dtrans=1 if country_name=="Moldova" & year==1991
replace gwf_dcivil_war=1 if country_name=="Moldova" & year==1991
replace civil_war_spell=1 if country_name=="Moldova"
replace yr_civil_war=1991 if country_name=="Moldova" & civil_war_spell==1 

*Coding Estonia 
replace gwf_dtrans=1 if country_name=="Estonia" & year==1991
replace gwf_dmass_nv=1 if country_name=="Estonia" & year==1991
replace mass_nv_spell=1 if country_name=="Estonia"
replace yr_mass_nv=1991 if country_name=="Estonia" & mass_nv_spell==1


*Coding Latvia
replace gwf_dtrans=1 if country_name=="Latvia" & year==1991
replace gwf_delite=1 if country_name=="Latvia" & year==1991
replace elite_spell=1 if country_name=="Latvia"
replace yr_elite=1991 if country_name=="Latvia" & elite_spell==1

*Coding Lithuania
replace gwf_dtrans=1 if country_name=="Lithuania" & year==1990
replace gwf_delite=1 if country_name=="Lithuania" & year==1990
replace elite_spell=1 if country_name=="Lithuania"
replace yr_elite=1990 if country_name=="Lithuania" & elite_spell==1


**Coding North Macedonia
replace gwf_dtrans=1 if country_name=="North Macedonia" & year==1991
replace gwf_delection=1 if country_name=="North Macedonia" & year==1991
replace election_spell=1 if country_name=="North Macedonia"
replace yr_election=1991 if country_name=="North Macedonia" & election_spell==1 


**Coding Montenegro
replace gwf_dtrans=1 if country_name=="Montenegro" & year==2006
replace gwf_delection=1 if country_name=="Montenegro" & year==2006
replace election_spell=1 if country_name=="Montenegro"
replace yr_election=2006 if country_name=="Montenegro" & election_spell==1

save "gwf_vdem.dta", replace


***Update East Germany
sort year ccode
keep if (ccode ==255 | ccode==265) & year>1990
replace country_name="German Democratic Republic"
recode ccode 255=265
sort ccode year
recode country_id 77=137 if ccode==265

replace gwf_dtrans=1 if year==1990
replace gwf_delection=1 if year==1990
replace election_spell=1 
replace yr_election=1990 
replace gwf_democracy=1 

sort ccode year
save "eastgermany.dta", replace


**Update Czech Republic and Slovakia's macro variable after 1990
use "gwf_vdem.dta", clear
sort year ccode

* Dealing with Czech Republic and Slovakia

* Czech
keep if (ccode ==315 |ccode ==316 ) 
recode ccode (315=316)
replace yr_mass_nv = 1989 if ccode==316 & year>1988
replace gwf_dtrans=1 if ccode==316 & year==1989
replace gwf_dmass_nv=1 if ccode==316 & year==1989
replace mass_nv_spell=1 if ccode==316 & year>1988


save "czech_update.dta", replace


* Slovakia
use "gwf_vdem.dta", clear

keep if (ccode ==315 |ccode ==317) 
recode ccode (315=317)
recode country_id (157=201)

replace yr_mass_nv = 1989 if ccode==317 & year>1988
replace gwf_dtrans=1 if ccode==317 & year==1989
replace gwf_dmass_nv=1 if ccode==317 & year==1989
replace mass_nv_spell=1 if ccode==317 & year>1988
replace country_name="Slovakia"
save "slovakia_update.dta", replace


**Merge and update macro data
use "gwf_vdem.dta", clear
drop if (ccode ==315 |ccode ==316 |ccode ==317) 

merge 1:1 ccode year using "czech_update.dta", update
drop _m
merge 1:1 ccode year using "slovakia_update.dta", update
drop _m

append using "eastgermany.dta"

sort  ccode year
save "gwf_vdem.dta", replace



**---------------------------------------------------------------------------------------
** Recode and prepare Transition data


** Merge top-down and bottom-up transitions

sum yr_elite yr_mass_nv yr_civil_war yr_election

gen yr_top = 0
replace yr_top = yr_elite if yr_elite>100
replace yr_top = yr_civil_war if yr_civil_war>100


gen yr_bottom = 0
replace yr_bottom = yr_mass_nv if yr_mass_nv>100
replace yr_bottom = yr_election if yr_election>100


gen gwf_top = gwf_delite 
replace gwf_top =1 if gwf_dcivil_war==1

gen gwf_bottom =  gwf_delection
replace gwf_bottom =1 if gwf_dmass_nv==1


**Fill in 0s for non-transition year
foreach var of varlist gwf_delite gwf_delection gwf_dmass_nv gwf_dcivil_war gwf_dtrans gwf_top gwf_bottom {

replace `var' = 0 if `var'!=1 
}

codebook gwf_delite gwf_delection gwf_dmass_nv gwf_dcivil_war gwf_dtrans



* Creating count variable for transitions
capture drop count_trans transition

bys ccode: gen count_trans=sum(gwf_dtrans)
tab count_trans

tab country_name if count_trans>2

recode count_trans (0=0) (1/4=1), gen(transition)
lab var transition "At least one transition happened in country"
replace transition=1 if country_name=="Bosnia and Herzegovina"
replace transition=1 if country_name=="Montenegro"

tab transition

tab country_name transition


tab country_name if count_trans>0 & count_trans!=.

table year if country_name=="Turkey", c(mean gwf_democracy) 
table year if country_name=="Russia", c(mean gwf_democracy) 

* Creating year of transition variable // 

gen trans_year = 0
replace  trans_year = yr_elite if yr_elite>100 
replace  trans_year = yr_election if yr_election>100 
replace  trans_year = yr_mass_nv if yr_mass_nv>100 
replace  trans_year = yr_civil_war if yr_civil_war>100 
 
label variable trans_year "Year transition"



* Creating regime variable and dropping autocracies 

tab v2x_regime
tab v2x_regime, nolabel
recode v2x_regime (0/1=0 "Autocracy") (2/3=1 "Democracy"), gen(democ_dum)
tab democ_dum

tab  country_name democ_dum if count_trans>0 & count_trans!=.



** Checking country coverage of transition data
*keep if democ_dum==1 
*keep if gwf_democracy==1
tab  country_name  if count_trans>0 & count_trans!=.



*** -------------------------------------------------
*** Create categorical variable for transitions

gen top=1 if elite_spell==1
replace top=1 if civil_war_spell==1
replace top=0 if top==.
gen bottom=1 if mass_nv_spell==1
replace bottom=1 if election_spell==1
replace bottom=0 if bottom==.



gen trans_cat = 0 if trans_year==0 & gwf_democracy==1
replace trans_cat = 1 if bottom==1
replace trans_cat = 2 if top==1
lab var trans_cat "Type of transition"

gen trans_cat_vdem = 0 if trans_year==0 & democ_dum==1
replace trans_cat_vdem = 1 if bottom==1
replace trans_cat_vdem = 2 if top==1



lab def translbl1 0 "No transition" 1 "Citizen-centered" 2 "Elite-centered"
lab val  trans_cat trans_cat_vdem translbl1
tab trans_cat
bysort ccode (year): carryforward trans_cat, replace


* Detailed transition variable
gen trans_cat2 = 0 if trans_year==0 & gwf_democracy==1
replace trans_cat2 = 1 if election_spell==1
replace trans_cat2 = 2 if mass_nv_spell==1
replace trans_cat2 = 3 if elite_spell==1
replace trans_cat2 = 4 if civil_war_spell==1

lab def translbl22 0 "No transition" 1 "Citizen-centered: Elections " 2 "Citizen-centered: Mass" 3 "Elite-centered: Elite" 4"Elite-centered: Civil war"
lab val  trans_cat2 translbl22
tab trans_cat2
bysort ccode (year): carryforward trans_cat2, replace
tab trans_cat2

*** -------------------------------------------------
*** Create  Years since transition
sort ccode year

bys ccode: egen trans_year2 = max(trans_year)

gen yr_since_trans = year - trans_year2 if trans_year>0
lab var yr_since_trans "Years since transition" 

tab yr_since_trans 


*Save Data
keep year ccode country_name yr_since_trans trans_year trans_cat e_migdpgr v2x_corr v2x_civlib democ_dum v2x_polyarchy v2x_polyarchy_codelow v2x_polyarchy_codehigh


sort ccode year
save "gwf_vdem.dta", replace


***-----------------------------------------------------
*** DATASET 3: CLAASSEN (2019) and CLAASSEN AND MAGALHAES (2022) - democartic support and satisfaction 

/* Data for both datasets (in csv format) used, can be downloaded here: http://chrisclaassen.com/data.html. The page also includes information on the variable descriptions. For more information on the method used to create the smooth country-year estimates, please check Claassen (2019) "Estimating smooth country‐year panels of public opinion." Political Analysis.


Citations:  Claassen, Christopher, 2019. Estimating smooth country–year panels of public opinion. Political Analysis, 27(1), pp.1-20. doi:10.1017/pan.2018.32

Claassen, Christopher, and Pedro C. Magalhães. 2022. Effective government and evaluations of democracy. Comparative Political Studies, 55(5), pp.869-894.. https://doi.org/10.1177/00104140211036042



*/


*Claassen (2019): Democartic Mood / Support
import delimited "dem_mood_v4.csv", encoding(ISO-8859-2) clear 

kountry iso3c, from(iso3c) to (cown)
rename _COWN_ ccode

recode ccode 345=341 if country=="Montenegro"
recode ccode 315=317 if country=="Slovakia"

lab var supdem "Democratic support for each country and year"


keep year ccode supdem
sort ccode year
save "dem_mood_claasen.dta", replace

*Claassen and Magalhaes (2022): Democratic 
import delimited "satis_est_v2.csv", encoding(ISO-8859-2) clear 

kountry iso_code, from(iso3c) to (cown)
rename _COWN_ ccode

recode ccode 345=341 if country=="Montenegro"
recode ccode 315=317 if country=="Slovakia"

lab var satis "Democratic satisfaction for each country and year"

keep year ccode satis
sort ccode year
save "demsat_claasen.dta", replace

 
***-----------------------------------------------------
*** MERGE ALL THREE DATASET TO ONE MACRO DATASET
 
 
use "gwf_vdem.dta", clear
merge 1:m ccode year using "dem_mood_claasen.dta", keep(master match)
drop _merge

merge 1:m ccode year using "demsat_claasen.dta", keep(master match)
drop _merge

*Save the data file
sort country year
save "macro_data.dta", replace


* Delete temp files
erase "czech_update.dta"
erase "slovakia_update.dta"
erase "eastgermany.dta"
erase "gwf_transitions.dta"
erase "gwf_vdem.dta"
erase "dem_mood_claasen.dta"
erase "demsat_claasen.dta"
