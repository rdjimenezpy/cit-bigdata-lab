#!/usr/bin/env bash
# ==============================================================================
# Script: download_csv_funcionarios_to_raw.sh
# Descripción:
#   Descarga archivos CSV comprimidos del portal de datos SFP para el año 2025
#   desde enero hasta diciembre, los descomprime en temp, valida/convierten a
#   UTF-8 y guarda los CSV normalizados en la carpeta raw/funcionarios.
#
# Uso:
#   chmod +x download_csv_funcionarios_to_raw.sh
#   ./download_csv_funcionarios_to_raw.sh
#
# Requisitos:
#   curl, unzip, file, iconv
# ==============================================================================

set -Eeuo pipefail

# ------------------------------------------------------------------------------
# Configuración general
# ------------------------------------------------------------------------------

YEAR="2025"

BASE_DIR="/opt/repo/cit-bigdata-lab/projects/data"
TEMP_DIR="${BASE_DIR}/temp"
RAW_DIR="${BASE_DIR}/raw/funcionarios"

BASE_URL="https://datos.sfp.gov.py/data"

# Mantener en true porque el script base usa curl -k para laboratorio.
# En un entorno productivo debería usarse false para validar certificados TLS.
CURL_INSECURE="true"

# Eliminar también los ZIP descargados después de procesar correctamente.
# Si se desea conservar los ZIP en temp, cambiar a false.
DELETE_ZIP_AFTER_OK="true"

# Codificaciones de respaldo esperadas para fuentes CSV públicas antiguas.
# UTF-8 se valida primero; si falla, se intenta convertir desde estas.
FALLBACK_ENCODINGS=("ISO-8859-1" "WINDOWS-1252")

# ------------------------------------------------------------------------------
# Funciones auxiliares
# ------------------------------------------------------------------------------

log() {
  printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*"
}

warn() {
  printf '[%s] ADVERTENCIA: %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >&2
}

error() {
  printf '[%s] ERROR: %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >&2
}

require_command() {
  local cmd="$1"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    error "No se encontró el comando requerido: ${cmd}"
    return 1
  fi
}

validate_requirements() {
  local required_commands=("curl" "unzip" "file" "iconv" "mkdir" "rm" "mv" "cp" "grep" "head")
  local missing=0

  for cmd in "${required_commands[@]}"; do
    if ! require_command "$cmd"; then
      missing=1
    fi
  done

  if [[ "$missing" -ne 0 ]]; then
    error "Instale los comandos faltantes antes de ejecutar el script."
    error "Ejemplo en Ubuntu/Debian: sudo apt update && sudo apt install -y curl unzip file"
    exit 1
  fi
}

build_curl_options() {
  CURL_OPTIONS=(-fL --retry 3 --retry-delay 3 --connect-timeout 20 --max-time 300)

  if [[ "${CURL_INSECURE}" == "true" ]]; then
    CURL_OPTIONS=(-k "${CURL_OPTIONS[@]}")
  fi
}

prepare_directories() {
  mkdir -p "${TEMP_DIR}"
  mkdir -p "${RAW_DIR}"
}

validate_utf8_file() {
  local file_path="$1"
  iconv -f UTF-8 -t UTF-8 "$file_path" >/dev/null 2>&1
}

convert_or_copy_to_utf8() {
  local source_csv="$1"
  local target_csv="$2"
  local temp_output="${target_csv}.tmp"

  rm -f "${temp_output}"

  log "Inspección MIME/codificación: $(file -bi "${source_csv}")"

  if validate_utf8_file "${source_csv}"; then
    log "Codificación detectada/validada: UTF-8. Se copia al destino raw."
    cp -f "${source_csv}" "${temp_output}"
  else
    local converted="false"
    local source_encoding=""

    for encoding in "${FALLBACK_ENCODINGS[@]}"; do
      log "Intentando conversión desde ${encoding} hacia UTF-8..."
      if iconv -f "${encoding}" -t UTF-8 "${source_csv}" -o "${temp_output}" 2>/dev/null; then
        converted="true"
        source_encoding="${encoding}"
        break
      fi
    done

    if [[ "${converted}" != "true" ]]; then
      rm -f "${temp_output}"
      error "No fue posible convertir a UTF-8: ${source_csv}"
      return 1
    fi

    log "Conversión completada desde ${source_encoding} hacia UTF-8."
  fi

  if validate_utf8_file "${temp_output}"; then
    mv -f "${temp_output}" "${target_csv}"
    log "Validación UTF-8: OK -> ${target_csv}"
  else
    rm -f "${temp_output}"
    error "El archivo resultante no superó la validación UTF-8: ${target_csv}"
    return 1
  fi
}

process_month() {
  local month="$1"

  local zip_name="funcionarios_${YEAR}_${month}.csv.zip"
  local expected_csv_name="funcionarios_${YEAR}_${month}.csv"
  local raw_csv_name="funcionarios_${YEAR}_${month}_utf8.csv"

  local zip_url="${BASE_URL}/${zip_name}"
  local zip_path="${TEMP_DIR}/${zip_name}"
  local raw_csv_path="${RAW_DIR}/${raw_csv_name}"

  log "=============================================================================="
  log "Procesando periodo: ${YEAR}-${month}"
  log "Archivo origen ZIP: ${zip_name}"
  log "Destino raw UTF-8: ${raw_csv_path}"

  cd "${TEMP_DIR}"

  log "Descargando: ${zip_url}"
  if ! curl "${CURL_OPTIONS[@]}" "${zip_url}" -o "${zip_path}"; then
    error "Falló la descarga del archivo: ${zip_url}"
    return 1
  fi

  log "Verificando listado interno del ZIP..."
  if ! unzip -l "${zip_path}"; then
    error "No se pudo listar el contenido del ZIP: ${zip_path}"
    return 1
  fi

  log "Verificando integridad del ZIP..."
  if ! unzip -tq "${zip_path}"; then
    error "La verificación de integridad del ZIP falló: ${zip_path}"
    return 1
  fi

  local csv_inside_zip=""
  csv_inside_zip="$(unzip -Z1 "${zip_path}" | grep -E "(^|/)${expected_csv_name}$" | head -n 1 || true)"

  if [[ -z "${csv_inside_zip}" ]]; then
    warn "No se encontró exactamente ${expected_csv_name} dentro del ZIP. Se buscará el primer CSV disponible."
    csv_inside_zip="$(unzip -Z1 "${zip_path}" | grep -Ei '\.csv$' | head -n 1 || true)"
  fi

  if [[ -z "${csv_inside_zip}" ]]; then
    error "No se encontró ningún archivo CSV dentro de: ${zip_path}"
    return 1
  fi

  log "CSV detectado dentro del ZIP: ${csv_inside_zip}"

  log "Descomprimiendo CSV en temp..."
  if ! unzip -o "${zip_path}" "${csv_inside_zip}" -d "${TEMP_DIR}" >/dev/null; then
    error "No se pudo descomprimir ${csv_inside_zip} desde ${zip_path}"
    return 1
  fi

  local extracted_csv_path="${TEMP_DIR}/${csv_inside_zip}"

  if [[ ! -f "${extracted_csv_path}" ]]; then
    error "No se encontró el CSV descomprimido esperado: ${extracted_csv_path}"
    return 1
  fi

  log "Convirtiendo o copiando a UTF-8 hacia raw..."
  if ! convert_or_copy_to_utf8 "${extracted_csv_path}" "${raw_csv_path}"; then
    error "Falló la normalización UTF-8 para el periodo ${YEAR}-${month}"
    return 1
  fi

  log "Eliminando CSV temporal: ${extracted_csv_path}"
  rm -f "${extracted_csv_path}"

  if [[ "${DELETE_ZIP_AFTER_OK}" == "true" ]]; then
    log "Eliminando ZIP temporal: ${zip_path}"
    rm -f "${zip_path}"
  fi

  log "Periodo ${YEAR}-${month} procesado correctamente."
  return 0
}

# ------------------------------------------------------------------------------
# Ejecución principal
# ------------------------------------------------------------------------------

main() {
  validate_requirements
  build_curl_options
  prepare_directories

  local successful_periods=()
  local failed_periods=()

  log "Inicio del proceso de descarga y normalización UTF-8 para el año ${YEAR}"
  log "Directorio temporal: ${TEMP_DIR}"
  log "Directorio raw: ${RAW_DIR}"

  for month in $(seq 1 12); do
    if process_month "${month}"; then
      successful_periods+=("${YEAR}_${month}")
    else
      failed_periods+=("${YEAR}_${month}")
      warn "Se continuará con el siguiente periodo."
    fi
  done

  log "=============================================================================="
  log "Resumen de ejecución"
  log "Periodos procesados correctamente: ${#successful_periods[@]}"
  if [[ "${#successful_periods[@]}" -gt 0 ]]; then
    printf '  - %s\n' "${successful_periods[@]}"
  fi

  log "Periodos con error: ${#failed_periods[@]}"
  if [[ "${#failed_periods[@]}" -gt 0 ]]; then
    printf '  - %s\n' "${failed_periods[@]}"
    error "El proceso finalizó con errores en uno o más periodos."
    exit 1
  fi

  log "Proceso finalizado correctamente para todos los periodos."
}

main "$@"
