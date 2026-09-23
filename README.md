# Estadistica Bayesiana Computacional

Sitio Quarto para un curso de Estadistica Bayesiana Computacional con R y Stan.

## Requisitos

- R
- RStudio
- Quarto
- CmdStan
- Paquetes de R: `cmdstanr`, `posterior`, `bayesplot`, `loo`, `ggplot2`, `dplyr`, `tidyr`, `coda`

## Instalar Quarto

Descargar el instalador desde:

<https://quarto.org/docs/get-started/>

Luego verificar en PowerShell:

```powershell
quarto --version
```

## Renderizar el sitio

Desde esta carpeta:

```powershell
quarto render
```

## Previsualizar el sitio

Desde esta carpeta:

```powershell
quarto preview
```

## Archivos Principales

- `index.qmd`: portada del curso.
- `temario.qmd`: contenido por unidades.
- `cronograma.qmd`: distribucion semanal sugerida.
- `instalacion.qmd`: guia para instalar R, Quarto y Stan.
- `materiales.qmd`: bibliografia, paquetes y recursos.
- `proyecto.qmd`: instrucciones del proyecto final.
- `entregas.qmd`: portal estatico de entregas, rubrica y flujo local de calificacion.
- `ejercicios/`: plantillas Rmd descargables para los ejercicios de cada unidad.
- `calificacion/calificar_lote_windows.ps1`: calificador por lote para Windows PowerShell 5.1.
- `practicas/monte-carlo.qmd`: primera practica computacional.
