function detected_outliers=analyzeOutliers(CutoutMat,discardDist)
% function analyzeOutliers(varargin)
% This function will calculate the euclidean distances between different
% spike waveforms and sort out outliers by their distance.
%
% obligatory input arguments:
% 'CutoutMat' is a Matrix containing spike waveform data in every column, all
% spikes of a spike train stored in one matrix
% 
% 'discardDist' is the euclidean distance threshold, if missing input dialog is 
% started 
% 
% obligatory output arguments:
% 'detected_outliers' vector containing indices of the detected outliers
%
%
% (0) R. Meier Feb 07 meier@biologie.uni-freiburg.de
% This function belongs to FIND_GUI Toolbox project
% http://find.bccn.uni-freiburg.de
%
% (1) adapted to FIND 2.0 by Kilias (kilias@bcf.uni-freiburg.de)


%% call function euclidien Distance
D=euclidDist(CutoutMat);

% find outliers
[rw,cl]=ind2sub(find(D>discardDist),size(D));
detected_outliers=unique([rw;cl]);

end