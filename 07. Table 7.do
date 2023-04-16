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
log using "$root/3analysis/do files/final revision/logfiles/Table 7.log", replace   

global regset1 "MotherAge firstbirthage yearseduc nonturkish  hage hyearseduc rural extfamily"
global regset2 "arranged dowry"
global regset3 "i.arranged i.dowry" 
global regset4 "MotherAge firstbirthage nonturkish  reg1 reg2 reg3 reg4 reg5 rural extfamily hage"

use "replication.dta", clear 

**Flag women with a singleton first birth** 
g flag=1 if bord==1 & Singleton==1 
bysort mid: egen sample=max(flag) 

keep if sample==1 
sort mid bord 
by mid: g prev_f=female[_n-1] //sex of the previous sibling 
 
***Table 7 Family Characteristics by the child's sex (Panels 1-4)***
eststo: estpost ttest $regset1 $regset2 if bord==1, by(girl1) 
eststo: estpost ttest $regset1 $regset2 if bord==2, by(girl2) 
eststo: estpost ttest $regset1 $regset2 if bord==3, by(girl3) 
eststo: estpost ttest $regset1 $regset2 if bord==4, by(girl4) 

esttab using "Table 7- Unweighted Means.csv", cells("mu_1") replace 
esttab using "Table 7- Unweighted Means.csv", cells("mu_2") append 
esttab using "Table 7- Unweighted Means.csv", cells("b") append 
esttab using "Table 7- Unweighted Means.csv", cells("p") append 
esttab using "Table 7- Unweighted Means.csv", cells("count") append 
***Table 7 Family Characteristics by the child's sex (Panels 1-4)***



foreach i in $regset1{
g m_`i'=`i'==. 
qui sum `i' 
replace `i'=r(mean) if `i'==. 
}

foreach i in $regset2{
recode `i' (.=999)
}

***Table 7 Chi-Sq Test at the buttom*** 
logit girl1 $regset1 $regset3  m_* i.wave if bord==1 
testparm $regset1 $regset3 i.wave m_*
logit girl2 $regset1 $regset3  m_* i.wave if bord==2 
testparm $regset1 $regset3 i.wave m_* 
logit girl3 $regset1 $regset3  m_* i.wave if bord==3 
testparm $regset1 $regset3 m_* i.wave
logit girl4 $regset1 $regset3  m_* i.wave if bord==4 
testparm $regset1 $regset3 m_* i.wave
***Table 7 Chi-Sq Test at the buttom*** 

eststo clear 

***Table 7 Differential Stopping (lower panel) 
g d1=(totalborn>1) 
g d2=(totalborn>2)
g d3=(totalborn>3) 
g d4=(totalborn>4) 

eststo: estpost ttest nbboys nbgirls totalborn d1 if bord==1, by(girl1) 
eststo: estpost ttest nbboys nbgirls totalborn d2 if bord==2, by(girl2) 
eststo: estpost ttest nbboys nbgirls totalborn d3 if bord==3, by(girl3) 
eststo: estpost ttest nbboys nbgirls totalborn d4 if bord==4, by(girl4) 

esttab using "Table 7n- Unweighted Means.csv", cells("mu_1") replace 
esttab using "Table 7n- Unweighted Means.csv", cells("mu_2") append 
esttab using "Table 7n- Unweighted Means.csv", cells("b") append 
esttab using "Table 7n- Unweighted Means.csv", cells("p") append 
esttab using "Table 7n- Unweighted Means.csv", cells("count") append 
***Table 7 Differential Stopping (lower panel) 


cap log close
