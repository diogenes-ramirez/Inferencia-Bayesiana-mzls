<#
.SYNOPSIS
Califica todos los archivos Rmd ubicados bajo una carpeta de entregas.

.DESCRIPTION
Ejecute este script solo dentro de una VM, contenedor o entorno Windows aislado.
calificar_entrega.R extrae y ejecuta codigo arbitrario de cada entrega; este script
no proporciona un sandbox.

.EXAMPLE
.\calificacion\calificar_lote_windows.ps1 -EntregasDir .\entregas

.EXAMPLE
.\calificacion\calificar_lote_windows.ps1 -EntregasDir .\entregas -ReportesDir .\calificacion\reportes
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$EntregasDir,

    [string]$ReportesDir = (Join-Path $PSScriptRoot "reportes")
)

$ErrorActionPreference = "Stop"

# Resolve paths before processing submissions so configuration errors are clear.
if (-not (Test-Path -LiteralPath $EntregasDir -PathType Container)) {
    throw "El directorio de entregas no existe o no es un directorio: $EntregasDir"
}

$rscript = Get-Command "Rscript.exe" -ErrorAction SilentlyContinue
if ($null -eq $rscript) {
    $rscript = Get-Command "Rscript" -ErrorAction SilentlyContinue
}
if ($null -eq $rscript) {
    throw "No se encontro Rscript. Instale R y agregue su directorio bin al PATH antes de ejecutar este script."
}

$grader = Join-Path $PSScriptRoot "calificar_entrega.R"
if (-not (Test-Path -LiteralPath $grader -PathType Leaf)) {
    throw "No se encontro el calificador requerido: $grader"
}

$deliveriesPath = (Resolve-Path -LiteralPath $EntregasDir).Path
if (-not (Test-Path -LiteralPath $ReportesDir -PathType Container)) {
    New-Item -ItemType Directory -Path $ReportesDir -Force | Out-Null
}
$reportsPath = (Resolve-Path -LiteralPath $ReportesDir).Path

$files = @(Get-ChildItem -LiteralPath $deliveriesPath -Recurse -File -Filter "*.Rmd")
if ($files.Count -eq 0) {
    Write-Warning "No se encontraron archivos .Rmd en: $deliveriesPath"
    exit 0
}

$successes = 0
$failures = 0

foreach ($file in $files) {
    # El directorio padre inmediato identifica al estudiante y evita colisiones
    # cuando todos usan el mismo nombre canonico para la unidad.
    $studentId = $file.Directory.Name
    $studentReportsDir = Join-Path $reportsPath $studentId
    if (-not (Test-Path -LiteralPath $studentReportsDir -PathType Container)) {
        New-Item -ItemType Directory -Path $studentReportsDir -Force | Out-Null
    }

    Write-Host "Calificando: $($file.FullName)"
    try {
        & $rscript.Path $grader $file.FullName $studentReportsDir
        if ($LASTEXITCODE -eq 0) {
            $successes++
            Write-Host "Correcta: $($file.Name)"
        }
        else {
            $failures++
            Write-Warning "Fallo ($LASTEXITCODE): $($file.FullName)"
        }
    }
    catch {
        $failures++
        Write-Warning "No se pudo ejecutar el calificador para $($file.FullName): $($_.Exception.Message)"
    }
}

Write-Host "Resumen: $successes evaluacion(es) correcta(s), $failures fallida(s)."
if ($failures -gt 0) {
    exit 1
}

exit 0
