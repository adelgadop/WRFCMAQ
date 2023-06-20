#!/bin/bash

# ================================== Install WRF-CMAQ =====================================
# Requirements: netCDF
#               intel compiler
#               mpich
#               I/O API version 3.2
# Author: Alejandro D. Peralta
# Date: June 2023
# =========================================================================================

#> Installing WRF-CMAQ
rm -rf CMAQ_REPO
rm -rf ../WRF4.4CMAQv5.4

git clone -b main https://github.com/USEPA/CMAQ.git CMAQ_REPO
cd CMAQ_REPO
git checkout -b my_branch

#> Considerations
HOME=/home/alejandro

#> Building and running in a user-specified directory outside of the repository
 # In the top level of CMAQ_REPO, the bldit_project.csh script will automatically replicate
 # the CMAQ folder structure and copy every build and run script out of the repository so
 # that you may modify them freely without version control.

sed -i 's: set CMAQ_HOME = /home/username/path: set CMAQ_HOME = ${HOME}/WRF4.4CMAQv5.4:' bldit_project.csh
./bldit_project.csh
export CMAQ_HOME="${HOME}/WRF4.4CMAQv5.4"
cd $CMAQ_HOME

#> Setting and fixing config_cmaq.csh
 # WRF source code expects that you have already collated the netCDF-C and netCDF-Fortran
 # libraries into one directory. If you have done so, ok.
 # If you are using netCDF classic - no HDF5 compression then set the following environment variable:

 export NETCDF_classic=1

 #> I/O API, netcdf Library locations used in WRF-CMAQ
 sed -i 's:netcdf_root_intel:${NETCDF}:' config_cmaq.csh
 sed -i 's:ioapi_root_intel:${HOME}/LIBRARIES/ioapi-3.2:' config_cmaq.csh
 sed -i 's:setenv WRF_ARCH #:setenv WRF_ARCH 15 #:' config_cmaq.csh
 sed -i '86,86i\        setenv NETCDF_classic 1' config_cmaq.csh   # adding a new line
 sed -i '87,87i\        setenv WRF_CMAQ 1' config_cmaq.csh         # adding a new line

 #> I/O API, netCDF, and MPI Library locations used in CMAQ
 sed -i 's:ioapi_inc_intel:${IOAPI}/ioapi/fixed_src:' config_cmaq.csh
 sed -i 's:ioapi_lib_intel:${IOAPI}/Linux2_x86_64ifort:' config_cmaq.csh
 sed -i 's:netcdf_lib_intel:${NETCDF}/lib:' config_cmaq.csh
 sed -i 's:netcdf_inc_intel:${NETCDF}/include:' config_cmaq.csh
 sed -i 's:netcdff_lib_intel:${NETCDF}/lib:' config_cmaq.csh
 sed -i 's:netcdff_inc_intel:${NETCDF}/include:' config_cmaq.csh
 sed -i 's:mpi_incl_intel:${HOME}/Build_CMAQ/LIBRARIES/mpich/include:' config_cmaq.csh
 sed -i 's:mpi_lib_intel:${HOME}/Build_CMAQ/LIBRARIES/mpich/lib:' config_cmaq.csh
 sed -i 's:setenv myFC mpiifort:setenv myFC mpifort:' config_cmaq.csh

#> Compiling WRF-CMAQ
 # MOdify the bldit_cctm.csh
 cd CCTM/scripts
 sed -i "84s/#set/set/g" bldit_cctm.csh

#> Run the bldit_cctm,csh script
./bldit_cctm.csh intel |& tee bldit_cctm_twoway.log

