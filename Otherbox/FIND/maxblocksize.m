function [mbsize,bsizetrace]=maxblocksize(startsize, varargin)
% [mbsize,bsizetrace]=maxblocksize(startsize,stepdepth,maxsize)
% returns bytes (not elements!)

if length(varargin)>=1
    maxsize=varargin{1};
else
    maxsize=Inf;
end

if length(varargin)==2
    stepdepth=varargin{2};
else
    stepdepth=6;
end

if startsize <=0;
    error('hehe, nice try...')
end

allocresult=1;
bsizetrace=[];

bsize=startsize;
while allocresult && bsize
    
    bsizetrace=[bsizetrace bsize];
%     disp(['trying ',num2str(bsize)]);
    allocresult=blockalloc(bsize);
    bsize=bsize*2;
    if allocresult==0
%         disp('failure');
    else
%         disp('success');
        % maxsize less than what fits --> all is well, return.
        if bsize/2 >= maxsize
            mbsize=bsize;
            return
        end
    end
end
bsize=bsize/2;



bsize=bsize/2;
bsizebase=bsize;
% disp(['base value is ',num2str(bsizebase)])
for ii=1:stepdepth
    bsizetrace=[bsizetrace bsizebase+bsize*(0.5^ii)];
    newval=bsizebase+bsize*(0.5^ii);
%     disp(['trying ',num2str(newval)])
    result=blockalloc(newval);
    if result
%         disp('success')
        bsizebase=newval;
    else
%         disp('failure')
    end
    if bsizebase >= maxsize
        mbsize=bsizebase;
%         disp('max size reached... exiting')
        return
    end
end
mbsize=bsizebase;
% disp(['maximum number of iterations reached. result is ',num2str(bsizebase)]);
end
