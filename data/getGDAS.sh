#!/bin/bash
# *** Baja datos del Global Data Assimilation System (GDAS) 
#
# USO: ./script.sh  <year> <month> <out_dir>
YEAR=$1    # dos digitos.
MONTH=$2   # tres letras minusculas.
OUTDIR=$3 # Ruta: ej: /media/ram/Windows/DATA/
#
# Descarga: gdas1.${MONTH}${YEAR}.w*
wget -P ${OUTDIR} -c -nd -nc -r --level=1 -A gdas1.${MONTH}${YEAR}.w* ftp://arlftp.arlhq.noaa.gov/pub/archives/gdas1/

