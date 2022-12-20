#!/bin/bash

#SBATCH --mail-type=ALL
#SBATCH --gres=gpu:1
#SBATCH --mem=64G
#SBATCH --cpus-per-task=4
#SBATCH --output=/home/marcbo/astgru/log/%j.out    
#SBATCH --error=/home/marcbo/astgru/log/%j.err

# Exit on errors
set -o errexit

# Set a directory for temporary files unique to the job with automatic removal at job termination
TMPDIR=$(mktemp -d)
if [[ ! -d ${TMPDIR} ]]; then
	    echo 'Failed to create temp directory' >&2
	        exit 1
fi
trap "exit 1" HUP INT TERM
trap 'rm -rf "${TMPDIR}"' EXIT
export TMPDIR

# Change the current directory to the location where you want to store temporary files, exit if changing didn't succeed.
# Adapt this to your personal preference
cd "${TMPDIR}" || exit 1

# Setup scratch directory
DATA=/itet-stor/marcbo/net_scratch/astgrudata

# Setup output directory (Assume that /models/, /histories/, /predictions/ exist in outdir)
OUTDIR=/itet-stor/marcbo/net_scratch/astgrudata/outdir

# Activate the conda environment
#source /home/marcbo/.bashrc
[[ -f /itet-stor/marcbo/net_scratch/conda/bin/conda ]] && eval "$(/itet-stor/marcbo/net_scratch/conda/bin/conda shell.bash hook)"
conda activate astgru
echo "Conda activated"



# Send some noteworthy information to the output log
echo "Running on node: $(hostname)"
echo "In directory:    $(pwd)"
echo "Starting on:     $(date)"
echo "SLURM_JOB_ID:    ${SLURM_JOB_ID}"


# Download and untar the training data
#wget -P ${DATA} https://icse2018.s3.us-east-2.amazonaws.com/funcom.tar.gz
#tar -xvzf ${DATA}/funcom.tar.gz -C ${DATA}


INDIR=${DATA}/funcom/data/standard


# Train the ast-attend-gru model
time python3 /home/marcbo/astgru/funcom/train.py --model-type=ast-attendgru --data=${INDIR} --outdir=${OUTDIR} --epochs=3

# Send more noteworthy information to the output log
echo "Finished at:     $(date)"

# End the script with exit code 0
exit 0
