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
log using "$root/3analysis/do files/final revision/logfiles/Table 3.log", replace 

use "replication.dta", clear 

***TABLE 3 UPPER PANEL***
*columns 1-7*
forvalues j=1(1)7{
forvalues k=1(1)7{
qui sum female if famsize2==`j' & bord==`k'
local var`j'`k'=r(mean) 
local v`j'`k' =(1-`var`j'`k'')/`var`j'`k''
dis `v`j'`k''
}
}
*columns 1-7*

*average birth order*
tab bord famsize2 
qui sum bord if female==0
local b1=r(mean) 
dis `b1'
qui sum bord if female==1
local b2=r(mean) 
dis `b2'
*average birth order*
***TABLE 3 UPPER PANEL***



***TABLE 3 LOWER PANEL***
keep if MotherAge>34 //age restriction 
*columns 1-7*
forvalues j=1(1)7{
forvalues k=1(1)7{
qui sum female if famsize2==`j' & bord==`k'
local var`j'`k'=r(mean) 
local v`j'`k' =(1-`var`j'`k'')/`var`j'`k''
dis `v`j'`k''
}
}
*columns 1-7*
*average birth order*
qui sum bord if female==0
local b1=r(mean) 
dis `b1'
qui sum bord if female==1
local b2=r(mean) 
dis `b2'
*average birth order*
***TABLE 3 LOWER PANEL***

cap log close
