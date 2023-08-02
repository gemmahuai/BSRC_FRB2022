#Archive files to numpy -
##Creating numpy arrays from archive files##
import numpy as np
import psrchive as psr
import sys

file=str(sys.argv[1]) #the .ar file with its full path
DM=float(sys.argv[2])
load_archive = psr.Archive_load(file)
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
wfall = data1[:, int(134277*0.01):int(134277*0.04)]
print(wfall.shape) #shape of numpy array
dt = load_archive.get_first_Integration().get_duration() / load_archive.get_nbin()
print(dt)  #resolution of file
dynamicspec = file+str(dt)+".npy"  #name of numpy array
np.save(dynamicspec,wfall)
