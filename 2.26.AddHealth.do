clear

use "C:\Users\kdn136\Downloads\21600-0001-Data.dta" 

local c_date = c(current_date)
display "`c_date'"
local time_string = subinstr("`c_date'", " ", "_", .)
display "`time_string'"

capture log close
log using `time_string'_addhealth.log, replace

* Racial Characteristics *

/* The Add Health Survey includes two racial self-identification questions/varaibles. One allows the respondent to select multiple races (H1GI6A-H1GI6E) by asking "What is your race? You may give more than one answer." However, the other variable only allows the respondent to select one race (H1GI8) by asking "Which one category best describes your racial beackground?"

Using the first question, one can determine if the respondent is single-raced or multiracial. Using the second question, one can determine how the respondent best identifies his or her race. */

gen anyAIAN=.
replace anyAIAN=1 if H1GI6C==1
replace anyAIAN=0 if H1GI6C==0
label define anyAIANlabel 0 "NO AIAN heritage" 1 "AIAN heritage"
label values anyAIAN anyAIANlabel

gen racialcomp_AIAN=.
replace racialcomp_AIAN=1 if H1GI6C==1 & H1GI6A !=1 & H1GI6B !=1 & H1GI6D !=1 & H1GI6E !=1
replace racialcomp_AIAN=2 if H1GI6C==1 & (H1GI6A ==1 | H1GI6B ==1 | H1GI6D ==1 | H1GI6E ==1 )
label define racialcomplabel 1 "single race AIAN" 2 "multiracial AIAN"
label values racialcomp_AIAN racialcomplabel

gen bestAIAN=.
replace bestAIAN=1 if H1GI8==3
replace bestAIAN=1 if racialcomp_AIAN==1
replace bestAIAN=0 if anyAIAN==1 & H1GI8!=3 & racialcomp_AIAN!=1
label define bestAIANlabel 0 "AIAN NOT best" 1 "AIAN best"
label values bestAIAN bestAIANlabel

label define race 1 "white" 2 "black" 3 "AIAN" 4 "Asian" 5 "other" 6 "refused" 8 "don't know"
label values H1GI9 race

tab racialcomp_AIAN bestAIAN
table H1GI9 racialcomp_AIAN bestAIAN


/* This table reveals that no respondents who have AIAN heritage, but do not best identify as AIAN are misclassified by interviewers as AIAN. Therefore, I will focus my analysis of behaviors associated with misclassification only on the subset of respondents with AIAN heritage who best identify as AIAN.*/


* Mismatch AIAN Identification Flags *

/* I will create a variable (mismatch) to indicate respondents from whom the interviwer's perception of their race (H1GI9) disagreed with the respondent's best description of his or her race as AIAN (bestAIAN).

mismatch = 1 if there is disagreement between respondent & interviewer
mismatch = 0 if there is agreement between respondent & interviewer */

gen mismatch=.
replace mismatch=1 if bestAIAN==1 & H1GI9 !=3
replace mismatch=0 if bestAIAN==1 & H1GI9 ==3
label define mismatchlabel 0 "match" 1 "mismatch"
label values mismatch mismatchlabel

tab H1GI9 mismatch
table H1GI9 racialcomp_AIAN mismatch



* Demographic Characteristics *


//GENDER
label define sex 1 "male" 2 "female"
label values BIO_SEX sex

tab BIO_SEX mismatch
table BIO_SEX racialcomp_AIAN mismatch
tab BIO_SEX,  sum(mismatch) mean freq
tab BIO_SEX racialcomp_AIAN, sum(mismatch) mean

//PARENT RACE
label define parent_race 0 "no AIAN" 1 "AIAN"
label values PA6_3 parent_race

tab PA6_3 mismatch
table PA6_3 racialcomp_AIAN mismatch
tab PA6_3,  sum(mismatch) mean freq
tab PA6_3 racialcomp_AIAN, sum(mismatch) mean

/*INTERESTING: Some the students who identify as single-race AIAN, have "parent" respondents who do NOT report any AIAN heritage. Need to look further into who is filling out the parent questionnaire */

//LOCATION
label define location 1 "rural" 2 "suburban" 3 "urban, residential only" 4 "3+ commercial property, retail" 5 "3+ commercial property, industrial" 6 "other"
label values H1IR12 location

tab H1IR12 mismatch
table H1IR12 racialcomp_AIAN mismatch
tab H1IR12,  sum(mismatch) mean freq
tab H1IR12 racialcomp_AIAN, sum(mismatch) mean
