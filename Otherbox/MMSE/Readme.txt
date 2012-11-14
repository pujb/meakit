The following contains the description of the m-files available in the toolbox for Multivariate Multiscale Complexity Analysis


1. Main Matlab script:

Filename: mmse.m

- This script generates multi-channel white and 1/f noise and calculates 
multivariate multiscale sample entropy estimates over different temporal 
scales. It is used to generate Figure 2 of Ref [1] below.
- The script produces a graph of MMSE estimates over different temporal 
scales (using coarse graining), giving an assessment of the complexity 
of the underlying dynamical structures in the data.
- The method uses the mvsampen_full.m function to generate full 
multivariate sample entropy for multichannel data over different temporal 
scales.
- Alternatively, you can replace this script with your own multivariate 
entropy estimates, for instance the 'naive' approach described below.
- To analyse MMSE of your own general data, please replace the 
corresponding lines in the script with your own data realisations.


2. Supporting Matlab scripts:

If you would like to look into the comparison of the 'naive' and 'full 
multivariate' approach to calculate MSampEn or into the ability of the 
'full multivariate' approach to discriminate between correlated and 
uncorrelated white as well as 1/f noise, the following Matlab programs 
are available:

a) Filename: mmse_correlated_vs_uncorrelated.m
- This code calculates multivariate sample entropy over different scales of
bivariate correlated and uncorrelated 1/f as well as white noise. It was 
used to generate Figure 3 of Ref [2] below.

b) Filename: mvsampen_naive.m
- This function is used to calculate MSampEn using the 'naive' 
multivariate approach, where the cross-channel correlations are not 
taken into account. This method was used in Reference [4] below.

c) Filename: mvsampen_full.m
- This function is used to calculate multivariate sample entropy 
(MSampEn) using the full multivariate approach, where both the 
inter-channel and cross-channel dependencies are taken into account; this 
method is used in References [1] and [2] below.

d) Filename: embd.m
- This function creates multivariate delay embedded vectors with the 
Embedding vector parameter M and time lag vector parameter tau.

e) Filename: powernoise.m
- This function generates samples of power law noise. The power spectrum
of this signal scales as f^(-alpha). This function is written by Max 
Little [Ref. 3], and was downloaded from 
http://www.maxlittle.net/software/index.php.


References:

[1] M. U. Ahmed and D. P. Mandic, "Multivariate multiscale entropy: A 
tool for complexity analysis of multichannel data," Physical Review E, 
vol. 84, no. 6, pp. 061918-1 – 061918-10, 2011.

[2] M. U. Ahmed and D. P. Mandic, "Multivariate multiscale entropy 
analysis," IEEE Signal Processing Letters, in press, 2012.

[3] M.A. Little, P.E. McSharry, S.J. Roberts, D.A.E. Costello, I.M. 
Moroz (2007), "Exploiting nonlinear recurrence and fractal scaling 
properties for voice disorder detection", BioMedical Engineering OnLine 
2007, 6:23.

[4] M. U. Ahmed, L. Li, J. Cao, and D. P. Mandic, "Multivariate 
multiscale entropy for brain consciousness analysis", Proceedings of the 
IEEE EMBC Conference, pp. 810-813, 2011.
