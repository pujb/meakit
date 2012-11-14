close all;
clear all;
clc;



%This code calculates multivariate sample entropy over different scales of
%bivariate correlated and uncorrelated 1/f as well as white noise.

for kk=1:20
 x1=powernoise(1,5000);
 x2=powernoise(1,5000);
 
x=[x1 x2];
[n,b]=size(x);

m1 = min(x(:,1)); M1= max(x(:,1));
x(:,1)= (x(:,1)-m1)/(M1-m1);
m2 = min(x(:,2)); M2= max(x(:,2));
x(:,2)= (x(:,2)-m2)/(M2-m2);

x=zscore(x);

sd = sum(std(x));
r = 0.15*sd; 
epsilon=15;
for j=1:epsilon
   for p=1:b
     for ii=1:n/j
     y(ii)=0;
         for k=1:j
            y(ii)=y(ii)+x((ii-1)*j+k,p);
         end
     y(ii)=y(ii)/j;
     end
  z=y(1:floor(n/j));
  X(:,p)=z;
  end
M = [2 2];
tau=[1 1];
e=mvsampen_full(M,r,tau,X');
SE(j)=e;
clear X;
end
MSEup(kk,:)=SE;
end

clear kk x y b sd n tau epsilon i ii k p j z r m e SE x1 x2 m1 m2 M1 M2;



for kk=1:20
 x1=randn(5000,1);
 x2=randn(5000,1);
 
 x=[x1 x2];


[n,b]=size(x);

m1 = min(x(:,1)); M1= max(x(:,1));
x(:,1)= (x(:,1)-m1)/(M1-m1);
m2 = min(x(:,2)); M2= max(x(:,2));
x(:,2)= (x(:,2)-m2)/(M2-m2);

x=zscore(x);

sd = sum(std(x));
r = 0.15*sd; 
epsilon=15;
for j=1:epsilon
   for p=1:b
     for ii=1:n/j
     y(ii)=0;
         for k=1:j
            y(ii)=y(ii)+x((ii-1)*j+k,p);
         end
     y(ii)=y(ii)/j;
     end
  z=y(1:floor(n/j));
  X(:,p)=z;
  end
M = [2 2 ];
tau=[1 1 ];
e=mvsampen_full(M,r,tau,X');
SE(j)=e;
clear X;
end
MSEuw(kk,:)=SE;
end

clear kk x y b sd n tau epsilon i ii k p j z r m e SE x1 x2 m1 m2 M1 M2;


for kk=1:20
    
N=5000;
x1=powernoise(1,5000);
x2=powernoise(1,5000);
x=[x1';x2'];

x=x-repmat(mean(x,2),1,N);
[U, D]=eig((x*x')/N);
x=D^(-0.5)*U'*x;


Xc=[1 0.95];
Xc=transpose(Xc)*Xc;
Xc=Xc-diag(diag(Xc))+diag(ones(1,2));
[U,S,V] = svd(Xc);
x=U*(S^0.5)*x;

xc=x(1,:)+i*x(2,:);

x1=real(xc);
x2=imag(xc);

x=[x1' x2'];

[n,b]=size(x);

m1 = min(x(:,1)); M1= max(x(:,1));
x(:,1)= (x(:,1)-m1)/(M1-m1);
m2 = min(x(:,2)); M2= max(x(:,2));
x(:,2)= (x(:,2)-m2)/(M2-m2);

x=zscore(x);

sd = sum(std(x));
r = 0.15*sd; 
epsilon=15;
for j=1:epsilon
   for p=1:b
     for ii=1:n/j
     y(ii)=0;
         for k=1:j
            y(ii)=y(ii)+x((ii-1)*j+k,p);
         end
     y(ii)=y(ii)/j;
     end
  z=y(1:floor(n/j));
  X(:,p)=z;
  end
M = [2 2 ];
tau=[1 1 ];
e=mvsampen_full(M,r,tau,X');
SE(j)=e;
clear X;
end
MSEcp(kk,:)=SE;
end

clear kk x y b sd n tau epsilon i ii k p j z r m e SE x1 x2 m1 m2 M1 M2;


for kk=1:20
    
N=5000;

x=randn(2,N);
x=x-repmat(mean(x,2),1,N);
[U, D]=eig((x*x')/N);
x=D^(-0.5)*U'*x;


Xc=[1 0.95];
Xc=transpose(Xc)*Xc;
Xc=Xc-diag(diag(Xc))+diag(ones(1,2));
[U,S,V] = svd(Xc);
x=U*(S^0.5)*x;

xc=x(1,:)+i*x(2,:);

x1=real(xc);
x2=imag(xc);

x=[x1' x2'];
[n,b]=size(x);

m1 = min(x(:,1)); M1= max(x(:,1));
x(:,1)= (x(:,1)-m1)/(M1-m1);
m2 = min(x(:,2)); M2= max(x(:,2));
x(:,2)= (x(:,2)-m2)/(M2-m2);

x=zscore(x);
sd = sum(std(x));
r = 0.15*sd; 
epsilon=15;
for j=1:epsilon
   for p=1:b
     for ii=1:n/j
     y(ii)=0;
         for k=1:j
            y(ii)=y(ii)+x((ii-1)*j+k,p);
         end
     y(ii)=y(ii)/j;
     end
  z=y(1:floor(n/j));
  X(:,p)=z;
  end
M = [2 2];
tau=[1 1];
e=mvsampen_full(M,r,tau,X');
SE(j)=e;
clear X;
end
MSEcw(kk,:)=SE;
end

clear kk x y b sd n tau epsilon i ii k p j z r m e SE x1 x2 m1 m2 M1 M2;



AMSEcp= mean(MSEcp,1);
Astdcp=std(MSEcp,1,1);

AMSEup= mean(MSEup,1);
Astdup=std(MSEup,1,1);

AMSEcw= mean(MSEcw,1);
Astdcw=std(MSEcw,1,1);

AMSEuw= mean(MSEuw,1);
Astduw=std(MSEuw,1,1);


figure
set(gca,'ylim',[0 2.5], 'xlim', [0 16])
errorbar(AMSEcp,Astdcp,'-Vr','DisplayName','Correlated bivariate 1/f noise')
%plot(MSEw,'-xr')
hold on
set(gca,'ylim',[0 2.5], 'xlim', [0 16])
errorbar(AMSEup,Astdup,'--ob','DisplayName','Uncorrelated bivariate 1/f noise')
%plot(MSEp,'-dg')
hold on
set(gca,'ylim',[0 2.5], 'xlim', [0 16])
errorbar(AMSEcw,Astdcw,':dm','DisplayName','Correlated bivariate white noise')

hold on
set(gca,'ylim',[0 2.5], 'xlim', [0 16])
errorbar(AMSEuw,Astduw,'-.sc','DisplayName','Uncorrelated bivariate white noise')

xlabel('Scale factor')
ylabel('Multivariate sample entropy')
legend('show');





