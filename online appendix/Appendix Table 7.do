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
log using "$root/3analysis/do files/final revision/logfiles/Appendix Table 7", replace 

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

***Older Sibling Sex Composition*** 
g 		 sss = 1 if girl1==0 & girl2==0
replace  sss = 2 if girl1==0 & girl2==1 
replace  sss = 2 if girl1==1 & girl2==0 
replace  sss = 3 if girl1==1 & girl2==1 
***Older Sibling Sex Composition*** 



eststo clear 

forvalues j=1(1)3{
forvalues k=0(1)1{
qui sum dead1 if sss==`j' & bord==3 & female==`k'
local mean`j'`k' = r(mean) 
local sd`j'`k' = r(sd) 
dis `mean`j'`k'' 
dis `sd`j'`k''
}
}


*** y = b0 + b1sss2 + b2ss3 + b3female + b4(ss2 x female) + b5(ss3 x female) + e ***
*** E[y | all boys, male] = b0 , E[y|all boys, female] = b0 + b3  *** 
*** E[y | mixed, male] = b0 + b1, E[y | mixed, female] = b0 + b1 + b3 + b4 *** 
*** E[y | all girls, male] = b0 + b2, E[y | all girls, female] = b0 + b2 + b3 + b5 *** 


***Table 8 Girl-Boy Diff. & Diff.-in-Diff - With and Without Covariate Adjustment*** 
eststo:reg dead1 sss##female if bord==3, robust
lincom 1.female + 2.sss#1.female
estadd scalar inte1=r(estimate) 
estadd scalar intse1=r(se) 
lincom 1.female + 3.sss#1.female 
estadd scalar inte2=r(estimate) 
estadd scalar intse2=r(se) 

eststo:reg dead1 sss##female girl1 girl2 i.wave##i.region $regset1 $regset3 m_* if bord==3, robust
lincom 1.female + 2.sss#1.female
estadd scalar inte1=r(estimate) 
estadd scalar intse1=r(se) 
lincom 1.female + 3.sss#1.female 
estadd scalar inte2=r(estimate) 
estadd scalar intse2=r(se) 


esttab  using "Online Table 7.csv", replace se r2  ///
star( * .1 ** .05 *** .01) b(%9.3f) se(%9.3f) label indicate() ///
nogaps scalars(inte1 intse1 inte2 intse2) keep(1.female 2.sss#1.female 3.sss#1.female)


