function [ connected ] = util_connect_spif_spikevalues( spv1, spv2 )
%UTIL_CONNECT_SPIF_SPIKEVALUES 工具函数：将两个Spikevalues连接成一个
%   将两个Spikevalues连接成一个Spikevalues。这个函数的实质是将两个一样大小的Cell
%   矩阵连接成一个Cell矩阵(按列)。
%
%   蒲江波 - 2009年6月17日

if size(spv1) ~= size(spv2)
    error('Two arguments must have the same size.');
end

[rows columns] = size(spv1);
connected = cell(rows,columns);

% 在行中迭代，将Cell矩阵中每个元素的值按column连接
for i = 1:rows
    connected{i} = [spv1{i}, spv2{i}];
end

end
