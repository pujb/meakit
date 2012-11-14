function stdExportMAT(varargin)
% H1 line
% Help text; use something like:
%-%% <summary text>
%-%%
%-%% Parameters to be passed as parameter-value pairs:
%-%%
%-%% %%%%% Obligatory Parameters %%%%%
%-%%
%-%% 'parameter1': Does this and that. Takes vector as argument. etc.
%-%%
%-%% 'parameter2': Does this and that.
%-%% Possible values:
%-%%    'value1' - does this. And that.
%-%%    
%-%%    'value2' - does something else.
%-%%
%-%% 'parameter3':
%-%% parameter3',[start,end]
%-%% Does this and that.
%-%%
%-%% %%%%% Optional Parameters %%%%%
%-%%
%-%% ... 
%-%%
%-%% Further comments:
%-%%
%-%% ... 
%-%%
%-%% Notes:
%-%%
%-%% - ...
%-%% - ...
%-%% ...
%-%% --------------------------------------------------
% (0) antje kilias 08/09 
% This function belongs to FIND_GUI Toolbox project
% http://find.bccn.uni-freiburg.de


global nsFile; 

% obligatory argument names
obligatoryArgs={'outputFile'};

% optional arguments names with default values
optionalArgs={}; 


errorMessage=checkPVP(varargin,obligatoryArgs,optionalArgs);
if ~isempty(errorMessage)
  error(errorMessage,''); 
end

% loading parameter value pairs into workspace, overwriting defaul values
pvpmod(varargin);

try
    save(outputFile,'nsFile');
%     FileInfo=nsFile.FileInfo;
%     Analog=nsFile.Analog;
%     Event=nsFile.Event;
%     Neural=nsFile.Neural;
%     Segment=nsFile.Segment;
%     EntityInfo=nsFile.EntityInfo;
%     
%     p=fieldnames(nsFile);
%     save(outputFile,(p{:}));
    
catch
    rethrow(lasterror);
end
