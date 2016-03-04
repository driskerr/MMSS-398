clear

use "C:\Users\kdn136\Downloads\21600-0001-Data.dta" 

label define racelabel 1 "white" 2 "black" 3 "AIAN" 4 "Asian" 5 "other" 6 "refused" 7 "legitimate skip" 8 "don't know" 9 "n/a"

*SELF-ID In-Home Survey*

gen self_home_racialcomp=.
replace self_home_racialcomp=1 if (H1GI6A==1 & H1GI6B !=1 & H1GI6C!=1 & H1GI6D !=1 & H1GI6E !=1) | (H1GI6A!=1 & H1GI6B==1 & H1GI6C!=1 & H1GI6D !=1 & H1GI6E !=1) | (H1GI6A!=1 & H1GI6B!=1 & H1GI6C==1 & H1GI6D !=1 & H1GI6E !=1) | (H1GI6A!=1 & H1GI6B!=1 & H1GI6C!=1 & H1GI6D==1 & H1GI6E !=1) |  (H1GI6A!=1 & H1GI6B!=1 & H1GI6C!=1 & H1GI6D!=1 & H1GI6E ==1)
replace self_home_racialcomp=2 if (H1GI6A==1 & (H1GI6B ==1 | H1GI6C ==1 | H1GI6D ==1 | H1GI6E ==1 )) | (H1GI6B==1 & (H1GI6A ==1 | H1GI6C ==1 | H1GI6D ==1 | H1GI6E ==1 )) | (H1GI6C==1 & (H1GI6A ==1 | H1GI6B ==1 | H1GI6D ==1 | H1GI6E ==1 )) | (H1GI6D==1 & (H1GI6A ==1 | H1GI6B ==1 | H1GI6C ==1 | H1GI6E ==1 )) | (H1GI6E==1 & (H1GI6A ==1 | H1GI6B ==1 | H1GI6C ==1 | H1GI6D ==1 ))
label define racialcomplabel 1 "monoracial" 2 "multiracial"
label values self_home_racialcomp racialcomplabel

tab self_home_racialcomp



*SELF-ID In-School Survey*

gen self_school_racialcomp=.
replace self_school_racialcomp=1 if (S6A==1 & S6B !=1 & S6C!=1 & S6D !=1 & S6E !=1) | (S6A!=1 & S6B==1 & S6C!=1 & S6D !=1 & S6E !=1) | (S6A!=1 & S6B!=1 & S6C==1 & S6D !=1 & S6E !=1) | (S6A!=1 & S6B!=1 & S6C!=1 & S6D==1 & S6E !=1) |  (S6A!=1 & S6B!=1 & S6C!=1 & S6D!=1 & S6E ==1)
replace self_school_racialcomp=2 if (S6A==1 & (S6B ==1 | S6C ==1 | S6D ==1 | S6E ==1 )) | (S6B==1 & (S6A ==1 | S6C ==1 | S6D ==1 | S6E ==1 )) | (S6C==1 & (S6A ==1 | S6B ==1 | S6D ==1 | S6E ==1)) | (S6D==1 & (S6A ==1 | S6B ==1 | S6C ==1 | S6E ==1)) | (S6E==1 & (S6A ==1 | S6B ==1 | S6C ==1 | S6D ==1))
label values self_school_racialcomp racialcomplabel

tab self_school_racialcomp
tab self_school_racialcomp self_home_racialcomp




*Parental Racial Combination*

//ADULT RESPONDENT RACE

/*Respondent self monoracial or multiracial*/
gen adult_respondent_racialcomp=.
replace adult_respondent_racialcomp=1 if (PA6_1==1 & PA6_2 !=1 & PA6_3!=1 & PA6_4 !=1 & PA6_5 !=1) | (PA6_1!=1 & PA6_2==1 & PA6_3!=1 & PA6_4 !=1 & PA6_5 !=1) | (PA6_1!=1 & PA6_2!=1 & PA6_3==1 & PA6_4 !=1 & PA6_5 !=1) | (PA6_1!=1 & PA6_2!=1 & PA6_3!=1 & PA6_4==1 & PA6_5 !=1) |  (PA6_1!=1 & PA6_2!=1 & PA6_3!=1 & PA6_4!=1 & PA6_5 ==1)
replace adult_respondent_racialcomp=2 if (PA6_1==1 & (PA6_2 ==1 | PA6_3 ==1 | PA6_4 ==1 | PA6_5 ==1 )) | (PA6_2==1 & (PA6_1 ==1 | PA6_3 ==1 | PA6_4 ==1 | PA6_5 ==1 )) | (PA6_3==1 & (PA6_1 ==1 | PA6_2 ==1 | PA6_4 ==1 | PA6_5 ==1 )) | (PA6_4==1 & (PA6_1 ==1 | PA6_2 ==1 | PA6_3 ==1 | PA6_5 ==1 )) | (PA6_5==1 & (PA6_1 ==1 | PA6_2 ==1 | PA6_3 ==1 | PA6_4 ==1 ))
label values adult_respondent_racialcomp racialcomplabel

tab adult_respondent_racialcomp

/*Respondent  monoracial race*/

gen adult_respondent_monoRace=.
replace adult_respondent_monoRace=1 if PA6_1==1 & adult_respondent_racialcomp==1
replace adult_respondent_monoRace=2 if PA6_2==1 & adult_respondent_racialcomp==1
replace adult_respondent_monoRace=3 if PA6_3==1 & adult_respondent_racialcomp==1
replace adult_respondent_monoRace=4 if PA6_4==1 & adult_respondent_racialcomp==1
replace adult_respondent_monoRace=5 if PA6_5==1 & adult_respondent_racialcomp==1
label values adult_respondent_monoRace racelabel

tab adult_respondent_monoRace


//RESPONDENT'S PARTNER RACE
/*Partner self monoracial or multiracial*/
gen partner_racialcomp=.
replace partner_racialcomp=1 if (PB5_1==1 & PB5_2 !=1 & PB5_3!=1 & PB5_4 !=1 & PB5_5 !=1) | (PB5_1!=1 & PB5_2==1 & PB5_3!=1 & PB5_4 !=1 & PB5_5 !=1) | (PB5_1!=1 & PB5_2!=1 & PB5_3==1 & PB5_4 !=1 & PB5_5 !=1) | (PB5_1!=1 & PB5_2!=1 & PB5_3!=1 & PB5_4==1 & PB5_5 !=1) |  (PB5_1!=1 & PB5_2!=1 & PB5_3!=1 & PB5_4!=1 & PB5_5 ==1)
replace partner_racialcomp=2 if (PB5_1==1 & (PB5_2 ==1 | PB5_3 ==1 | PB5_4 ==1 | PB5_5 ==1 )) | (PB5_2==1 & (PB5_1 ==1 | PB5_3 ==1 | PB5_4 ==1 | PB5_5 ==1 )) | (PB5_3==1 & (PB5_1 ==1 | PB5_2 ==1 | PB5_4 ==1 | PB5_5 ==1 )) | (PB5_4==1 & (PB5_1 ==1 | PB5_2 ==1 | PB5_3 ==1 | PB5_5 ==1 )) | (PB5_5==1 & (PB5_1 ==1 | PB5_2 ==1 | PB5_3 ==1 | PB5_4 ==1 ))
label values partner_racialcomp racialcomplabel

tab partner_racialcomp


/*Partner monoracial race*/
gen partner_monoRace=.
replace partner_monoRace=1 if PB5_1==1 & partner_racialcomp==1
replace partner_monoRace=2 if PB5_2==1 & partner_racialcomp==1
replace partner_monoRace=3 if PB5_3==1 & partner_racialcomp==1
replace partner_monoRace=4 if PB5_4==1 & partner_racialcomp==1
replace partner_monoRace=5 if PB5_5==1 & partner_racialcomp==1
label values partner_monoRace racelabel

tab partner_monoRace


//BIO PARENTS RACE

/*Mother racial composition*/
gen biomother_racialcomp=.
replace biomother_racialcomp=adult_respondent_racialcomp if PC1==1
replace biomother_racialcomp=partner_racialcomp if PC2==1 & (PC1==9 | PC1==10)

tab biomother_racialcomp

/*Mother mono race*/
gen biomother_monoRace=.
replace biomother_monoRace=adult_respondent_monoRace if PC1==1
replace biomother_monoRace=partner_monoRace if PC2==1 & (PC1==9 | PC1==10)

tab biomother_monoRace

/*Father racial composition*/
gen biofather_racialcomp=.
replace biofather_racialcomp=adult_respondent_racialcomp if PC1==9
replace biofather_racialcomp=partner_racialcomp if PC6B==1 & (PC1==1 | PC1==2)

tab biofather_racialcomp

/*Father mono race*/
gen biofather_monoRace=.
replace biofather_monoRace=adult_respondent_monoRace if PC1==9
replace biofather_monoRace=partner_monoRace if PC6B==1 & (PC1==1 | PC1==2)

tab biofather_monoRace


//CHILD'S RACIAL COMPOSITION
gen parental_racialcombo=.
replace parental_racialcombo=1 if biomother_monoRace=biofather_monoRace
replace parental_racialcombo=2 if biomother_monoRace!=biofather_monoRace
replace parental_racialcombo=2 if biomother_racialcomp==2 | biofather_racialcomp==2
label values parental_racialcombo racialcomplabel

tab parental_racialcombo

tab parental_racialcombo self_home_racialcomp
tab parental_racialcombo self_school_racialcomp
table parental_racialcombo self_home_racialcomp self_school_racialcomp



