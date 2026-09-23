# Calificacion de entregas

El calificador local revisa estructura y objetos ejecutables; no renderiza el documento por defecto. La calificacion automatica suma 70 puntos (10 de estructura y 60 de objetos y validaciones); el docente asigna los 30 puntos restantes por razonamiento, interpretacion y calidad del codigo.

## Calificar una entrega

Desde la raiz del proyecto:

```sh
Rscript calificacion/calificar_entrega.R ejercicios/unidad-01-fundamentos-computacionales.Rmd
```

Para elegir un directorio de reportes:

```sh
Rscript calificacion/calificar_entrega.R ruta/a/unidad-01-fundamentos-computacionales.Rmd calificacion/reportes
```

## Calificar un lote en Windows

En PowerShell 5.1, desde la raiz del proyecto y dentro de un entorno aislado:

```powershell
.\calificacion\calificar_lote_windows.ps1 -EntregasDir .\entregas
```

La estructura esperada es `entregas/<estudiante_id>/unidad-XX-...Rmd`: una carpeta inmediata por estudiante y exactamente un Rmd por unidad:

```text
entregas/
  estudiante-001/
    unidad-01-fundamentos-computacionales.Rmd
    unidad-02-...Rmd
  estudiante-002/
    unidad-01-fundamentos-computacionales.Rmd
```

Para elegir el directorio de salida:

```powershell
.\calificacion\calificar_lote_windows.ps1 -EntregasDir .\entregas -ReportesDir .\calificacion\reportes
```

El script busca recursivamente los archivos `.Rmd`, continua aunque otra entrega falle y devuelve un codigo distinto de cero si alguna evaluacion falla. Cada reporte se guarda en `ReportesDir/<estudiante_id>/`, donde `estudiante_id` es el nombre de la carpeta inmediata de la entrega. Esto evita colisiones cuando todos usan el mismo nombre canonico por unidad.

## Reporte

El CSV registra la comprobacion, si aprobo, puntos maximos, puntos obtenidos y detalle accionable. Los reportes se separan por estudiante y unidad. El puntaje automatico tiene un maximo de 70. Los 30 puntos restantes quedan pendientes de revision docente para razonamiento, interpretacion y calidad del codigo.

## Seguridad

El script usa `knitr::purl()` para extraer codigo R y despues lo ejecuta en un entorno nuevo. Esto **no es un sandbox**: una entrega puede leer, escribir o ejecutar acciones en la maquina. Use una maquina virtual, contenedor o entorno Windows equivalente aislado y controlado por el docente; no lo ejecute en la maquina personal ni con datos sensibles. Se requieren R (con `Rscript` disponible en `PATH`) y `knitr`; `rmarkdown` no es necesario porque no se renderiza.

## Ajustar una rubrica

Edite la configuracion `rubrica_unidad_XX` correspondiente en `calificacion/rubricas_unidades.R`: conserve el nombre canonico y sincronice `objetos_requeridos`, marcadores y funcion `validar_unidad_XX` con la plantilla. Cada rubrica separa 10 puntos de estructura automatica, 60 de objetos y validaciones, y 30 de revision manual.
