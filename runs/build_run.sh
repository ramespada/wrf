#!/bin/bash
#=========================================================#
#   Prepara directorio para corrida de WRF                #
#* * * * * * * * * * * * ** * * * * * * * * * * * * * * * #
exp_name=mar2009Bahia
#INPUTS:
dir=/home/ramiroespada
#src:
WPSSRC=${dir}/stage/WRFV4gnu/WPS   #Ruta al source del WPS
WRFSRC=${dir}/stage/WRFV4gnu/WRF   #Ruta al source del WRF
#data:
meteo_path=${dir}/stage/data/GFS2 #ruta a archivos meteorologicos
geog_path=${dir}/stage/data/WPS_GEOG
#default namelists and tables:
namelist_path=${dir}/WRF/misc/namelists
tables_path=${dir}/WRF/misc/tablas
sbatch_path=${dir}/WRF/misc/sbatch
#dates
start_date='2009-03-14_00:00:00'   #%Y-%m-%D_%H:%M:%D
end_date='2009-03-15_00:00:00'      #%Y-%m-%D_%H:%M:%D 

add2namelist="
e_we  =  50,
e_sn  =  50,  
geog_data_res = 'default',
dx        = 15000,
dy        = 15000,
map_proj  = 'lambert',
ref_lat   = -38.73,
ref_lon   = -62.23,
truelat1  = -33.721,
truelat2  = -33.721,
stand_lon = -59.834,
interval_seconds = 21600,
time_step = 260,
num_metgrid_levels = 27,
ra_lw_physics=1, ra_sw_physics = 2,radt=30,
cu_physics=5,mp_physics=28,bl_pbl_physics=1,
sf_sfclay_physics=1,sf_surface_physics=2,sf_urban_physics=0,
chem_in_opt=0,kemit=1,emiss_opt=0,emiss_inpt_opt=0,
chem_opt=401,dust_opt=1,dust_schme=1,
aer_drydep_opt=1,aerchem_onoff=1,
aer_op_opt=1,
opt_pars_out=0,
"
#* * * * * * * * * * * * ** * * * * * * * * * * * * * * * #
#+========================================================#
#
echo -e " * * * * * * * * * * * * * * * * * * * * * * * * *"
echo -e "  %Inicio.                                        "
echo -e ""
#check directories existence
echo -e "\e[36m Checkeando existencia de directorios:            \e[0m"    
DIRECTORIES=($WPSSRC $WRFSRC $meteo_path $geog_path $namelist_path $tables_path)
for DIRECTORY in "${DIRECTORIES[@]}"; do
        if [ ! -d "$DIRECTORY" ]; then
                echo -e "\e[31m ERROR:  El directorio ${DIRECTORY} NO existe!\e[0m"; exit;
        else
                echo -e "Directorio ${DIRECTORY} \e[32m Ok, Existe!\e[0m"; continue;
        fi
done
#--------------------------------------------------------#
#parse dates:
echo -e "\e[36m -------------------------------------------------\e[0m"
echo -e "\e[36m Parseando fechas:                               \e[0m"    
     read start_year start_month start_day start_hour start_min start_sec <<< ${start_date//[-:\/_ ]/ }
     read end_year end_month end_day end_hour end_min end_sec <<< ${end_date//[-:\/_ ]/ }
echo "Fecha inicial:  "$start_year $start_month $start_day $start_hour
echo "Fecha final:  "$end_year $end_month $end_day $end_hour

diff_secs=$(($(date -d "$end_year-$end_month-$end_day $end_hour" '+%s')-$(date -d "$start_year-$start_month-$start_day $start_hour" '+%s')))
echo "Difrencia de tiempo (en seg.):  "$diff_secs
run_days=$(($diff_secs/(24*60*60)))
echo "Dias de corrida:  "$run_days
run_hours=$((($diff_secs-$run_days*24*60*60)/(60*60)))
echo "Diferencia horaria:  "$run_hours

add2namelist=$add2namelist",start_date=$start_date,end_date=$end_date,start_year=$start_year,start_month=$start_month,start_day=$start_day,start_hour=$start_hour,end_year=$end_year,end_month=$end_month,end_day=$end_day,end_hour=$end_hour,run_days=$run_days,run_hours=$run_hours"

printf '%s\n' "${my_array[@]}"

#parse variables on namelist:
echo -e "\e[36m -------------------------------------------------"
echo -e "\e[36m  Parseando variables de namelist:                "    
  add2namelist_NO_SPACES=$(echo $add2namelist | sed 's/[[:space:]]//g')
  add2namelist_NO_SPACES_array=(${add2namelist_NO_SPACES//[,;]/ })
echo -e "\e[36m -------------------------------------------------\e[0m"
echo -e "\e[36m  Creando directorio de trabajo '$exp_name'       \e[0m"    
if [ -d "$exp_name" ]; then
        echo -e "\e[31m ERROR:  El directorio $exp_name ya existe!\e[0m"; exit;
else
        mkdir ${exp_name};
        ls | grep ${exp_name};
fi
cd ${exp_name}

echo -e "\e[36m -------------------------------------------------\e[0m"
echo -e "\e[36m  Creando dir 'wps'                               \e[0m"
mkdir wps
cd wps

#namelist
cp ${namelist_path}/namelist.wps namelist.wps
        for var_inp in "${add2namelist_NO_SPACES_array[@]}"; do
                var_name=$(echo $var_inp | sed 's/\(.*\)=.*/\1/g')
        if grep -q $var_name namelist.wps; then
                echo -e "Agregando \e[32m ${var_inp}\e[0m a namelist.wps "
                sed -i "s/.*\b$var_name\b.*/$var_inp,/g" namelist.wps
        fi
        done
#tables
cp ${tables_path}/wps/GEOGRID.TBL GEOGRID.TBL
cp ${tables_path}/wps/Vtable  Vtable
cp ${tables_path}/wps/METGRID.TBL METGRID.TBL
#data
ln -s ${geog_path} .
cp -p ${WPSSRC}/link_grib.csh link_grib.csh
tcsh link_grib.csh ${meteo_path}/fnl*
#exe
ln -s ${WPSSRC}/geogrid.exe geogrid.exe
ln -s ${WPSSRC}/ungrib.exe ungrib.exe
ln -s ${WPSSRC}/metgrid.exe metgrid.exe
cd ..
find wps/ -print

echo -e "\e[36m --------------------------------------------------\e[0m"
echo -e "\e[36m  Creando dir 'wrf'\e[0m"
mkdir wrf
cd wrf

#namelist 
cp ${namelist_path}/namelist.input namelist.input
        for var_inp in "${add2namelist_NO_SPACES_array[@]}"; do
                var_name=$(echo $var_inp | sed 's/\(.*\)=.*/\1/g')
        if grep -q $var_name namelist.input; then
                echo -e "Agregando \e[32m${var_inp}\e[0m a namelist.input"
                sed -i "s/.*\b$var_name\b.*/\t$var_inp,/g" namelist.input
        fi

        done
#tables
cp -p ${tables_path}/wrf/* .
#exes
ln -s ${WRFSRC}/main/real.exe real.exe
ln -s ${WRFSRC}/main/wrf.exe wrf.exe
#sbatchs
cp ${sbatch_path}/sbatch.real .
cp ${sbatch_path}/sbatch.wrf .

cd ..
find wrf/ -print
cd ..
echo " * * * * * * * * * * * * * * * * * * * * * * * * *"
echo " %Fin. "
exit
