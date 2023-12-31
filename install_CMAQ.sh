#!/bin/bash

# ============================== Install CMAQ v5.4=============================
# Requirements: netCDF-C 4.7.4 & netCDF-fortran 4.5.3 from /opt/comp_ifort_2021 
#               intel compiler
#               mpich
#               I/O API version 3.2
# Author: Alejandro D. Peralta
# Date: December 2023
# =============================================================================

#> Installing WRF-CMAQ
rm -rf CMAQ_REPO
rm -rf ../CMAQv5.4

git clone -b main https://github.com/USEPA/CMAQ.git CMAQ_REPO
cd CMAQ_REPO
git checkout -b my_branch

#> Considerations
export DIR="/opt/comp_ifort_2021"                   # Only works for AMANAN server with intel compiler
LIBRARY_PATH="${HOME}/BLDLIB"                       # Find your library folder where I/O API is
export HOME_IO="${LIBRARY_PATH}/ioapi-3.2"          # Path in which your I/O API was installed
#export NETCDF_classic=1

#> Building and running in a user-specified directory outside of the repository
 # In the top level of CMAQ_REPO, the bldit_project.csh script will automatically replicate
 # the CMAQ folder structure and copy every build and run script out of the repository so
 # that you may modify them freely without version control.

sed -i 's: set CMAQ_HOME = /home/username/path: set CMAQ_HOME = ${HOME}/CMAQv5.4:' bldit_project.csh
./bldit_project.csh
export CMAQ_HOME="${HOME}/CMAQv5.4"

# We only can compile CMAQ with OpenMPI
export PATH="$DIR/openmpi/bin:$PATH"
export LD_LIBRARY_PATH="$BUILD_LIBS/openmpi/lib:$LD_LIBRARY_PATH"

which mpifort
which mpicc
# I didn't have successful when I tried to compile with MPICH, so with OpenMPI yes

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
 #sed -i '86,86i\        setenv NETCDF_classic 1' config_cmaq.csh         # adding a new line
 #sed -i '87,87i\        setenv WRF_CMAQ 1' config_cmaq.csh               # adding a new line to install WRF_CMAQ

 #> I/O API, netCDF, and MPI Library locations used in CMAQ
 sed -i 's:ioapi_inc_intel:${IOAPI}/ioapi/fixed_src:' config_cmaq.csh
 sed -i 's:ioapi_lib_intel:${IOAPI}/Linux2_x86_64ifort:' config_cmaq.csh
 sed -i 's:netcdf_lib_intel:${NETCDF}/lib:' config_cmaq.csh
 sed -i 's:netcdf_inc_intel:${NETCDF}/include:' config_cmaq.csh
 sed -i 's:netcdff_lib_intel:${NETCDF}/lib:' config_cmaq.csh
 sed -i 's:netcdff_inc_intel:${NETCDF}/include:' config_cmaq.csh
 sed -i 's:mpi_incl_intel:${DIR}/openmpi/include:' config_cmaq.csh
 sed -i 's:mpi_lib_intel:${DIR}/openmpi/lib:' config_cmaq.csh
 sed -i 's:setenv myFC mpiifort:setenv myFC mpifort:' config_cmaq.csh
 sed -i 's:setenv myCC icc:setenv myCC mpicc' config_cmaq.csh
 sed -i 's:setenv netcdf_lib "-lnetcdf":setenv netcdf_lib "-lnetcdff -lnetcdf":' config_cmaq.csh

#> Compiling CCTM
 # Modify the bldit_cctm.csh
 cd CCTM/scripts
# sed -i "84s/#set/set/g" bldit_cctm.csh              # This is only to compile WRF-CMAQ
sed -i 's:set ICL_MPI   = .:set ICL_MPI   = $MPI_INCL_DIR:' bldit_cctm.csh

#> Run the bldit_cctm,csh script
./bldit_cctm.csh intel |& tee bldit.cctm.log          # See and the end if the executable were created 
ls BLD_CCTM_v54_intel/*.exe              # if CCTM_v54.exe exists, so you've installed the CMAQ 

