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
log using "$root/3analysis/do files/final revision/logfiles/Appendix Table 5p1", replace  

global regfam1 "MotherAge hage firstbirthage"
global regfam2 "nonturkish educat heducat region rural wave arranged dowry"
global regfam3 "i.educat i.heducat i.nonturkish i.region i.rural i.wave i.arranged i.dowry" 

use "replication.dta", clear 

**Flag women with a singleton first birth** 
g flag=1 if bord==1 & Singleton==1 
bysort mid: egen sample=max(flag)   
keep if bord==1 & sample==1 //Comparison is at family level & only women with singleton first birth 

foreach i in $regfam1{
g m_`i'=`i'==. 
qui sum `i' 
replace `i'=r(mean) if `i'==. 
}


foreach i in $regfam2{
recode `i' (.=999)
}

eststo: reg nbliving girl1##extfamily ChildAlive $regfam1 $regfam3 m_* , robust
lincom 1.girl1+1.girl1#1.extfamily  
estadd scalar coef1=r(estimate) 
estadd scalar se1=r(se)
qui sum nbliving if extfamily==0 & e(sample)==1 & girl1==0 
estadd scalar mean1=r(mean) 
qui sum nbliving if extfamily==1 & e(sample)==1 & girl1==0 
estadd scalar mean2=r(mean) 

testparm 1.girl1#extfamily


eststo: poisson nbliving girl1##extfamily ChildAlive $regfam1 $regfam3 m_* , robust
lincom 1.girl1+1.girl1#1.extfamily  
estadd scalar coef1=r(estimate) 
estadd scalar se1=r(se)


testparm 1.girl1#extfamily

esttab  using "Table 5.1 - extfamily.csv", replace se r2 pr2 ///
star( * .1 ** .05 *** .01) b(%9.3f) se(%9.3f) label indicate() ///
nogaps scalars(coef1 coef2 coef3 coef4  se1 se2 se3 se4 mean1 mean2 mean3 mean4) keep(1.girl1 1.girl1#1.extfamily)
***Patrilocal Residence***  
