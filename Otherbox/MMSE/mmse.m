close all;
clear all;
clc;

num_datapoints = 5000; % changed by Pu to evaluate the program.

%This script generates  multi-channel white and 1/f noise realisations and calculates multivariate sample entropy 
%estimates for different temporal scales. 

for kk=1:20

x=randn(num_datapoints,3);
[n,b]=size(x);

m1 = min(x(:,1)); M1= max(x(:,1));
x(:,1)= (x(:,1)-m1)/(M1-m1);
m2 = min(x(:,2)); M2= max(x(:,2));
x(:,2)= (x(:,2)-m2)/(M2-m2);
m3 = min(x(:,3)); M3= max(x(:,3));
x(:,3)= (x(:,3)-m3)/(M3-m3);


x=zscore(x);

sd = sum(std(x));
r = 0.15*sd; 
epsilon=20;
for j=1:epsilon
   for p=1:b
     for i=1:n/j
     y(i)=0;
         for k=1:j
            y(i)=y(i)+x((i-1)*j+k,p);
         end
     y(i)=y(i)/j;
     end
  z=y(1:floor(n/j));
  X(:,p)=z;
  end
M = [2 2 2 ];
tau=[1 1 1 ];
e=mvsampen_full(M,r,tau,X');
SE(j)=e;
clear X;
end
MSEw(kk,:)=SE;
end

clear kk x sd n tau epsilon j z r m e SE xx m1 m2 m3 M1 M2 M3;

for kk=1:20
x1= powernoise(1, num_datapoints);
x2= powernoise(1, num_datapoints);
x3= powernoise(1, num_datapoints);

x=[x1 x2 x3];

[n,b]=size(x);

m1 = min(x(:,1)); M1= max(x(:,1));
x(:,1)= (x(:,1)-m1)/(M1-m1);
m2 = min(x(:,2)); M2= max(x(:,2));
x(:,2)= (x(:,2)-m2)/(M2-m2);
m3 = min(x(:,3)); M3= max(x(:,3));
x(:,3)= (x(:,3)-m3)/(M3-m3);

x=zscore(x);

sd = sum(std(x));
r = 0.15*sd; 
epsilon=20;
for j=1:epsilon
   for p=1:b
     for i=1:n/j
     y(i)=0;
         for k=1:j
            y(i)=y(i)+x((i-1)*j+k,p);
         end
     y(i)=y(i)/j;
     end
  z=y(1:floor(n/j));
  X(:,p)=z;
  end
M = [2 2 2 ];
tau=[1 1 1 ];
e=mvsampen_full(M,r,tau,X');
SE(j)=e;
clear X;
end
MSEp(kk,:)=SE;
end

clear kk x sd n tau epsilon j z r m e SE xx m1 m2 m3 M1 M2 M3;

for kk=1:20
x1= powernoise(1, num_datapoints);
x2= powernoise(1, num_datapoints);
x3=randn(num_datapoints,1);
x=[x1 x2 x3 ];

[n,b]=size(x);

m1 = min(x(:,1)); M1= max(x(:,1));
x(:,1)= (x(:,1)-m1)/(M1-m1);
m2 = min(x(:,2)); M2= max(x(:,2));
x(:,2)= (x(:,2)-m2)/(M2-m2);
m3 = min(x(:,3)); M3= max(x(:,3));
x(:,3)= (x(:,3)-m3)/(M3-m3);

x=zscore(x);

sd = sum(std(x));
r = 0.15*sd; 
epsilon=20;
for j=1:epsilon
   for p=1:b
     for i=1:n/j
     y(i)=0;
         for k=1:j
            y(i)=y(i)+x((i-1)*j+k,p);
         end
     y(i)=y(i)/j;
     end
  z=y(1:floor(n/j));
  X(:,p)=z;
   end
M= [2 2 2];
tau=[1 1 1];
e=mvsampen_full(M,r,tau,X');
SE(j)=e;
clear X;
end
MSEm1(kk,:)=SE;
end

clear kk x sd n tau epsilon j z r m e SE xx m1 m2 m3 M1 M2 M3;

for kk=1:20
x1= powernoise(1, num_datapoints);
x2=randn(num_datapoints,1);
x3=randn(num_datapoints,1);
x=[x1 x2 x3 ];

[n,b]=size(x);

m1 = min(x(:,1)); M1= max(x(:,1));
x(:,1)= (x(:,1)-m1)/(M1-m1);
m2 = min(x(:,2)); M2= max(x(:,2));
x(:,2)= (x(:,2)-m2)/(M2-m2);
m3 = min(x(:,3)); M3= max(x(:,3));
x(:,3)= (x(:,3)-m3)/(M3-m3);

x=zscore(x);

sd = sum(std(x));
r = 0.15*sd; 
epsilon=20;
for j=1:epsilon
   for p=1:b
     for i=1:n/j
     y(i)=0;
         for k=1:j
            y(i)=y(i)+x((i-1)*j+k,p);
         end
     y(i)=y(i)/j;
     end
  z=y(1:floor(n/j));
  X(:,p)=z;
  end
M = [2 2 2];
tau =[1 1 1];
e=mvsampen_full(M,r,tau,X');
SE(j)=e;
clear X;
end
MSEm2(kk,:)=SE;
end

clear kk x sd n tau epsilon j z r m e SE xx m1 m2 m3 M1 M2 M3;

AMSEw= mean(MSEw,1);
Astdw=std(MSEw,1,1);

AMSEp= mean(MSEp,1);
Astdp=std(MSEp,1,1);

AMSEm1= mean(MSEm1,1);
Astdm1=std(MSEm1,1,1);

AMSEm2= mean(MSEm2,1);
Astdm2=std(MSEm2,1,1);


figure
hold on
set(gca,'ylim',[0 1.5], 'xlim', [0 21])
errorbar(AMSEp,Astdp,'-ob', 'DisplayName','All three channels contain 1/f noise')

hold on
set(gca,'ylim',[0 1.5], 'xlim', [0 21])
errorbar(AMSEm1,Astdm1,'-sg', 'DisplayName','Two channels contain 1/f noise, one contain white noise')

hold on
set(gca,'ylim',[0 1.5], 'xlim', [0 21])
errorbar(AMSEm2,Astdm2,'-dc', 'DisplayName','One channel contains 1/f noise, two contain white noise')

hold on
set(gca,'ylim',[0 1.5], 'xlim', [0 21])
errorbar(AMSEw,Astdw,'-xr', 'DisplayName', 'All three channels contain white noise')

xlabel('Scale factor')
ylabel('Multivariate sample entropy')
legend('show');





