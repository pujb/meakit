function [X,Y]=imdatsep(x,y,x1,y1,sen);
%Function to separate data points from 2 sets of x and y vectors, produced by
%IM2DAT.M.
%
%Data points in the first set of vectors is compared with the second set. Only
%the data point that exist in the first set and not the second will be output.
%
%The fuction also supports and exclusion range for both x and y, any data point
%loacted in the range is automatically excluded from the output.
%
%This fuction is supposed to work with output from im2dat.m and helps in
%separating multiple plots on a single image.
%
%SYNTAX:
%		[X,Y]=imdatsep(xvector,yvector,x1vector or range[xmin xmax],...
%				y1vector or range[ymin ymax],sensitivity);
%If a specific range of data is to be excluded then a range of x maybe
%specified, a range of y can also be specified or both. Note: To specify rangey
%only: rangex must be specified out of data range:
%                 [X,Y]=imdatsep(x,y,[1000,1000],range[ymin ymax]).
%
%SENSITIVITY(scaler): This tell the function how close two data points should be
%before they are taken to be the same. This is important when two sets of
%vectors are being compared. IM2DAT.M
%find approximate points with the help of contour; hence, when two different
%layers of contour are compared the points will rarely ever match. Thus, 
%filtering will not be possible without a given degree of acceptable error.			
%
%(Function tested on MATLAB 5.1)
%			Written by: Sumeet Yamdagni
%			Email: syamdagni@hotmail.com
%------------------------------------------------------------------


%Default
Range=0;
X=[];
Y=[];
%------------------------------
if nargin<3
	error('Not enough input arguments')
%==============================
elseif nargin==3
%_________________________	
	if length(x1)~=2
		error('Vector of invalid range')
	else
		Range=1;
	end
%__________________________
	%if isnum(x)&isnum(y)&isnum(x1)
	%else
	%error('Invalid arguments')
	%end
%==============================
elseif nargin==4
%___________________________________
	if length(x1)==2&length(y1)==2;
		Range=2;
	end
%___________________________________
	%if isnum(x)&isnum(x1)&isnum(y)&isnum(y1)
	%else
		%error('Invalid arguments')
	%end
%==============================
elseif nargin==5
	if Range==0&length(sen)==1;
	else
	error('Invalid Sensitvity')
	end
%==============================
elseif nargin>5
   error('Too many input arguments')
end
%---------------------------------

%No errors

%------------------------------------
if Range==1|Range==2
	
	Z=[x;y];
	Comp=char('(x1(1,1)>Z(1,C))|(Z(1,C)>x1(1,2))',...
	'((x1(1,1)>Z(1,C))|(Z(1,C)>x1(1,2)))|((y1(1,1)>Z(2,C))|(Z(2,C)>y1(1,2)))');
	
	I=length(x);
	
	for C=1:I
	
		if eval(Comp(Range,:))
			X=[X,Z(1,C)];
			Y=[Y,Z(2,C)];
		end
	end
%-----------------------------------x1 and y1 are data vectors
else
	%=======================
		I=length(x);
		Z=[x;y];
		J=length(x1);
		Z1=[x1;y1];

	%========================
	for C=1:I
		
		flag=0;
		for K=1:J
			if (-sen<(Z(1,C)-Z1(1,K))&(Z(1,C)-Z1(1,K))<sen)&...
			(-sen<(Z(2,C)-Z1(2,K))&(Z(1,C)-Z1(1,K))<sen)
				flag=1;
			end
		end
	
	
		if flag==0;
			X=[X,Z(1,C)];
			Y=[Y,Z(2,C)];
		end
		
	end
	%======================
end
%-------------------------------------