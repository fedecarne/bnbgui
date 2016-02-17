#!/bin/bash
# specify BASH shell
#$ -S /bin/bash
#$ -t 1-3
# pass environment variables to job, e.g. LD_LIBRARY_PATH
#$ -v LD_LIBRARY_PATH
# run job in the current working directory where qsub is executed from
#$ -cwd
#  specify that the job requires 16GB of memory
#$ -l m_mem_free=16G

# run commands and application
pwd
date
./run_bnb_extract.sh /opt/hpc/pkg/MATLAB/R2013a "data/lad" "t1_" ".tif" "rois.mat" "t1_reg.mat" "roi/r$SGE_TASK_ID.mat" $SGE_TASK_ID
date
