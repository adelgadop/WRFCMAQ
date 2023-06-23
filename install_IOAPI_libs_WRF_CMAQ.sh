#!/bin/bash

# ============================= Install I/O API 3.2 =================================
# Requirements: netCDF-C 4.7.4 & netCDF-fortran 4.5.3 from /opt/comp_ifort_2021
#               intel compiler from /opt/comp_ifort_2021
#               Only tested for AMANAN server (Centos-8)
# Author: Alejandro D. Peralta
# Date: June 2023
# ===================================================================================

# Considerations
LIBRARY_PATH="${HOME}/YOUR_FOLDER"                  # Make your directory or replace 
                                                    # YOUR_FOLDER with a folder created 
                                                    # (e.g., LIBRARIES if your path is /home/alejandro/LIBRARIES)
rm -rf ${LIBRARY_PATH}/ioapi-3.2                    # Removing previous versions
export BIN="Linux2_x86_64ifort"                     # Altere de acordo com seu sistema / change based on your system
IOAPI_VERSION="20200828"                            # Recommended version I/O API for WRF-CMAQ
export HOME_IO="${LIBRARY_PATH}/ioapi-3.2"          # Path in which your I/O API will be installed
export CPLMODE='nocpl'                              # CMAS CENTER recommended this

# Change to the library path
cd "$LIBRARY_PATH"

# Download I/O API
git clone https://github.com/cjcoats/ioapi-3.2
cd ioapi-3.2
git checkout -b "$IOAPI_VERSION"                    # This is suggested by CMAS CENTER

# Create the $BIN directory
mkdir "$BIN"

#> Link netcdf libraries inside the $BIN directory
 # The netCDF installation requires a "-DIOAPI_NCF4=1" 
 # inside the Makeinclude.$BIN
 # We need this flag in case the netCDF installed didn't consider
 # flags as during its installation.
 # For example if you installed netCDF like this:
 #
 # tar -zxvf netcdf-4.1.3.tar.gz     
 # cd netcdf-4.1.3
 # ./configure --prefix=$DIR/netcdf --disable-dap --disable-netcdf-4 --disable-shared
 # make
 # make install
 # cd .. # To go back to LIBRARIES
 #
 # You can write on the terminal 'nc-config --libs' and 'nf-config --flibs' to see libraries of netCDF
 # 'nc-config --version' and 'nf-config --version' tell you the netCDF version for C and Fortran
 #
 # Since that, we won't require use the flag "-DIOAPI_NCF4=1" in Makeinclude.$BIN. 
 # For more details see the suggestions in 
 # https://www.cmascenter.org/ioapi/documentation/all_versions/html/AVAIL.html#ncf4 

find "$NETCDF/lib/" -name "*" -exec ln -sf {} "$BIN" \;   # We link netCDF libraries inside $BIN folder

# We copy Makefile.nocpl as Makefile inside both directories (ioapi & m3tools)
cp ioapi/Makefile.nocpl ioapi/Makefile
cp m3tools/Makefile.nocpl m3tools/Makefile
cp Makefile.template Makefile

# Fixing flags inside ${HOME_IO}/Makefile
sed -i "139,146s/# //g" Makefile

cd ioapi
sed -i 's:OMPFLAGS  = -openmp:OMPFLAGS = #-qopenmp:g' Makeinclude.$BIN
sed -i 's:OMPLIBS   = -openmp:OMPLIBS =  #-qopenmp:g' Makeinclude.$BIN
sed -i '36,36i\ -DIOAPI_NCF4=1 \\' Makeinclude.$BIN        # adding a new line only for netCDF from /opt/comp_ifort_2021
                                                           # This is true if the netCDF installed didn't consider the 
                                                           # flags as --disable-netcdf-4 --disable-dap
echo Makeinclude.$BIN

cd ..
make configure

make all |& tee make.log                                   # This will install the I/O API

# We check if compilation was successfully installed
if [ -f "${BIN}/libioapi.a" ] && [ -f "${BIN}/m3xtract" ]; then
    # Display success message if both files exist
    ls -lrt ${BIN}/libioapi.a
    ls -lrt ${BIN}/m3xtract
    echo "Files were created successfully!"
else
    # Display error message if any file is missing
    echo "File creation failed. Please check for errors."
fi

# We do another test to ensure that the I/O API program was successfuly installed
cd tests
./ioapitest.csh ${HOME_IO} ${BIN}
