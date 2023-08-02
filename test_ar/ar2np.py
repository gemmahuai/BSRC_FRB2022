#Archive files to numpy -
##Creating numpy arrays from archive files##
import numpy as np
import psrchive as psr
import sys

arfile = str(sys.argv[1])
DM = float(sys.argv[2])
load_archive = psr.Archive_load(arfile)
load_archive.pscrunch()   #scrunches polarization channel
#load_archive.fscrunch_to_nchan()  #scrunch frequency channel
#load_archive.bscrunch()  #scrunch in time 
load_archive.set_dispersion_measure(DM)  #set dispersion measure
load_archive.dedisperse()  #dedisperese the file
load_archive.remove_baseline()
w = load_archive.get_weights().squeeze()
data1 = load_archive.get_data().squeeze()
print(data1.shape)   
data1 *= w[..., np.newaxis]
wfall = data1
wfall = wfall[:, 18350:20971] # for the upward drifting frb: extract phase from 0.28 to 0.32
print(wfall.shape) #shape of numpy array
dt = load_archive.get_first_Integration().get_duration() / load_archive.get_nbin()
print(dt)  #resolution of file
dynamicspec = arfile+str(dt)+".npy"  #name of numpy array
np.save(dynamicspec,wfall)
