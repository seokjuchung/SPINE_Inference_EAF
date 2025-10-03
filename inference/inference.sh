#!/bin/bash
CFG=/exp/sbnd/app/users/sc5303/SPINE/spine-prod/config/sbnd/sbnd_full_chain_250901.cfg
LOG_DIR=/exp/sbnd/data/users/sc5303/SPINE/inference_test/log
FNAME=/exp/sbnd/data/users/sc5303/SPINE/2025_workshop/data/larcv.root

# PARSL_DIR=/lus/eagle/projects/neutrinoGPU/bearc/sbnd_parsl

workdir=/exp/sbnd/data/users/sc5303/SPINE/inference_test/work
#cores_per_worker=8
container=/exp/sbnd/app/users/sc5303/SPINE/larcv2_ub2204-cuda121-torch251-custom.sif

mkdir -p $workdir
cd $workdir
echo "Current directory: "
pwd
echo "Current files: "
ls

# echo "Load singularity"
# module use /soft/spack/gcc/0.6.1/install/modulefiles/Core
# module load apptainer
# set -e

# echo "Find GPUs"
# nvidia-smi
# module use /soft/modulefiles 
# module load conda
# conda activate sbn
# BESTCUDAS=$(python3 -c 'import gpustat;import numpy as np;stats=gpustat.GPUStatCollection.new_query();memory=np.array([gpu.memory_used for gpu in stats.gpus]);indices=np.argsort(memory)[:4];print(",".join(map(str, indices)))')
# export CUDA_VISIBLE_DEVICES=$BESTCUDAS
# echo "CUDA_VISIBLE_DEVICES=$CUDA_VISIBLE_DEVICES"
# export OPENBLAS_NUM_THREADS=1
# conda deactivate


# these lines replace hard-coded path in SPINE cfg files from github
# put the changes in a temporary copy
TMP_CFG=$(mktemp)
cp $CFG $TMP_CFG
cp /exp/sbnd/app/users/sc5303/SPINE/spine-prod/config/sbnd/flashmatch_250408.cfg /tmp/

echo "Config: $TMP_CFG"

# singularity run -B /lus/eagle/ -B /lus/grand/ --nv $container <<EOL

source /home/sc5303/.bashrc
conda activate apptainer_env

apptainer run --bind /exp/ --nv $container <<EOL
    unset LD_PRELOAD
    echo "Running in: "
    pwd

    # #Find best GPU
    # if [ -z "$CUDA_VISIBLE_DEVICES" ]; then
    #     export CUDA_VISIBLE_DEVICES=0
    #     echo "CUDA_VISIBLE_DEVICES not set, using 0,1,2,3"
    # fi
    # echo GPU Selected
    # echo $CUDA_VISIBLE_DEVICES
    
    export CUDA_VISIBLE_DEVICES=0
    echo "Begin training"
    source /exp/sbnd/app/users/sc5303/SPINE/OpT0Finder/configure.sh
    python /exp/sbnd/app/users/sc5303/SPINE/spine/bin/run.py -c $TMP_CFG -S $FNAME
    echo "Training complete"

EOL
conda deactivate