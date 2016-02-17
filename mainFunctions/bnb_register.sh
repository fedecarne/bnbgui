#!/bin/bash
# specify BASH shell
#$ -S /bin/bash
#$ -t 1-"224"
# pass environment variables to job, e.g. LD_LIBRARY_PATH
#$ -v LD_LIBRARY_PATH
# run job in the current working directory where qsub is executed from
#$ -cwd
#  specify that the job requires 16GB of memory
#$ -l m_mem_free="16"G

# run commands and application
pwd
date
./run_bnb_register.sh /opt/hpc/pkg/MATLAB/R2013a "data/160110_fm082" "t1_00" ".tif" "1" "data/160110_fm082/reg_med.tif" "data_out/out$SGE_TASK_ID" $SGE_TASK_ID
date
