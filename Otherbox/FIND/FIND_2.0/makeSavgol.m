function fir=makeSavgol(varargin)
% function fir=makeSavgol(varargin);
%
% fir = SavitzkyGolay(n[,nr]) gives a Savitzky-Golay smoothing filter
% of total width nr-nl+1. It extends -nl data points to the left and nr
% data points to the right of the point of operation. Works by least
% squares fitting of a polynomial to nr-nl+1 consecutive data points. A
% differentiating filter is obtained by specifying the <option, value>
% pair <'DerivativeOrder', ld> where ld=1 for the first derivative, ld=2
% for the second derivative, and so on. It is obtained by evaluating the
% ld-th derivative of the fitted polynomial at the position of the
% (1-nl)-th data point. The default is ld=0 for smoothing. The option
% <'TimeStep', h> can be used to account for any sampling rate. This
% effectively leads to a scaling of all filter coefficients by
% (1/h)^ld. The order of the fitted polynomial can be specified by
% <'PolynomialOrder', m>, the default is m=2 corresponding to a
% parabola. It is expected that m+1<=nr-nl+1. Data windowing can be
% enforced by <'WindowFunction', wf> where wf='Uniform' is the
% default, 'Welch' can also be specified. See Numerical Recipes in C
% (Second Edition) for further details.
%
% !Determine input arguments as parameter value pairs!
% Obligatory Arguments:
% 'n'
%
% Optional Arguments: 
% 'h'  -> 'TimeStep', default 1
% 'ld' -> 'DerivativeOrder', default 0
% 'm'  -> 'PolynomialOrder', default 2
% 'wf' -> 'WindowFunction', default "Uniform"
% 'nr' - if nr is given, the value for n will be used as nl. 
% for details - see above.
% 
%  For method details see :
%  
% 
% (1) Adapted to FIND, Feb. 2008 -  meier@biologie.uni-freiburg.de
% (0) Version 1.4 - 31/03/00     - rotter@biologie.uni-freiburg.de
%     original version 'SavitzkyGolay.m'
%
%
% Original References of this tool
%
%   [1] Savitzky A, Golay MJE (1964)
%       Smoothing and Differentiation of Data by Simplified Least Squares
%       Procedures. Analytical Chemistry 36:1627-1639
%       
%   [2] Numerical Recipes in C: The Art of Scientific Computing 
%       William H. Press, Saul A. Teukolsky, William T. Vetterling
%       Cambridge University Press; ISBN13: 978-0521431088
%       -> for discussion of parameters
%
%   [3] Meier R, Egert U, Aertsen A, Nawrot M (2008)
%       FIND - a unified framework for neural data analysis
%       (submitted manuscript)
%       -> application: time-dereivative of rate function from 
%          single trial spike trains
%
%

% Check parameters to avoid an underdetermined situation
%
% n
argIdx_n=find(cell2mat(cellfun(@(x) strcmp(x,'n'),varargin,'UniformOutput',0)));
if isempty(argIdx_n)
    error('missing input argument ''n''');
else
    n=varargin{argIdx_n+1};
    if length(n)~=1 || n<=0
        error('invalid value for input argument n');
    end
end

% set defaults
h  = 1;
ld = 0;
m  = 2;
wf = 'Uniform';

argIdx_h=find(cell2mat(cellfun(@(x) strcmp(x,'h'),varargin,'UniformOutput',0)));
if ~isempty(argIdx_h)
    h=varargin{argIdx_h+1};
    if ~(length(h)==1 && h>0)
        error('invalid value for input argument h');
    end
end

argIdx_ld=find(cell2mat(cellfun(@(x) strcmp(x,'ld'),varargin,'UniformOutput',0)));
if ~isempty(argIdx_ld)
    ld=varargin{argIdx_ld+1};
   if ~(length(ld)==1 && ld>0)
        error('invalid value for input argument ld');
    end
end

argIdx_m=find(cell2mat(cellfun(@(x) strcmp(x,'m'),varargin,'UniformOutput',0)));
if ~isempty(argIdx_m)
    m=varargin{argIdx_m+1};
    if ~(length(m)==1 && m>0)
        error('invalid value for input argument m');
    end
end

argIdx_wf=find(cell2mat(cellfun(@(x) strcmp(x,'wf'),varargin,'UniformOutput',0)));
if ~isempty(argIdx_wf)
    wf=varargin{argIdx_wf+1};
    if ~ismember(lower(wf),{'uniform','welch'})
        error('invalid value for input argument wf');
    end
end

argIdx_nr=find(cell2mat(cellfun(@(x) strcmp(x,'nr'),varargin,'UniformOutput',0)));
if ~isempty(argIdx_nr)
    nr=varargin{argIdx_nr+1};
    if ~(length(nr)==1 && nr>0)
        error('invalid value for input argument nr');
    end
end

   
% if nr is specified, n is supposed to be nl.  
if exist('nr')
  nl = -n;
else
  nl = -n;
  nr= n;
  
end

if nr-nl+1 < m+1
  error('Value for PolynomialOrder is too high.');
end

%
% Generate list of weights.

switch lower(wf)
  case 'uniform'
    w = ones(1,nr-nl+1);
  case 'welch'
    w = 1 - [(nl:-1)/(nl-1) 0 (1:nr)/(nr+1)].^2;
  otherwise
    disp('Unknown value for option WindowFunction');
end

%
% This is the (weighted) design matrix of the corresponding
% least-squares problem.
%

A = zeros(nr-nl+1,m+1);

for j = 0 : m
  for i = nl : nr
    A(i-nl+1,j+1) = i^j * w(i-nl+1);
  end
end

%
% Finally, compute the filter coefficients.
%

A = pinv(A);
fir = prod(1:ld) / h^ld * A(ld+1,:) .* w;



