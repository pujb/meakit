function [Xmean,Ymean1]=im2dat(Inputfile,xscale,yscale,option1,option2);
%Function to determine data points from a image file of a plot.
%
%SYNTAX:
%[X,Y]=IM2DAT(Inputfile,[xaxis_min xaxis_max],[yaxis_min ... 				
%				yaxis_max],optional1,optional2)
%
%PREPARING THE PLOT IMAGE:
%It is advisable to convert the image file into a bitmap.(For other supported formats 'help imread')
%NOTE: This fuction will accept Truecolor(24-bit), which the fuction convert to grayscale.			
%
%OPTIONAL ARGUMENTS:
%The optional arguments maybe given in any order.
%PLOT_SHADE==[minshading,maxshading]--Min shading and Max shading are optional. These
%arguments restrict the output data to particular range. This is useful if image contains more than
%one plot and is effective only when the plots have different colors, or shades of gray. Use 
%IMDATSEP.M function to seperate the common data for two sets of output vectors, from this 
%function.
%
%TYPE==<scalar>--The way the image is processed
%1=This version uses 3D Contour plot(DEFAULT)
%2=This version uses 2D Contour plot
%3=This versions uses edge determination(sobel technique) & 3D Contour plot
%4=Filter out Red and use 3D Contour plot (24bit truecolor no conversion)
%5=Filter out Green and use 3D Contour plot (24bit truecolor no conversion)
%6=Filter out Blue and use 3D Contour plot (24bit truecolor no conversion)
%7=Accepts an image matrix, in place of a file. Matrix should not be given as string. Process
%		followed is as with 'type 1'.NOTE: Matrix should be 2D.
%
%OUTPUT:
%The Output Data is assigned to X,Y(Vectors). They can be used to make point plots and for
%curve fitting. To make line plots, sort the output vectors using IMDATSORT.M.However, This 
%only works for simple plots.
%
%(Function tested on MATLAB 5.1)
%					Written by: Sumeet Yamdagni
%					Email: syamdagni@hotmail.com
%---------------------------------------------------------------------------------

%Defaults
flag_Clim=1;  %The minimum shading limit will be assigned, which will be determined later.
types=1;   		%Assigning default process.

%Validating arguments
%---------------------------------------------------------------------------------
if nargin==4
	%===================
	if length(option1)==1
		%______________________
		if option1<1|option1>7
			error('Type out of range')
		end
		%______________________
		types=option1;
	%==================	
	elseif length(option1)==2
		%______________________
		if max(option1)>1
			error('Shading limits out of range. Choose values between 0&1')
		end
		%______________________
		plot_shade=option1;		
		flag_Clim=0; %User defined shading range will be used.
	%==================
	else
		error('Option1 vector of invaild length')
	
	end
	%==================
%------------------------------------
elseif nargin==5
	%===================
	if length(option2)==1
	
		if option2<1|option2>7
			error('Type out of range')
		end
	
		types=option2;
	%===================
	elseif length(option2)==2
	
		if max(option2)>1
			error('Shading limits out of range. Choose values between 0&1')
		end
	
		plot_shade=option2;		
		flag_Clim=0; %User defined shading range will be used.
	%====================
	else
		error('Option2 vector of invaild length')
	end
	%====================

%-------------------------------------
elseif nargin > 5
   error('Too many input arguments')
%-------------------------------------
elseif nargin < 3
   error('Not enough input arguments')
end
%---------------------------------------------------------------------------------

%Inputfile is an image matrix. Then it should be 2D.
if types==7&length(size(Inputfile))~=2
	error('Image matrix must be 2D')
end

%Validating input scale vectors
if length(xscale)~=2|length(yscale)~=2;
	error('Input scale vector of invaild length')
end

%---------------------------------------------------------------------------------
ModImg=char('P=double(Img);','P=double(Img);','P=edge(Img,''sobel'');',...
'P=double(Img(:,:,1));','P=double(Img(:,:,2));','P=double(Img(:,:,3));','P=double(Img);');

ImgPlot=char('[dummy,h1]=contour3(x,y,P);','[dummy,h1]=contour(x,y,P);',...
'[dummy,h1]=contour3(x,y,P);','[dummy,h1]=contour3(x,y,P);',...
'[dummy,h1]=contour3(x,y,P);','[dummy,h1]=contour3(x,y,P);','[dummy,h1]=contour3(x,y,P);');
%---------------------------------------------------------------------------------

if types~=7
	Img = imread(Inputfile);	%Reading image data into a file
else
	
	Img=Inputfile;						%Accepting user image matrix
end

%Validating whether the file is grayscale
if (types==1|types==2|types==3|types==7)&isrgb(Img);
	disp('Using the inbuilt RGB2GRAY.m coverter');
	Img=rgb2gray(Img);
end

%----------------Modify Img----------------
P=[];
eval(ModImg(types,:));
%-----------------------------------------

%Preparing mesh for contour
[mI,nI]=size(P);
x1=linspace(xscale(1),xscale(2),nI);
y1=linspace(yscale(1),-yscale(2),mI);	%The negative sign is to prevent image inversion, due to 																		
%standard screen representation
[x,y]=meshgrid(x1,y1);

figure;
%--------------ImgPlot---------------
eval(ImgPlot(types,:));
%-----------------------------------

%h1 handler represents the handler for all children of axes.
%set(get(get(h1(1),'parent'),'parent'),'Visible','off');

%Color Map
%cmap=<color_map>;
cmap=gray;
colormap(cmap);

%Finding handle data points
[size_h1,dummy]=size(h1);

%Control variables
t=0;
k=0;
l=0;

%Output vectors
Xmean=[];
Ymean=[];

Clim=get(get(h1(1),'Parent'),'Clim'); %Gets the shading limits

%Determining Data points--------------------------------------------------------------
for k=1:size_h1;
	%-----------------------------------	
	if get(h1(k),'Type')=='patch';
%[m,n]=size(get(h1(k),'Faces'));	%To restrict the number of data points
	
		%Shading To be considered as per user input only if optional arguments given.
		if flag_Clim==0
		HighShade=plot_shade(2);
		LowShade=plot_shade(1);
		else
		%Arguments not given, using shading limit
		HighShade=Clim(1);
		LowShade=Clim(1);
		end
		
%	if m<16---------------------Polygons with more than 16 sides will be excluded, n can vary 															
%depending on user. Note line 88
		
		%Checking the intensity of shading
		Cdat=get(h1(k),'CData'); %Gets shading data
		%===================================
		if Cdat(1)<=HighShade&Cdat(1)>=LowShade;
			%True--This is a data point we can use
			Xdat=get(h1(k),'XData');
			Ydat=get(h1(k),'YData');
		
			%Calculating the average of the data point
			[size_dat,n]=size(Xdat); %The size of the two vectors will be the same
		
			%To eliminate NaN
			Xdat(size_dat)=0;
			Ydat(size_dat)=0;
		
			%Calculating the data point
			t=t+1;
			Xmean(t)=sum(Xdat)/(size_dat-1);
			Ymean(t)=sum(Ydat)/(size_dat-1);
			end
			%===============================
%end
	end
%--------------------------------------
end
%---------------------------------------------------------------------------------
ymax=yscale(2);						
Ymean1=Ymean+ymax;			%This rectifies the provision taken for preventing inversion
