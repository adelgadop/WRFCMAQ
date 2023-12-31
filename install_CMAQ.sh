#!/bin/bash

# ============================== Install CMAQ v5.4=============================
# Requirements: netCDF-C 4.7.4 & netCDF-fortran 4.5.3 from /opt/comp_ifort_2021 
#               intel compiler
#               mpich
#               I/O API version 3.2
# Author: Alejandro D. Peralta
# Date: December 2023
# =============================================================================

#> Installing CMAQ and MCIP, BCON and ICON
rm -rf CMAQ_REPO
rm -rf ../CMAQv5.4

git clone -b main https://github.com/USEPA/CMAQ.git CMAQ_REPO
cd CMAQ_REPO
git checkout -b my_branch

#> Considerations
export DIR="/opt/comp_ifort_2021"                   # Only works for AMANAN server with intel compiler
export NETCDF_classic=1

#> Building and running in a user-specified directory outside of the repository
 # In the top level of CMAQ_REPO, the bldit_project.csh script will automatically replicate
 # the CMAQ folder structure and copy every build and run script out of the repository so
 # that you may modify them freely without version control.

sed -i 's: set CMAQ_HOME = /home/username/path: set CMAQ_HOME = ${HOME}/CMAQv5.4:' bldit_project.csh
./bldit_project.csh
export CMAQ_HOME="${HOME}/CMAQv5.4"

# We only can compile CMAQ with OpenMPI that it is needed include in your ~/.bashrc
#export PATH="$DIR/openmpi/bin:$PATH"
#export LD_LIBRARY_PATH="$DIR/openmpi/lib:$LD_LIBRARY_PATH"

cd $CMAQ_HOME

#> Setting and fixing config_cmaq.csh
 # WRF source code expects that you have already collated the netCDF-C and netCDF-Fortran
 # libraries into one directory. If you have done so, ok.
 # If you are using netCDF classic - no HDF5 compression then set the following environment variable:

 #> I/O API, netcdf Library locations used in WRF-CMAQ
 sed -i 's:netcdf_root_intel:${NETCDF}:' config_cmaq.csh
 sed -i 's:ioapi_root_intel:${HOME}/BLDLIB/ioapi-3.2:' config_cmaq.csh   # I/O API location that passed all tests
 sed -i 's:setenv WRF_ARCH #:setenv WRF_ARCH 15 #:' config_cmaq.csh      # Ok according to the AMANAN system
                                                                         # to install WRF-ARW, see details in 
                                                                         # WRF guide installation.
 sed -i '86,86i\        setenv NETCDF_classic 1' config_cmaq.csh         # adding a new line
 #sed -i '87,87i\        setenv WRF_CMAQ 1' config_cmaq.csh               # adding a new line to install WRF_CMAQ

 #> I/O API, netCDF, and MPI Library locations used in CMAQ
 sed -i 's:ioapi_inc_intel:${IOAPI}/ioapi/fixed_src:' config_cmaq.csh
 sed -i 's:ioapi_lib_intel:${IOAPI}/Linux2_x86_64ifort:' config_cmaq.csh
 sed -i 's:netcdf_lib_intel:${NETCDF}/lib:' config_cmaq.csh
 sed -i 's:netcdf_inc_intel:${NETCDF}/include:' config_cmaq.csh
 sed -i 's:netcdff_lib_intel:${NETCDF}/lib:' config_cmaq.csh
 sed -i 's:netcdff_inc_intel:${NETCDF}/include:' config_cmaq.csh
 sed -i 's:mpi_incl_intel:${DIR}/mpich/include:' config_cmaq.csh
 sed -i 's:mpi_lib_intel:${DIR}/mpich/lib:' config_cmaq.csh
 sed -i 's:setenv myFC mpiifort:setenv myFC mpif90:' config_cmaq.csh
 sed -i 's:setenv myCC icc:setenv myCC mpicc' config_cmaq.csh
 sed -i 's:setenv netcdf_lib "-lnetcdf":setenv netcdf_lib "-lnetcdff -lnetcdf":' config_cmaq.csh
 sed -i 's:setenv mpi_lib "-lmpi":setenv mpi_lib "-lmpich":' config_cmaq.csh

#> Compiling CCTM
 # Modify the bldit_cctm.csh
 cd CCTM/scripts
# sed -i "84s/#set/set/g" bldit_cctm.csh              # This is only to compile WRF-CMAQ
sed -i 's:set ICL_MPI   = .:set ICL_MPI   = $MPI_INCL_DIR:' bldit_cctm.csh

#> Run the bldit_cctm,csh script
./bldit_cctm.csh intel |& tee bldit.cctm.log          # See and the end if the executable were created 
ls BLD_CCTM_v54_intel/*.exe              # if CCTM_v54.exe exists, so you've installed the CMAQ 

#> Install MCIP
cd $CMAQ_HOME/PREP/mcip/src
sed -i "51s:/usr/local/apps/netcdf-4.7.3/intel-19.0:$NETCDF:" Makefile
sed -i "52s:/usr/local/apps/ioapi-3.2_20181011/intel-19.0:${HOME}/BLDLIB/ioapi-3.2:" Makefile
make |& tee make.mcip.log
ls mcip.exe

#> Building the BCON executable
cd $CMAQ_HOME/PREP/bcon/scripts
./bldit_bcon.csh intel |& tee make_bcon.log
ls BLD_BCON_v54_intel/*.exe

#> Building the ICON executable
cd $CMAQ_HOME/PREP/icon/scripts
./bldit_icon.csh intel |& tee make_icon.log
ls BLD_ICON_v54_intel/*.exe

