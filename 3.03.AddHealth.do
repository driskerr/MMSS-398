clear

use "C:\Users\kdn136\Downloads\21600-0001-Data.dta" 

local c_date = c(current_date)
display "`c_date'"
local time_string = subinstr("`c_date'", " ", "_", .)
display "`time_string'"

capture log close
log using `time_string'_addhealth.log, replace

* General Racial Characteristics *

/* May want to consider Campbell 2006's two descriptors of mono/multiracial background,
once based on self-identification, and another based on parent-identification (if 
two parents are of different races or one parent is multiracial).

Currently just using self-identification */

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

tab BIO_SEX mismatchAIAN
table BIO_SEX racialcomp_AIAN mismatchAIAN
tab BIO_SEX,  sum(mismatchAIAN) mean freq
tab BIO_SEX racialcomp_AIAN, sum(mismatchAIAN) mean

//AGE
recode H1GI1M (96=.), gen (w1bmonth)
recode H1GI1Y (96=.), gen (w1byear)
gen w1bdate = mdy(w1bmonth, 15,1900+w1byear)
format w1bdate %d
gen w1idate=mdy(IMONTH, IDAY,1900+IYEAR)
format w1idate %d
gen AGE=int((w1idate-w1bdate)/365.25)

tab AGE
tab AGE if anyAIAN==1
tab AGE if bestAIAN==1
tab AGE if mismatchAIAN==1

tab AGE mismatchAIAN
table AGE racialcomp_AIAN mismatchAIAN
tab AGE,  sum(mismatchAIAN) mean freq
tab AGE racialcomp_AIAN, sum(mismatchAIAN) mean


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
label define location 1 "rural" 2 "suburban" 3 "urban" 6 "other"
label values H1IR12 location

recode H1IR12 4/5 = 3

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
/*Crosnoe 2012
H1TO15 (During the past 12 months, on how many days did you drink alcohol?) 
Currently coded from 1 (nearly everyday) to 7 (never)
change to coded from 0 (none) to 6 (everyday)*/

/*O'Connor 1998 
sex at an early age (H1CO1 with H1CO2M, H1CO2Y)
engage in fighting (H1FV5) (H1DS5)
injuring or threatening someone (H1FV7-H1FV8)
use cigarettes (H1TO3)
use alcohol (H1TO15)
use marijuana (H1TO32)

controlling factors (for sex): 
family connectedness
felt parental disapproval of sex (H1PA1, H1PA4 ) or using contraceptives (H1PA3, H1PA6)
felt connected to school
religious (H1RE3 - attend services in past year or H1RE4 - how important is religion to you)
looked younger than peers (H1FP6 | H1MP4 depending on gender)

controlling factors (for violence): 
gun access in home (H1TO53)
recent suicide attempt in family (H1SU6)
victim (H1FV2-H1FV6)/witness (H1FV1) of violence
sell drugs (H1DS12)
carry weapons (H1FV9)
connected to family or connected to school

controlling factors (for substance use): 
cigarettes (H1TO50)/alcohol accessible at home (H1TO51)
family connectedness
school connectedness
religious (H1RE3 - attend services in past year or H1RE4 - how important is religion to you)
high self-esteem
looking older than peers (H1FP6 | H1MP4 depending on gender)  */


/*Hoffman 2008 standardized response categories and combined 13 Add Health items to create
"new variables with higher scores representing greater involvement in delinquient
behavior". Then use natural logarithms of each to normalize distribution.

CONTROLS:
family structure: dummy variables for two bio, single-parent, step family, other
parental attachement: standardized and summed the 5 items in AddHealth (get along with parents, like their parents, are understood by parents, treated fairly by parents, make parents disappointed**REVERSE CODED**)
parental supervision: asked parents how many of their childrens' friends' parents they know
academic performance: GPA in four subjects
academic values: standardized & summed - (importance of good grades, being prepared for class, perception of graduating hs, perception of attending college)
individual: sex, family SES (parent response), race/ethnicity, residential mobility (move in last 4 yrs), hrs worked per week (with quadratic term)
school percieved quality: standardized & summed & aggregated on school level (school fair, teacher care, teacher trust, school function well)
school safety: experience problem at school
*/


//INTEGRATION INTO SOCIAL NETWORKS
/*Crosnoe 2012 refers to this as socioemotional functioning measured by
whether they did not feel socially accepted (H1PF35)
feel loved & wanted (H1PF36)
feel close to people at school (H1ED19)
feel part of things at school (H1ED20)
(H1ED18) trouble getting along with other students (must be recoded from 0 to 4 to 1 to 5)

Averaged scores across the five indicators to create a "Feelings of Ill Fit" Variable

latent variable: how often they felt lonely (H1FS13) */


/*O'Connor 1998 recognizes "school connectedness" as
perception that teachers are fair (H1ED23)
feeling close to people at school (H1ED19)
feeling a part of school (H1ED20) */


/*Callahan 2010 "social connectedness" composite variable of 
"I feel close to people at this school" (H1ED19)
"I feel happy to be at this school" (H1ED22)
"I feel like I am a part of this school" (H1ED20)
then separated into 5 quintiles? or rounded ratings? */


/*Campbell 2006 refers to this as "self-percieved social acceptance"
"I feel socially accepted" (H1PF35)
dummy variable of 1 if strongly agree or agree

& "positive connection to school"
1. mean of responses to "feeling close to people at school" (H1ED19) & "feels a part of school" (H1ED20)
2. dummy variable if respondent participates in any clubs, sports teams or other organized activities (if S44A1-S44A33==1 of S44==0) */




//MENTAL HEALTH
/*O'Connor 1998 - 
emotionally upset or suicidal (H1SU1), 
individual measures of self-esteem, percieved risk of untimely death (H1EE12)

controlling risk factors for suicide: 
sense of family-connectedness, 
family history of suicide (H1SU6)
guns accessible in home (H1TO53) */

/*Campbell 2006 used 
depression (H1FS1 - H1FS19)
seriously considering suicide (H1SU1)
feeling socially accepted (H1PF35)
feeling close to others at school (H1ED19)
participating in extracirricular activities (S44==0)

notes that there are 19 questions modified from the Center for Epidemiologic
Studies Depression Scale (CES-D) - used 18 of CES-D items and a question not
included in the scale "how often you felt life was not worth living?", see
Radolff (1977) on indicating high level of depression

CONTROL VARAIBLES
1. gender, age
2.socioeconomic status
2a. mother education:
2a.1 dummy: hs diploma or some college
2a.2 dummy: college degree of more
2b.ln(household income) constructed by parental response & supplemented by student response
3. calculated school heterogeneity (aka diversity)
4. "students at school are prejudiced" (H1ED21)
5. home context
5a. dummy: "parents get along with student" (PC34A) if always or often
5b. "intact family in the household" - both parents living with adolescent

*/
