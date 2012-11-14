function out=csv2cell(filename,varargin)
% Loads a character separated value file to a cell array of strings
%
% function out=csv2cell(filename,varargin)
% 'filename' must be a string, 'varargin' must be a single character
%
% Markus Nenniger 2007

% set default separator ',' if varargin is not specified
if ~isempty(varargin)
    %some errorcatching
    if length(varargin{:})>1|| ~ischar(varargin{:})
        error('separator must only be a single character')
    end
    separator=varargin;
else
    separator={','};
end

% open file and assign handle
fh=fopen(filename);

% initialize line counter
myline=1;

% initialize cell array
out={};

% loop until EOF, then break
while 1
    % save line to temporory variable tline
    tline = fgetl(fh);

    % break out of loop if EOF is reached
    if ~ischar(tline),   break,   end
    
    % set appropriate boundary indices for cell contents
    separatoridx=[0 find(tline==separator{1}) length(tline)+1];
    
    %ignore separators at the end of a line
    if separatoridx(end-1)==length(tline)
        separatoridx=separatoridx(1:end-1);
    end
    
    % copy characters between separators to their respective cells
    for ii=length(separatoridx):-1:2
        leftidx=separatoridx(ii-1)+1;
        rightidx=separatoridx(ii)-1;
        out{myline,ii-1}=tline(leftidx:rightidx);
    end
    
    %one line done, increment line counter
    myline=myline+1;
end

%if - for whatever reason - cells are left empty, issue a warning
if ~iscellstr(out);warning('there are empty cells');end

% tidy up
fclose(fh);