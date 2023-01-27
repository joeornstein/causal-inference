*****************************************************************************************************
************** PROJECT: Can Online Civic Education Induce Democratic Citizenship? ///
				* Experimental Evidence from a New Democracy 
************** AIM: This do-file replicates Figure 1
************** AJPS -- Finkel, Neundorf, Rascon-Ramirez 2022
************** Created by: Anja Neundorf
************** Date: 09.09.2022
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
global 		logs			"${main}logs/TunisiaDemocracy_figure1.log"


cd "${main}data/"



***** INSTALL THE FOLLOWING ADO IF YOU DON'T HAVE IT IN YOUR COMPUTER

*ssc install blindschemes 
set scheme plotplain


***********************************
***** Figure 1 
***********************************

*** Extra do-file to create macro data
*** do "EXTRA_GenMacroData"

/* The data used is based on Varieties of Democracy (V-Dem) 

The data displayed in Figure 1 is taken from V-Dem, version 10 "Country-Year: V-Dem Full+Others". The data can be downloaded here: https://v-dem.net/dsarchive.html. 

Citation: Coppedge, Michael, John Gerring, Carl Henrik Knutsen, Staffan I. Lindberg, Jan Teorell, David Altman, Michael Bernhard, M. Steven Fish, Adam Glynn, Allen Hicken, Anna Luhrmann, Kyle L. Marquardt, Kelly McMann, Pamela Paxton, Daniel Pemstein, Brigitte Seim, Rachel Sigman, Svend-Erik Skaaning, Jeffrey Staton, Steven Wilson, Agnes Cornell, Nazifa Alizada, Lisa Gastaldi, Haakon Gjerløw, Garry Hindle, Nina Ilchenko, Laura Maxwell, Valeriya Mechkova, Juraj Medzihorsky, Johannes von Römer, Aksel Sundström, Eitan Tzelgov, Yi-ting Wang, Tore Wig, and Daniel Ziblatt. 2020. ”V-Dem [Country–Year/Country–Date] Dataset v10”. Varieties of Democracy (V-Dem) Project. https://doi.org/10.23696/vdemds20.Project. https://doi.org/10.23696/vdemds21.


The codebook with exact definitions of each variable used here is available in the data folder as well when downloading the data via the link above.  

*/

use "macro_data.dta", clear

keep year country_name v2x_polyarchy v2x_polyarchy_codelow v2x_polyarchy_codehigh

keep if country_name == "Tunisia"

drop if year<1956

twoway(line v2x_polyarchy year, lp(solid) lc(black) lw(medium)) (line v2x_polyarchy_codelow year, lp(shortdash) lc(gs5) lw(medthin)) (line v2x_polyarchy_codehigh year, lp(shortdash) lc(gs5) lw(medthin)), xline(2011, lp(solid)) legend(off) ylabel(0(0.2)1, labsize(medsmall)) ytitle("Level of democracy", size(medlarge)) xlabel(1955(10)2015, labsize(medsmall)) xtitle(" ") 
graph export  "$figures/MacroTunisia.pdf", as(pdf) replace	
	
**log close
