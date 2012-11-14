x=[1:1000000];
load test y
factor=2;
x=condense(x,factor);
y=condense(y,factor);
starttime=cputime;
P=findpeaks(x,y,0.0000000007,.2,50,50);
ElapsedTime=cputime-starttime;
 ['Found '  num2str(length(P)) ' peaks in a ' num2str(length(x)) '-point signal in ' num2str(ElapsedTime) ' seconds.']
PointsPerSecond=length(y)/ElapsedTime
plot(x(1:2000/factor),y(1:2000/factor))

