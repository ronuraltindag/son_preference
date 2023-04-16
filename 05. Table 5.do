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
log using "$root/3analysis/do files/final revision/logfiles/Table 5.log", replace 

global regset1 "MotherAge firstbirthage yearseduc nonturkish  reg1 reg2 reg3 reg4 reg5 rural hage hyearseduc extfamily"
global regset2 "arranged dowry"
global regset3 "i.arranged i.dowry" 
global regset4 "Motherage firstbirthage nonturkish  reg1 reg2 reg3 reg4 reg5 rural extfamily hage"
global outcomes "nbpregnancies totalborn nbliving ccontraceptive abort1" 
global outcomes1 "nbpregnancies totalborn nbliving"



use "replication.dta", clear 

**Flag women with a singleton first birth** 
g flag=1 if bord==1 & Singleton==1 
bysort mid: egen sample=max(flag)   
keep if bord==1 & sample==1 //Comparison is at family level & only women with singleton first birth 


g 			agec=1 if MotherAge<30 //Panel (B)
replace     agec=2 if MotherAge>29 & MotherAge<40  //Panel (C)
replace     agec=3 if MotherAge>39 //Panel (D) 


foreach i in $regset1{
g m_`i'=`i'==. 
qui sum `i' 
replace `i'=r(mean) if `i'==. 
}

foreach i in $regset2{
recode `i' (.=999)
}



***TABLE 5***
*panel(A)- OLS* 
foreach i in $outcomes{
eststo: reg `i' girl1 i.wave##i.region ChildAlive $regset1 $regset3 m_*, robust 
qui sum `i' if girl1==0 & e(sample)==1   
estadd scalar ycontrolmean=r(mean) 
}
*panel(A)- OLS* 

*panel (A) OLS without Covariates - goes to online appendix* 
foreach i in $outcomes{
eststo: reg `i' girl1, robust 
}
*panel (A) OLS without Covariates - goes to online appendix* 

*panel (B) - OLS* 
foreach i in $outcomes{
eststo: reg `i' girl1 i.wave##i.region ChildAlive $regset1 $regset3 m_* if agec==1, robust 
qui sum `i' if girl1==0 & e(sample)==1   
estadd scalar ycontrolmean=r(mean) 
}
*panel (B) - OLS* 

*panel (C) - OLS* 
foreach i in $outcomes{
eststo: reg `i' girl1 i.wave ChildAlive $regset1 $regset3 m_* if agec==2, robust 
qui sum `i' if girl1==0 & e(sample)==1   
estadd scalar ycontrolmean=r(mean) 
}
*panel (C) - OLS* 

*panel (D) - OLS * 
foreach i in $outcomes{
eststo: reg `i' girl1 i.wave##i.region ChildAlive $regset1 $regset3 m_* if agec==3, robust 
qui sum `i' if girl1==0 & e(sample)==1   
estadd scalar ycontrolmean=r(mean) 
}
*panel (D) - OLS * 

*panel (A) - MLE* 
foreach i in $outcomes1{
eststo: poisson `i' girl1 i.wave##i.region ChildAlive $regset1 $regset3 m_* , robust 
}
*panel (A) - MLE* 

*panel (B) - MLE* 
foreach i in $outcomes1{
eststo: poisson `i' girl1 i.wave##i.region ChildAlive $regset1 $regset3 m_* if agec==1, robust   
}
*panel (B) - MLE* 

*panel (C) - MLE* 
foreach i in $outcomes1{
eststo: poisson `i' girl1 i.wave##i.region ChildAlive $regset1 $regset3 m_* if agec==2, robust 
}
*panel (C) - MLE* 

*panel (D) - MLE* 
foreach i in $outcomes1{
eststo: poisson `i' girl1 i.wave##i.region ChildAlive $regset1 $regset3 m_* if agec==3, robust 
}
*panel (D) - MLE* 


esttab  using "Table 5n.csv", replace se r2  ///
star( * .1 ** .05 *** .01) b(%9.3f) se(%9.3f) label indicate() ///
keep(girl1) nogaps scalars(ycontrolmean)

cap log close
