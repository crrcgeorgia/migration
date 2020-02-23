clear

cd "D:\Rati\Blog\Blog 18\data"

use CB2019_Georgia_response_30Jan2020.dta

******************* DV   *******************
/// EMIGRAT (If you had a chance, would you leave forever to live somewhere else?) => permanent
/// MIGSHRT ( Would you leave for a certain period of time to live somewhere else?) => temporary 

gen permanent = EMIGRAT
recode permanent (-2/-1 = 0) 

gen temporary = MIGSHRT
recode temporary (-2/-1 = 0) 

*************************************** IV   ****************************************

/// demographic vars: sett, age, gender, education, havejob, minority, internet

/// reported language knowleadge: language

/// close relative living abroad: relative_abroad

//// wealth index : ownearship of houshold items 


/// =================================================================================
/// recoding demographic variables 
/// =================================================================================

/// STRATUM
gen sett = STRATUM

/// RESPAGE
gen age = RESPAGE

/// gender
/// recoding Female from 2 to 0
gen gender = RESPSEX
recode gender (2=0) /// female = 0 

//// RESPEDU  => education 
/*  1 = secondary or lower 2 = secodanry technical 3 = higher */
gen education = RESPEDU
recode education (1/4 = 1) (5 = 2) (6/8 = 3) (-9 / -1 = .)

//// EMPLSIT => havejob 
/* 1 = empl 0 = no */
gen havejob = EMPLSIT
recode havejob (5/6 = 1) (1/4 = 0) (7/8 = 0) (-9 / -1 = . )

///  ETHNIC -- Ethnicity of the respondent  => minority
/* 0 = Georgian   1 = Non-Georgian   */
gen minority = ETHNIC
recode minority (4 / 7 = 1)  (3 =0) (2=1) (1=1) (-9 / -1 = .)

///// Internet exposure FRQINTR => internet
/* 1 = Every day 2 = Less often 3 = Never	 */
gen internet = FRQINTR
recode internet (1=1) (2/4 =2) (5/6 = 3) (-9 / -1 = .)


//// Wealth Index => utility
foreach var of varlist OWNCOTV OWNDIGC OWNWASH OWNFRDG OWNAIRC OWNCARS OWNCELL OWNCOMP {
gen `var'r = `var' 
}

foreach var of varlist OWNCOTVr OWNDIGCr OWNWASHr OWNFRDGr OWNAIRCr OWNCARSr OWNCELLr OWNCOMPr {
recode `var' (-9 / -1 = .)
}

gen utility = (OWNCOTVr + OWNDIGCr + OWNWASHr + OWNFRDGr + OWNAIRCr + OWNCARSr + OWNCELLr + OWNCOMPr)

/// =================================================================================
/// reported language knowleadge
/// =================================================================================
/// dummy of knowleadge at least one foreign langauge above Beginner (KNOWRUS KNOWENG KNOWOTH)
gen language = 0

replace language = 1 if KNOWRUS > 2 | KNOWENG  > 2 | KNOWOTH  > 2

/// =================================================================================
/// close relative living abroad  
/// =================================================================================
/// CLRLABR > relative_abroad
gen relative_abroad = CLRLABR
recode relative_abroad (-2/-1 = 0) 



//// Weighting

svyset PSU [pweight=INDWT], strata(SUBSTRATUM) fpc(NPSUSS) singleunit(certainty) || ID, fpc(NHHPSU) || _n, fpc(NADHH)


/// ============================================================================================================================
/// Base demo Model 1 for permanent: i.sett age gender i.education havejob minority i.internet language relative_abroad utility
/// ============================================================================================================================
svy: logit  permanent i.sett age gender i.education havejob minority i.internet language relative_abroad utility
margins, dydx(*) post
marginsplot, horizontal xline(0) yscale(reverse) recast(scatter)

svy: logit  permanent i.sett age gender i.education havejob minority i.internet language relative_abroad utility
margins, at(sett=(1 2 3 ))
marginsplot

svy: logit  permanent i.sett age gender i.education havejob minority i.internet language relative_abroad utility
margins, at(age=(20 40 60  ))
marginsplot

svy: logit  permanent i.sett age gender i.education havejob minority i.internet language relative_abroad utility
margins, at(minority=(0 1))
marginsplot

svy: logit  permanent i.sett age gender i.education havejob minority i.internet language relative_abroad utility
margins, at(utility=(1 2 3 4 5 6 7 8))
marginsplot


/// ============================================================================================================================
/// Base demo Model 2 for temporary: i.sett age gender i.education havejob minority i.internet language relative_abroad utility
/// ============================================================================================================================

svy: logit  temporary i.sett age gender i.education havejob minority i.internet language relative_abroad utility
margins, dydx(*) post
marginsplot, horizontal xline(0) yscale(reverse) recast(scatter)


svy: logit  temporary i.sett age gender i.education havejob minority i.internet language relative_abroad utility
margins, at(education=(1 2 3 ))
marginsplot

svy: logit  temporary i.sett age gender i.education havejob minority i.internet language relative_abroad utility
margins, at(age=(20 40 60  ))
marginsplot

svy: logit  temporary i.sett age gender i.education havejob minority i.internet language relative_abroad utility
margins, at(gender=(0 1))
marginsplot

svy: logit  temporary i.sett age gender i.education havejob minority i.internet language relative_abroad utility
margins, at(internet =( 1 2 3))
marginsplot

svy: logit  temporary i.sett age gender i.education havejob minority i.internet language relative_abroad utility
margins, at(relative_abroad =( 0 1 ))
marginsplot