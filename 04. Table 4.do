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
log using "$root/3analysis/do files/final revision/logfiles/Table 4.log", replace 

global regset1 "MotherAge firstbirthage yearseduc nonturkish  reg1 reg2 reg3 reg4 reg5 rural hage hyearseduc extfamily"
global regset2 "arranged dowry"
global regset3 "i.arranged i.dowry" 
global regset4 "Motherage firstbirthage nonturkish  reg1 reg2 reg3 reg4 reg5 rural extfamily hage"

use "replication.dta", clear 

**Flag women with a singleton first birth** 
g flag=1 if bord==1 & Singleton==1 
bysort mid: egen sample=max(flag)   

keep if bord==1 & sample==1 //Comparison is at family level & only women with singleton first birth 

***TABLE 4 & Means and t-tests*** 
eststo: estpost ttest $regset1 $regset2, by(girl1) 
esttab using "Table 4n- Unweighted Means.csv", cells("mu_1") replace 
esttab using "Table 4n- Unweighted Means.csv", cells("mu_2") append 
esttab using "Table 4n- Unweighted Means.csv", cells("b") append 
esttab using "Table 4n- Unweighted Means.csv", cells("p") append 
esttab using "Table 4n- Unweighted Means.csv", cells("count") append 
***TABLE 4 & Means and t-tests*** 

***TABLE 4 & joint F-test*** 
foreach i in $regset1{
g m_`i'=`i'==. 
qui sum `i' 
replace `i'=r(mean) if `i'==. 
}

foreach i in $regset2{
recode `i' (.=999)
}


logit girl1 $regset1 $regset3  m_* i.wave 
testparm $regset1 $regset3 m_* i.wave

***TABLE 4 & joint F-test*** 

cap log close
