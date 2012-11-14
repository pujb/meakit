function A = util_get_assortativity( network_connection_matrix, varargin )
%UTIL_GET_ASSORTATIVITY Calculte the assortativity of the network
%   Input:
%       network_connection_matrix:  The network connection matrix. (CCPeak)
%       thresholding:   Used to threshold the network connection matrix. [default: 0.1]
%       thresholding_method:   'percent' / 'direct' [default]
%                           @percent, lower thresholding% will be removed.
%                           @direct, values < thresholding will be removed.
%
%   Created on Oct/20/2010 By Pu Jiangbo
%   Britton Chance Center for Biomedical Photonics
%
%   $Revision:
%       PJB#2011-04-06  Bug fix.

pvpmod(varargin);

if ~exist('thresholding', 'var')
    thresholding = 0.1;
end

if ~exist('thresholding_method', 'var')
    thresholding_method = 'direct';
end

if strcmpi(thresholding_method, 'percent')
    thresholding = util_get_value_by_percent(network_connection_matrix, thresholding, 1);
    disp(['Thresholding by percent, current value level is ' num2str(thresholding)]);
else
    disp(['Thresholding by value: ' num2str(thresholding)]);
end

% Call
[A, M] = assortativity(network_connection_matrix, thresholding);
disp(['Number of valid connection: ' num2str(M) '.']);

end


function [r,M] = assortativity(CCpeak,lv)
% By Chen Wenjuan, v. 2010/10/19
% r>0 ---- 正匹配网络，节点倾向与自己相似的点建立连接
% r<0 ---- 负匹配网络，节点倾向与自己不相似的点建立连接
% M   ---- 网络中大于阈值的功能连接数目

[x,y]=find(CCpeak>lv);
M=length(x);
if M>0
    j=zeros(M,1);
    k=zeros(M,1);
    for i=1:M
        j(i)=length(find(CCpeak(x(i),:)>lv))+length(find(CCpeak(:,x(i))>lv));
        k(i)=length(find(CCpeak(y(i),:)>lv))+length(find(CCpeak(:,y(i))>lv));
    end
    upvalue=sum(j.*k)/M-(sum((j+k)/(2*M)))^2;
    downvalue=(sum(j.^2)+sum(k.^2))/(2*M)-(sum((j+k)/(2*M)))^2;
    r=upvalue/downvalue;
else
    r=0;
end


end