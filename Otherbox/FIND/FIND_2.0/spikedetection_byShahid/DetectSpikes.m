% Spike Detection program: This program read data file, apply high pass filter then detect spike and sort spike.


%% ======== Data file description 
filename ='';   % Data file name
chn=1;          % Channel number of Extracellular signal  
dur = [0 5];    % Duration [start end] of data in sec to be considered for spike detection (best duration {end-start]= 5 sec)  


%% ===== Parameters for Spike Detection 
cutfrq=300;     % Cut-off frequency for high pass filter in Hz
nfft=256;       % Number of FFT point (FFT resolution)
nrpt=2;         % Number of CoB method Repetition to the signal
thrld= 0.45;    % Threshold level  (should be 0.15 to 0.4 if nrpt==1, 
                % and higher value when nrpt is higher but maximum value must be below 1 (around 0.6 is fine))
display =1;     % Choice of output display (figure)

%% ===== Parameters for Clustering 
wpre= 1.5;      % duration (in msec) of the spike prior the spike peak 
wpost=1.5;      % duration (in msec) of the spike post the spike peak 
nclusters=4;    % Number of clustering
clustype=1;     % Choice of Clustering technique (1 or 2)  
                % clustype=2 use superparamagnetic clustering technique, it works only on windows machine
%%============================================

% %------- Read data file
[RawSignal, samp]= ReadFile(filename, chn, dur, display);

% %-------  High Pass filter: Cut-off low frequency signal
HpSignal=highpass(RawSignal, samp, cutfrq);

% %------- Detect Spike Index  (spkidx)
spkidx=spbyrcob(HpSignal, samp, nfft, thrld, nrpt, display);
%spkidx = spbyplain(HpSignal, samp, ndevs_p, ndevs_n, display);

% %------- Sort the spike and cluster it : spikes, index of spikes & cluster number
[spikes, idx, classes]=sortspk(HpSignal, samp, spkidx, wpre, wpost, nclusters, clustype);



