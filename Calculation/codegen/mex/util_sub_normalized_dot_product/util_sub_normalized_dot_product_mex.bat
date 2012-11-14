@echo off
set MATLAB=E:\PROGRA~1\MATLAB\R2012a
set MATLAB_ARCH=win32
set MATLAB_BIN="E:\Program Files (x86)\MATLAB\R2012a\bin"
set ENTRYPOINT=mexFunction
set OUTDIR=.\
set LIB_NAME=util_sub_normalized_dot_product_mex
set MEX_NAME=util_sub_normalized_dot_product_mex
set MEX_EXT=.mexw32
call mexopts.bat
echo # Make settings for util_sub_normalized_dot_product > util_sub_normalized_dot_product_mex.mki
echo COMPILER=%COMPILER%>> util_sub_normalized_dot_product_mex.mki
echo COMPFLAGS=%COMPFLAGS%>> util_sub_normalized_dot_product_mex.mki
echo OPTIMFLAGS=%OPTIMFLAGS%>> util_sub_normalized_dot_product_mex.mki
echo DEBUGFLAGS=%DEBUGFLAGS%>> util_sub_normalized_dot_product_mex.mki
echo LINKER=%LINKER%>> util_sub_normalized_dot_product_mex.mki
echo LINKFLAGS=%LINKFLAGS%>> util_sub_normalized_dot_product_mex.mki
echo LINKOPTIMFLAGS=%LINKOPTIMFLAGS%>> util_sub_normalized_dot_product_mex.mki
echo LINKDEBUGFLAGS=%LINKDEBUGFLAGS%>> util_sub_normalized_dot_product_mex.mki
echo MATLAB_ARCH=%MATLAB_ARCH%>> util_sub_normalized_dot_product_mex.mki
echo BORLAND=%BORLAND%>> util_sub_normalized_dot_product_mex.mki
echo OMPFLAGS= >> util_sub_normalized_dot_product_mex.mki
echo OMPLINKFLAGS= >> util_sub_normalized_dot_product_mex.mki
echo EMC_COMPILER=lcc>> util_sub_normalized_dot_product_mex.mki
echo EMC_CONFIG=optim>> util_sub_normalized_dot_product_mex.mki
"E:\Program Files (x86)\MATLAB\R2012a\bin\win32\gmake" -B -f util_sub_normalized_dot_product_mex.mk
