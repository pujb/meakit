function [ connected ] = util_connect_spif_spiketimes( spt1, spt2, varargin )
%UTIL_CONNECT_SPIF_SPIKETIMES 工具函数：将两个Spiketimes连接成一个
%   将两个Spiketimes连接成一个Spiketimes。这个函数的实质是将两个一样大小的Cell
%   矩阵连接成一个Cell矩阵(按行)。
%
%   'auto_extend'：用于连接几个矩阵时用，将spt2中的spiketime值统一的加上一个auto_extend指定的数（ms）
%
%   蒲江波 - 2009年6月17日
%   蒲江波 - 2009年7月3日
%       加上auto_extend这个参数，能够将两个spiketimes按照时间连接起来(后面的spiketimes统一的加上一个基准值：前面的文件的长度)

pvpmod(varargin);

if size(spt1) ~= size(spt2)
    error('Two arguments must have the same size.');
end

[rows columns] = size(spt1);
connected = cell(rows,columns);

% 在行中迭代，将Cell矩阵中每个元素的值按row连接
if exist('auto_extend', 'var')
    for i = 1:rows
        connected{i} = [spt1{i}; spt2{i} + auto_extend];
    end
else
    for i = 1:rows
        connected{i} = [spt1{i}; spt2{i}];
    end
end

end

