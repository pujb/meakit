function [hpsig]=highpass(signal, samp, cutfrq)
% This function use butterworth (or Eliptic) filter for cut-off lower
% frequency signal (High Pass)

%       hpsig : Output >> High passed signal  
%
%       signal  : Raw Signal to process
%       samp    : Sampling frequency 
%       cutfrq  : Cut-off frequency for high pass filter (Default =300Hz) 
% 
% 
% Example:
%         HpSignal=highpass(RawSignal, samp, cutfrq);
% 
% Developed by Dr. Shahjahan Shahid. (ssh@cs.stir.ac.uk)
% University of Stirling.  
% Last updated 14 Feb 2009.
%=========================================================================


if ~exist('cutfrq'); cutfrq=300; end %#ok<EXIST>
 
%Use Butterworth filter
[b,a]=butter(8,[cutfrq/(samp/2)],'high');  %#ok<NBRAK>
% Use Elliptic (Cauer) filter 
%[b,a]=ellip(2,0.1,40,[fmin_detect fmax_detect]*2/samp);
hpsig =filtfilt(b,a,signal); 
hpsig=hpsig/abs(max(hpsig));       % normalized signal
return


