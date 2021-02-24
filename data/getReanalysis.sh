#!/bin/bash
# *** Baja datos del Reanalysis
#
# USO: ./script.sh  <year> <month> <out_dir>
YEAR=$1    # dos digitos.
MONTH=$2
OUTDIR=$3 # Ruta: ej: /media/ram/Windows/DATA/
#
# Descarga: RP${YEAR}*
wget -P ${OUTDIR} -c -nd -nc -r --level=1 -A RP${YEAR}${MONTH}* ftp://arlftp.arlhq.noaa.gov/pub/archives/reanalysis/
#

