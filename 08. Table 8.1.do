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
log using "$root/3analysis/do files/final revision/logfiles/Table 81.log", replace  

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


***Referee 2 asked to drop those whose who were born less than a year before the survey was conducted
keep if AgeinMonths>11 

***Mortality***
g 		dead1=1 if ChildAlive==0 & AgeAtDeath<12
replace dead1=0 if dead1==.

g       dead2=1 if ChildAlive==0 & AgeAtDeath<60 
replace dead2=0 if dead2==.  
***Mortality***




eststo clear 

***Table 8 mean infant mortality rates by previous sibling's sex and birth order***
forvalues j=0(1)1{
forvalues k=0(1)1{
qui sum dead1 if prev_f==`j' & female==`k' & bord==2
local mean`i'`j'`k'=r(mean) 
local sd`i'`j'`k'=r(sd)
dis `mean`i'`j'`k''
dis `sd`i'`j'`k''
}
}
***Table 8 mean infant mortality rates by previous sibling's sex and birth order***



***Table 8 Girl-Boy Diff. & Diff.-in-Diff - With and Without Covariate Adjustment*** 
eststo:reg dead1 prev_f##female if bord==2, robust  
lincom 1.female + 1.prev_f#1.female
estadd scalar inte=r(estimate) 
estadd scalar intse=r(se) 


eststo:reg dead1 prev_f##female i.wave##i.region $regset1 $regset3 m_* if bord==2 , robust 
lincom 1.female + 1.prev_f#1.female
estadd scalar inte=r(estimate) 
estadd scalar intse=r(se) 
***Table 8 Girl-Boy Diff. & Diff.-in-Diff - With and Without Covariate Adjustment*** 



esttab  using "Table 8.csv", replace se r2  ///
star( * .1 ** .05 *** .01) b(%9.3f) se(%9.3f) label indicate() ///
nogaps scalars(inte intse) keep(1.female  1.prev_f#1.female 1.prev_f)

eststo clear 




