function BGSlider(n,h)
% Called when the BG slider is clicked.

global x
global y
global SlopeThreshold 
global AmpThreshold  
global SmoothWidth
global FitWidth
global P
global PeakNumber

warning off MATLAB:divideByZero

BaselinePoints=8;  % Change as you wish

% Acquire background points from user mouse clicks
title(['Click on ' num2str(BaselinePoints) ' points on the baseline between the peaks.'])
X=[];Y=[];
for g=1:BaselinePoints;
   [clickX,clickY] = ginput(1);
   X(g)=clickX;
   Y(g)=clickY;
   xlabel(['Baseline point '  num2str(g) ])
end
yy=y;
for k=1:length(X)-1,
   fp=val2ind(x,X(k));
   lp=val2ind(x,X(k+1));
   yy(fp:lp)=y(fp:lp)-((Y(k+1)-Y(k))/(X(k+1)-X(k))*(x(fp:lp)-X(k))+Y(k));
end
y=yy;
if PeakNumber==0,
    P=findpeakslidersRedraw(x,y,SlopeThreshold,AmpThreshold,SmoothWidth,FitWidth);
else
    RedrawPeak
end

function [index,closestval]=val2ind(x,val)
% Returns the index and the value of the element of vector x that is closest to val
% If more than one element is equally close, returns vectors of indicies and values
% Tom O'Haver (toh@umd.edu) October 2006
% Examples: If x=[1 2 4 3 5 9 6 4 5 3 1], then val2ind(x,6)=7 and val2ind(x,5.1)=[5 9]
% [indices values]=val2ind(x,3.3) returns indices = [4 10] and values = [3 3]
dif=abs(x-val);
index=find((dif-min(dif))==0);
closestval=x(index);