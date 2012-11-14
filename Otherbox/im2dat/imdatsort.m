function [X,Y]=imdatsort(x1,y1)
%This fucntion is used to sort the two output vectors from IM2DAT.M. The output
%can be used to draw a line plot.
%
%Syntax:
%				[X,Y]=imdatsort(x,y)
%
%(Function tested on MATLAB 5.1)
%                                                 Written by: Sumeet Yamdagni
%                                                 Email: syamdagni@hotmail.com
%--------------------------------------------------------------------


Z=[x1; y1];
n=length(Z);

for i=1:(n-1)

for j=1:(n-i)

if Z(1,j)>Z(1,j+1)
	T=Z(:,j+1);
	Z(:,j+1)=Z(:,j);
	Z(:,j)=T;
end

end
end

X=[];
Y=[];
X=Z(1,:);
Y=Z(2,:);