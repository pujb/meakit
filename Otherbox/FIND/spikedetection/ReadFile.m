function [RawSignal samp]= ReadFile(filename, extch, dur, show)
%
%       RawSignalx  : Output >> Raw signal (Extracellular signal)
%       samp        : Output >> Sampling frequency
%
%       Filename    : Data file name (File should contain extracellular signal and sampling frequency)     
%       extch       : channel number  
%       dur         : duration of data to read
%       show        : logical indication for display data (applying a HP filter 300Hz cut-off frequency.

%
% Developed by Dr. Shahjahan Shahid. (ssh@cs.stir.ac.uk)
% University of Stirling.  
% Last updated 14 Feb 2009

RawSignal=[];  samp=[];
if ~exist('extch')||~exist('dur'); disp('Invalid input argument'); return; end %#ok<EXIST,EXIST>
if max(size(dur))~=2;  disp('Invalid Parameter ''dur'''); return; end
if ~exist('show'); show=0; end %#ok<EXIST>

if ~exist('filename') || isempty(filename) %#ok<EXIST>
    [FileName,PathName] = uigetfile({'*.mat'; '*.dat'}, 'File Selector');
    filename=[PathName,FileName]; 

end
if ~ischar(filename) || ~exist(filename, 'file'); return; end
%[pathstr, name, ext] = fileparts(filename);

%read the file
x=load(filename);
if isfield(x, 'setsignal'); sig=x.setsignal;
elseif isfield(x, 'data'); sig=x.data;
elseif isfield(x, 'signal'); sig=x.signal;
else disp('data format mismatch'); return
end
if isfield(x, 'samp'); samp=x.samp;
else disp('File does not contain data of Sampling Frequency');
    disp('Default Sampling Frequency (24KHz) is assumed');
    samp=24e3;
end
dtpoint=(dur(1)*samp+1): (dur(2)*samp);
RawSignal=sig(dtpoint, extch);
clear x sig

if show
    %Filter the raw Signal
    [b,a]=butter(8,[300/(samp/2)],'high'); %#ok<NBRAK>
    filtRaw=filtfilt(b,a,RawSignal);

    data=filtRaw/max(abs(filtRaw));

    h = findobj('name', [FileName ' (applying a high pass filter)']); if ~isempty(h); close (h); end
    fid=signaldisp1(data, samp);
    set(fid, 'name', [FileName ' (applying a high pass filter)']);
end

