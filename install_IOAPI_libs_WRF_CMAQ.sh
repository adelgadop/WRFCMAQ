#!/bin/bash

# ============================= Install I/O API 3.2 =================================
# Requirements: netCDF-C 4.7.4 & netCDF-fortran 4.5.3 from /opt/comp_ifort_2021
#               intel compiler from /opt/comp_ifort_2021
#               Only tested for AMANAN server (Centos-8)
# Author: Alejandro D. Peralta
# Date: June 2023
# ===================================================================================

# Considerations
LIBRARY_PATH="/home/alejandro/BLDLIB"    # Altere para o seu caminho / change your path
rm -rf ${LIBRARY_PATH}/ioapi-3.2         # Removing previous versions
BIN="Linux2_x86_64ifort"                 # Altere de acordo com seu sistema / change based on your system
export BIN=${BIN}
IOAPI_VERSION="20200828"                 # Recommended version I/O API for WRF-CMAQ
export HOME="${LIBRARY_PATH}/ioapi-3.2"
export CPLMODE='nocpl'

# Change to the library path
cd "$LIBRARY_PATH"

# Download I/O API
git clone https://github.com/cjcoats/ioapi-3.2
cd ioapi-3.2
git checkout -b "$IOAPI_VERSION"

# Create the $BIN directory
mkdir "$BIN"

#> Link netcdf libraries inside the $BIN directory
 # the netCDF installation requires a "-DIOAPI_NCF4=1" inside the Makeinclude.$BIN

find "$NETCDF/lib/" -name "*" -exec ln -sf {} "$BIN" \; 

# We copy Makefile.nocpl as Makefile inside both directories
cp ioapi/Makefile.nocpl ioapi/Makefile
cp m3tools/Makefile.nocpl m3tools/Makefile
cp Makefile.template Makefile

# Fixing flags
sed -i "139,146s/# //g" Makefile

cd ioapi
sed -i 's:OMPFLAGS  = -openmp:OMPFLAGS = #-qopenmp:g' Makeinclude.$BIN
sed -i 's:OMPLIBS   = -openmp:OMPLIBS =  #-qopenmp:g' Makeinclude.$BIN
sed -i '36,36i\ -DIOAPI_NCF4=1 \\' Makeinclude.$BIN        # adding a new line only for netCDF from /opt/comp_ifort_2021
echo Makeinclude.$BIN

cd ..
make configure

make all |& tee make.log

# We check if compilation was successful
if [ -f "${BIN}/libioapi.a" ] && [ -f "${BIN}/m3xtract" ]; then
    # Display success message if both files exist
    ls -lrt ${BIN}/libioapi.a
    ls -lrt ${BIN}/m3xtract
    echo "Files were created successfully!"
else
    # Display error message if any file is missing
    echo "File creation failed. Please check for errors."
fi

# Test if the I/O API program was successfuly installed
cd tests
./ioapitest.csh ${HOME} ${BIN}
