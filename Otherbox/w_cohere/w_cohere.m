function Cohere_w = w_cohere(x,y,fs_o,Dt,t_step,fs_d,w_name,Scale)

% This function estimates and plots a wavelet-based magnitude-squared (MS)
% coherence "Cohere_w" between two time series "x" and "y" both sampled at
% "fs_o" Hz.
%
% Other required input parameters:
% "Dt" - one half of the time interval in seconds for estimating localized
% power spectra;
% "t_step" - time step in samples at which the coherence will be evaluated;
%
% Optional input parameters:
% "fs_d" - the desired sampling frequency in Hz; used to downsample the
% data. If not specified, the data will not be downsampled;
% "w_name" - the name of a complex wavelet function to be used for the
% decomposition. If nor given the complex Morlet 'cmor1-2' will be used;
% "Scale" - maximum scale for the decomposition; it determines the lowest
% frequency contents. If not specified, the scale from 4 (the finest details)
% to 200 (the coarsest) will be used.
%
% Example: 
% x = 2.4*randn(1,200) + 1*sin(0.4+0.3*(1:200)) + 0.97*sin(0.43*(1:200));
% y = 1.9*randn(1,200) + 0.85*sin(1.8+0.3*(1:200)) + 0.75*sin(1.3+0.43*(1:200));
% Ch = w_cohere(x,y,100,0.005,20,100,'cmor1-2',150);
%
% a modified version of the estimator by Li et al., 2006, "Interaction
% dynamics of neuronal populations analysed using wavelet transforms".
%
% by Gleb Tcheslavski, gleb@vt.edu, February 2010

switch nargin
    case 7
        Scale = 200;                %default for the optional Scale parameter
    case 6
        Scale = 200;
        w_name = 'cmor1-2';         %default wavelet name
    case 5
        Scale = 200;
        w_name = 'cmor1-2';
        fs_d = fs_o;                %default - no resampling
end

w_scale = 4:0.5:Scale;            %scale parameter for wavelet... scale 1 is the finest (HF components); scales less than 4 contradict Nyquist-Shannon theorem
t_start = 1;                %the first time instance to be analyzed...

% downsampling
Q = round(fs_o/fs_d);            %downsampling factor
x = resample(x,1,Q);
y = resample(y,1,Q);

fs = fs_o/Q;          %true new sampling frequency
it = 1/fs;                 %sampling step (period)
dt = round(Dt*fs);          %a half of "digital" time step, samples

% estimating "cwt"...
Wx = cwt(x,w_scale,w_name);            %so called cwt...
Wy = cwt(y,w_scale,w_name);

t_end = size(Wx,2)-2*dt;    %the last time instance

%estimating localized "power spectra"
for t_ind = t_start:t_step:t_end
    wx = Wx(:,t_ind:t_ind+2*dt);              %time localization of cwts'
    wy = Wy(:,t_ind:t_ind+2*dt);
    for s_ind = 1:size(wx,1)
        Sxx = sum(wx(s_ind,:).*conj(wx(s_ind,:)));       %the normalization by scale is omitted since non-important for soherence
        Syy = sum(wy(s_ind,:).*conj(wy(s_ind,:)));
        Sxy = sum(wx(s_ind,:).*conj(wy(s_ind,:)));
        Cohere_w((t_ind-t_start)/t_step+1,s_ind) = abs(Sxy)^2/(Sxx*Syy);
    end
end

% Plotting...
t_scale = (t_start:t_step:t_end)/fs + Dt;       %time scale
f_scale = 2*fs./w_scale;                        %frequency scale
figure; surf(t_scale,f_scale,(Cohere_w')); colorbar; shading flat; view(2); xlim([min(t_scale), max(t_scale)]); ylim([min(f_scale), max(f_scale)])
xlabel('Time localization, sec'); ylabel('Freqency localization, Hz'); set(gca,'ydir','normal'); set(gcf,'position',[100,500,900,300]); set(gca,'position',[.05 .15 .86 .73])
title(['Wavelet-based MS coherence for time windows of ',num2str(2*dt),' samples (', num2str(2*Dt),' seconds) length; spaced by ',num2str(t_step),' samples.'])
