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
log using "$root/3analysis/do files/final revision/logfiles/Table 6", replace 

global regset1 "firstbirthage reg2 reg3 reg4 reg5 rural yearseduc hyearseduc m_hyearseduc"
global regset2 "MotherAge extfamily hage nonturkish wave2 wave3 wave4 nonturkish"
global regset2a "MotherAge extfamily hage nonturkish wave2 wave3 wave4 hyearseduc"
global regset3 "arranged dowry"




use "replication.dta", clear 

**Flag women with a singleton first birth** 
g flag=1 if bord==1 & Singleton==1 
bysort mid: egen sample=max(flag)   
keep if bord==1 & sample==1 //Comparison is at family level & only women with singleton first birth 
set seed 20052015 
***RSS estimator results will be slightly different even if you fix the seed*** 
***LOO estimator results will be exactly the same if you fix the seed*** 


tab wave, g(wave) 


foreach i in $regset2a{
g m_`i'=`i'==. 
qui sum `i' 
replace `i'=r(mean) if `i'==. 
}



foreach i in $regset3{
recode `i' (.=999)
}


tab arranged, g(ar)
tab dow, g(dow) 


reg nbliving $regset1, robust 

***Table 6*** 
estrat nbliving girl1 $regset1, groups(5) savegroup  
tab estrat_loo_group
mean nbliving if girl1==0, over(estrat_loo_group) 

estrat nbliving girl1 $regset1, groups(5) savegroup cov($regset1 $regset2 ar2 ar3 dow2 dow3 m_hage m_hyearseduc ChildAlive)
tab estrat_loo_group
mean nbliving if girl1==0, over(estrat_loo_group) 
***Table 6*** 
cap log close
