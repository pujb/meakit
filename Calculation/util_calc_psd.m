function util_calc_psd( signal, Fs )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

window=rectwin(100); %矩形窗
window1=hamming(100); %海明窗
window2=blackman(100); %blackman窗

n = 0:1/Fs:1;
noverlap = 20; %数据无重叠
nfft = 1024;
range = 'onesided'; %频率间隔为[0 Fs/2]，只计算一半的频率

[Pxx, f] = pwelch(signal, window, noverlap, nfft, Fs, range);
[Pxx1,f] = pwelch(signal, window1, noverlap, nfft, Fs, range);
[Pxx2,f] = pwelch(signal, window2, noverlap, nfft, Fs, range);

plot_Pxx=10*log10(Pxx);
plot_Pxx1=10*log10(Pxx1);
plot_Pxx2=10*log10(Pxx2);

figure(1)
plot(f,plot_Pxx);

pause;

figure(2)
plot(f,plot_Pxx1);

pause;

figure(3)
plot(f,plot_Pxx2);


end

