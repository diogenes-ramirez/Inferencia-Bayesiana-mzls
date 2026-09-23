#!/usr/bin/env Rscript
# Prerrequisitos: R y el paquete knitr.
# Seguridad: este script extrae y EJECUTA codigo arbitrario del estudiante.
# No es un sandbox. Ejecute solamente en un contenedor, VM o entorno desechable
# controlado por el docente. No renderiza el Rmd de forma predeterminada.

args <- commandArgs(trailingOnly = TRUE)
uso <- "Uso: Rscript calificacion/calificar_entrega.R <ruta/a/entrega.Rmd> [directorio_salida]"
script_arg <- grep("^--file=", commandArgs(), value = TRUE)
script_dir <- if (length(script_arg)) dirname(normalizePath(sub("^--file=", "", script_arg[1]))) else "calificacion"
source(file.path(script_dir, "rubricas_unidades.R"))

estado <- 0L
filas <- list()
agregar <- function(nombre, aprobado, puntos, detalle, tipo = "automatico") {
  filas[[length(filas) + 1L]] <<- data.frame(tipo = tipo, comprobacion = nombre,
    aprobado = isTRUE(aprobado), puntos_maximos = puntos,
    puntos_obtenidos = if (isTRUE(aprobado)) puntos else 0,
    detalle = detalle, stringsAsFactors = FALSE)
}
escribir_reporte <- function(salida, entrega, unidad, advertencias) {
  if (!dir.exists(salida)) dir.create(salida, recursive = TRUE, showWarnings = FALSE)
  tabla <- if (length(filas)) do.call(rbind, filas) else data.frame(tipo=character(),comprobacion=character(),aprobado=logical(),puntos_maximos=numeric(),puntos_obtenidos=numeric(),detalle=character())
  archivo <- file.path(salida, paste0("reporte_", ifelse(is.na(unidad), "invalida", unidad), ".csv"))
  write.csv(tabla, archivo, row.names = FALSE, fileEncoding = "UTF-8")
  cat("\nReporte:", archivo, "\n")
  cat("Entrega:", entrega, "\nUnidad:", ifelse(is.na(unidad), "no identificada", unidad), "\n")
  cat("Puntaje automatico:", sum(tabla$puntos_obtenidos), "/ 70\n")
  cat("Revision manual pendiente: 30 / 30\n")
  if (length(advertencias)) cat("Advertencias/errores:\n-", paste(advertencias, collapse = "\n- "), "\n")
  print(tabla, row.names = FALSE)
}

if (length(args) < 1L || length(args) > 2L) {
  agregar("argumentos", FALSE, 0, uso, "configuracion")
  escribir_reporte(if (length(args) == 2L) args[2] else ".", if (length(args)) args[1] else "", NA_character_, "Cantidad de argumentos invalida.")
  quit(status = 2L)
}

entrega <- args[1]
salida <- if (length(args) == 2L) args[2] else "calificacion/reportes"
advertencias <- "ADVERTENCIA DE SEGURIDAD: el codigo del estudiante se ejecuta; use un entorno aislado."
if (!file.exists(entrega)) {
  agregar("archivo", FALSE, 0, "No existe la entrega indicada.", "configuracion")
  escribir_reporte(salida, entrega, NA_character_, c(advertencias, "Ruta de entrega invalida."))
  quit(status = 2L)
}

nombre <- basename(entrega)
coincidencias <- names(rubricas_unidades)[vapply(rubricas_unidades, function(r) identical(r$archivo, nombre), logical(1))]
if (length(coincidencias) != 1L) {
  agregar("nombre de archivo", FALSE, 0, "El nombre debe coincidir exactamente con una plantilla conocida.", "configuracion")
  escribir_reporte(salida, entrega, NA_character_, c(advertencias, paste("Archivo no reconocido:", nombre)))
  quit(status = 2L)
}
unidad <- coincidencias[1]
rubrica <- rubricas_unidades[[unidad]]
fuente <- tryCatch(readLines(entrega, warn = FALSE, encoding = "UTF-8"), error = function(e) e)
if (inherits(fuente, "error")) {
  agregar("lectura", FALSE, 0, conditionMessage(fuente), "configuracion")
  escribir_reporte(salida, entrega, unidad, c(advertencias, conditionMessage(fuente)))
  quit(status = 2L)
}

fin_yaml <- if (length(fuente) >= 2L && trimws(fuente[1]) == "---") which(trimws(fuente[-1]) == "---")[1] + 1L else NA_integer_
yaml <- if (!is.na(fin_yaml)) fuente[seq_len(fin_yaml)] else character()
yaml_ok <- length(yaml) >= 2L && all(vapply(c("title:", "author: \"\"", "date: \"\"", "output: html_document"), function(x) any(grepl(x, yaml, fixed = TRUE)), logical(1)))
agregar("YAML requerido", yaml_ok, 4, "Debe incluir title, author vacio, date vacia y output: html_document.")
marcadores_ok <- vapply(rubrica$marcadores_requeridos, function(m) any(grepl(m, fuente, fixed = TRUE)), logical(1))
for (i in seq_along(marcadores_ok)) agregar(rubrica$marcadores_requeridos[i], marcadores_ok[i], 1.2, "Seccion requerida por la plantilla.")

if (!requireNamespace("knitr", quietly = TRUE)) {
  agregar("dependencia knitr", FALSE, 0, "Instale knitr para extraer codigo: install.packages('knitr').", "configuracion")
  escribir_reporte(salida, entrega, unidad, c(advertencias, "Falta la dependencia knitr; no se ejecuto codigo."))
  quit(status = 2L)
}

codigo <- tempfile("entrega_", fileext = ".R")
extraccion <- tryCatch({knitr::purl(input = entrega, output = codigo, documentation = 0, quiet = TRUE); NULL}, error = function(e) e)
if (inherits(extraccion, "error")) {
  agregar("extraccion knitr::purl", FALSE, 0, conditionMessage(extraccion), "ejecucion")
  escribir_reporte(salida, entrega, unidad, c(advertencias, paste("No se pudo extraer codigo:", conditionMessage(extraccion))))
  quit(status = 1L)
}
# El entorno de evaluacion no contiene objetos previos del estudiante. Su padre
# permite usar los paquetes base recomendados por las plantillas (por ejemplo,
# stats, cargado por Rscript) sin convertir esta ejecucion en un renderizado.
entorno <- new.env(parent = globalenv())
ejecucion <- tryCatch({sys.source(codigo, envir = entorno); NULL}, error = function(e) e)
unlink(codigo)
if (inherits(ejecucion, "error")) {
  agregar("ejecucion", FALSE, 0, conditionMessage(ejecucion), "ejecucion")
  escribir_reporte(salida, entrega, unidad, c(advertencias, paste("Error al ejecutar codigo extraido:", conditionMessage(ejecucion))))
  quit(status = 1L)
}

for (r in rubrica$validar(entorno)) agregar(r$nombre, r$aprobado, r$puntos, r$detalle)
escribir_reporte(salida, entrega, unidad, advertencias)
