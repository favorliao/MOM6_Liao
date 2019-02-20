#!/bin/bash
module purge
module load intel-mpi/intel/2018.3/64
module load intel/18.0/64/18.0.3.222
module load hdf5/intel-16.0/intel-mpi/1.8.16
module load netcdf/intel-16.0/hdf5-1.8.16/intel-mpi/4.4.0

EXENAME="mom1902"
#EXENAME="geoclime1203temp"
#liao
#double check the code directory, should use geoclime codes
BASEDIR="/tigress/GEOCLIM/LRGROUP/Liao/MOM6-Liao"
#
MKF_TEMPLATE="$BASEDIR/tigercpu-intel_optimized.mk"
 
echo "Compile FMS"
mkdir -p build/intel/shared/repro/
(cd build/intel/shared/repro/; rm -f path_names; \
"$BASEDIR/src/mkmf/bin/list_paths" "$BASEDIR/src/FMS"; \
"$BASEDIR/src/mkmf/bin/mkmf" -t $MKF_TEMPLATE -p libfms.a -c "-Duse_libMPI -Duse_netCDF -DSPMD -DMAXFIELDMETHODS_=400" path_names)

echo "Make NETCDF "
#(cd build/intel/shared/repro/; source ../../env; make clean; make NETCDF=3 REPRO=1 libfms.a -j)
(cd build/intel/shared/repro/; source ../../env; make clean; make NETCDF=3 libfms.a -j)


echo "List Model Code paths"
BUILDDIR="build/intel/$EXENAME/repro/"
mkdir -p $BUILDDIR
(cd $BUILDDIR; rm -f path_names; \
"$BASEDIR/src/mkmf/bin/list_paths" -v -v -v ./ $BASEDIR/src/MOM6/config_src/{dynamic,coupled_driver} $BASEDIR/src/MOM6/src/{*,*/*}/ $BASEDIR/src/{atmos_null,coupler,land_null,ice_ocean_extras,icebergs,SIS2,FMS/coupler,FMS/include}/ $BASEDIR/src/ocean_shared/{generic_tracers,mocsy/src}) 

echo "Compile Model and make executable file"
(cd $BUILDDIR; \
"$BASEDIR/src/mkmf/bin/mkmf" -t $MKF_TEMPLATE -o '-I../../shared/repro' -p $EXENAME -l '-L../../shared/repro -lfms' -c '-Duse_libMPI -Duse_netCDF -DSPMD -Duse_AM3_physics -D_USE_LEGACY_LAND_ -D_USE_MOM6_DIAG -D_USE_GENERIC_TRACER -DUSE_PRECISION=2' path_names )

(cd $BUILDDIR; source ../../env;make clean; make NETCDF=3 $EXENAME -j)




#new
#mkdir -p build/intel/ice_ocean_SIS2/repro/
#(cd build/intel/ice_ocean_SIS2/repro/; rm -f path_names; \
#../../../../src/mkmf/bin/list_paths -l ./ ../../../../src/MOM6/config_src/{dynamic,coupled_driver} ../../../../src/MOM6/src/{*,*/*}/ ../../../../src/{atmos_null,coupler,land_null,ice_ocean_extras,icebergs,SIS2,FMS/coupler,FMS/include}/)
#(cd build/intel/ice_ocean_SIS2/repro/; \
#../../../../src/mkmf/bin/mkmf -t ../../../../src/mkmf/templates/ncrc-intel.mk -o '-I../../shared/repro' -p MOM6 -l '-L../../shared/repro -lfms' -c '-Duse_libMPI -Duse_netCDF -DSPMD -Duse_AM3_physics -D_USE_LEGACY_LAND_' path_names )
#(cd build/intel/ice_ocean_SIS2/repro/; source ../../env; make NETCDF=3 REPRO=1 MOM6 -j)

