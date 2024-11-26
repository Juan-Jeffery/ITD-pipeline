#!/bin/sh

set -euo pipefail

# Global Variable
BASHRC=~/.bashrc

shopt -s expand_aliases
# source $BASHRC
source $ITD_PIPELINE_CONFIG
source $BANNER_SH
source $TOOLS


eval "$(conda shell.bash hook)"
# conda activate $PINDEL_ENV

VERSION=0.1.1
VERBOSE=0
SAMPLE_ID=SAMPLE
OUT_DIR=./

usage(){
>&2 cat << EOF
Usage: $0
  [ -V | --version ]
  [ -v | --verbose args; default=0 ]
  [ -h | --help ]
  [ -S | --sample_id args; default=SAMPLE ]
  [ -t | --tumor args ]
  [ -n | --normal args ]
  [ -o | --out_dir args; default=./ ]
EOF
}

args=$(getopt -a -o Vv:hs:t:n:o: --long version,verbose:,help,sample_id:,tumor:,normal:,out_dir: -- "$@")

if [[ $? -gt 0 ]]; then
  usage
  exit 1
fi

eval set -- ${args}
while :
do
  case $1 in
    -V | --version)        echo $VERSION ; exit 1 ;;
    -v | --verbose)        VERBOSE=$2 ; shift 2 ;;
    -h | --help)           usage ; exit 1 ;;
    -s | --sample_id)      SAMPLE_ID=$2 ; shift 2;;
    -t | --tumor)          TUMOR_SAMPLE=$2 ; shift 2;;
    -n | --normal)         NORMAL_SAMPLE=$2 ; shift 2;;
    -o | --out_dir)        OUT_DIR=$2   ; shift 2 ;;

    # -- means the end of the arguments; drop this, and break out of the while loop
    --) shift; break ;;
    *) >&2 echo Unsupported option: $1
       usage 
       exit 1;;
  esac
done

log 1 "Version          : ${VERSION}"
log 1 "Sample Case ID   : ${SAMPLE_ID}"
log 1 "Tumor Sample     : ${TUMOR_SAMPLE}"
log 1 "Normal Sample    : ${NORMAL_SAMPLE}"
log 1 "Output Directory : ${OUT_DIR}"
log 1 ""

# sliced BAM file location
TUMOR_ID=$(basename "$TUMOR_SAMPLE" .bam)
NORMAL_ID=$(basename "$NORMAL_SAMPLE" .bam)

TUMOR_DIR=${OUT_DIR}/${TUMOR_ID}
NORMAL_DIR=${OUT_DIR}/${NORMAL_ID}

check_and_create_dir ${OUT_DIR} ${TUMOR_ID}
log 1 ""

check_and_create_dir ${OUT_DIR} ${NORMAL_ID}
log 1 ""


SAMPLE_DIR=${OUT_DIR}/${TUMOR_ID}_${NORMAL_ID}
check_and_create_dir ${OUT_DIR} ${TUMOR_ID}_${NORMAL_ID}
log 1 ""

# FIXME: [ ] add a writing lock for  dir, T_dir and N_dir:
# |-> [ ] if exist: wait writing lock removed
# |-> [ ] else: create a writing lock and write file

# step 1: BAM slicing

bash ${PIPELINE_DIR}/utility/slice_bam.sh -v $VERBOSE \
  -f ${TUMOR_SAMPLE} \
  -o $TUMOR_DIR \
  -s $PINDEL_SLICE_CHROM


bash ${PIPELINE_DIR}/utility/slice_bam.sh -v $VERBOSE \
  -f ${NORMAL_SAMPLE} \
  -o $NORMAL_DIR \
  -s $PINDEL_SLICE_CHROM

# FIXME: [ ] remove writign lock after complete
# |-> [ ] remove writing lock if self create it
# |-> [ ] continue code after writing lock is removed 

# step 2: create Pindel Config File

# conda activate $PINDEL_ENV


CONFIG_DIR=${SAMPLE_DIR}/config
check_and_create_dir ${SAMPLE_DIR} config



echo "Partitions: ${partition_array[@]}"

for partition in ${partition_array[@]}; do
  # make config
  log 1 "running pindel on $SAMPLE_ID:\t$partition"

  bash ${PIPELINE_DIR}/utility/make_config.sh -v $VERBOSE \
    -i $OUT_DIR \
    -o $CONFIG_DIR \
    -S $SAMPLE_ID \
    -t $TUMOR_ID \
    -n $NORMAL_ID \
    -p $partition

  CONFIG_FILE=$CONFIG_DIR/${TUMOR_ID}_${NORMAL_ID}.${partition}.bam_config.txt
  check_file_existence "pindel configuration" $CONFIG_FILE

  check_and_create_dir $SAMPLE_DIR $partition

  # pindel calling
  sbatch ${PIPELINE_DIR}/scripts/run_pindel.sh -v $VERBOSE \
    -i $SAMPLE_DIR \
    -c $CONFIG_FILE \
    -s $SAMPLE_ID \
    -o $SAMPLE_DIR/$partition / 
  
done


