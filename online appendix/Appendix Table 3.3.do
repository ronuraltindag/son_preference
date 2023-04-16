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
log using "$root/3analysis/do files/final revision/logfiles/Appendix Table 3p3", replace 

global regheduc1 "MotherAge hage firstbirthage"
global regheduc2 "nonturkish region rural extfamily arranged dowry educat wave"
global regheduc3 "i.educat i.nonturkish i.region i.rural i.extfamily i.arranged i.dowry i.wave" 

use "replication.dta", clear 

**Flag women with a singleton first birth** 
g flag=1 if bord==1 & Singleton==1 
bysort mid: egen sample=max(flag)   
keep if bord==1 & sample==1 //Comparison is at family level & only women with singleton first birth 



foreach i in $regheduc1{
g m_`i'=`i'==. 
qui sum `i' 
replace `i'=r(mean) if `i'==. 
}


foreach i in $regheduc2{
recode `i' (.=999)
}

eststo: reg nbliving girl1##heducat ChildAlive $regheduc1 $regheduc3 m_* , robust
lincom 1.girl1+1.girl1#0.heducat
estadd scalar coef1=r(estimate) 
estadd scalar se1=r(se)
lincom 1.girl1+1.girl1#1.heducat
estadd scalar coef2=r(estimate) 
estadd scalar se2=r(se) 
lincom 1.girl1+1.girl1#2.heducat 
estadd scalar coef3=r(estimate) 
estadd scalar se3=r(se)
qui sum nbliving if heducat==0 & e(sample)==1 & girl1==0 
estadd scalar mean1=r(mean) 
qui sum nbliving if heducat==1 & e(sample)==1 & girl1==0 
estadd scalar mean2=r(mean) 
qui sum nbliving if heducat==2 & e(sample)==1 & girl1==0 
estadd scalar mean3=r(mean) 

testparm 1.girl1#1.heducat 1.girl1#2.heducat

eststo: poisson nbliving girl1##heducat ChildAlive $regheduc1 $regheduc3 m_* , robust
lincom 1.girl1+1.girl1#0.heducat 
estadd scalar coef1=r(estimate) 
estadd scalar se1=r(se)
lincom 1.girl1+1.girl1#1.heducat
estadd scalar coef2=r(estimate) 
estadd scalar se2=r(se) 
lincom 1.girl1+1.girl1#2.heducat
estadd scalar coef3=r(estimate) 
estadd scalar se3=r(se)
qui sum nbliving if heducat==0 & e(sample)==1 & girl1==0 
estadd scalar mean1=r(mean) 
qui sum nbliving if heducat==1 & e(sample)==1 & girl1==0 
estadd scalar mean2=r(mean) 
qui sum nbliving if heducat==2 & e(sample)==1 & girl1==0 
estadd scalar mean3=r(mean) 

testparm 1.girl1#1.heducat 1.girl1#2.heducat

esttab  using "Online Table 3.3 - heducat.csv", replace se r2 pr2 ///
star( * .1 ** .05 *** .01) b(%9.3f) se(%9.3f) label indicate() ///
nogaps scalars(coef1 coef2 coef3 coef4  se1 se2 se3 se4 mean1 mean2 mean3 mean4) keep(1.girl1)

***Father's Education***
