*****************************************************************************
***************SETUP CODE HEADER FOR ALL PROGRAMS****************************
***************  TURKEY FAMILY PLANNING PAPER  ******************************
*****************************************************************************
clear
clear matrix
clear mata
cap log close
set more off 
set maxvar 20000
#delim ; 
if "`c(username)'"=="onuraltindag" {;global root "/Users/onuraltindag/Dropbox/family planning/";};
else if "`c(username)'"=="raltindag" {;global root "C:/Users/raltindag/Dropbox/family planning/";};
else if "`c(username)'"=="TYPE STATA USER NAME HERE" {;global root "Define the part -> XXX/Dropbox/online/";};
# delim cr ;
include "$root/2progs/00_Set_paths.do"
************************************************************************
************************************************************************
log using "$root/3analysis/do files/final revision/logfiles/Table 82.log", replace  

global regset1 "MotherAge firstbirthage yearseduc nonturkish  hage hyearseduc rural extfamily"
global regset2 "arranged dowry"
global regset3 "i.arranged i.dowry" 
global regset4 "MotherAge firstbirthage nonturkish  reg1 reg2 reg3 reg4 reg5 rural extfamily hage"
global outcomes "dead1 dead2" 



**use "$root/5prepdata/tdhs BR pooled.dta", clear 


use "replication.dta", clear 

**Flag women with a singleton first birth** 
g flag=1 if bord==1 & Singleton==1 
bysort mid: egen sample=max(flag) 

keep if sample==1 
sort mid bord 
by mid: g prev_f=female[_n-1] //sex of the previous sibling 
 



foreach i in $regset1{
g m_`i'=`i'==. 
qui sum `i' 
replace `i'=r(mean) if `i'==. 
}

foreach i in $regset2{
recode `i' (.=999)
}


keep if hw5!=. & hw5<9000 //only children under-5 are measured 

g stunt=(hw5<-200) //stunting
g underw=(hw8<-200) //underweight 

***Outcome means and sds in Table 8, Panels (2) and (3)***

forvalues i=0(1)1{
forvalues j=0(1)1{
qui sum stunt if prev_f==`i' & female==`j' & bord==2
local mean`i'`j'=r(mean) 
local sd`i'`j'=r(sd)
dis `mean`i'`j''
dis `sd`i'`j''
}
}

forvalues i=0(1)1{
forvalues j=0(1)1{
qui sum underw if prev_f==`i' & female==`j' & bord==2
local mean`i'`j'=r(mean) 
local sd`i'`j'=r(sd)
dis `mean`i'`j''
dis `sd`i'`j''
}
}

***Outcome means and sds in Table 8, Panels (2) and (3)***




***Diff.-in-diff. estimaete in Table8, Panels (2) and (3)***
eststo clear 
eststo:reg stunt prev_f##female  if bord==2, robust
lincom 1.female + 1.prev_f#1.female
estadd scalar inte=r(estimate) 
estadd scalar intse=r(se) 

eststo:reg stunt prev_f##female i.bord i.wave##i.region $regset1 $regset3 m_*  if bord==2, robust
lincom 1.female + 1.prev_f#1.female
estadd scalar inte=r(estimate) 
estadd scalar intse=r(se) 

eststo:reg underw prev_f##female  if bord==2, robust
lincom 1.female + 1.prev_f#1.female
estadd scalar inte=r(estimate) 
estadd scalar intse=r(se) 

eststo:reg underw prev_f##female i.bord i.wave##i.region $regset1 $regset3 m_*  if bord==2, robust
lincom 1.female + 1.prev_f#1.female
estadd scalar inte=r(estimate) 
estadd scalar intse=r(se) 
***Diff.-in-diff. estimaete in Table8, Panels (2) and (3)***


esttab  using "Table 8p2.csv", replace se r2  ///
star( * .1 ** .05 *** .01) b(%9.3f) se(%9.3f) label indicate() ///
nogaps scalars(inte intse ycontrolmean) keep(1.female  1.prev_f#1.female 1.prev_f)

cap log close
