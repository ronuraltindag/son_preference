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
log using "$root/3analysis/do files/final revision/logfiles/Table 2.log", replace  

use "replication.dta", clear 

***TABLE 2 UPPER PANEL*** 
*columns 1-4 & and family size={1,2,3,4}* 
forvalues j=1(1)4{
forvalues k=1(1)4{
quietly sum nbboys if wave==`j' & famsize1==`k' & bord==1
local b`j'`k'=r(mean) 
quietly sum nbgirls if wave==`j' & famsize1==`k' & bord==1
local g`j'`k'=r(mean) 
local var`j'`k'=`b`j'`k''/`g`j'`k''
dis `var`j'`k''
}
} 
*columns 1-4 & and family size={1,2,3,4}*

*column 5 & family size={1,2,3,4}* 
forvalues k=1(1)4{
quietly sum nbboys if famsize1==`k' & bord==1
local b`k'=r(mean) 
quietly sum nbgirls if famsize1==`k' & bord==1
local g`k'=r(mean) 
local var`k'=`b`k''/`g`k''
dis `var`k''
}
*column 5 & family size={1,2,3,4}*

*columns 1-4 & family size={5 and over}*
forvalues j=1(1)4{
qui tab girl_alive if wave==`j' & nbliving>4 & girl_alive==1
local ng`j'=r(N)
qui tab boy_alive  if wave==`j' & nbliving>4 & boy_alive==1 
local nb`j'=r(N)
local var`j'=`nb`j''/`ng`j''
dis `var`j''
}
*columns 1-4 & family size={5 and over}*

*column 5 & family size={5 and over}*
qui tab girl_alive if nbliving>4 & girl_alive==1
local ng=r(N)
qui tab boy_alive  if  nbliving>4 & boy_alive==1 
local nb=r(N)
local var=`nb'/`ng'
dis `var'
*column 5 & family size={5 and over}*




*columns 1-4 & overall* 
forvalues j=1(1)4{
quietly sum nbboys if wave==`j' &  bord==1
local b`j'=r(mean) 
quietly sum nbgirls if wave==`j' & bord==1
local g`j'=r(mean) 
local var`j'=`b`j'`k''/`g`j'`k''
dis `var`j''
}
*columns 1-4 & overall* 

*column 5 & overall* 
quietly sum nbboys if  bord==1
local b=r(mean) 
quietly sum nbgirls if bord==1
local g=r(mean) 
local var=`b'/`g'
dis `var'
*column 5 & overall* 

*columns 1-5 & nb ever born and nb still alive* 
forvalues j=1(1)4{
quietly sum totalborn if wave==`j' &  bord==1
local n2`j'=r(mean)
dis `n2`j''
}

quietly sum totalborn if bord==1
local n2=r(mean)
dis `n2'

forvalues j=1(1)4{
quietly sum nbliving if wave==`j' &  bord==1
local n1`j'=r(mean) 
dis  `n1`j'' 
}

quietly sum nbliving if bord==1
local n1=r(mean) 
dis `n1'
*columns 1-5 & nb ever born and nb still alive* 

*columns 1-5 & number of observations* 
tab wave if bord==1
*columns 1-5 & number of observations* 
***TABLE 2 UPPER PANEL*** 

***TABLE 2 LOWER PANEL*** 

keep if MotherAge>34 //Age restriction 


*column 1 & family size={1,2,3,4}* 
forvalues k=1(1)4{
quietly sum nbboys if famsize1==`k' & bord==1
local b`k'=r(mean) 
quietly sum nbgirls if famsize1==`k' & bord==1
local g`k'=r(mean) 
local var`k'=`b`k''/`g`k''
dis `var`k''
}
*column 1 & family size={1,2,3,4}* 

*column 1 & family size={5 and over}*
qui tab girl_alive if nbliving>4 & girl_alive==1
local ng=r(N)
qui tab boy_alive  if  nbliving>4 & boy_alive==1 
local nb=r(N)
local var=`nb'/`ng'
dis `var'
*column 1 & family size={5 and over}*

*column 1 & overall*
quietly sum nbboys if bord==1
local b=r(mean) 
quietly sum nbgirls if bord==1
local g=r(mean)
local var=`b'/`g'
dis `var'
*column 1 & overall*

*column 2 & number of observations*
tab famsize1 if bord==1 & nbliving>0
*column 2 & number of observations*


*column 5 & fsize=small*
qui tab girl_alive if nbliving<4 & girl_alive==1
local ng=r(N)
qui tab boy_alive  if  nbliving<4 & boy_alive==1 
local nb=r(N)
local var=`nb'/`ng'
dis `var'
*column 5 & fsize=small*

*column 5 & fsize=large*
qui tab girl_alive if nbliving>3 & girl_alive==1
local ng=r(N)
qui tab boy_alive  if  nbliving>3 & boy_alive==1 
local nb=r(N)
local var=`nb'/`ng'
dis `var'
*column 5 & fsize=large*

*column 5 & overall*
qui tab girl_alive if  girl_alive==1
local ng=r(N)
qui tab boy_alive  if  boy_alive==1 
local nb=r(N)
local var=`nb'/`ng'
dis `var'
*column 5 & overall*

cap log close
