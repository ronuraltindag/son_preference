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
log using "TDHS BR-revized Table 2", replace  

use "$root/5prepdata/tdhs BR pooled.dta", clear 

g fgender=1 if b4==2  & bord==1 
replace fgender=0 if b4==1 & bord==1 
bysort mid: egen girl1=max(fgender)
label var girl1 "first-born female" 


tab b4,g(female) 
rename female2 female 
drop female1 
replace b2=1900+b2 if b2<1900
g YoB = b2 
label var YoB "year of birth" 

bysort mid: g i=_n 
bysort mid: g j=_N

g girl_alive=female*b5
g boy_alive=(1-female)*b5
bysort mid: egen nbgirls=sum(girl_alive) 
bysort mid: egen nbboys=sum(boy_alive) 
assert nbliving==nbboys+nbgirls

label variable girl_alive "female child & alive" 
label variable boy_alive "male child & alive" 
label variable nbgirls "number of girls alive" 
label variable nbboys  "number of boys alive" 
label variable nbliving "number of children alive" 

g       famsize1=nbliving if nbliving<5 
replace famsize1=5 if nbliving>4 

label variable famsize1 "number of children alive censored at 5" 

#delimit ; 
label define famsize1
0 "no children alive" 
1 "one child" 
2 "two children"
3 "three children" 
4 "four children" 
5 "five or more children";

#delimit cr 

label val famsize1 famsize1 
g lfamily=(nbliving>3) 
label variable lfamily "large family, nb children>3"

label variable wave "DHS wave" 
label define wave 1 "DHS 1993" 2 "DHS 1998" 3 "DHS 2003" 4 "DHS 2008" 
label val wave wave 

label var i "==1 when the analysis is at mother level" 
label variable totalborn "number of births"  

g MotherAge=v012 
label var MotherAge "Current Age of Mother" 

g       famsize2=1 if j==1 
replace famsize2=2 if j==2 
replace famsize2=3 if j==3 
replace famsize2=4 if j==4 
replace famsize2=5 if j==5 
replace famsize2=6 if j==6
replace famsize2=7 if j>=7

label var famsize2 "number of births- censored at 7" 

#delimit ; 
label define famsize2
1 "single birth" 
2 "two births" 
3 "three births"
4 "four births" 
5 "five births" 
6 "six births"
7 "seven or more births";
#delimit cr 

label val famsize2 famsize2 

label variable female "child's sex - female ==1" 
label variable bord "child's birth order" 
label variable mid "unique mother id" 

tab region, g(reg) 
g ChildAlive=(b5==1) 
g FChildAlive=1 if ChildAlive==1 & bord==1 

g Singleton=(b0==0) 

g sgender=1 if b4==2 & bord==2 
replace sgender=0 if b4==1 & bord==2
bysort mid: egen girl2=max(sgender)

g tgender=1 if b4==2 & bord==3 
replace tgender=0 if b4==1 & bord==3 
bysort mid: egen girl3=max(tgender)

g qgender=1 if b4==2 & bord==4 
replace qgender=0 if b4==1 & bord==4 
bysort mid: egen girl4=max(qgender)

replace v007 = 1900 + v007 if v007<1900
g AgeinMonths = (v007-b2)*12 + v006-b1

g AgeAtDeath = b7 

g 		bcg=0 if h2==0 
replace bcg=1 if h2==1 | h2==2 | h2==3

g       dpt=0 if h3==0
replace dpt=1 if h3==1 | h3==2 | h3==3

g       polio=0 if h4==0
replace polio=1 if h4==1 | h4==2 | h4==3

g       measles=0 if h9==0
replace measles=1 if h9==1 | h9==2 | h9==3

label var ChildAlive "Child is still Alive ==1"
label var FChildAlive "First Child is still Alive ==1" 
label var Singleton "Birth is singleton" 
label var firstbirthage "Mother's Age at First Birth" 
label var rural "Family lives in Rural Areas"
label var extfamily "Patrilocal residency" 
label var nonturkish "Mother is Non-Turkish ==1" 
label var hage "Husband's Age" 
label var arranged "Marriage is arranged ==1" 
label var dowry "bride money paid to wive's family at marriage ==1" 
label var girl1 "First-born Female ==1" 
label var girl2 "Second-born Female ==1" 
label var girl3 "Third-born Female ==1" 
label var girl4 "Fourth-born Female ==1" 
label var nbpregnancies "Total of number of pregnancies"
label var ccontraceptive "currently using contraceptive ==1" 
label var abort1 "ever had pregnancy termination ==1" 
label var AgeinMonths "Child's age in months" 
label var AgeAtDeath "Child's age at death in months" 
label var bcg "bcg vaccination ==1" 
label var dpt "pdt vaccination ==1" 
label var polio "polio vaccination ==1" 
label var measles "measles vaccination ==1" 


keep nbboys nbgirls nbliving famsize1 famsize2 lfamily girl_alive boy_alive totalborn i wave MotherAge female bord mid ///
firstbirthage yearseduc nonturkish  reg1 reg2 reg3 reg4 reg5 rural hage hyearseduc extfamily arranged dowry ///
Singleton ChildAlive FChildAlive girl1 girl2 girl3 girl4 nbpregnancies ccontraceptive abort1 region AgeinMonths AgeAtDeath ///
hw5 hw8 educat heducat bcg dpt polio measles 



save "replication.dta", replace 


