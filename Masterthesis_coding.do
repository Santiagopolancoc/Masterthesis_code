
 * SET UP
 * Setting up the working directory
 
 global project "/Users/santiago/Desktop/Masterthesis/Data"
 
 cd "/Users/santiago/Desktop/Masterthesis/Data"
 
 * ENCUESTA NACIONAL DE CALIDAD DE VIDA 2016 (ECV)
* Importing Datasets 
* Database 1
 import delimited "Composicion_2016.csv", clear
 keep directorio secuencia_encuesta secuencia_p gender age relationship edu_father edu_mother ethnicity
 save "Hogar_composicion_2016.dta", replace
 
* Database 2
 import delimited "Educacion_2016.csv", clear

duplicates drop directorio secuencia_p secuencia_encuesta, force
 save "Hogar_educacion_2016.dta", replace
 
* Database 3
 import delimited "DatosViv_2016.csv", clear
 
 keep directorio secuencia_encuesta secuencia_p strata region

duplicates drop directorio, force
 save "Hogar_datos_2016.dta", replace

* Pooling of the datasets
* 1) Pooling using the variables (keys) DIRECTORIO-SECUENCIA_P-SECUENCIA_ENCUESTA
use "Hogar_composicion_2016.dta", clear
duplicates drop directorio secuencia_p secuencia_encuesta, force
merge 1:1 directorio secuencia_p secuencia_encuesta using "Hogar_educacion_2016.dta"
drop if _merge == 2
drop _merge

merge m:1 directorio using "Hogar_datos_2016.dta"
drop if _merge == 2
 drop _merge

drop if missing(edu_mother) & missing(edu_father)
drop if missing(edu_child)
sort directorio secuencia_p secuencia_encuesta
 
* Preparation of the variables 
* Ensure that ordinal variables are stored as numeric
foreach var in edu_child edu_mother strata {
    capture confirm numeric variable `var'
    if _rc {
        capture destring `var', replace ignore(" ")
        if _rc {
            encode `var', gen(_tmp_`var')
            drop `var'
            rename _tmp_`var' `var'
        }
    }
}
* Clean potential text used for missing values in education variables
foreach var of varlist edu_child edu_mother {
    replace `var' = . if inlist(`var', 99, 999)
}

* Ensure that nominal variables are stored as numeric
foreach var in gender ethnicity region age {
    capture confirm numeric variable `var'
    if _rc {
        capture destring `var', replace ignore(" ")
        if _rc {
            encode `var', gen(_tmp_`var')
            drop `var'
            rename _tmp_`var' `var'
        }
    }
}

* Confirm numeric storage for regression variables
foreach var in edu_child edu_mother age gender ethnicity region strata {
    confirm numeric variable `var'
}

* Pooled dataset 
save "ECV_2016.dta", replace 
use "ECV_2016.dta", clear 

* Proxy for the education of the children in years of education 
gen edu_years_child = .
gen edu_years_child = 0 if edu_child == 1
replace edu_years_child = 5 if edu_child == 2
replace edu_years_child = 10 if edu_child == 3
replace edu_years_child = 14 if edu_child == 4
replace edu_years_child = 17 if edu_child == 5
replace edu_years_child = 18 if edu_child == 6
replace edu_years_child = 19 if edu_child == 7
replace edu_years_child = 20 if edu_child == 8
replace edu_years_child = 21 if edu_child == 9
replace edu_years_child = 22 if edu_child == 10
replace edu_years_child = 23 if edu_child == 11
replace edu_years_child = 24 if edu_child == 12
replace edu_years_child = 26 if edu_child == 13
label var edu_years_child "Proxy: years of education (child)"

* Proxy for the education of the mother in years of education  
gen edu_years_mother = 7 if edu_mother == 1
replace edu_years_mother = 10    if edu_mother == 2
replace edu_years_mother = 12 if edu_mother == 3
replace edu_years_mother = 16 if edu_mother == 4
replace edu_years_mother = 18 if edu_mother == 5
replace edu_years_mother = 19 if edu_mother == 6
replace edu_years_mother = 20 if edu_mother == 7
replace edu_years_mother = 21 if edu_mother == 8
replace edu_years_mother = 0 if edu_mother == 9
replace edu_years_mother = . if edu_mother == 10
label var edu_years_mother "Proxy: years of education (mother)"

* Label nominal variables according to survey documentation
capture label drop gender_lbl
label define gender_lbl 1 "Hombre" 2 "Mujer"
label values gender gender_lbl
label var gender "Gender"

capture label drop ethnicity_lbl
label define ethnicity_lbl 1 "Indígena" 2 "Gitano" 3 "Raizal" 4 "Palenquero" 5 "Negro o mulato" 6 "Ninguno de los anteriores"
label values ethnicity ethnicity_lbl
label var ethnicity "Ethnicity"

capture label drop region_lbl
label define region_lbl 1 "Atlántica" 2 "Oriental" 3 "Central" 4 "Pacífica" 5 "Bogotá" 6 "Antioquia" 7 "Valle del Cauca" 8 "San Andrés" 9 "Orinoquía"
label values region region_lbl
label var region "Region"

* Label strata as an ordered categorical variable
capture label drop strata_lbl
label define strata_lbl 1 "Bajo-bajo" 2 "Bajo" 3 "Medio-bajo" 4 "Medio" 5 "Medio-alto" 6 "Alto"
label values strata strata_lbl
label var strata "Household stratum"

* Determination of cohorts 

gen cohort = "Cohort 1" if age > 24 & age < 40 
replace cohort = "Cohort 2" if age > 39 & age < 55 
replace cohort = "Cohort 3" if age > 54 & age < 66
 
tabulate cohort, gen(cat_cohort)

* ECONOMETRIC ANALYSIS 




