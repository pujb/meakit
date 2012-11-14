function [ well, row, column ] = util_find_fourwell_ch2well( chID )
%UTIL_FIND_FOURWELL_CH2WELL Locate the hole where the electrode is in a
%4-well MEA.
%
%   Input:      CHID (11 - 88)
%   Output:     well:   The hole id.
%               row/column. (0.5 = electrodes in the middle of two rows / cols)
%   Layout:
%           1  2
%           3  4
%
%   Created on Jul/12/2009 By Pu Jiangbo
%   Britton Chance Center for Biomedical Photonics

% WELL 1
if chID == 33
    well = 1;
    row = 1;
    column = 1;
    return;
end

if chID == 21
    well = 1;
    row = 1;
    column = 2;
    return;    
end

if chID == 31
    well = 1;
    row = 1;
    column = 3;
    return;
end

if chID == 44
    well = 1;
    row = 1.5;
    column = 4;
    return;
end

if chID == 12
    well = 1;
    row = 2;
    column = 1;
    return;
end

if chID == 22
    well = 1;
    row = 2;
    column = 2;
    return;
end

if chID == 32
    well = 1;
    row = 2;
    column = 3;
    return;
end

if chID == 23
    well = 1;
    row = 2.5;
    column = 4;
    return;
end

if chID == 13
    well = 1;
    row = 3;
    column = 1;
    return;
end

if chID == 34
    well = 1;
    row = 3;
    column = 2;
    return;
end

if chID == 15
    well = 1;
    row = 3;
    column = 3;
    return;
end

if chID == 35
    well = 1;
    row = 3.5;
    column = 4;
    return;
end

if chID == 24
    well = 1;
    row = 4;
    column = 1;
    return;
end

if chID == 14
    well = 1;
    row = 4;
    column = 2;
    return;
end

if chID == 25
    well = 1;
    row = 4;
    column = 3;
    return;
end

% WELL 2

if chID == 51
    well = 2;
    row = 1;
    column = 1;
    return;
end

if chID == 54
    well = 2;
    row = 1;
    column = 2;
    return;
end

if chID == 62
    well = 2;
    row = 1;
    column = 3;
    return;
end

if chID == 63
    well = 2;
    row = 1;
    column = 4;
    return;
end

if chID == 52
    well = 2;
    row = 2;
    column = 1;
    return;
end

if chID == 53
    well = 2;
    row = 2;
    column = 2;
    return;
end

if chID == 71
    well = 2;
    row = 2;
    column = 3;
    return;
end

if chID == 72
    well = 2;
    row = 2;
    column = 4;
    return;
end

if chID == 41
    well = 2;
    row = 3;
    column = 1;
    return;
end

if chID == 42
    well = 2;
    row = 3;
    column = 2;
    return;
end

if chID == 82
    well = 2;
    row = 3;
    column = 3;
    return;
end

if chID == 73
    well = 2;
    row = 3;
    column = 4;
    return;
end

if chID == 43
    well = 2;
    row = 4;
    column = 1.5;
    return;
end

if chID == 61
    well = 2;
    row = 4;
    column = 2.5;
    return;
end

if chID == 83
    well = 2;
    row = 4;
    column = 3.5;
    return;
end

% WELL 3

if chID == 16
    well = 3;
    row = 1;
    column = 1.5;
    return;
end

if chID == 38
    well = 3;
    row = 1;
    column = 2.5;
    return;
end

if chID == 56
    well = 3;
    row = 1;
    column = 3.5;
    return;
end

if chID == 26
    well = 3;
    row = 2;
    column = 1;
    return;
end

if chID == 17
    well = 3;
    row = 2;
    column = 2;
    return;
end

if chID == 57
    well = 3;
    row = 2;
    column = 3;
    return;
end

if chID == 58
    well = 3;
    row = 2;
    column = 4;
    return;
end

if chID == 27
    well = 3;
    row = 3;
    column = 1;
    return;
end

if chID == 28
    well = 3;
    row = 3;
    column = 2;
    return;
end

if chID == 46
    well = 3;
    row = 3;
    column = 3;
    return;
end

if chID == 47
    well = 3;
    row = 3;
    column = 4;
    return;
end

if chID == 36
    well = 3;
    row = 4;
    column = 1;
    return;
end

if chID == 37
    well = 3;
    row = 4;
    column = 2;
    return;
end

if chID == 45
    well = 3;
    row = 4;
    column = 3;
    return;
end

if chID == 48
    well = 3;
    row = 4;
    column = 4;
    return;
end

% WELL 4

if chID == 74
    well = 4;
    row = 1;
    column = 2;
    return;
end

if chID == 85
    well = 4;
    row = 1;
    column = 3;
    return;
end

if chID == 75
    well = 4;
    row = 1;
    column = 4;
    return;
end

if chID == 64
    well = 4;
    row = 1.5;
    column = 1;
    return;
end

if chID == 84
    well = 4;
    row = 2;
    column = 2;
    return;
end

if chID == 65
    well = 4;
    row = 2;
    column = 3;
    return;
end

if chID == 86
    well = 4;
    row = 2;
    column = 4;
    return;
end

if chID == 76
    well = 4;
    row = 2.5;
    column = 1;
    return;
end

if chID == 67
    well = 4;
    row = 3;
    column = 2;
    return;
end

if chID == 77
    well = 4;
    row = 3;
    column = 3;
    return;
end

if chID == 87
    well = 4;
    row = 3;
    column = 4;
    return;
end

if chID == 55
    well = 4;
    row = 3.5;
    column = 1;
    return;
end

if chID == 68
    well = 4;
    row = 4;
    column = 2;
    return;
end

if chID == 78
    well = 4;
    row = 4;
    column = 3;
    return;
end

if chID == 66
    well = 4;
    row = 4;
    column = 4;
    return;
end

% If we arrived here, there must be something wrong.
error(['There is no an electrode labeled ' num2str(chID)]);
end

