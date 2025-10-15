* SET UP
* Setting up the working directory

global project "/Users/santiago/Desktop/Masterthesis/Data"

cd "/Users/santiago/Desktop/Masterthesis/Data"

* ENCUESTA DE CALIDAD DE VIDA 2016 (ECV)
* Importing Datasets: 

* Database 1

import delimited "Composicion_2016.csv", clear

keep directorio secuencia_encuesta secuencia_p gender age relationship edu_father edu_mother ethnicity

save "Hogar_composicion_2016.dta", replace


* Database 2
import delimited "Educacion_2016.csv", clear

keep directorio secuencia_encuesta secuencia_p edu_child

duplicates drop directorio secuencia_encuesta secuencia_p , force 

save "Hogar_educacion_2016.dta", replace


* Database 3
import delimited "DatosViv_2016.csv", clear

keep directorio secuencia_encuesta secuencia_p strata region

save "Hogar_datos_2016.dta", replace

* Pooling de los datasets:  

use "Hogar_composicion.dta", clear

duplicates drop directorio secuencia_encuesta, force 

merge  1:1 directorio secuencia_encuesta using "Hogar_educacion.dta"
drop _merge

merge  m:1 directorio using "Hogar_datos.dta"
drop _merge
drop if missing(edu_madre) & missing(edu_padre)
drop if missing(edu_hijo)

sort directorio


