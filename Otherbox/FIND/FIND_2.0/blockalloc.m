function allocresult=blockalloc(bsize)
% allocresult=blockalloc(bsize)
% tries to allocate a variable of size bsize
% return 1 if successful, and 0 if not.
    try
        clear tmp
        tmp=zeros(round(bsize/8),1);
        allocresult=1;
    catch
        allocresult=0;
    end
end