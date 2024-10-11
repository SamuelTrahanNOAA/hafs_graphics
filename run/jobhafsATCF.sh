#!/bin/sh
#
#  echo "Usage:     sh $0 2019082900 HFSA Dorian 05L COMhafs"
#
set -x

ymdh=${1:-2019082900}
stormModel=${2:-HFSA}
stormname=${3:-NATL}
stormid=${4:-00L}

COMhafs=${5:-${COMhafs:-/hafs/com/dir}}
HOMEgraph=${HOMEgraph:-$(pwd)/..}

modelLabels="['BEST','OFCL','${stormModel}','HWRF','HMON','AVNO']"
modelColors="['black','red','cyan','purple','green','blue']"
modelMarkers="['hr','.','.','.','.','.']"
modelMarkerSizes="[18,15,15,15,15,15]"
nset=""

STORMID=`echo ${stormid} | tr '[a-z]' '[A-Z]' `
stormid=`echo ${stormid} | tr '[A-Z]' '[a-z]' `
STORMNAME=`echo ${stormname} | tr '[a-z]' '[A-Z]' `
stormname=`echo ${stormname} | tr '[A-Z]' '[a-z]' `

stormnmid=`echo ${stormname}${stormid} | tr '[A-Z]' '[a-z]' `
STORMNMID=`echo ${stormnmid} | tr '[a-z]' '[A-Z]' `
STORMNM=${STORMNMID:0:-3}
stormnm=${STORMNM,,}
STID=${STORMNMID: -3}
stid=${STID,,}
STORMNUM=${STID:0:2}
BASIN1C=${STID: -1}
basin1c=${BASIN1C,,}
yyyy=`echo ${ymdh} | cut -c1-4`

atcfFile=${6:-${COMhafs}/${stormid}.${ymdh}.hafs.trak.atcfunix}

export HOMEgraph=${HOMEgraph:-/mnt/lfs5/HFIP/hwrfv3/${USER}/hafs_graphics}
export USHgraph=${USHgraph:-${HOMEgraph}/ush}
export WORKgraph=${WORKgraph:-${COMhafs}/../../../${ymdh}/${STORMID}/emc_graphics}
export COMgraph=${COMgraph:-${COMhafs}/emc_graphics}

source ${USHgraph}/graph_pre_job.sh.inc
export machine=${WHERE_AM_I:-wcoss_cray} # platforms: wcoss_cray, wcoss_dell_p3, hera, orion, jet

if [ ${machine} = jet ]; then
  export ADECKgraph=${ADECKgraph:-/mnt/lfs5/HFIP/hwrf-data/hwrf-input/abdeck/aid}
  export BDECKgraph=${BDECKgraph:-/mnt/lfs5/HFIP/hwrf-data/hwrf-input/abdeck/btk}
  export cartopyDataDir=${cartopyDataDir:-/mnt/lfs5/HFIP/hwrfv3/local/share/cartopy}
elif [ ${machine} = hera ]; then
  export ADECKgraph=${ADECKgraph:-/scratch1/NCEPDEV/hwrf/noscrub/input/abdeck/aid}
  export BDECKgraph=${BDECKgraph:-/scratch1/NCEPDEV/hwrf/noscrub/input/abdeck/btk}
  export cartopyDataDir=${cartopyDataDir:-/scratch1/NCEPDEV/hwrf/noscrub/local/share/cartopy}
elif [ ${machine} = orion ]; then
  export ADECKgraph=${ADECKgraph:-/work/noaa/hwrf/noscrub/input/abdeck/aid}
  export BDECKgraph=${BDECKgraph:-/work/noaa/hwrf/noscrub/input/abdeck/btk}
  export cartopyDataDir=${cartopyDataDir:-/work/noaa/hwrf/noscrub/local/share/cartopy}
elif [ ${machine} = wcoss2 ]; then
  export ADECKgraph=${ADECKgraph:-/lfs/h2/emc/hur/noscrub/input/abdeck/aid}
  export BDECKgraph=${BDECKgraph:-/lfs/h2/emc/hur/noscrub/input/abdeck/btk}
  export cartopyDataDir=${cartopyDataDir:-/lfs/h2/emc/hur/noscrub/local/share/cartopy}
else
  export ADECKgraph=${ADECKgraph:-/your/abdeck/aid}
  export BDECKgraph=${BDECKgraph:-/your/abdeck/btk}
  export cartopyDataDir=${cartopyDataDir:-/your/local/share/cartopy}
fi

if [ ${basin1c} = 'l' ]; then
  basin2c='al'
  BASIN2C='AL'
  BASIN='NATL'
elif [ ${basin1c} = 'e' ]; then
  basin2c='ep'
  BASIN2C='EP'
  BASIN='EPAC'
elif [ ${basin1c} = 'c' ]; then
  basin2c='cp'
  BASIN2C='CP'
  BASIN='CPAC'
elif [ ${basin1c} = 'w' ]; then
  basin2c='wp'
  BASIN2C='WP'
  BASIN='WPAC'
elif [ ${basin1c} = 's' ] || [ ${basin1c} = 'p'  ]; then
  basin2c='sh'
  BASIN2C='SH'
  BASIN='SH'
elif [ ${basin1c} = 'a' ] || [ ${basin1c} = 'b'  ]; then
  basin2c='io'
  BASIN2C='IO'
  BASIN='NIO'
else
  echo "WRONG BASIN DESIGNATION basin1c=${basin1c}"
  echo 'SCRIPT WILL EXIT'
  exit 1
fi

work_dir="${WORKgraph}"
archbase="${COMgraph}/figures"
archdir="${archbase}/RT${yyyy}_${BASIN}/${STORMNM}${STID}/${STORMNM}${STID}.${ymdh}"

mkdir -p ${work_dir}
cd ${work_dir}

if [ -f ${atcfFile} ]; then
  atcfFile=${atcfFile}
elif [ -f ${atcfFile%.all} ]; then
  atcfFile=${atcfFile%.all}
else
  echo "File ${atcfFile} does not exist"
  echo 'SCRIPT WILL EXIT'
  exit 1
fi

# make the track and intensity plots
sh ${HOMEgraph}/ush/python/ATCF/plotATCF.sh ${STORMNM} ${STID} ${ymdh} ${stormModel} ${COMhafs} ${ADECKgraph} ${BDECKgraph} ${HOMEgraph}/ush/python ${WORKgraph} ${archdir} ${modelLabels} ${modelColors} ${modelMarkers} ${modelMarkerSizes} ${nset}

date

echo 'job done'
