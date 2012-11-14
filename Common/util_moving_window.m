function [ result ] = util_moving_window( x, window_length, mode, func, varargin )
%UTIL_MOVING_WINDOW Applying a @func handle to window-ed data
%   Input:
%           x:              1-D data (Matrix data also partly supported, see the codes)
%           window_length:  Window width
%           mode:           'Cont' or 'Jump'
%           func:           Function handle:  Y=F(X)
%           funcargs:       Function args: Y=F(X, ...), if needed.
%
%   Output:
%           result:         In most cases, as a 1-D vector (cell array as if x is a Matrix).
%
%   Created on Jun/09/2012 By Pu Jiangbo
%   Britton Chance Center for Biomedical Photonics
%
%   $Revision:
%       PJB#2012-06-11  Adding codes to determine if x is a vector/matrix.
%       PJB#2012-06-12  Adding codes to support the Matrix version of
%                       sliding window algorithm.
%       PJB@2012-06-12  Bug Fix: varargout -> varargout {:}, otherwise the
%                       @func could not receive correct arguments.


% Init variables
n_len = length(x);
if window_length < 1 || window_length > n_len
    error('Wrong input: window_length > 1, < length of x.')
end
w_len = window_length;

if strcmpi(mode, 'cont')
    mode = 0;
elseif strcmpi(mode, 'jump')
    mode = 1;
else
    error('Wrong input: mode should be CONT or JUMP.');
end
    
% Determine if X is a vector
if isvector(x)
    % x is a vector
    if mode == 0
        % Smoothly sliding window
        % start_pos -> start_pos + w_len - 1
        % start_pos ++
        % START: 1
        % END: if start_pos + w_len - 1>= n_len => start_pos -> n_len
        result = zeros(n_len-w_len+1, 1);
        for i = 1:n_len
            result(i) = func(x(i:i+w_len-1), varargin{:});
            %disp(x(i:i+w_len-1));disp(', ')
            if i+w_len-1 >= n_len
                result(i+1) = func(x(i+1:end), varargin{:});
                %disp(x(i+1:end));disp(', end')
                break;
            end
        end
    elseif mode == 1
        % Jumping window
        % start_pos -> start_pos + w_len - 1
        % start_pos = start_pos + w_len
        % START: 1
        % END: if start_pos + w_len + w_len >= n_len => start_pos + w_len -> n_len
        %      It means: if the next round of next round cannot complete a window, then
        %      extend the next round.
        result = zeros(fix(n_len/w_len), 1);
        result_i = 1;
        for i = 1:w_len:n_len
            result(result_i) = func(x(i:i+w_len-1), varargin{:});
            %disp(x(i:i+w_len-1));disp(', ')
            result_i = result_i + 1;
            if i+w_len+w_len >= n_len
                result(result_i) = func(x(i+w_len:end), varargin{:});
                %disp(x(i+w_len:end));disp(', end')
                break;
            end
        end
    end
else
    % x is a matrix
    disp('Matrix input is detected, please check the code, make sure you are using the right way.')
    % We should apply the @func to a windowed-data of the matrix
    % Window-data size:
    %   Number of rows = window_length
    %   Number of cols = cols of x
    % The user should check the format of input matrix, Note, the layout of
    % result is in a 1-D cell array.
    % One window-ed dataset -> One numberic result.
    if mode == 0
        % Smoothly sliding window
        % start_pos -> start_pos + w_len - 1
        % start_pos ++
        % START: 1
        % END: if start_pos + w_len - 1>= n_len => start_pos -> n_len
        result = cell(n_len-w_len+1, 1);
        % Generate a movie
        % Used only in the case that x is a matrix. I.E.
        % We can show you a movie of changing patterns in
        % result-cell array.
        % DECLARE: globale movie_frames, in the console
        % UNCOMMENT THIS: ==>
        % global movie_frames
        % figure,movie_frames = moviein(n_len-w_len+1, 1);
        % ==END
        for i = 1:n_len
            result{i} = func(x(i:i+w_len-1,:), varargin{:});
            % UNCOMMENT THIS: ==>
            % imagesc(func(x(i:i+w_len-1,:)));title([num2str(i) ' of ' num2str(n_len-w_len+1)]);drawnow;movie_frames(:,i)=getframe;
            % ==END
            %disp(x(i:i+w_len-1));disp(', ')
            if i+w_len-1 >= n_len
                result{i+1} = func(x(i+1:end,:), varargin{:});
                % UNCOMMENT THIS: ==>
                % imagesc(func(x(i+1:end,:)));title([num2str(i+1) ' of ' num2str(n_len-w_len+1)]);drawnow;movie_frames(:,i+1)=getframe;
                % ==END
                %disp(x(i+1:end));disp(', end')
                break;
            end
        end
    elseif mode == 1
        % Jumping window
        % start_pos -> start_pos + w_len - 1
        % start_pos = start_pos + w_len
        % START: 1
        % END: if start_pos + w_len + w_len >= n_len => start_pos + w_len -> n_len
        %      It means: if the next round of next round cannot complete a window, then
        %      extend the next round.
        result = cell(fix(n_len/w_len), 1);
        result_i = 1;
        for i = 1:w_len:n_len
            result{result_i} = func(x(i:i+w_len-1,:), varargin{:});
            %disp(x(i:i+w_len-1));disp(', ')
            result_i = result_i + 1;
            if i+w_len+w_len >= n_len
                result{result_i} = func(x(i+w_len:end,:), varargin{:});
                %disp(x(i+w_len:end));disp(', end')
                break;
            end
        end
    end
end

end

