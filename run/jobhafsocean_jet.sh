#!/bin/sh
#BATCH --job-name=jobhafsocean
#SBATCH --account=hwrfv3
##SBATCH --qos=batch
#SBATCH --qos=debug
#SBATCH --nodes=1
#SBATCH --tasks-per-node=20
#SBATCH --cpus-per-task=1
##SBATCH -t 01:00:00
#SBATCH -t 00:30:00
#SBATCH --partition=xjet
##SBATCH --partition=sjet
#SBATCH -o jobhafsocean.log.%j
#SBATCH -e jobhafsocean.log.%j
##SBATCH --mem=8000
##SBATCH --exclusive
#SBATCH -D.

set -x

date

YMDH=${1:-${YMDH:-2023090706}}
STORM=${STORM:-LEE}
STORMID=${STORMID:-13L}
stormModel=${stormModel:-HFSA}
TRACKON=${TRACKON:-yes}
fhhhAll=$(seq -f "f%03g" 0 3 126)

#HOMEgraph=/your/graph/home/dir
#WORKgraph=/your/graph/work/dir # if not specified, a default location relative to COMhafs will be used
#COMgraph=/your/graph/com/dir   # if not specified, a default location relative to COMhafs will be used
#COMhafs=/your/hafs/com/dir

export HOMEgraph=${HOMEgraph:-/mnt/lfs4/HFIP/hwrfv3/${USER}/hafs_graphics}
export USHgraph=${USHgraph:-${HOMEgraph}/ush}
export DRIVERDOMAIN=${USHgraph}/driverDomain.sh
export DRIVEROCEAN=${USHgraph}/driverOcean.sh

export COMhafs=${COMhafs:-/hafs/com/${YMDH}/${STORMID}}
export WORKgraph=${WORKgraph:-${COMhafs}/../../../${YMDH}/${STORMID}/emc_graphics}
export COMgraph=${COMgraph:-${COMhafs}/emc_graphics}

source ${USHgraph}/graph_pre_job.sh.inc
export machine=${WHERE_AM_I:-jet} # platforms: wcoss2, hera, orion, jet
if [ ${machine} = jet ]; then
  export cartopyDataDir=${cartopyDataDir:-/mnt/lfs4/HFIP/hwrfv3/local/share/cartopy}
elif [ ${machine} = hera ]; then
  export cartopyDataDir=${cartopyDataDir:-/scratch1/NCEPDEV/hwrf/noscrub/local/share/cartopy}
elif [ ${machine} = orion ]; then
  export cartopyDataDir=${cartopyDataDir:-/work/noaa/hwrf/noscrub/local/share/cartopy}
elif [ ${machine} = wcoss2 ]; then
  export cartopyDataDir=${cartopyDataDir:-/lfs/h2/emc/hur/noscrub/local/share/cartopy}
else
  export cartopyDataDir=${cartopyDataDir:-/your/local/share/cartopy}
fi

export TOTAL_TASKS=${TOTAL_TASKS:-${SLURM_NTASKS:-480}}
export NCTSK=${NCTSK:-10}
export NCNODE=${NCNODE:-10}
export OMP_NUM_THREADS=${OMP_NUM_THREADS:-1}

source ${USHgraph}/graph_runcmd.sh.inc

mkdir -p ${WORKgraph}
cd ${WORKgraph}

#Generate the cmdfile
cmdfile="cmdfile_ocean.$STORM$STORMID.$YMDH"
rm -f $cmdfile
touch $cmdfile

#==============================================================================
# For the ocean figures
#==============================================================================

for fhhh in ${fhhhAll}; do

figScriptAll=( \
  plot_sst.py \
  plot_sss.py \
  plot_mld.py \
  plot_ohc.py \
  plot_z20.py \
  plot_z26.py \
  plot_storm_sst.py \
  plot_storm_sss.py \
  plot_storm_mld.py \
  plot_storm_ohc.py \
  plot_storm_z20.py \
  plot_storm_z26.py \
  plot_storm_tempz40m.py \
  plot_storm_tempz70m.py \
  plot_storm_tempz100m.py \
  plot_storm_wvelz40m.py \
  plot_storm_wvelz70m.py \
  plot_storm_wvelz100m.py \
  plot_storm_forec_track_tran_temp.py \
  plot_storm_lat_tran_temp.py \
  )

nscripts=${#figScriptAll[*]}

for((i=0;i<${nscripts};i++));
do

  echo ${figScriptAll[$i]}
# echo "${APRUNS} ${DRIVEROCEAN} $stormModel $STORM $STORMID $YMDH $trackOn ${figScriptAll[$i]} > ${WORKgraph}/$STORM$STORMID.$YMDH.${figScriptAll[$i]%.*}.log 2>&1 ${BACKGROUND}" >> $cmdfile
  echo "time ${DRIVEROCEAN} $stormModel $STORM $STORMID $YMDH $trackOn ${figScriptAll[$i]} > ${WORKgraph}/$STORM$STORMID.$YMDH.${figScriptAll[$i]%.*}.log 2>&1" >> $cmdfile

done

done

#==============================================================================

chmod u+x ./$cmdfile
${APRUNC} ${MPISERIAL} -m ./$cmdfile

date

echo 'job done'
