#!/bin/bash

#SBATCH --mail-type=ALL
#SBATCH --gres=gpu:1
#SBATCH --mem=64G
#SBATCH --cpus-per-task=4
#SBATCH --output=/home/marcbo/astgru/log/%j.out
#SBATCH --error=/home/marcbo/astgru/log/%j.err

# Job script for predicting and evaluating BLEU scores of the ast-attend-gru model on the test dataset

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
DATA=/itet-stor/marcbo/net_scratch/astgrudata/funcom/data/standard

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

# We predict on the model of the 3rd epoch
MODEL=${OUTDIR}/models/ast-attendgru_E03_1667860826.h5


time python3 /home/marcbo/astgru/funcom/predict.py ${MODEL} --data=${DATA} --outdir=${OUTDIR} --gpu=0

# Output predictions will be written to a file in ${OUTDIR}/predictions

# Calculate the BLEU scores
PREDICTION=${OUTDIR}/predictions/predict-ast-attendgru_E03_1667860826.txt


time python3 /home/marcbo/astgru/funcom/bleu.py ${PREDICTION} --data=${DATA}/output --outdir=${OUTDIR}

# Send more noteworthy information to the output log
echo "Finished at:     $(date)"

# End the script with exit code 0
exit 0
