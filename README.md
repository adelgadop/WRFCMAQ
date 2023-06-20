# WRF-CMAQ coupled instalation
This repository focuses on the installation of the Weather Research and Forecasting (WRF) coupled with the Community Multiscale Air Quality (CMAQ) model. The WRF-CMAQ model (Wong et al., 2012) facilitates the exchange of information between CMAQ and WRF, allowing the examination of how chemistry impacts weather phenomena.

Additionally, this repository provides Bash scripts to install the I/O API v3.2 library, a crucial dependency for the WRF-CMAQ model. The I/O API installation script is specifically tailored for the AMANAN server, utilizing the Intel compiler. The other script installs the WRF-CMAQ model using libraries from the I/O API 3.2.

We encourage that IT of the IAG-USP can use these scripts in order to facilitate the installation of the I/O API v3.2 and the WRF-CMAQ coupled model.

We followed the installation tutorials from the US EPA GitHub:

- (CMAQ build library intel)[https://github.com/USEPA/CMAQ/blob/main/DOCS/Users_Guide/Tutorials/CMAQ_UG_tutorial_build_library_intel.md]
- (Tutorial WRF-CMAQ Benchmark)[https://github.com/USEPA/CMAQ/blob/main/DOCS/Users_Guide/Tutorials/CMAQ_UG_tutorial_WRF-CMAQ_Benchmark.md]

# Acknowledgment
Thank you to the US EPA for creating WRF-CMAQ and to the CMAS Center (https://cmascenter.org/) for developing the I/O API v3.2 program.
