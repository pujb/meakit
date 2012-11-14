@echo off
set MATLAB=D:\MATLAB\R2011a
set MATLAB_ARCH=win32
set MATLAB_BIN="D:\MATLAB\R2011a\bin"
set ENTRYPOINT=mexFunction
set OUTDIR=E:\Software Profiles\matlab\util\Model\gcd\codegen\mex\glia_Ca_3_3\
set LIB_NAME=glia_Ca_3_3_mex
set MEX_NAME=glia_Ca_3_3_mex
set MEX_EXT=.mexw32
call mexopts.bat
echo # Make settings for glia_Ca_3_3 > glia_Ca_3_3_mex.mki
echo COMPILER=%COMPILER%>> glia_Ca_3_3_mex.mki
echo COMPFLAGS=%COMPFLAGS%>> glia_Ca_3_3_mex.mki
echo OPTIMFLAGS=%OPTIMFLAGS%>> glia_Ca_3_3_mex.mki
echo DEBUGFLAGS=%DEBUGFLAGS%>> glia_Ca_3_3_mex.mki
echo LINKER=%LINKER%>> glia_Ca_3_3_mex.mki
echo LINKFLAGS=%LINKFLAGS%>> glia_Ca_3_3_mex.mki
echo LINKOPTIMFLAGS=%LINKOPTIMFLAGS%>> glia_Ca_3_3_mex.mki
echo LINKDEBUGFLAGS=%LINKDEBUGFLAGS%>> glia_Ca_3_3_mex.mki
echo MATLAB_ARCH=%MATLAB_ARCH%>> glia_Ca_3_3_mex.mki
echo BORLAND=%BORLAND%>> glia_Ca_3_3_mex.mki
echo OMPFLAGS= >> glia_Ca_3_3_mex.mki
echo EMC_COMPILER=msvc100>> glia_Ca_3_3_mex.mki
echo EMC_CONFIG=debug>> glia_Ca_3_3_mex.mki
"D:\MATLAB\R2011a\bin\win32\gmake" -B -f glia_Ca_3_3_mex.mk
