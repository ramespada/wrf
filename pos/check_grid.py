from netCDF4 import Dataset
from matplotlib import pyplot as plt
from mpl_toolkits.basemap import Basemap
import numpy as np

#Leo NETCDF
data = Dataset("/home/ramiroespada/stage/runs/prueba01/wrf/wrfinput_d01")
#data=Dataset("/home/ram/Desktop/WRF/pos/pruebas/met_em.d01.2018-10-10_00:00:00.nc")
#Extraigo LAT LON
VAR= 'CLAYFRAC'#'DUST_1_BXS'##'EROD'#, 'SANDFRAC'
lat= data.variables['CLAT'][0,:,:]
lon=data.variables['CLONG'][0,:,:]
var=data.variables[VAR][0,:,:] 
#var=data.variables['EROD'][0,0,:,:] 

# --------------------------------------------------------------------------------#
# Plotear:
m = Basemap(projection='robin',lon_0=-55,resolution='c') 
#projection='hammer',kav7','eck4','moll','geos'
#resolution='l','c','h'
x, y = m(lon,lat)

m.drawmapboundary(color='#202020',fill_color='#add8e6')
m.drawparallels(np.arange(-90,90,20),labels=[1])
m.drawmeridians(np.arange(-230,130,20),labels=[1])
m.fillcontinents(color='#f5f5dc',lake_color='#add8e6')
m.drawcoastlines()
m.drawcountries()
#m.scatter(x[::5,::5],y[::5,::5],marker="x",s=15,c='r',zorder=10,alpha=0.9)
m.contourf(x,y,var,zorder=10,alpha=0.7)
m.colorbar()
plt.title(VAR)

plt.show()

