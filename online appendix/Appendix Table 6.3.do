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
log using "$root/3analysis/do files/final revision/logfiles/Appendix Table 6p3.log", replace 

global regdow1 "MotherAge hage firstbirthage"
global regdow2 "nonturkish educat heducat region rural wave extfamily arranged"
global regdow3 "i.educat i.heducat i.nonturkish i.region i.rural i.wave i.extfamily i.arranged" 

use "replication.dta", clear 

**Flag women with a singleton first birth** 
g flag=1 if bord==1 & Singleton==1 
bysort mid: egen sample=max(flag)   
keep if bord==1 & sample==1 //Comparison is at family level & only women with singleton first birth 
keep if MotherAge>34 //Sample of older women 

foreach i in $regdow1{
g m_`i'=`i'==. 
qui sum `i' 
replace `i'=r(mean) if `i'==. 
}


foreach i in $regdow2{
recode `i' (.=999)
}

eststo: reg nbliving girl1##dowry ChildAlive $regdow1 $regdow3 m_* , robust
lincom 1.girl1+1.girl1#1.dowry
estadd scalar coef1=r(estimate) 
estadd scalar se1=r(se)

qui sum nbliving if dowry==0 & e(sample)==1 & girl1==0 
estadd scalar mean1=r(mean) 
qui sum nbliving if dowry==1 & e(sample)==1 & girl1==0 
estadd scalar mean2=r(mean) 



eststo: poisson nbliving girl1##dowry ChildAlive $regdow1 $regdow3 m_* , robust
lincom 1.girl1+1.girl1#1.dowry
estadd scalar coef1=r(estimate) 
estadd scalar se1=r(se)

qui sum nbliving if dowry==0 & e(sample)==1 & girl1==0 
estadd scalar mean1=r(mean) 
qui sum nbliving if dowry==1 & e(sample)==1 & girl1==0 
estadd scalar mean2=r(mean) 

esttab  using "Table 6.3 - bride price.csv", replace se r2 pr2 ///
star( * .1 ** .05 *** .01) b(%9.3f) se(%9.3f) label indicate() ///
nogaps scalars(coef1 coef2 coef3 coef4  se1 se2 se3 se4 mean1 mean2 mean3 mean4) keep(1.girl1 1.girl1#1.dowry)


***Bride Price***
