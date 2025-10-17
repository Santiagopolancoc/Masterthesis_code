
 * SET UP
 * Setting up the working directory
 
 global project "/Users/santiago/Desktop/Masterthesis/Data"
 
 cd "/Users/santiago/Desktop/Masterthesis/Data"
 
 * ENCUESTA DE CALIDAD DE VIDA 2016 (ECV)
* Importing Datasets: 
* Database 1
* Importing Datasets:
 
* Base 1: tabla de personas con las variables demográficas de interés
 import delimited "Composicion_2016.csv", clear
 keep directorio secuencia_encuesta secuencia_p gender age relationship edu_father edu_mother ethnicity
 save "Hogar_composicion_2016.dta", replace
 
* Database 2
* Base 2: tabla de personas con información educativa
 import delimited "Educacion_2016.csv", clear

duplicates drop directorio secuencia_p secuencia_encuesta, force
 save "Hogar_educacion_2016.dta", replace
 

* Base 3: tabla de vivienda con las características del hogar
 import delimited "DatosViv_2016.csv", clear
 
 keep directorio secuencia_encuesta secuencia_p strata region

duplicates drop directorio, force
 save "Hogar_datos_2016.dta", replace

* Pooling de los datasets:
* 1) Combinamos tablas de personas respetando las llaves DIRECTORIO-SECUENCIA_P-SECUENCIA_ENCUESTA
use "Hogar_composicion_2016.dta", clear
duplicates drop directorio secuencia_p secuencia_encuesta, force
merge 1:1 directorio secuencia_p secuencia_encuesta using "Hogar_educacion_2016.dta"
drop if _merge == 2
drop _merge
 
* 2) Traemos información del hogar (nivel vivienda) usando la llave DIRECTORIO
merge m:1 directorio using "Hogar_datos_2016.dta"
drop if _merge == 2
 drop _merge

* 3) Limpieza final
drop if missing(edu_mother) & missing(edu_father)
drop if missing(edu_child)
sort directorio secuencia_p secuencia_encuesta
 
* La base resultante contiene una observación por persona con la información del hogar asociado
save "ECV_2016.dta", replace 

* Preparation of the variables 

* Proxy for the education of the children in years of education 
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

* Generacion de Cohortes y Proxys 

gen cohort = "Cohort 1" if age > 24 & age < 40 
replace cohort = "Cohort 2" if age > 39 & age < 55 
replace cohort = "Cohort 3" if age > 54 & age < 66
 
tabulate cohort, gen(cat_cohort)




