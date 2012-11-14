function [ varargout ] = util_analyze_bintable( bintable, varargin )
%UTIL_ANALYZE_BINTABLE A series method for analysing the bintable produced
%by UTIL_PRINT_BINS_WITH_FILES.
%   Input/Output:
%       When used to get DIVs from a specific bin or a range of bins.
%           ->method:   'queryDIVfromBIN'
%           ->binnumber:  e.g. 100, or [1:81]
%           <-div:      32, or [32 34]
%       When used to get binrange from a specific DIV or a range of DIVs.
%       Please note, when giving a specific DIV, it must be in the DIV
%       list. But when giving a DIV range, only make sure the start/end DIV
%       are in the list.
%           ->method:   'queryBINRANGEfromDIV'
%           ->div:      e.g. 9, or [9:13]
%           <-binrange: [1159 ... 2239]
%       When used to print out the bintable.
%           ->method:   'print'
% P.S.
% BINTABLE FORMAT = FILENAME, STARTBIN, ENDBIN, DIV
%
%   Created on Nov/12/2012 By Pu Jiangbo
%   Britton Chance Center for Biomedical Photonics


% Analyze parameter
pvpmod(varargin);

if strcmpi(method, 'queryDIVfromBIN')
    % User gives BIN Number, Return DIV
    % DIV = %FUNC%('BINNUMBER',BINNUMBER); BINNUMBER can be a range or a
    % specific bin number.
    % Check parameter
    if ~exist('binnumber', 'var')
        help util_analyze_bintable 
        error('Wrong input - BINNUMBER.');
    end
    % Check if the user gives a range
    binstart = 0; binend = 0;
    if isscalar(binnumber)
        binstart = binnumber;
        binend = binnumber;
    else
        if binnumber(1) > binnumber(end)
            error('Wrong input - BINNUMBER should be in ascending form.')
        end
        binstart = binnumber(1);
        binend = binnumber(end); 
    end
    % Check start
    divstart = 0; divend = 0; divstarti = 0; divendi = 0; isfound = false;
    for i = 1:length(bintable)
        if binstart >= cell2mat(bintable(i,2)) && binstart <= cell2mat(bintable(i,3))
            divstart = cell2mat(bintable(i,4));
            divstarti = i;
            isfound = true;
            break;
        end
    end
    if ~isfound
        error('Wrong input - BINNUMBER-START invalid.');
    end
    % Check end
    isfound = false;
    for i = length(bintable):-1:1
        if binend <= cell2mat(bintable(i,3)) && binend >=cell2mat(bintable(i,2))
            divend = cell2mat(bintable(i,4));
            divendi = i;
            isfound = true;
            break;
        end
    end
    if ~isfound
        error('Wrong input - BINNUMBER-END invalid.');
    end
    % Convert
    if divstart == divend
        div = divstart;
    else
        div = cell2mat(bintable([divstarti:divendi],4));
    end
    % Return
    varargout{1} = div;       
elseif strcmpi(method, 'queryBINRANGEfromDIV')
    % User gives DIV, returns bin range
    % BINRANGE = %FUNC%('DIV',DIV); DIV can be a specific DIV or a range.
    % Check parameter
    if ~exist('div', 'var')
        help util_analyze_bintable
        error('Wrong input - DIV.');
    end
    % Check if the user gives a range
    divstart = 0; divend = 0;
    if isscalar(div)
        divstart = div;
        divend = div;
    else
        if div(1) > div(end)
            error('Wrong input - DIV should be in ascending form.')
        end
        divstart = div(1);
        divend = div(end); 
    end
    % Check start
    binstart = 0; binend = 0; isfound = false;
    for i = 1:length(bintable)
        if divstart == cell2mat(bintable(i,4))
            binstart = cell2mat(bintable(i,2));
            isfound = true;
            break;
        end
    end
    if ~isfound
        error('Wrong input - DIV-START invalid.')
    end
    % Check end
    isfound = false;
    for i = length(bintable):-1:1
        if divend == cell2mat(bintable(i,4))
            binend = cell2mat(bintable(i,3));
            isfound = true;
            break;
        end
    end
    if ~isfound
        error('Wrong input - DIV-END invalid.')
    end    
    % Convert
    binrange = [binstart:binend];
    % Return
    varargout{1} = binrange; 
elseif strcmpi(method, 'print')
    % Only print out the bintable
    for i = 1:length(bintable)
        disp(cell2mat(bintable(i,1)))
        fprintf(['START-BIN: ' num2str(cell2mat(bintable(i,2))) '\t\t END-BIN: ' num2str(cell2mat(bintable(i,3))) '\t\t DIV: ' num2str(cell2mat(bintable(i,4))) '\n'])
    end
    varargout{1} = 0;
else
    help util_analyze_bintable
    error('Wrong input - method.');
end

end

