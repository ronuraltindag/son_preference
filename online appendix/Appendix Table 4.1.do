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
log using "$root/3analysis/do files/final revision/logfiles/Appendix Table 4p1", replace 

global regwave1 "MotherAge hage firstbirthage"
global regwave2 "nonturkish educat heducat region rural extfamily arranged dowry"
global regwave3 "i.educat i.heducat i.nonturkish i.region i.rural i.extfamily i.arranged i.dowry" 

use "replication.dta", clear 

**Flag women with a singleton first birth** 
g flag=1 if bord==1 & Singleton==1 
bysort mid: egen sample=max(flag)   
keep if bord==1 & sample==1 //Comparison is at family level & only women with singleton first birth 
keep if MotherAge>34 //Older mothers


foreach i in $regwave1{
g m_`i'=`i'==. 
qui sum `i' 
replace `i'=r(mean) if `i'==. 
}


foreach i in $regwave2{
recode `i' (.=999)
}

***Wave***
eststo: reg nbliving girl1##wave ChildAlive $regwave1 $regwave3 m_* , robust
lincom 1.girl1+1.girl1#1.wave 
estadd scalar coef1=r(estimate) 
estadd scalar se1=r(se)
lincom 1.girl1+1.girl1#2.wave
estadd scalar coef2=r(estimate) 
estadd scalar se2=r(se) 
lincom 1.girl1+1.girl1#3.wave 
estadd scalar coef3=r(estimate) 
estadd scalar se3=r(se)
lincom 1.girl1+1.girl1#4.wave 
estadd scalar coef4=r(estimate) 
estadd scalar se4=r(se)
qui sum nbliving if wave==1 & e(sample)==1 & girl1==0 
estadd scalar mean1=r(mean) 
qui sum nbliving if wave==2 & e(sample)==1 & girl1==0 
estadd scalar mean2=r(mean) 
qui sum nbliving if wave==3 & e(sample)==1 & girl1==0 
estadd scalar mean3=r(mean) 
qui sum nbliving if wave==4 & e(sample)==1 & girl1==0 
estadd scalar mean4=r(mean) 

testparm 1.girl1#2.wave 1.girl1#3.wave 1.girl1#4.wave


eststo: poisson nbliving girl1##wave ChildAlive $regwave1 $regwave3 m_* , robust
lincom 1.girl1+1.girl1#1.wave 
estadd scalar coef1=r(estimate) 
estadd scalar se1=r(se)
lincom 1.girl1+1.girl1#2.wave
estadd scalar coef2=r(estimate) 
estadd scalar se2=r(se) 
lincom 1.girl1+1.girl1#3.wave 
estadd scalar coef3=r(estimate) 
estadd scalar se3=r(se)
lincom 1.girl1+1.girl1#4.wave 
estadd scalar coef4=r(estimate) 
estadd scalar se4=r(se)
qui sum nbliving if wave==1 & e(sample)==1 & girl1==0 
estadd scalar mean1=r(mean) 
qui sum nbliving if wave==2 & e(sample)==1 & girl1==0 
estadd scalar mean2=r(mean) 
qui sum nbliving if wave==3 & e(sample)==1 & girl1==0 
estadd scalar mean3=r(mean) 
qui sum nbliving if wave==4 & e(sample)==1 & girl1==0 
estadd scalar mean4=r(mean) 

testparm 1.girl1#2.wave 1.girl1#3.wave 1.girl1#4.wave

esttab  using "Online Table 4 - wave.csv", replace se r2 pr2 ///
star( * .1 ** .05 *** .01) b(%9.3f) se(%9.3f) label indicate() ///
nogaps scalars(coef1 coef2 coef3 coef4  se1 se2 se3 se4 mean1 mean2 mean3 mean4) keep(1.girl1)



