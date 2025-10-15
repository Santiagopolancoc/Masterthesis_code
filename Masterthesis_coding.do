 (cd "$(git rev-parse --show-toplevel)" && git apply --3way <<'EOF' 
diff --git a/Masterthesis_coding.do b/Masterthesis_coding.do
index 693b09a498233def5229f8e25ee27ddd7e3b70aa..128815f23b1bded2a8032b57af69898cee88244f 100644
--- a/Masterthesis_coding.do
+++ b/Masterthesis_coding.do
@@ -1,56 +1,47 @@
 * SET UP
 * Setting up the working directory
 
 global project "/Users/santiago/Desktop/Masterthesis/Data"
 
 cd "/Users/santiago/Desktop/Masterthesis/Data"
 
 * ENCUESTA DE CALIDAD DE VIDA 2016 (ECV)
-* Importing Datasets: 
-
-* Database 1
+* Importing Datasets:
 
+* Base 1: tabla de personas con las variables demográficas de interés
 import delimited "Composicion_2016.csv", clear
-
 keep directorio secuencia_encuesta secuencia_p gender age relationship edu_father edu_mother ethnicity
-
 save "Hogar_composicion_2016.dta", replace
 
-
-* Database 2
+* Base 2: tabla de personas con información educativa
 import delimited "Educacion_2016.csv", clear
-
 keep directorio secuencia_encuesta secuencia_p edu_child
-
-duplicates drop directorio secuencia_encuesta secuencia_p , force 
-
+duplicates drop directorio secuencia_p secuencia_encuesta, force
 save "Hogar_educacion_2016.dta", replace
 
-
-* Database 3
+* Base 3: tabla de vivienda con las características del hogar
 import delimited "DatosViv_2016.csv", clear
-
 keep directorio secuencia_encuesta secuencia_p strata region
-
+duplicates drop directorio, force
 save "Hogar_datos_2016.dta", replace
 
-* Pooling de los datasets:  
-
-use "Hogar_composicion.dta", clear
-
-duplicates drop directorio secuencia_encuesta, force 
-
-merge  1:1 directorio secuencia_encuesta using "Hogar_educacion.dta"
+* Pooling de los datasets:
+* 1) Combinamos tablas de personas respetando las llaves DIRECTORIO-SECUENCIA_P-SECUENCIA_ENCUESTA
+use "Hogar_composicion_2016.dta", clear
+duplicates drop directorio secuencia_p secuencia_encuesta, force
+merge 1:1 directorio secuencia_p secuencia_encuesta using "Hogar_educacion_2016.dta"
+drop if _merge == 2
 drop _merge
 
-merge  m:1 directorio using "Hogar_datos.dta"
+* 2) Traemos información del hogar (nivel vivienda) usando la llave DIRECTORIO
+merge m:1 directorio using "Hogar_datos_2016.dta"
+drop if _merge == 2
 drop _merge
-drop if missing(edu_madre) & missing(edu_padre)
-drop if missing(edu_hijo)
-
-sort directorio
-npm install -g @openai/codex
-brew install codex
-codex
 
+* 3) Limpieza final
+drop if missing(edu_mother) & missing(edu_father)
+drop if missing(edu_child)
+sort directorio secuencia_p secuencia_encuesta
 
+* La base resultante contiene una observación por persona con la información del hogar asociado
+save "ECV_2016_panel_personas.dta", replace 
EOF
)




