function spkidx=spbyrcob(hpsig, samp, nfft, thrld, nrpt, display)

%
%       spkidx  : Output >> index of peak of spike
%
%       hpsig   : High Passed signal  
%       samp    : sampling frequency 
%       nfft    : number of FFT point
%       thrl    : level of threshold (direct amplitude -used at last stage)
%       nrpt    : number of cob repetition 
%       display : logical (true to plot signal and spike)
%
% Example:
%      pkidx=spbyrcob(HpSignal, samp, nfft, thrld, nrpt, display);
%
% Developed by Dr. Shahjahan Shahid. (ssh@cs.stir.ac.uk)
% University of Stirling.  
% Last updated 18 Feb 2009.

spdur = 1;             % detector dead time (in ms) it is assumed that the ISI is minimum 1 ms 
ref = floor(spdur *samp/1000);      % In data  point

%==================== spike detection ==========================
signal= hpsig;
pktrain=zeros(size(signal,1), nrpt);   allspid=signal*0; spid=[]; 

for n=1:nrpt     
    mat=[]; for i=1:length(spid), mat=[mat; spid(i)+[-ref:0]]; end
    signal(mat)=0;

    [spid pktr]=spbycob(signal, nfft, thrld); 

    pktrain(:, n)=pktr(:);
    allspid(spid)=1;
end
if size(pktrain,2)>1; pktrain=max(pktrain'); end %#ok<UDIM>
index=find(allspid>0); 

if ~isempty(index)
    %index=[index idx(end)];
    % --- Reject the events which are too close
    simp=find(diff(index)<=ref);
    simp =[simp simp+1]';
    [v in]=min(pktrain(index(simp)));
    nanid=(in+simp(1,:)-1);
    % --- check if neighbour events are also spikes
    if ~isempty(simp)
        %index(nanid(v<(max(pktrain(index(simp)))+thrld)/2))=[];
        index(nanid)=[];
    end
end
    %==================== spike detection end ==========================

spkidx=index; 

if display
    sp_train= zeros(1, length(hpsig)); sp_train(spkidx)=pktrain(spkidx);
    try
        signaldisp([0.5*hpsig sp_train(:)]*100)
    catch
        plot(hpsig); hold on, plot(sp_train, 'color', [.65 .65 .65]),
    end
    title([' Signal & Spikes']) ;
end
return

% ===================  Functions ====================================
function [spkidx peaktrain]=spbycob(signal,  nfft, thrl)
%
%  spikes = spbycob(signal, nfft, thrl, display)
%  find the spike index in data using
%
%       spkidx  : Output >> index of peak of spike
%       signal  : Signal (spike train to be analyzed)
%       nfft    : number of fourier point
%       thrl    : level of threshold (direct amplitude -used at last stage)
%
% Example:
%  spkidx = spbycob(hpsig, 256, .03, 1);
%

% Developed by Dr. Shahjahan Shahid.
% University of Stirling.  
% Last updated 14 Oct 2008.
%=========================================================================


if exist('signal')~=1 ||...
        exist('nfft')~=1 ||...
        exist('thrl')~=1
    disp(['Invalid format of input arguments....']); return;
end


try
    step=[];
    signal=signal-mean(signal);
    signal =signal(:);
    lt=length(signal);
    % ------------------ Inverse Filter -----------------------------
    step=1;
    [iht]=ifilt(signal,nfft);

    %----------------------Noisy Impulse find -----------------------
    step=2;
    signal=[signal(1:end-1)+signal(2:end); 0]*.5;
    ft=conv(signal,iht);
    ft=ft(:); ft=[zeros(nfft/2+6,1); ft((nfft+1):(end-nfft))];

    %================Denoising =====================
   
    step=3;
    xtra0=length(ft)-nfft*(floor(length(ft)/nfft));
    if xtra0>0; ft=[ft; zeros(2^nextpow2(xtra0)-xtra0,1)]; end;    % Zero padding to use wevelet function

    %[s] = wden(ft,'rigrsure','s','mln',n,'bior1.5');

    temp=ft; [a,d]=swt(ft, 3, 'coif1');
    if abs(skewness(temp))<1
        for n=1:3
            s=iswt(a(n,:), zeros(1, length(d)), 'coif1')';
            if abs(skewness(s))> abs(skewness(temp))
                temp=s;
                if abs(skewness(s))>=1; break; end
            end
        end
    end

    if abs(skewness(temp))<1
        for n=1:3
            s=iswt( zeros(1, length(d)), d(n,:), 'coif1')';
            if abs(skewness(s))> abs(skewness(temp))
                temp=s; %disp('used D');
                if abs(skewness(s))>=1; break; end
            end
        end
    end
    ft=temp;

    %----------------------Noise Suppressing -------------
    step=4;
    f(lt,1)=0;  f(1:length(ft))=ft;
    t1=f.*(f>=0);                    %t1 matches at s(nfft/2+7:end -nfft/2-6) for WT &   s(nfft/2:end -nfft/2)
    %g=sort(t1,'descend'); t=(10*t1/min(g(1:10)));
    t=t1/max(t1);


    abovethrl= find(t>0); h=[abovethrl(1);  abovethrl(2:end).*(diff(abovethrl)~=1)]; pulses=h(h>0);
    sp_id=[]; for i=2:length(pulses); [val ind]=max(t(pulses(i-1):pulses(i))); sp_id(i-1)=pulses(i-1)+ind-1; end
    sp_id=[sp_id, pulses(end)];
    peaktrain= zeros(lt, 1); peaktrain(sp_id)= t(sp_id);
    %peaktrain=peaktrain/max(abs(peaktrain));

    %----------------------Noise thresholding -------------
    step=5;
    % ===== sort events  which come due to noise term ======

    idx=find(peaktrain>thrl); idx=idx(:)';

    if length(idx)>1;
        %------------- find best spikes events among neighbour spikes events
        spend=find((diff(idx)-1)>0);
        spstrt=[1, 1+spend(1:end-1)];
        index=zeros(size(spstrt));
        for c =1 : length(spstrt);
            [v in]=max(peaktrain(idx(spstrt(c):spend(c))));
            index(c)=idx(spstrt(c))+in-1;
        end
    else index=idx;
    end

    if ~isempty(index)
        index=[index idx(end)];
        % --- Reject the events which are too close
        simp=find(diff(index)<=12);
        simp =[simp; simp+1];
        [v in]=min(peaktrain(index(simp)));
        nanid=(in+simp(1,:)-1);
        % --- check if neighbour events are also spikes
        if ~isempty(simp)
        index(nanid(v<(max(peaktrain(index(simp)))+thrl)/2))=[];
        end
    end
    spkidx=index; 
    tmp=peaktrain*0; tmp(spkidx)=peaktrain(spkidx); peaktrain=tmp;
    
catch
    if step==1; disp('Error at function [iht]=ifilt(signal,nfft)');
    elseif step==2; disp('Error on blind equatization');
    elseif step==3; disp('Error on denoising by wavelet');
    elseif step==4; disp('Error on noise suppression ');
    elseif step==5; disp('Error on thresholding');
    else disp('Error on running');
    end
    return;

end

return


%================== FUNCTION Inverse Filter Estimation ==================

function [ht1, flag]=ifilt(x,nfft)
%
%
%

flag=0;
[bx,bc]=bg(x,nfft);
if sum(real(bx(:)))<0
    [bx,bc]=bg(-x,nfft); flag=1;
end

lb=log(bx); b=ifft(lb);
hx=([b(1,1:end)]); cbhx=hx(2:end)-real(b(1,1)); cbhx=[hx]; cbhx=cbhx-mean(cbhx); chx=exp(cbhx);


% ----------- Fourier Phase Estimation ---------------------

N=nfft/2;

if rem(N,2)==0
    Nby2=N+1;
else
    Nby2=N;
end
r=1;
Nby4=fix(Nby2/2)+1;
R=2*sum(1:Nby4-1)+Nby4-Nby2+1;

psi=zeros(R,1);
amat=zeros(R,Nby2);
for k=2:Nby4
    for l=2:k
        r=r+1;
        psi(r,1)=angle(bx(l,k));
        amat(r,k)=amat(r,k)+1;
        amat(r,l)=amat(r,l)+1;
        amat(r,l+k-1)=amat(r,l+k-1)-1;
    end
end
for k=Nby4+1:Nby2-1
    for l=2:(Nby2+1-k)
        r=r+1;
        psi(r,1)=angle(bx(l,k));
        amat(r,k)=amat(r,k)+1;
        amat(r,l)=amat(r,l)+1;
        amat(r,l+k-1)=amat(r,l+k-1)-1;
    end
end

amat(1,1)=1; psi(1,1)=angle(bx(1,1));

%-------------------- phase unwrapping -----------------------
PHI=[angle(chx(1:end)) 0];
kwrap = fix( (amat*PHI' - psi(1:end)) /(2*pi));
phi = amat(:,1:Nby2-1) \ (psi(1:end) + 2*pi*kwrap);

%--------------- Magnitude & Phase for IFFT ------------------
mag=abs(chx);
mag=[mag]';  mag = [mag(1:Nby2-1); flipud(mag(1:Nby2-2))];
phz = [phi(1:Nby2-1); -flipud(phi(1:Nby2-2))];
chx =( 1./mag) .* exp(-sqrt(-1)*phz);
%chx =( mag) .* exp(sqrt(-1)*phz);


ht1=ifft(chx);
%ht1=(ifftshift(ht1));
ht1=real(ifftshift(ht1));
if flag==1  ht1=-ht1;  end

return


    %=================== FUNCTION Bispectrum Estimation ===================

 function [Bx,Bc, Px]=bg(data, nfft)
%
%
%


if isempty(data) error('No data to analyze'); end

[Row, Col]= size(data); if (min(Row, Col)~=1) data=data(:); end

len=length(data);
if (floor(len/nfft)==0) error('short data length'); end

%------------------------------- Data Segmentation in M Realization and K Samples each =======

samp=nfft;                % Samples per realization
realz=fix(length(data)/samp);                  % Number of realization
data=data(1:samp*realz);
data=reshape(data,samp,realz);


%------------------------------- Window setting -------------------------------

wind=hann(samp); wind=wind(:);

%------------------------------- Spectrum -------------------------------

if (rem(nfft,2)~=0)
    mrow =fix(nfft/2)+1;
else
    mrow=nfft/2;
end
ncol=mrow;

Px = zeros(nfft,1);
Bx = zeros(mrow,ncol);

mask = hankel([1:mrow],[mrow:mrow+ncol-1] );   % the hankel mask (faster)

Nsamp = [1:samp]';
for Nrealz = 1:realz
    xseg = data(Nsamp)- mean(data(Nsamp)); % Subtract mean value from each record
    xseg   = xseg.*wind;                   % Passing data through window
    Xf     = fft(xseg, nfft)/samp;
    CXf    = conj(Xf);

    Bx  = Bx + (Xf(1:mrow) * Xf(1:ncol).').* CXf(mask);
    Px = Px + Xf.*CXf;

    Nsamp = Nsamp + samp;
end

Px = Px/(realz);        % averaging
Bx = Bx/(realz);        % Bispectrum averaging

%------------------------------- find out the Bicoherence -------------------------------

nm=(Px(1:mrow)*Px(1:ncol).').*Px(mask);
Bc=Bx.^2./(nm);

return


