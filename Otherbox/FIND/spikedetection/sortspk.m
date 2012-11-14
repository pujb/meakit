function [spikes, idx, classes]=sortspk(hpsig, samp, spkidx, wpre, wpost, nclusters, clustype)
% This function sorts (separates) the spike with respect to clusters. 
% Inputs are High passed signal, position of possible spike (index),
% Sampling frequency, pre and post time (in mS) of spike event and possible number of  clusting.  


%     spikes      :  Output >> Estimated spikes considered for clustering
%     idx         :  Output >> index of peak of spike
%     classes     :  Output >> Cluster number of each spike 
%
%     fname       : temporary file name (file contains raw signal(signal),
%                   High Passed signal (hpsig), sampling frequency (samp)and 
%                   index of peak of spike (spkidx)
%     wpre        : pre-event of spike time (in ms)
%     wpost       : post-event of spike time (in ms)) 
%     nclusters   : number of cluster (assumed spike template) 

% Example:    
%    [spikes, idx]=sortspk(HpSignal, samp, spkidx, 1, 1, 4, 1);
% 
% 
% Developed by Dr. Shahjahan Shahid. (ssh@cs.stir.ac.uk)
% University of Stirling.  
% Last updated 18 Feb 2009.
%=========================================================================

w_pre=floor(wpre*samp/1000);        % In data  point
w_post=floor(wpost*samp/1000);      % In data  point
peakat=0.5e-3*samp;

% =============== peak spike shape for sorting =====================
indexmat=zeros(length(spkidx),w_pre+w_post+1);
for i = 1:length(spkidx)     % ----- peak alignment 
    idmat=spkidx(i)-peakat:spkidx(i)+peakat;
    [v in]= max(abs(hpsig(idmat(1,:))));
    tol= -9+in; %-w_pre;
    indexmat(i, :)=spkidx(i)+tol-w_pre:spkidx(i)+tol+w_post;
end
sig=hpsig(:); 
spikes=sig(indexmat);
minsp=min(spikes(:)); maxsp=max(spikes(:)); 

% ====== Spike feature extraction
[feaspikes]=spkfea(spikes, 10);
        
if clustype ==1
    %====== K-means Clustering =============

    classes = kmeans(feaspikes, nclusters);
else
    %====== SPC Clustering =================
    
    [clu, tree] = spc_cluster(feaspikes);
    for temp=1:size(clu,1);
        classes = clu(temp,3:end)+1;
        if max(classes)==nclusters; break;
        elseif max(classes)>nclusters classes = clu(temp-1,3:end)+1; break
        end
    end
    classes=classes(:);
end


lnclr= ['k', 'b', 'r', 'g', 'c', 'm', 'y', 'b', 'r', 'g', 'c', 'm', 'y', 'b']';

figure; hold on; 
for i = 1 : nclusters;  
    plot(spikes((classes==i), :)', lnclr(i)); 
    title(['# ' num2str(length(spikes))]);
end

plotnum=100+nclusters*10; 
figname= ['Sorted Spikes']; 
h = findobj('name', figname);
if ~isempty(h); close (h); end
figure; set(gcf, 'name', figname)
for i = 1 : nclusters; 
    subplot(plotnum+i), plot (spikes((classes==i), :)', lnclr(i));  
    ylim([minsp maxsp]); title(['# ' num2str(length(classes(classes==i)))]);
end
pause(.5);
sptr=hpsig(:)*0; sptr(spkidx)=1;
sp=[];
figname= ['Sorted Spikes Train'];
h = findobj('name', figname);
if ~isempty(h); close (h); end
idx=find(sptr>0);
for i = 1:nclusters
    eval(['id = (idx(classes==' num2str(i) '));']);
    eval(['sp_' num2str(i-1) ' = sptr*0; sp_' num2str(i-1) '(id)=1;']);
    eval(['sp=[sp sp_' num2str(i-1) '];'])
end
signaldisp(100*[0.8*hpsig(:) sp]);
set(gcf, 'name', figname)
return


%%============================== Finctions ===============================
function [clu, tree] = spc_cluster(indexmat)
 
fname='out.mat';
mintemp =0.00;
maxtemp=0.20;
tempstep= .01;
SWCycles=100;
KNearNeighb=11;
 
% dim=handles.par.inputs;
% fname=handles.par.fname;
% fname_in=handles.par.fname_in;
% 
% % DELETE PREVIOUS FILES
% delfile1= [fname '.dg_01.lab'];
% delfile2= [fname '.dg_01'];
% 
% if exist(delfile1)==2; eval( ['delete(delfile1)' ],'[];'); end
% if exist(delfile2)==2; eval( ['delete(delfile2)' ],'[];'); end
 
 
tempfile1=[fname(1:end-4), '_tmp1']; 
tempfile2=[fname(1:end-4), '_tmp2']; 
tempfile3=[fname(1:end-4), '_tmp3']; 
 
spikeset=indexmat(:, 1:1:end);
%load(fname);
save(tempfile1, 'spikeset','-ascii');
 
 
[n, dim]=size(spikeset);
fid=fopen(tempfile2,'wt');
fprintf(fid,'NumberOfPoints: %s\n',num2str(n));
fprintf(fid,'DataFile: %s\n',tempfile1);
fprintf(fid,'OutFile: %s\n',tempfile3);
fprintf(fid,'Dimensions: %s\n',num2str(dim));
fprintf(fid,'MinTemp: %s\n',num2str(mintemp));
fprintf(fid,'MaxTemp: %s\n',num2str(maxtemp));
fprintf(fid,'TempStep: %s\n',num2str(tempstep));
fprintf(fid,'SWCycles: %s\n',num2str(SWCycles));
fprintf(fid,'KNearestNeighbours: %s\n',num2str(KNearNeighb));
fprintf(fid,'MSTree|\n');
fprintf(fid,'DirectedGrowth|\n');
fprintf(fid,'SaveSuscept|\n');
fprintf(fid,'WriteLables|\n');
fprintf(fid,'WriteCorFile~\n');
% if randomseed ~= 0
%     fprintf(fid,'ForceRandomSeed: %s\n',num2str(randomseed));
% end    
fclose(fid);
 
% [str,maxsize,endian]=computer;
% handles.par.system=str;
% switch handles.par.system
%     case 'PCWIN'
if exist([pwd '\cluster.exe'])==0
    directory = which('cluster.exe');
    copyfile(directory,pwd);
end
dos(sprintf('cluster.exe %s',tempfile2));
        
clu=load([tempfile3 '.dg_01.lab']);
tree=load([tempfile3 '.dg_01']); 
delete *_tmp?;
delete *_tmp3.dg*;
delete *.mag
delete *.edges
delete *.param
%delete(fname_in); 

%%================== Function====================

function [inspk coeff]=spkfea(spikes, feapnt)
    
% smoothing the spike to redice noise effect. 
for n=1:size(spikes,1); spikes(n, :)=[spikes(n, 1:end-2)+spikes(n, 2:end-1)+spikes(n, 3:end), 0, 0]./3; end
 
%[C,S,L] = princomp(spikes);
S=[]; for i=1:size(spikes,1); [c,l]=dwt(spikes(i,:),'haar');  S(i,1:size(c,2))=c(1:size(c,2)); end
%S=[]; for i=1:size(spikes,1); [c,l]=wavedec(spikes(i,:),4,'bior2.2');  S(i,1:size(c,2))=c(1:size(c,2)); end
%S=[]; for i=1:size(spikes,1); [c,l]=wavedec(spikes(i,:),4,'haar');  S(i,1:size(c,2))=c(1:size(c,2)); end
%S=spikes;
 
for i=1: size(S,2); % size(spikes,2)                                 % KS test for coefficient selection    
    thr_dist = std(S(:,i)) * 3;
    thr_dist_min = mean(S(:,i)) - thr_dist;
    thr_dist_max = mean(S(:,i)) + thr_dist;
    aux = S(find(S(:,i)>thr_dist_min & S(:,i)<thr_dist_max),i);
 
    if length(aux) > 10;
        [ksstat]=test_ks(aux);
        sd(i)=ksstat;
    else
        sd(i)=0;
    end
end
[max ind]=sort(sd);
%coeff(1:feapnt)=ind(size(spikes,2):-1:size(spikes,2)-feapnt+1);
coeff(1:feapnt)=ind(size(S,2):-1:size(S,2)-feapnt+1);
%CREATES INPUT MATRIX FOR SPC
inspk=zeros(size(spikes,1),feapnt);
for i=1:size(spikes,1)
    for j=1:feapnt
        inspk(i,j)=S(i,coeff(j));
    end
end
 
 
function [KSmax] = test_ks(x)
% 
% Calculates the CDF (expcdf)
[y_expcdf,x_expcdf]=cdfcalc(x);
 
%
% The theoretical CDF (theocdf) is assumed to be normal  
% with unknown mean and sigma
 
zScores  =  (x_expcdf - mean(x))./std(x);
theocdf  =  normcdf(zScores , 0 , 1);
 
%
% Compute the Maximum distance: max|S(x) - theocdf(x)|.
%
 
delta1    =  y_expcdf(1:end-1) - theocdf;   % Vertical difference at jumps approaching from the LEFT.
delta2    =  y_expcdf(2:end)   - theocdf;   % Vertical difference at jumps approaching from the RIGHT.
deltacdf  =  abs([delta1 ; delta2]);
 
KSmax =  max(deltacdf);


