function [ C1,P1,H1 ] = glia_Ca_3_3(C,P,H,location_release_amount,Row,Col)  %#codegen
%GLIA_CA Summary of this function goes here

%% Parameters
deltaT=0.001;       %% Time step interval (s),i.e. 1ms
taoh=2.0;           %% the time constant for the dynamics of h, unit : s
b=0.111;            %% Fraction of open IP3 receptors at [Ca2+]=0
V1=0.889;           %% the proportion of IP3Rs that are activated by the binding of Ca2+
kp=0.17;            %% the linear rate of IP3 breakdown, unit : /s
mu0=0.567;          %% the proportion of IP3Rs that are activated at [IP3] =0¦ÌM
mu1=0.433;          %% the proportion of IP3Rs that are activated by bound IP3

kflux=16.2*400;     %% the maximum total Ca2+ flux through all IP3Rs, unit : ¦ÌM/s
gamma=2.0*400;      %% the maximmum rate of Ca2+ pumping from the cytosol, unit : ¦ÌM/s
k1=0.7*400;         %% Kinetic constant, unit : ¦ÌM
k2=0.7*400;         %% Kinetic constant, unit : ¦ÌM
kgamma=0.1*400;     %% Kinetic constant of calcium pumps of ER, unit : ¦ÌM
Dp=300/400;         %% the cytosolic diffusion coefficients of IP3, unit : (¦Ìm)^2/s
Dc=20/400;          %% the cytosolic diffusion coefficients of Ca2+, unit : (¦Ìm)^2/s
kmu=4*400;          %%  Kinetic constant of mu, unit : ¦ÌM
peq=0.28*400;       %% IP3 resting concentration, unit : uM

Fp=5/20;            %% IP3 permeability of the cell membrane, unit : ¦Ìm/s
Fc=1.1/20;          %% Ca2+ permeability of the cell membrane, unit : ¦Ìm/s

C1=ones(150,150);   %% the cytosolic free calcium concentration, unit : ¦ÌM
P1=ones(150,150);   %% the cytosolic IP3 concentration, unit : ¦ÌM
H1=ones(150,150);   %% the proportion of IP3Rs that have not been closed by Ca2+


%% Calculation
ip3_rel=find(location_release_amount(:,3)~=0);
for i=1:length(ip3_rel)
    x=ceil(location_release_amount(ip3_rel(i),1)/20);
    y=ceil(location_release_amount(ip3_rel(i),2)/20);
    P(x,y)=P(x,y)+location_release_amount(ip3_rel(i),3)*0.009;
end

C=C*400;
P=P*400;

for j=2:(Col-1)
    for i=2:(Row-1)
        old_cij = C(i,j);
        old_pij = P(i,j);
        old_hij = H(i,j);
        C1(i,j)=old_cij+deltaT*(Dc*(C(i+1,j)-2*old_cij+C(i-1,j)+C(i,j+1)-2*old_cij+C(i,j-1))+kflux*(mu0+mu1*P(i,j)/(kmu+P(i,j)))*H(i,j)*(b+V1*old_cij/(k1+old_cij))-gamma*old_cij/(kgamma+old_cij));
        P1(i,j)=old_pij+deltaT*(Dp*(P(i+1,j)-2*old_pij+P(i-1,j)+P(i,j+1)-2*old_pij+P(i,j-1))+kp*(peq-old_pij));
        H1(i,j)=old_hij+deltaT*(k2^2/(k2^2+old_cij^2)-old_hij)/taoh;
        if(mod(i,3)==0)
            C1(i,j)=C1(i,j)-deltaT*(old_cij-C(i+1,j))*Fc;
            C1(i+1,j)=C1(i+1,j)+deltaT*(old_cij-C(i+1,j))*Fc;
            P1(i,j)=P1(i,j)-deltaT*(old_pij-P(i+1,j))*Fp;
            P1(i+1,j)=P1(i+1,j)+deltaT*(old_pij-P(i+1,j))*Fp;
        end
        if(mod(j,3)==0)
            C1(i,j)=C1(i,j)-deltaT*(old_cij-C(i,j+1))*Fc;
            C1(i,j+1)=C1(i,j+1)+deltaT*(old_cij-C(i,j+1))*Fc;
            P1(i,j)=P1(i,j)-deltaT*(old_pij-P(i,j+1))*Fp;
            P1(i,j+1)=P1(i,j+1)+deltaT*(old_pij-P(i,j+1))*Fp;
        end
    end
end

C1(1,2:(Col-1))=C1(2,2:(Col-1));
C1(Row,2:(Col-1))=C1(Row-1,2:(Col-1));
C1(2:(Row-1),1)=C1(2:(Row-1),2);
C1(2:(Row-1),Col)=C1(2:(Row-1),(Col-1));
C1(1,1)=C1(2,2);
C1(1,Col)=C1(2,(Col-1));
C1(Row,1)=C1(Row-1,2);
C1(Row,Col)=C1(Row-1,(Col-1));

P1(1,2:(Col-1))=P1(2,2:(Col-1));
P1(Row,2:(Col-1))=P1(Row-1,2:(Col-1));
P1(2:(Row-1),1)=P1(2:(Row-1),2);
P1(2:(Row-1),Col)=P1(2:(Row-1),(Col-1));
P1(1,1)=P1(2,2);
P1(1,Col)=P1(2,(Col-1));
P1(Row,1)=P1(Row-1,2);
P1(Row,Col)=P1(Row-1,(Col-1));

H1(1,2:(Col-1))=H1(2,2:(Col-1));
H1(Row,2:(Col-1))=H1(Row-1,2:(Col-1));
H1(2:(Row-1),1)=H1(2:(Row-1),2);
H1(2:(Row-1),Col)=H1(2:(Row-1),(Col-1));
H1(1,1)=H1(2,2);
H1(1,Col)=H1(2,(Col-1));
H1(Row,1)=H1(Row-1,2);
H1(Row,Col)=H1(Row-1,(Col-1));

C1=C1/400;
P1=P1/400;
end
