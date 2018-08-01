#!/bin/bash

#
# Do _not_ submit this to the batch system! It runs on the head node and controls submission
# of work to the batch system. It disconnects from command line and output goes to the log
# directory.
#

WORK_DIR=/home/thomas.e/olga
RESULTS_DIR=${WORK_DIR}/pdx-genome/test
CWL_DIR=${WORK_DIR}/pdx-genome/src
LOG_DIR=${WORK_DIR}/pdx-genome/logs
VENV_DIR=${WORK_DIR}/pdx-genome/toil-env
#WEHI_PIPELINE=${WORK_DIR}/wehi-pipeline/src

cd $RESULTS_DIR

module load python
. ${VENV_DIR}/bin/activate

DRMAA_LIBRARY_PATH=/stornext/System/data/apps/pbs-drmaa/pbs-drmaa-1.0.19/lib/libdrmaa.so
#export PYTHONPATH=${WEHI_PIPELINE}

fn=`date +%Y_%m_%d_%H_%M`

cwlwehi \
    --batchSystem drmaa \
    --jobQueue submit \
    --jobNamePrefix pdx \
    --jobStore ${fn}.wf \
    ${CWL_DIR}/pdx-scatter.cwl ${CWL_DIR}/pdx-inp.yml
    # &>> ${LOG_DIR}/${fn}.toil.log \
# & disown
