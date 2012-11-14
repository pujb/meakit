function r= anyrnd(f,M,N)
%r= ANYRND(F,M,N) returns a matrix of random numbers of size M by N 
%	generated from an user-defined frequency distribution F. F can be 
%	specified as a 2-column vector where first column are the centers 
%	of bins and second column are frequencies. F can also be a 1-column 
%	vector of values, in which case a frequency distribution is generated 
%	with HIST using 100 bins. It works better the more detailed is the 
%	distribution (obviously).
%  
%	Example:
%	x= linspace(0,10*6.28,1000)';
%	y= 10*sin(x);
%	[n,v]= hist(y,100);	%Generate freq. dist.
%	f= [v',n'];				%Put it in f
%	r= anyrnd(f,1000,1); %Call anyrnd
%	hist(y,50);hold on;	%Plot both dist.
%	hist(r,50);
% 
%	Author: F. de Castro

%-- Generate freq. dist. if needed
if size(f,2) == 2
	v= f(:,1); n= f(:,2);
else
	[n,v]= hist(f(:,1),100);
end

%-- Initialize
r= zeros(M,N);
fcum= zeros(length(f),1);
s= sum(n);
maxf= max(f);

%-- Cummulative frequencies
fcum(1)= n(1)/s;
for j= 2:length(n)
	fcum(j)= fcum(j-1)+ n(j)/s;
end

%-- Random picking
for k= 1:N
	for j= 1:M
		loe= find(fcum >= rand);
		r(j,k)= v(loe(1));
	end
end
