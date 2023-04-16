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
log using "$root/3analysis/do files/final revision/logfiles/Appendix Table 8", replace 

global regset1 "MotherAge firstbirthage yearseduc nonturkish  hage hyearseduc rural extfamily"
global regset2 "arranged dowry"
global regset3 "i.arranged i.dowry" 
global regset4 "MotherAge firstbirthage nonturkish  reg1 reg2 reg3 reg4 reg5 rural extfamily hage"
global outcomes "bcg dpt polio measles" 



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


foreach k in $outcomes{
forvalues i=0(1)1{
forvalues j=0(1)1{
qui sum `k' if prev_f==`i' & female==`j' 
local mean`k'`i'`j'=r(mean) 
local sd`k'`i'`j'=r(sd)
dis `mean`k'`i'`j''
dis `sd`k'`i'`j''
}
}
}





foreach i in $outcomes{
eststo: reg `i' prev_f##female, cluster(mid)
lincom 1.female + 1.prev_f#1.female
estadd scalar inte=r(estimate) 
estadd scalar intse=r(se) 
}


foreach i in $outcomes{
eststo: reg `i' prev_f##female i.bord i.wave##i.region $regset1 $regset3 m_* , cluster(mid)
lincom 1.female + 1.prev_f#1.female
estadd scalar inte=r(estimate) 
estadd scalar intse=r(se) 
}

esttab  using "Appendix Table 8.csv", replace se r2  ///
star( * .1 ** .05 *** .01) b(%9.3f) se(%9.3f) label indicate() ///
nogaps scalars(inte intse) keep(1.female  1.prev_f#1.female 1.prev_f)






