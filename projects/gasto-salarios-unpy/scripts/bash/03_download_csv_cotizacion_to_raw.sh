#!/usr/bin/env bash
# ==============================================================================
# Script: download_csv_cotizacion_to_raw.sh
# Descripción:
#   Descarga el archivo CSV de cotización USD mensual desde Google Drive,
#   lo guarda temporalmente en la carpeta temp, valida si está en UTF-8,
#   convierte a UTF-8 cuando corresponde, guarda el resultado normalizado
#   en raw/clasificadores y elimina el CSV temporal.
#
# Uso:
#   chmod +x download_csv_cotizacion_to_raw.sh
#   ./download_csv_cotizacion_to_raw.sh
#
# Requisitos:
#   curl, file, iconv, grep, sed, awk, mktemp
# ==============================================================================

set -Eeuo pipefail

# ------------------------------------------------------------------------------
# Configuración general
# ------------------------------------------------------------------------------

BASE_DIR="/opt/repo/cit-bigdata-lab/projects/data"
TEMP_DIR="${BASE_DIR}/temp"
RAW_DIR="${BASE_DIR}/raw/clasificadores"

TEMP_FILE_NAME="cotizacion_usd_mensual.csv"
RAW_FILE_NAME="cotizacion_usd_mensual.utf8.csv"

TEMP_CSV_PATH="${TEMP_DIR}/${TEMP_FILE_NAME}"
RAW_CSV_PATH="${RAW_DIR}/${RAW_FILE_NAME}"

# ID del archivo en Google Drive.
# URL original:
# https://drive.google.com/file/d/1qjm1eRfJY6DGnvaAyJQRs4WH8FImoj2M/view?usp=sharing
GOOGLE_DRIVE_FILE_ID="1qjm1eRfJY6DGnvaAyJQRs4WH8FImoj2M"

# Usar true porque el script base utiliza curl -k.
# En un entorno productivo debería usarse false para validar certificados TLS.
CURL_INSECURE="true"

# Codificaciones de respaldo esperadas para fuentes CSV públicas.
# Primero se valida UTF-8. Si falla, se intenta convertir desde estas.
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
  local required_commands=("curl" "file" "iconv" "grep" "sed" "awk" "mktemp" "mkdir" "rm" "mv" "cp" "head" "du")
  local missing=0

  for cmd in "${required_commands[@]}"; do
    if ! require_command "$cmd"; then
      missing=1
    fi
  done

  if [[ "${missing}" -ne 0 ]]; then
    error "Instale los comandos faltantes antes de ejecutar el script."
    error "Ejemplo en Ubuntu/Debian: sudo apt update && sudo apt install -y curl file"
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
  iconv -f UTF-8 -t UTF-8 "${file_path}" >/dev/null 2>&1
}

is_probably_html() {
  local file_path="$1"

  # Detecta cuando Google Drive descarga una página HTML en vez del CSV real.
  if file -bi "${file_path}" | grep -qiE 'text/html|charset=us-ascii'; then
    if head -c 512 "${file_path}" | grep -qiE '<!DOCTYPE html|<html|Google Drive|accounts.google.com'; then
      return 0
    fi
  fi

  if head -c 512 "${file_path}" | grep -qiE '<!DOCTYPE html|<html|Google Drive|accounts.google.com'; then
    return 0
  fi

  return 1
}

download_google_drive_file() {
  local file_id="$1"
  local output_path="$2"

  local cookie_file
  local first_response
  local confirm_token
  local drive_url

  cookie_file="$(mktemp)"
  first_response="$(mktemp)"
  drive_url="https://drive.google.com/uc?export=download&id=${file_id}"

  log "Descargando desde Google Drive ID=${file_id}"
  log "URL directa: ${drive_url}"

  # Primera descarga.
  if ! curl "${CURL_OPTIONS[@]}" -c "${cookie_file}" "${drive_url}" -o "${first_response}"; then
    rm -f "${cookie_file}" "${first_response}"
    error "Falló la descarga inicial desde Google Drive: ${file_id}"
    return 1
  fi

  # Si la primera respuesta ya es el CSV, se mueve directamente.
  if ! is_probably_html "${first_response}"; then
    mv -f "${first_response}" "${output_path}"
    rm -f "${cookie_file}"
    return 0
  fi

  # Si Google Drive entrega una página intermedia, se intenta obtener token
  # de confirmación desde cookies o desde el HTML.
  confirm_token="$(
    awk '/download_warning/ {print $NF}' "${cookie_file}" | tail -n 1
  )"

  if [[ -z "${confirm_token}" ]]; then
    confirm_token="$(
      grep -oE 'confirm=[0-9A-Za-z_%-]+' "${first_response}" \
        | head -n 1 \
        | sed 's/confirm=//' || true
    )"
  fi

  if [[ -z "${confirm_token}" ]]; then
    rm -f "${cookie_file}" "${first_response}"
    error "Google Drive no entregó el CSV directamente."
    error "Causa probable: archivo privado, permiso insuficiente o restricción de Google Drive."
    error "Revise que el archivo con ID ${file_id} tenga permiso público de lectura."
    return 1
  fi

  log "Se detectó confirmación de Google Drive. Reintentando con token..."

  if ! curl "${CURL_OPTIONS[@]}" -b "${cookie_file}" \
    "https://drive.google.com/uc?export=download&confirm=${confirm_token}&id=${file_id}" \
    -o "${output_path}"; then
    rm -f "${cookie_file}" "${first_response}"
    error "Falló la descarga con token de confirmación para Google Drive ID=${file_id}"
    return 1
  fi

  rm -f "${cookie_file}" "${first_response}"

  if is_probably_html "${output_path}"; then
    error "El archivo descargado sigue pareciendo HTML, no CSV: ${output_path}"
    error "Revise que el enlace de Google Drive sea público y apunte al CSV correcto."
    return 1
  fi

  return 0
}

convert_or_copy_to_utf8() {
  local source_csv="$1"
  local target_csv="$2"
  local temp_output="${target_csv}.tmp"

  rm -f "${temp_output}"

  log "Inspección MIME/codificación del archivo fuente:"
  file -bi "${source_csv}"

  if validate_utf8_file "${source_csv}"; then
    log "Codificación validada: UTF-8. Se copia al destino raw."
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
    log "Archivo generado en raw: ${target_csv}"
    log "Inspección MIME/codificación del archivo final:"
    file -bi "${target_csv}"
    log "Validación UTF-8: OK"
  else
    rm -f "${temp_output}"
    error "El archivo resultante no superó la validación UTF-8: ${target_csv}"
    return 1
  fi
}

cleanup_temp_csv() {
  if [[ -f "${TEMP_CSV_PATH}" ]]; then
    log "Eliminando CSV temporal: ${TEMP_CSV_PATH}"
    rm -f "${TEMP_CSV_PATH}"
  else
    warn "No se encontró CSV temporal para eliminar: ${TEMP_CSV_PATH}"
  fi
}

# ------------------------------------------------------------------------------
# Ejecución principal
# ------------------------------------------------------------------------------

main() {
  validate_requirements
  build_curl_options
  prepare_directories

  log "=============================================================================="
  log "Inicio del proceso de descarga y normalización UTF-8"
  log "Archivo fuente temporal: ${TEMP_CSV_PATH}"
  log "Archivo destino raw: ${RAW_CSV_PATH}"
  log "Directorio temporal: ${TEMP_DIR}"
  log "Directorio raw: ${RAW_DIR}"

  cd "${TEMP_DIR}"

  log "Descargando archivo CSV en carpeta temp..."
  download_google_drive_file "${GOOGLE_DRIVE_FILE_ID}" "${TEMP_CSV_PATH}"

  if [[ ! -s "${TEMP_CSV_PATH}" ]]; then
    error "El archivo descargado está vacío: ${TEMP_CSV_PATH}"
    exit 1
  fi

  if is_probably_html "${TEMP_CSV_PATH}"; then
    error "El archivo descargado no parece ser CSV sino HTML: ${TEMP_CSV_PATH}"
    error "No se realizará conversión para evitar generar un raw inválido."
    exit 1
  fi

  log "Archivo descargado correctamente: ${TEMP_CSV_PATH}"
  log "Tamaño del archivo: $(du -h "${TEMP_CSV_PATH}" | awk '{print $1}')"

  log "Convirtiendo o copiando a UTF-8 hacia raw..."
  convert_or_copy_to_utf8 "${TEMP_CSV_PATH}" "${RAW_CSV_PATH}"

  cleanup_temp_csv

  log "=============================================================================="
  log "Proceso finalizado correctamente."
  log "Archivo disponible en: ${RAW_CSV_PATH}"
}

main "$@"
