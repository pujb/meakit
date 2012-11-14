function e=mvsampen_naive(M,r,tau,ts)
% This function calculates multivariate sample entropy using the naive approach
% Inputs:

% M - embedding vector parameter
% r - threshold scalar parameter 
% tau - time lag vector parameter
% ts - multivariate time series-a matrix of size nvarxnsamp

% Output:
% e- scalar quantity


%number of match templates of length m closed within the tolerance r where m=sum(M) is calculated first
[nvar,nsamp]=size(ts);
A=embd(M,tau,ts);%all the embedded vectors are created
y=pdist(A,'chebychev');%infinite norm is calculated between all possible pairs
[r1,c1,v1]= find(y<=r);% threshold is implemented
p1=numel(v1);%number of match templates of length m closed within the tolerance r where m=sum(M).

clear  y r1 c1 v1 A;

M=repmat(M,nvar,1);
I=eye(nvar);
M=M+I;

% number of match templates of length m+1 closed within the tolerance r where m=sum(M) is calculated afterwards
for h=1:nvar % this loop takes into account all the subspaces of dimension m+1 separately
B=embd(M(h,:),tau,ts);
z=pdist(B,'chebychev');
[r2,c2,v2]= find(z<=r);
p2(h)=numel(v2);
clear  z r2 c2 v2 B;
end

p2=mean(p2); % average number of match templates of length m over all the subspaces closed within the tolerance r where m=sum(M).

e=log(p1/p2);


