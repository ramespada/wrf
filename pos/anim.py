import numpy as np
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation
from mpl_toolkits.basemap import Basemap
from netCDF4 import Dataset

def getData(filepath,varname='TOT_DUST'):
    data = Dataset(filepath)       
   
    z=0 #Seteo altura.
    
    lat=data.variables['XLAT'][0,:,:];
    lon=data.variables['XLONG'][0,:,:];
    u=data.variables['U'][:,z,:,:]; u=u[:,:,1:]
    v=data.variables['V'][:,z,:,:]; v=v[:,1:,:]

    var=data.variables[varname][:,z,:,:];
    
    return lat,lon,u,v,var

def buildMap(minlat,maxlat,minlon,maxlon,lat0,lon0):
    mymap = Basemap(projection='tmerc',
                lon_0=lon0,lat_0=lat0,
                urcrnrlon=maxlon,llcrnrlon=minlon,
                urcrnrlat=maxlat,llcrnrlat=minlat,
                resolution='l')
    return mymap

def drawMap(mymap):
    mymap.drawcoastlines(); mymap.drawmapboundary();mymap.drawcountries()
    mymap.drawparallels(range(int(m.latmin),int(m.latmax), 10), labels=[1, 0, 0, 0])
    mymap.drawmeridians(range(int(m.lonmin),int(m.lonmax), 10), labels=[0, 0, 0 , 1])

def init():
    ax.clear()
    drawMap(m)
    ax.pcolormesh(x, y, var[0,:,:], alpha=0.8)

def animate(i):
    ax.clear()
    drawMap(m)
    ax.pcolormesh(x, y, var[i,:,:], alpha=0.8)
    ax.barbs(x[::4,::4],y[::4,::4],u[i,::4,::4],v[i,::4,::4],length=4,alpha=0.5)
    ax.annotate(s='t: '+str(i),xy=(m.latmin,m.lonmax))
     
lat, lon, u, v, var = getData(filepath="/home/ramiroespada/stage/runWRF/dust_gocart_20181010/wrf/wrfout_d01_2018-10-10_00:00:00",varname='TOT_DUST')
var=np.ma.masked_where(var<30,var)
fig, ax = plt.subplots()
m = buildMap(minlat=-55,maxlat=-20., minlon=-90.,maxlon=-50.,lat0=-40,lon0=-65)
drawMap(m)
x, y = m(lon,lat)
    
FuncAnimation(fig, animate, init_func=init,
             frames=var.shape[0],
             interval=2e+2,
             blit=False,repeat=True)
    
plt.show()

