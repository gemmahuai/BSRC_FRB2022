
import numpy as np
from astropy import units as u
import sys
from sigpyproc.Readers import FilReader 
import datetime as dt

if (len(sys.argv)!=7):
    print('Wrong inputs!')
    print('Usage: python ToA_calc.py filename(.fil) ToA(s) ToA(mjd) f1(MHz) f2(MHz) DM(cm^-3 pc)')
    sys.exit()
starttime = dt.datetime.now()

file, toa, toa_mjd, f1, f2, DM  = str(sys.argv[1]), float(sys.argv[2]), float(sys.argv[3]), float(sys.argv[4]), float(sys.argv[5]), float(sys.argv[6])

def ToA_calc(file, toa, tmjd, f1, f2, DM):
    """Calculates the expected arriving time at another frequency band given the dispersion measure. 
    
    Parameters
    ----------
    toa = time of arrival at the top of the measured band in second (in its corresponding .fil file) 
    tmjd= time of arrival at the top of the measured band in MJD
    f1  = starting frequency (highest freq) in MHz of the target band 
    f2  = starting frequency (highest freq) in MHz of the measured band
    DM  = dispersion measure of the pulsar at the measured band in cm^{-3}pc
    
    Returns the calculated time of arrival in MJD at f1 of the interested band. 
    """
    f = FilReader(file)
    Ttot = f.header['tobs'] # in sec
    Tstart = f.header['tstart'] #mjd
    f1,f2 = f1/1000,f2/1000 # GHz
    delta_t = (4.15 * DM * ((1/f1**2) - (1/f2**2))) * u.millisecond #in ms
    t_mjd = tmjd + delta_t.to(u.day).value # in mjd
    t_mjd_arrival = t_mjd - Tstart 
    t = t_mjd_arrival * 24*3600 # in second
    #t = toa + delta_t.value/1000 # in seconds
    #if t>Ttot:
    #    t -=Ttot
    #    print('Go to the next FIL file')
    #    return(0)
    if (t_mjd<Tstart)|(t<0):
        t = np.abs(t)
        print('Please go to the previous FIL file.')
        return(0,t_mjd)
    return(t,t_mjd)


f = FilReader(file)
Ttot = f.header['tobs'] # in sec

t = ToA_calc(file, toa, toa_mjd, f1, f2, DM)
endtime = dt.datetime.now()
#print('The arriving time is {:.3f} s, which is {} in MJD'.format(t[0],t[1]))
print(t[0])
#print('Running time {:.2f} us'.format((endtime-starttime).microseconds))
