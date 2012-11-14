function [ sti_seq ] = util_loadstimulation_fromxml( filename )
%UTIL_LOADSTIMULATION_FROMXML 工具函数：从给定的XML文件中载入刺激方案
%   从给定的XML文件中载入刺激方案
%   输入参数：Filename，指定的刺激方案文件，一般是由RBS生成
%   输出刺激方案结构体：sti_seq
%
%   蒲江波 2010年5月3日

% 打开XML文件
xDoc = xmlread(filename);

% 获取节点
all_items = xDoc.getElementsByTagName('node');

% 初始化进度条
h = waitbar(0, 'Please wait...');
set(h,'Name','Please wait while reading:');

% Note that the item list index is zero-based.
for i = 0:all_items.getLength - 1
    sti_seq(i+1) = parse_node_byname(all_items.item(i));
    waitbar(i/(all_items.getLength - 1), h, strrep(filename, '\', '\\'));
    % strrep is used to deal with the TeX intepreter (path\string)
end

% 关闭进度条
close(h);

end

function [result] = parse_node_byname(node)
% PARSE_NODE_BYNAME 分析XML的节点，将节点中的内容作为一个结构体返回
%   参数：
%       输入：node：节点
%       输出：result：返回之包括节点全部信息的结构体
%
%   蒲江波 2010年5月3日


%[#text:      1     11:00:34     47            400            300
% 3000            PN   ]
% getLength-1是因为这个item列表是从0开始的，所以要-1；
% 但是第一个是#text，属于无用信息#text。第二个有用，第三个无用，故step=2
% 这句可以获取所有的信息并存在结构体中，但是，不能很好的判断那些是数字型信息，哪些是字符型
% for i=1:2:node.getLength-1
    % result.(char(node.getChildNodes.item(i).getNodeName)) = char(node.getChildNodes.item(i).getTextContent)
% end

result.index = str2num(char(node.getChildNodes.item(1).getTextContent));
result.time = strtrim(char(node.getChildNodes.item(3).getTextContent));
result.elec = str2num(char(node.getChildNodes.item(5).getTextContent));
result.phase_duration = str2num(char(node.getChildNodes.item(7).getTextContent));
result.pulse_amplitude = str2num(char(node.getChildNodes.item(9).getTextContent));
result.inter_stimulus_interval = str2num(char(node.getChildNodes.item(11).getTextContent));
result.shape = strtrim(char(node.getChildNodes.item(13).getTextContent));

end

