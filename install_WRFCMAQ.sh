#!/bin/bash

# ================================== Install WRF-CMAQ =====================================
# Requirements: netCDF-C 4.7.4 & netCDF-fortran 4.5.3 from /opt/comp_ifort_2021 
#               intel compiler
#               mpich
#               I/O API version 3.2
# Author: Alejandro D. Peralta
# Date: June 2023
# =========================================================================================

#> Installing WRF-CMAQ
rm -rf CMAQ_REPO
rm -rf ../WRFCMAQv5.4

git clone -b main https://github.com/USEPA/CMAQ.git CMAQ_REPO
cd CMAQ_REPO
git checkout -b my_branch

#> Considerations
export DIR="/opt/comp_ifort_2021"                   # Only works for AMANAN server with intel compiler
LIBRARY_PATH="${HOME}/YOUR_FOLDER"                  # Find your library folder where I/O API were installed
export HOME_IO="${LIBRARY_PATH}/ioapi-3.2"          # Path in which your I/O API was installed
export NETCDF_classic=1

#> Building and running in a user-specified directory outside of the repository
 # In the top level of CMAQ_REPO, the bldit_project.csh script will automatically replicate
 # the CMAQ folder structure and copy every build and run script out of the repository so
 # that you may modify them freely without version control.

sed -i 's: set CMAQ_HOME = /home/username/path: set CMAQ_HOME = ${HOME}/WRFCMAQv5.4:' bldit_project.csh
./bldit_project.csh
export CMAQ_HOME="${HOME}/WRFCMAQv5.4"
cd $CMAQ_HOME

#> Setting and fixing config_cmaq.csh
 # WRF source code expects that you have already collated the netCDF-C and netCDF-Fortran
 # libraries into one directory. If you have done so, ok.
 # If you are using netCDF classic - no HDF5 compression then set the following environment variable:

 #> I/O API, netcdf Library locations used in WRF-CMAQ
 sed -i 's:netcdf_root_intel:${NETCDF}:' config_cmaq.csh
 sed -i 's:ioapi_root_intel:${HOME_IO}:' config_cmaq.csh                 # I/O API passed all tests
                                                                         # ${HOME_IO} is the path when the I/O API was 
                                                                         # installed.
 sed -i 's:setenv WRF_ARCH #:setenv WRF_ARCH 15 #:' config_cmaq.csh      # Ok according to the AMANAN system
                                                                         # to install WRF-ARW, see details in 
                                                                         # WRF guide installation.
 sed -i '86,86i\        setenv NETCDF_classic 1' config_cmaq.csh         # adding a new line
 sed -i '87,87i\        setenv WRF_CMAQ 1' config_cmaq.csh               # adding a new line to install WRF_CMAQ

 #> I/O API, netCDF, and MPI Library locations used in CMAQ
 sed -i 's:ioapi_inc_intel:${IOAPI}/ioapi/fixed_src:' config_cmaq.csh
 sed -i 's:ioapi_lib_intel:${IOAPI}/Linux2_x86_64ifort:' config_cmaq.csh
 sed -i 's:netcdf_lib_intel:${NETCDF}/lib:' config_cmaq.csh
 sed -i 's:netcdf_inc_intel:${NETCDF}/include:' config_cmaq.csh
 sed -i 's:netcdff_lib_intel:${NETCDF}/lib:' config_cmaq.csh
 sed -i 's:netcdff_inc_intel:${NETCDF}/include:' config_cmaq.csh
 sed -i 's:mpi_incl_intel:${DIR}/mpich/include:' config_cmaq.csh
 sed -i 's:mpi_lib_intel:${DIR}/mpich/lib:' config_cmaq.csh
 sed -i 's:setenv myFC mpiifort:setenv myFC ifort:' config_cmaq.csh

#> Compiling WRF-CMAQ
 # MOdify the bldit_cctm.csh
 cd CCTM/scripts
 sed -i "84s/#set/set/g" bldit_cctm.csh

#> Run the bldit_cctm,csh script
./bldit_cctm.csh intel |& tee bldit_cctm_twoway.log   # See and the end if the executable were created 
ls BLD_WRFv4.4_CCTM_v54_intel/main/*.exe              # if ndown.exe, real.exe, tc.exe and wrf.exe 
                                                      # were created, so you've installed the WRF-CMAQ 

