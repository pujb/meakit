function [H,sigma]=hurst(d, k)
% Unbiased estimator of the Hurst exponent.
%
% Usage: 
%     [H,sigma]=hurst(d [,k])
%
% INPUTS:
% .    d: data
% .    k: scales which will be used in the determination.
% .       (k may also be of the form [mink maxk] or simly [maxk] which will
% .        run faster than explicitly specifying the scales)
%  
% INPUTS:
% .    H: hurst exponent estimate.
% .    sigma: standard dev estimate.
%  
% Will make a plot if called with no output arguments.
%
% Author: Aslak Grinsted 2007
%
% using iterative method described in Koutsoyiannis 2003:
% <a href="http://dx.doi.org/10.1623/hysj.48.1.3.43481">http://dx.doi.org/10.1623/hysj.48.1.3.43481</a>
% <a href="http://www.itia.ntua.gr/getfile/537/2/2003HSJHurstSuppl.pdf">suppl</a>
% <a href="http://www.itia.ntua.gr/getfile/537/3/2003HSJHurstPP.pdf">preprint</a>
%
% I also really recommend reading this <a href="http://tamino.wordpress.com/2008/06/10/hurst/">blog</a> entry on Hurst exponents. 

% return
if nargin==0
    fprintf('No input arguments for hurst. -Loading stockreturns as an example!...\n')
    d=load('stockreturns.mat');d=d.stocks(:,1);
%    d=loadproxy('nautadata.txt');d=d(:,2);%hurst(d(:,2))
end
d=d(:);

N=length(d);

if nargin<2
    k=[1 floor(N/10)];
end
k=k(:);
if length(k)>2
    sk=zeros(size(k));
    for jj=1:length(k) %slow method but works always....
        %      ds2=moving(d,k(jj));ds2(isnan(ds2))=[];
        %      sk(jj,2)=std(ds2(~isnan(ds2)))*k(jj);
        ds=filter(ones(k(jj),1),1,d); %moving
        ds(1:k(jj)-1)=[];
        sk(jj)=std(ds); %dont need to multiply because filter is summing
    end
else
    if length(k)<2
        k=[1 k];
    end
    if k(1)==1
        ds=zeros(size(d,1)+1,1);
    else
        ds=filter(ones(k(1)-1,1),1,d); %moving
        ds(1:k(1)-2)=[];
    end
    k=(k(1):k(2))';
    sk=zeros(size(k));
    for jj=1:length(k)
        ds(end)=[];
        ds=ds+d(k(jj):end); %moving
        %sk(jj)=std(ds(1:end-2)+ds(3:end)-ds(2:end-1)*2); 
        sk(jj)=std(ds); 
    end
end
lnsk=log(sk);
p=2;
kp=k.^p; %weight from paper
lnk=log(k);
a11=sum(1./kp);
a12=sum(lnk./kp);
%H=polyfit(lnk,lnsk,1); H=H(1); %traditional simplistic estimate
H=0.5; lastH=inf;
itercount=0;
while abs(H-lastH)>0.00001
    lastH=H;
    H=min(H,1);
    ck=sqrt((N./k-(N./k).^(2*H-1))./(N./k-.5));
    lnck=log(ck);
    dk=lnk+log(N./k)./(1-(N./k).^(2-2*H));
    b1=sum(lnsk./kp)-sum(lnck./kp);
    b2=sum(dk.*lnsk./kp)-sum(dk.*lnck./kp);
    a21=sum(dk./kp);
    a22=sum(dk.*lnk./kp);
    H=(a11*b2-a21*b1)/(a11*a22-a21*a12);
    itercount=itercount+1;
    if itercount>50
        error('Hurst.m failed to converge.')
    end
end

sigma=exp((b1-a12*H)/a11);

if nargout==0
    %p=[H log(sigma)];
    [g,a]=ar1(d); vv=a^2/(1-g^2);
    g0k=vv * (k.*(1-g^2)-2*g*(1-g.^k))/((1-g)^2) ; %theoretical ar1 .. eq10 (hurst made easy paper)
    fit=ck.*(k.^H)*sigma; %eq.14
    loglog(k,sk,'.-',k,fit,'k-',k,sqrt(g0k),'r:')
    
    text(k(round(end*.7)),sk(round(end*.7)),'Empirical','horiz','right','vert','bottom','color',[0 0 1])
    text(k(end),fit(end),sprintf('SSS, H=%.2f \\sigma=%s',H,num2str(sigma,4)),'horiz','right','vert','bottom')
    text(k(end),sqrt(g0k(end)),sprintf('AR1, \\gamma=%.2f',g),'horiz','right','color',[1 0 0],'vert','top')
    
%    text(0.5,0.6,sprintf('H=%.2f \\sigma=%s',H,num2str(sigma,4)),'horiz','right','units','normalized')
    xlabel('k')
    ylabel('s_k')
    clear H avgsigma sigma
    axis tight
end

