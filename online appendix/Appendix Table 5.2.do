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
log using "$root/3analysis/do files/final revision/logfiles/Appendix Table 5p2", replace

global regmar1 "MotherAge hage firstbirthage"
global regmar2 "nonturkish educat heducat region rural wave extfamily dowry"
global regmar3 "i.educat i.heducat i.nonturkish i.region i.rural i.wave i.extfamily i.dowry" 

use "replication.dta", clear 

**Flag women with a singleton first birth** 
g flag=1 if bord==1 & Singleton==1 
bysort mid: egen sample=max(flag)   
keep if bord==1 & sample==1 //Comparison is at family level & only women with singleton first birth 

foreach i in $regmar1{
g m_`i'=`i'==. 
qui sum `i' 
replace `i'=r(mean) if `i'==. 
}


foreach i in $regmar2{
recode `i' (.=999)
}

eststo: reg nbliving girl1##arranged ChildAlive $regmar1 $regmar3 m_* , robust
lincom 1.girl1+1.girl1#1.arranged
estadd scalar coef1=r(estimate) 
estadd scalar se1=r(se)

qui sum nbliving if arranged==0 & e(sample)==1 & girl1==0 
estadd scalar mean1=r(mean) 
qui sum nbliving if arranged==1 & e(sample)==1 & girl1==0 
estadd scalar mean2=r(mean) 



eststo: poisson nbliving girl1##arranged ChildAlive $regmar1 $regmar3 m_* , robust
lincom 1.girl1+1.girl1#1.arranged
estadd scalar coef1=r(estimate) 
estadd scalar se1=r(se)

qui sum nbliving if arranged==0 & e(sample)==1 & girl1==0 
estadd scalar mean1=r(mean) 
qui sum nbliving if arranged==1 & e(sample)==1 & girl1==0 
estadd scalar mean2=r(mean) 

esttab  using "Table 5.2 - arranged.csv", replace se r2 pr2 ///
star( * .1 ** .05 *** .01) b(%9.3f) se(%9.3f) label indicate() ///
nogaps scalars(coef1 coef2 coef3 coef4  se1 se2 se3 se4 mean1 mean2 mean3 mean4) keep(1.girl1 1.girl1#1.arranged)
***Arranged Marriage***
