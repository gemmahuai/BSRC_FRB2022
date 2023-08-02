import psrchive
import numpy as np
import matplotlib.pyplot as plt

import DM_phase
from DM_phase import _dedisperse_waterfall
from DM_phase import get_DM
import sys

file = str(sys.argv[1])
DM_0 = float(sys.argv[2])

print("Here we go!!")

# Load data
load_archive = psrchive.Archive_load(file)
load_archive.pscrunch()
load_archive.set_dispersion_measure(DM_0)
load_archive.dedisperse()
load_archive.remove_baseline()
# load_archive.bscrunch(4)
# load_archive.fscrunch_to_nchan(256)
w = load_archive.get_weights().squeeze() 
data = load_archive.get_data().squeeze()
print(data.shape)
data *= w[..., np.newaxis]
data = data[:, int(134277*0.68):int(134277*0.74)] #time interval containing the frb.
#data = data[:, 73000:75000] #for GMRT cand1
#data = data[:, 98500:100500] #for GMRT cand2 100050:100300
#data = data[:, 17800:21800] #for GMRT cand3 74500:75050
#data = data[:,178:218]
#data = data[:, 129800:132800] #for GMRT cand4
wfall = data

# Load frequencies and time duration
#a = load_archive.get_first_Integration()
dt = load_archive.get_first_Integration().get_duration() / load_archive.get_nbin()
f_ch = np.array([load_archive.get_first_Integration().get_centre_frequency(i) for i in range(load_archive.get_nchan())])
# freq = []
# for f in range(a.get_nchan()):
#      freq.append(a.get_centre_frequency(f))
# freq_array = np.array(freq)
#dt = a.get_duration() / a.get_nbin()

# Plot the waterfall
#plt.imshow(
#    wfall, 
#    extent=[0, dt*wfall.shape[1]*1e3, min(f_ch), max(f_ch)],
#    origin='lower',
#    interpolation="nearest",
#    aspect="auto",
#)
#plt.xlabel('Time (ms)')
#plt.ylabel('Frequemcy (MHz)')
#plt.show()


# Use DM_phase
dm_list = np.arange(-6, 6, 0.01)  # List of DM to search
dm, dm_err = get_DM(wfall, dm_list, dt, f_ch)
bDM = DM_0 + dm
print("Best DM is ", bDM)
# Dedisperse the waterfall to the new value and plot it
wfall_dedisp = _dedisperse_waterfall(wfall, dm, f_ch, dt)
plt.show()

plt.imshow(
    wfall_dedisp,
    cmap="viridis",
    origin="upper",
    aspect="auto",
    interpolation="nearest",
    extent=[0, dt*wfall.shape[1]*1e3, min(f_ch), max(f_ch)]
)
plt.xlabel('Time (ms)')
plt.ylabel('Frequemcy (MHz)')
plt.show()

# Downsample and plot it again
def downsample_waterfall(wfall, t_scrunch=2, f_scrunch=16):
    # Downsample a waterfall
    #wfall = wfall[: wfall.shape[0] // f_scrunch * f_scrunch, : wfall.shape[1] // t_scrunch * t_scrunch]
    wfall = wfall.reshape([wfall.shape[0] // f_scrunch, f_scrunch, wfall.shape[1]]).mean(axis=1)
    wfall = wfall.reshape([wfall.shape[0], wfall.shape[1] // t_scrunch, t_scrunch]).mean(axis=-1)
    return wfall

plt.imshow(
    downsample_waterfall(wfall_dedisp, t_scrunch=4, f_scrunch=16),
    cmap="viridis",
    origin="upper",
    aspect="auto",
    interpolation="nearest",
    extent=[0, dt*wfall.shape[1]*1e3, min(f_ch), max(f_ch)]
)
plt.xlabel('Time (ms)')
plt.ylabel('Frequemcy (MHz)')
# oname = "GBT_G."+str(bDM)+".pdf"
# plt.savefig(oname, bbox_inches='tight', dpi=300)
plt.show()
