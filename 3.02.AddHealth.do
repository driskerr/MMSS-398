clear

use "C:\Users\kdn136\Downloads\21600-0001-Data.dta" 

local c_date = c(current_date)
display "`c_date'"
local time_string = subinstr("`c_date'", " ", "_", .)
display "`time_string'"

capture log close
log using `time_string'_addhealth.log, replace

* General Racial Characteristics *

label define racelabel 1 "white" 2 "black" 3 "AIAN" 4 "Asian" 5 "other" 6 "refused" 7 "legitimate skip" 8 "don't know" 9 "n/a"
label values H1GI8 racelabel
label values H1GI9 racelabel

gen racialcomp=.
replace racialcomp=1 if (H1GI6A==1 & H1GI6B !=1 & H1GI6C!=1 & H1GI6D !=1 & H1GI6E !=1) | (H1GI6A!=1 & H1GI6B==1 & H1GI6C!=1 & H1GI6D !=1 & H1GI6E !=1) | (H1GI6A!=1 & H1GI6B!=1 & H1GI6C==1 & H1GI6D !=1 & H1GI6E !=1) | (H1GI6A!=1 & H1GI6B!=1 & H1GI6C!=1 & H1GI6D==1 & H1GI6E !=1) |  (H1GI6A!=1 & H1GI6B!=1 & H1GI6C!=1 & H1GI6D!=1 & H1GI6E ==1)
replace racialcomp=2 if (H1GI6A==1 & (H1GI6B ==1 | H1GI6C ==1 | H1GI6D ==1 | H1GI6E ==1 )) | (H1GI6B==1 & (H1GI6A ==1 | H1GI6C ==1 | H1GI6D ==1 | H1GI6E ==1 )) | (H1GI6C==1 & (H1GI6A ==1 | H1GI6B ==1 | H1GI6D ==1 | H1GI6E ==1 )) | (H1GI6D==1 & (H1GI6A ==1 | H1GI6B ==1 | H1GI6C ==1 | H1GI6E ==1 )) | (H1GI6E==1 & (H1GI6A ==1 | H1GI6B ==1 | H1GI6C ==1 | H1GI6D ==1 ))
label define racialcomplabel 1 "monoracial" 2 "multiracial"
label values racialcomp racialcomplabel

tab racialcomp

gen bestRace=.
replace bestRace=1 if H1GI8==1
replace bestRace=1 if H1GI6A==1 & H1GI6B !=1 & H1GI6C!=1 & H1GI6D !=1 & H1GI6E !=1
replace bestRace=2 if H1GI8==2
replace bestRace=2 if H1GI6A!=1 & H1GI6B==1 & H1GI6C!=1 & H1GI6D !=1 & H1GI6E !=1
replace bestRace=3 if H1GI8==3
replace bestRace=3 if H1GI6A!=1 & H1GI6B!=1 & H1GI6C==1 & H1GI6D !=1 & H1GI6E !=1
replace bestRace=4 if H1GI8==4
replace bestRace=4 if H1GI6A!=1 & H1GI6B!=1 & H1GI6C!=1 & H1GI6D==1 & H1GI6E !=1
replace bestRace=5 if H1GI8==5
replace bestRace=5 if H1GI6A!=1 & H1GI6B!=1 & H1GI6C!=1 & H1GI6D!=1 & H1GI6E ==1
replace bestRace=6 if H1GI8==6
replace bestRace=8 if H1GI8==8
label values bestRace racelabel

tab bestRace
tab bestRace racialcomp
tab bestRace H1GI9
table racialcomp H1GI9, by(bestRace)

gen mismatch=.
replace mismatch=1 if bestRace!=H1GI9
replace mismatch=0 if bestRace==H1GI9
label define mismatchlabel 0 "match" 1 "mismatch"
label values mismatch mismatchlabel

tab mismatch
table bestRace mismatch racialcomp
tab bestRace racialcomp, sum(mismatch) mean


* AIAN Racial Characteristics *

/* The Add Health Survey includes two racial self-identification questions/varaibles. One allows the respondent to select multiple races (H1GI6A-H1GI6E)by asking "What is your race? You may give more than one answer." However, the other variable only allows the respondent to select one race (H1GI8) by asking "Which one category best describes your racial beackground?"		

Using the first the first question, one can determine if the respondent is single-raced or multiracial. Using the second question, one can determine how the respondent best identifies his or her race. */

gen anyAIAN=.
replace anyAIAN=1 if H1GI6C==1
replace anyAIAN=0 if H1GI6C==0
label define anyAIANlabel 0 "NO AIAN heritage" 1 "AIAN heritage"
label values anyAIAN anyAIANlabel

gen racialcomp_AIAN=.
replace racialcomp_AIAN=1 if H1GI6C==1 & racialcomp==1
replace racialcomp_AIAN=2 if H1GI6C==1 & racialcomp==2
label define racialcomp_AIANlabel 1 "monoracial AIAN" 2 "multiracial AIAN"
label values racialcomp_AIAN racialcomp_AIANlabel

gen bestAIAN=.
replace bestAIAN=1 if bestRace==3
replace bestAIAN=0 if anyAIAN==1 & bestRace!=3
label define bestAIANlabel 0 "AIAN NOT best" 1 "AIAN best"
label values bestAIAN bestAIANlabel

tab racialcomp_AIAN bestAIAN
table H1GI9 racialcomp_AIAN bestAIAN


/* This table reveals that no respondents who have AIAN heritage, but do not best identify as AIAN are misclassified by interviewers as AIAN. Therefore, I will focus my analysis of behaviors associated with misclassification only on the subset of respondents with AIAN heritage who best identify as AIAN.*/



* Mismatch AIAN Identification Flags *

/* I will create a variable (mismatch) to indicate respondents from whom the interviwer's perception of their race (H1GI9) disagreed with the respondent's best description of his or her race as AIAN (bestAIAN).

mismatch = 1 if there is disagreement between respondent & interviewer
mismatch = 0 if there is agreement between respondent & interviewer */

gen mismatchAIAN=.
replace mismatchAIAN=1 if bestAIAN==1 & H1GI9 !=3
replace mismatchAIAN=0 if bestAIAN==1 & H1GI9 ==3
label define mismatchAIANlabel 0 "match AIAN" 1 "mismatch AIAN"
label values mismatchAIAN mismatchAIANlabel

tab H1GI9 mismatchAIAN
table H1GI9 racialcomp_AIAN mismatchAIAN



* Demographic Characteristics *


//GENDER
label define sex 1 "male" 2 "female" 6 "refused"
label values BIO_SEX sex

tab BIO_SEX
tab BIO_SEX if anyAIAN==1
tab BIO_SEX if bestAIAN==1
tab BIO_SEX if mismatchAIAN==1

tab BIO_SEX mismatch
table BIO_SEX racialcomp_AIAN mismatchAIAN
tab BIO_SEX,  sum(mismatchAIAN) mean freq
tab BIO_SEX racialcomp_AIAN, sum(mismatchAIAN) mean

//PARENT QUESTIONNAIRE RESPONDENT RACE
label define parent_race 0 "no AIAN" 1 "AIAN" 6 "refused" 9 "unknown"
label values PA6_3 parent_race

tab PA6_3
tab PA6_3 if anyAIAN==1
tab PA6_3 if bestAIAN==1
tab PA6_3 if mismatchAIAN==1

tab PA6_3 mismatchAIAN
table PA6_3 racialcomp_AIAN mismatchAIAN
tab PA6_3,  sum(mismatchAIAN) mean freq
tab PA6_3 racialcomp_AIAN, sum(mismatchAIAN) mean

/*INTERESTING: Some the students who identify as single-race AIAN, have "parent" respondents who do NOT report any AIAN heritage. Need to look further into who is filling out the parent questionnaire */

label define relationship 1 "bio mom" 2 "step mom" 3 "adopt mom" 4 "foster mom" 5 "grandmom" 6 "aunt" 7 "other female relative" 8 "other female non-relative" 9 "bio dad"
label values PC1 relationship

gen biomotherAIAN=.
replace biomotherAIAN=1 if PC1==1 & PA6_3==1
replace biomotherAIAN=1 if (PC1==9 | PC1==10) & PC2==1 & PB5_3==1
replace biomotherAIAN=0 if PC1==1 & PA6_3!=1
replace biomotherAIAN=0 if (PC1==9 | PC1==10) & PC2==1 & PB5_3!=1
replace biomotherAIAN=9 if PC1!=1 & PC2!=1
label values biomotherAIAN parent_race

gen biofatherAIAN=.
replace biofatherAIAN=1 if PC1==9 & PA6_3==1
replace biofatherAIAN=1 if (PC1==1 | PC1==2) & PC6B==1 & PB5_3==1
replace biofatherAIAN=0 if PC1==9 & PA6_3!=1
replace biofatherAIAN=0 if (PC1==1 | PC1==2) & PC6B==1 & PB5_3!=1
replace biofatherAIAN=9 if PC1!=9 & PC6B!=1
label values biofatherAIAN parent_race

tab biofatherAIAN biomotherAIAN
table anyAIAN biofatherAIAN biomotherAIAN
table racialcomp_AIAN biofatherAIAN biomotherAIAN
table bestAIAN biofatherAIAN biomotherAIAN, by(racialcomp_AIAN)
table mismatchAIAN biofatherAIAN biomotherAIAN, by(racialcomp_AIAN)
table H1GI9 biofatherAIAN biomotherAIAN, by(racialcomp_AIAN)

//LOCATION
label define location 1 "rural" 2 "suburban" 3 "urban, residential only" 4 "3+ commercial property, retail" 5 "3+ commercial property, industrial" 6 "other"
label values H1IR12 location

tab H1IR12 
tab H1IR12  if anyAIAN==1
tab H1IR12  if bestAIAN==1
tab H1IR12  if mismatchAIAN==1

tab H1IR12 mismatchAIAN
table H1IR12 racialcomp_AIAN mismatchAIAN
tab H1IR12,  sum(mismatchAIAN) mean freq
tab H1IR12 racialcomp_AIAN, sum(mismatchAIAN) mean


* Outcome Variables *

//DEVIANT BEHAVIOR

//INTEGRATION INTO SOCIAL NETWORKS

//MENTAL HEALTH
