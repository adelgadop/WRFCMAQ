# WRF-CMAQ coupled installation
This repository focuses on installing the Weather Research and Forecasting (WRF) coupled with the Community Multiscale Air Quality (CMAQ) model. The WRF-CMAQ model (Wong et al., 2012) facilitates the exchange of information between CMAQ and WRF, allowing the examination of how chemistry impacts weather phenomena.

This repository also provides Bash scripts to install the I/O API v3.2 library, a necessary dependency for the WRF-CMAQ model. The I/O API installation script is tailored explicitly for the AMANAN server, utilizing the Intel compiler. The other script installs the WRF-CMAQ model using libraries from the I/O API 3.2 and others already installed, such as netCDF (netCDF-C and netCDF-Fortran) and MPICH.

We encourage the IT team of the IAG-USP can use these scripts to facilitate the installation of the I/O API v3.2 and the WRF-CMAQ coupled model.

We followed the installation tutorials from the US EPA GitHub:

- [CMAQ build library intel](https://github.com/USEPA/CMAQ/blob/main/DOCS/Users_Guide/Tutorials/CMAQ_UG_tutorial_build_library_intel.md)
- [Tutorial WRF-CMAQ Benchmark](https://github.com/USEPA/CMAQ/blob/main/DOCS/Users_Guide/Tutorials/CMAQ_UG_tutorial_WRF-CMAQ_Benchmark.md)

## Objective of this repository
- Create scripts to install for any user inside the AMANAN server.
- Create an I/O API helpful script for the IT team of the IAG-USP, who can use it to install a shared library for users that want to install WRF-CMAQ.

## IMPORTANT NOTES
Please, **ENSURE** that your `.bashrc` is set up to switch off the chemical option and KPP of WRF:

```bash
export WRF_EM_CORE=1
export WRF_NMM_CORE=0
export WRF_CHEM=0                        # Chemistry turned off
export WRFIO_NCD_LARGE_FILE_SUPPORT=1
export WRF_KPP=0                         # KPP turned off
export YACC='/usr/bin/yacc -d'
export FLEX_LIB_DIR="/usr/lib64"
export MALLOC_CHECK_=0
```
On the other hand, if your `.bashrc` has commented lines such as `# export WRF_CHEM=1`, please go out from the server and enter again and verify in the terminal your variables:

```bash
[alejandro@amanan ~]$ echo $WRF_CHEM $WRF_KPP $HDF5

[alejandro@amanan ~]$

```

If there is nothing to see, you are right.

## Installation of Meteorology-Chemistry Interface Processor (MCIP)
The Meteorology-Chemistry Interface Processor (MCIP) ingests output from the Weather Research and Forecasting (WRF) Model to prepare the meteorology files used within the CMAQ Modeling System. However, WRF-CMAQ coupled model doesn't require the MCIP program, because it can create the GRIDDESC and other files (METCRO2D...). The MCIP output is also helpful for creating SMOKE emission files considering global emissions from CAMS and EDGAR. We can install the MCIP if we have installed the I/O API and the netCDF, successfully. The installation steps are:

- Create an alias called "lib" in your I/O API directory that it has been installed previously. `ln -sf ~/BLDLIB/ioapi-3.2/Linux2_x86_64ifort lib`
- Go to `/home/alejandro/WRFCMAQv5.4/PREP/mcip/src`
- Open the Makefile. I used `vi Makefile`to open it.

```
49 #...Intel Fortran                                                                                 
50 FC      = ifort                                                                 
51 NETCDF = /opt/comp_ifort_2021/netcdf                                            
52 IOAPI_ROOT = /home/alejandro/BLDLIB/ioapi-3.2                                   
53 ###FFLAGS  = -g -O0 -check all -C -traceback -FR -I$(NETCDF)/include  \         
54 ###          -I$(IOAPI_ROOT)/Linux2_x86_64ifort                                 
55 FFLAGS  = -O3 -traceback -FR -I$(NETCDF)/include -I$(IOAPI_ROOT)/Linux2_x86_64ifort
56 LIBS    = -L$(IOAPI_ROOT)/lib -lioapi \                                         
57           -L$(NETCDF)/lib -lnetcdff -lnetcdf
```
- Close Makefile and install the MCIP with `make |& tee make.mcip.log`
- Verify if the `mcip.exe` was created.

## Building the BCON executable
1. Go to the directory that contains the BCON scripts:
```
csh
cd $CMAQ_HOME/PREP/bcon/scripts
./bldit_bcon.csh intel |& tee make_bcon.log
```
Look for the executable **BCON_v54.exe** in the $CMAQ_HOME/PREP/bcon/scripts/BLD_BCON_v54_intel directory to see if the build script completed successfully.

## Building the ICON executable
1. Go to the directory that contains the BCON scripts:
```
csh
cd $CMAQ_HOME/PREP/icon/scripts
./bldit_icon.csh intel |& tee make_icon.log
```
Look for the executable **ICON_v54.exe** in the $CMAQ_HOME/PREP/bcon/scripts/BLD_ICON_v54_intel directory to see if the build script completed successfully.

# Acknowledgment
Thank you to the US EPA for creating WRF-CMAQ and to the CMAS Center (https://cmascenter.org/) for developing the I/O API v3.2 program.
