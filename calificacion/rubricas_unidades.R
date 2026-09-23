# Rubricas para las entregas por unidad. Solo requiere R base.
# Cada validador devuelve comprobaciones automaticas; interpretacion y codigo
# se califican manualmente (30 puntos).

resultado <- function(nombre, aprobado, puntos, detalle) {
  list(nombre = nombre, aprobado = isTRUE(aprobado), puntos = puntos,
       obtenido = if (isTRUE(aprobado)) puntos else 0, detalle = detalle)
}

es_numerico <- function(x, minimo = 1L) is.numeric(x) && length(x) >= minimo && all(is.finite(x))
es_escalar <- function(x, inferior = -Inf, superior = Inf) {
  es_numerico(x) && length(x) == 1L && x >= inferior && x <= superior
}
objeto <- function(env, nombre) if (exists(nombre, envir = env, inherits = FALSE)) get(nombre, envir = env) else NULL
chequeo <- function(nombre, condicion, puntos, detalle) resultado(nombre, condicion, puntos, detalle)
marcadores_base <- c("## Instrucciones de entrega", "## Ejercicio 1", "## Ejercicio 2", "## Ejercicio 3", "## Declaracion")
categorias_estandar <- list(estructura_automatica = 10, objetos_y_validacion_automatica = 60,
                            revision_manual_razonamiento_interpretacion_codigo = 30)

validar_unidad_01 <- function(e) list(
  chequeo("posterior_muestras", es_numerico(objeto(e,"posterior_muestras"), 5000), 20, "Se requieren al menos 5000 muestras posteriores finitas."),
  chequeo("media_posterior", es_escalar(objeto(e,"media_posterior"), 0, 1), 15, "Debe ser un escalar finito entre 0 y 1."),
  chequeo("intervalo_credible", {x <- objeto(e,"intervalo_credible"); es_numerico(x,2) && length(x)==2 && x[1]<x[2]}, 15, "Debe tener dos limites finitos y ordenados."),
  chequeo("coherencia", {x<-objeto(e,"posterior_muestras"); m<-objeto(e,"media_posterior"); es_numerico(x,1) && es_escalar(m,0,1) && abs(mean(x)-m)<0.1}, 10, "La media debe ser coherente con las muestras (tolerancia 0.1)."))
validar_unidad_02 <- function(e) list(
  chequeo("grilla_posterior", es_numerico(objeto(e,"grilla_posterior"),20),20,"Se requieren al menos 20 pesos finitos."),
  chequeo("integral_aproximada", es_escalar(objeto(e,"integral_aproximada"),0,Inf),15,"Debe ser un escalar positivo."),
  chequeo("cuantiles_posteriores", {x<-objeto(e,"cuantiles_posteriores");es_numerico(x,2)&&length(x)==2&&x[1]<x[2]},15,"Deben ser dos cuantiles ordenados."),
  chequeo("pesos_validos", {x<-objeto(e,"grilla_posterior");es_numerico(x,20)&&all(x>=0)},10,"Los pesos de la grilla no deben ser negativos."))
validar_unidad_03 <- function(e) list(
  chequeo("estimaciones_mc",es_numerico(objeto(e,"estimaciones_mc"),100),20,"Se requieren al menos 100 simulaciones finitas."),
  chequeo("estimacion_mc",es_escalar(objeto(e,"estimacion_mc")),15,"Debe ser un escalar finito."),
  chequeo("error_estandar",es_escalar(objeto(e,"error_estandar"),0,Inf),15,"Debe ser un escalar no negativo."),
  chequeo("coherencia",{x<-objeto(e,"estimaciones_mc");m<-objeto(e,"estimacion_mc");es_numerico(x,100)&&es_escalar(m)&&abs(mean(x)-m)<0.1*max(1,abs(m))},10,"La estimacion debe ser coherente con el promedio simulado."))
validar_unidad_04 <- function(e) list(
  chequeo("cadena_mcmc",es_numerico(objeto(e,"cadena_mcmc"),200),20,"Se requieren al menos 200 estados finitos."),
  chequeo("media_cadena",es_escalar(objeto(e,"media_cadena")),15,"Debe ser un escalar finito."),
  chequeo("autocorrelacion_lag1",es_escalar(objeto(e,"autocorrelacion_lag1"),-1,1),15,"Debe estar entre -1 y 1."),
  chequeo("coherencia",{x<-objeto(e,"cadena_mcmc");m<-objeto(e,"media_cadena");es_numerico(x,200)&&es_escalar(m)&&abs(mean(x)-m)<0.1*max(1,abs(m))},10,"La media debe coincidir aproximadamente con la cadena."))
validar_unidad_05 <- function(e) list(
  chequeo("cadena_mh",es_numerico(objeto(e,"cadena_mh"),500),20,"Se requieren al menos 500 iteraciones finitas."),
  chequeo("tasa_aceptacion",es_escalar(objeto(e,"tasa_aceptacion"),.Machine$double.eps,1-.Machine$double.eps),15,"Debe estar estrictamente entre 0 y 1."),
  chequeo("propuesta_sd",es_escalar(objeto(e,"propuesta_sd"),.Machine$double.eps,Inf),15,"La desviacion de propuesta debe ser positiva."),
  chequeo("variacion_cadena",{x<-objeto(e,"cadena_mh");es_numerico(x,500)&&length(unique(x))>1},10,"La cadena debe contener mas de un estado distinto."))
validar_unidad_06 <- function(e) list(
  chequeo("cadena_gibbs",{x<-objeto(e,"cadena_gibbs");(is.matrix(x)||is.data.frame(x))&&nrow(x)>=200&&ncol(x)>=2&&all(is.finite(as.matrix(x)))},20,"Se requieren 200 filas, dos columnas y valores finitos."),
  chequeo("medias_gibbs",es_numerico(objeto(e,"medias_gibbs"),2),15,"Se requieren al menos dos medias finitas."),
  chequeo("correlacion_gibbs",es_escalar(objeto(e,"correlacion_gibbs"),-1,1),15,"Debe estar entre -1 y 1."),
  chequeo("coherencia",{x<-objeto(e,"cadena_gibbs");m<-objeto(e,"medias_gibbs");is.matrix(x)&&es_numerico(m,2)&&all(abs(colMeans(x)[1:2]-m[1:2])<0.1* pmax(1,abs(m[1:2])))},10,"Las medias deben ser coherentes con las dos columnas."))
validar_unidad_07 <- function(e) list(
  chequeo("rhat_valor",es_escalar(objeto(e,"rhat_valor"),1,1.1),20,"R-hat debe estar entre 1 y 1.1."),
  chequeo("ess_valor",es_escalar(objeto(e,"ess_valor"),.Machine$double.eps,Inf),15,"ESS debe ser positivo."),
  chequeo("diagnosticos_mcmc",{x<-objeto(e,"diagnosticos_mcmc");is.data.frame(x)&&nrow(x)>=1},15,"Se requiere una tabla con al menos una fila."),
  chequeo("diagnosticos_nombrados",{x<-objeto(e,"diagnosticos_mcmc");is.data.frame(x)&&length(names(x))>0},10,"La tabla debe tener columnas nombradas."))
validar_unidad_08 <- function(e) list(
  chequeo("ajuste_stan",{x<-objeto(e,"ajuste_stan");is.list(x)||is.character(x)||is.data.frame(x)},20,"Se requiere un ajuste o representacion documentada."),
  chequeo("muestras_stan",{x<-objeto(e,"muestras_stan");is.numeric(x)&&length(x)>=100&&all(is.finite(x))},15,"Se requieren 100 draws finitos."),
  chequeo("resumen_posterior",{x<-objeto(e,"resumen_posterior");is.data.frame(x)&&nrow(x)>=1},15,"Se requiere una tabla posterior."),
  chequeo("rhat_valor",es_escalar(objeto(e,"rhat_valor"),1,1.1),10,"R-hat debe estar entre 1 y 1.1."))
validar_unidad_09 <- function(e) list(
  chequeo("muestras_hmc",{x<-objeto(e,"muestras_hmc");(is.matrix(x)||is.data.frame(x))&&nrow(x)>=100&&ncol(x)>=2&&all(is.finite(as.matrix(x)))},20,"Se requieren 100 draws en dos columnas."),
  chequeo("energia_hmc",es_numerico(objeto(e,"energia_hmc"),100),15,"Se requieren 100 energias finitas."),
  chequeo("tasa_aceptacion_hmc",es_escalar(objeto(e,"tasa_aceptacion_hmc"),.Machine$double.eps,1-.Machine$double.eps),15,"Debe estar estrictamente entre 0 y 1."),
  chequeo("longitudes",{x<-objeto(e,"muestras_hmc");z<-objeto(e,"energia_hmc");(is.matrix(x)||is.data.frame(x))&&is.numeric(z)&&nrow(x)==length(z)},10,"Draws y energias deben tener la misma longitud."))
validar_unidad_10 <- function(e) list(
  chequeo("muestras_nuts",es_numerico(objeto(e,"muestras_nuts"),100),20,"Se requieren 100 draws finitos."),
  chequeo("profundidad_arbol",es_escalar(objeto(e,"profundidad_arbol"),0,Inf),15,"Debe ser un escalar no negativo."),
  chequeo("divergencias",{x<-objeto(e,"divergencias");es_escalar(x,0,Inf)&&x==floor(x)},15,"Debe ser un entero no negativo."),
  chequeo("profundidad_entera",{x<-objeto(e,"profundidad_arbol");es_escalar(x,0,Inf)&&x==floor(x)},10,"La profundidad debe ser un entero no negativo."))
validar_unidad_11 <- function(e) list(
  chequeo("ajuste_regresion",{x<-objeto(e,"ajuste_regresion");is.list(x)||is.data.frame(x)||is.character(x)},20,"Se requiere una representacion del ajuste."),
  chequeo("coeficientes_posteriores",es_numerico(objeto(e,"coeficientes_posteriores"),2),15,"Se requieren al menos dos coeficientes finitos."),
  chequeo("predicciones_posteriores",es_numerico(objeto(e,"predicciones_posteriores"),10),15,"Se requieren al menos 10 predicciones finitas."),
  chequeo("predicciones_variables",{x<-objeto(e,"predicciones_posteriores");es_numerico(x,10)&&length(unique(x))>1},10,"Las predicciones deben mostrar variacion."))
validar_unidad_12 <- function(e) list(
  chequeo("efectos_grupo",es_numerico(objeto(e,"efectos_grupo"),2),20,"Se requieren efectos de al menos dos grupos."),
  chequeo("sigma_grupo",es_escalar(objeto(e,"sigma_grupo"),.Machine$double.eps,Inf),15,"La desviacion entre grupos debe ser positiva."),
  chequeo("predicciones_posteriores",es_numerico(objeto(e,"predicciones_posteriores"),10),15,"Se requieren al menos 10 predicciones finitas."),
  chequeo("efectos_variables",{x<-objeto(e,"efectos_grupo");es_numerico(x,2)&&length(unique(x))>1},10,"Los efectos de grupo deben mostrar variacion."))
validar_unidad_13 <- function(e) list(
  chequeo("log_lik",{x<-objeto(e,"log_lik");(is.matrix(x)||is.data.frame(x))&&nrow(x)>=10&&ncol(x)>=1&&all(is.finite(as.matrix(x)))},20,"Se requiere log-verosimilitud punto a punto con 10 filas."),
  chequeo("elpd_estimado",es_escalar(objeto(e,"elpd_estimado")),15,"Debe ser un escalar finito."),
  chequeo("predicciones_posteriores",es_numerico(objeto(e,"predicciones_posteriores"),10),15,"Se requieren al menos 10 predicciones finitas."),
  chequeo("predicciones_variables",{x<-objeto(e,"predicciones_posteriores");es_numerico(x,10)&&length(unique(x))>1},10,"Las predicciones deben mostrar variacion."))
validar_unidad_14 <- function(e) list(
  chequeo("muestras_aproximadas",es_numerico(objeto(e,"muestras_aproximadas"),100),20,"Se requieren al menos 100 muestras finitas."),
  chequeo("estimacion_alternativa",es_escalar(objeto(e,"estimacion_alternativa")),15,"Debe ser un escalar finito."),
  chequeo("comparacion_metodos",{x<-objeto(e,"comparacion_metodos");is.data.frame(x)&&nrow(x)>=2},15,"Se requiere una tabla comparativa con dos filas."),
  chequeo("comparacion_nombrada",{x<-objeto(e,"comparacion_metodos");is.data.frame(x)&&length(names(x))>0},10,"La tabla comparativa debe tener columnas nombradas."))

crear_rubrica <- function(archivo, objetos, validador) list(
  archivo = archivo, objetos_requeridos = objetos, marcadores_requeridos = marcadores_base,
  categorias = categorias_estandar, puntos_automaticos_maximos = 70,
  puntos_revision_manual = 30, validar = validador)

rubrica_unidad_01 <- crear_rubrica("unidad-01-fundamentos-computacionales.Rmd", c("posterior_muestras","media_posterior","intervalo_credible"), validar_unidad_01)
rubrica_unidad_02 <- crear_rubrica("unidad-02-aproximaciones-numericas.Rmd", c("grilla_posterior","integral_aproximada","cuantiles_posteriores"), validar_unidad_02)
rubrica_unidad_03 <- crear_rubrica("unidad-03-monte-carlo.Rmd", c("estimaciones_mc","estimacion_mc","error_estandar"), validar_unidad_03)
rubrica_unidad_04 <- crear_rubrica("unidad-04-introduccion-mcmc.Rmd", c("cadena_mcmc","media_cadena","autocorrelacion_lag1"), validar_unidad_04)
rubrica_unidad_05 <- crear_rubrica("unidad-05-metropolis-hastings.Rmd", c("cadena_mh","tasa_aceptacion","propuesta_sd"), validar_unidad_05)
rubrica_unidad_06 <- crear_rubrica("unidad-06-gibbs.Rmd", c("cadena_gibbs","medias_gibbs","correlacion_gibbs"), validar_unidad_06)
rubrica_unidad_07 <- crear_rubrica("unidad-07-diagnostico-mcmc.Rmd", c("rhat_valor","ess_valor","diagnosticos_mcmc"), validar_unidad_07)
rubrica_unidad_08 <- crear_rubrica("unidad-08-stan.Rmd", c("ajuste_stan","muestras_stan","resumen_posterior","rhat_valor"), validar_unidad_08)
rubrica_unidad_09 <- crear_rubrica("unidad-09-hmc.Rmd", c("muestras_hmc","energia_hmc","tasa_aceptacion_hmc"), validar_unidad_09)
rubrica_unidad_10 <- crear_rubrica("unidad-10-nuts.Rmd", c("muestras_nuts","profundidad_arbol","divergencias"), validar_unidad_10)
rubrica_unidad_11 <- crear_rubrica("unidad-11-regresion-glm-bayesianos.Rmd", c("ajuste_regresion","coeficientes_posteriores","predicciones_posteriores"), validar_unidad_11)
rubrica_unidad_12 <- crear_rubrica("unidad-12-modelos-jerarquicos.Rmd", c("efectos_grupo","sigma_grupo","predicciones_posteriores"), validar_unidad_12)
rubrica_unidad_13 <- crear_rubrica("unidad-13-evaluacion-modelos.Rmd", c("log_lik","elpd_estimado","predicciones_posteriores"), validar_unidad_13)
rubrica_unidad_14 <- crear_rubrica("unidad-14-temas-avanzados-panoramicos.Rmd", c("muestras_aproximadas","estimacion_alternativa","comparacion_metodos"), validar_unidad_14)
rubricas_unidades <- list(unidad_01=rubrica_unidad_01, unidad_02=rubrica_unidad_02, unidad_03=rubrica_unidad_03, unidad_04=rubrica_unidad_04, unidad_05=rubrica_unidad_05, unidad_06=rubrica_unidad_06, unidad_07=rubrica_unidad_07, unidad_08=rubrica_unidad_08, unidad_09=rubrica_unidad_09, unidad_10=rubrica_unidad_10, unidad_11=rubrica_unidad_11, unidad_12=rubrica_unidad_12, unidad_13=rubrica_unidad_13, unidad_14=rubrica_unidad_14)
