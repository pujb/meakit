

Spike sorting from Raw Signal:


Start from file DetectSpikes.m 

Four steps are involved 

  1. Load Raw signal   The data file must have at least 
  2. Use High Pass filter to cut-out the low frequency signal from the raw signal  (Plain or CoB method)
  3. Detect Spike in high passed signal
  4. Sort and cluster the spikes.

Matlab code 

  load(‘testdata.mat’);                                    % use appropriate path 
  [hpsig]=highpass(signal, samp, 300);
  spkidx = spbycob(hpsig, 256, .03, 1);                    % spike detection by CoB Method
  %  spkidx = spbyplain(hpsig, samp, 2.5, 2.5, 1);         % spike detection by  plain method
  [spikes, idx, classes]=sortspk(hpsig, spkidx, samp, 1, 1, 4);

List of Files:
  DetectSpikes.m 
  ReadFile.m      
  highpass.m      
  spbyrcob.m
  sortspk.m         
  
  signaldisp.m    
  signaldisp.fig 
  signaldisp1.m    
  signaldisp1.fig  
  Cluster.exe
  testdata.mat    
  
  Readme.txt



----------------------------------------
Dr. Shahjahan Shahid (ssh@cs.stir.ac.uk)
18 Feb 2009. 