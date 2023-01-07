#!/bin/bash

#SBATCH --mail-type=ALL
#SBATCH --mem=120G
#SBATCH --output=/home/marcbo/dataprep/log/%j.out
#SBATCH --error=/home/marcbo/dataprep/log/%j.err
#SBATCH --exclude=tikgpu[01-09],artongpu01

#Job script to run astattendgru preprocessing
#Important that this job runs on a cpu node, to ensure that srcML works
#Hence the --exclude option.


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

# Activate the conda environment
#source /home/$USER/.bashrc
[[ -f /itet-stor/${USER}/net_scratch/conda/bin/conda ]] && eval "$(/itet-stor/${USER}/net_scratch/conda/bin/conda shell.bash hook)"
conda activate /itet-stor/${USER}/codesearch-attacks_itetnas04/envs/astgruenv
echo "Conda activated"

# Send some noteworthy information to the output log
echo "Running on node: $(hostname)"
echo "In directory:    $(pwd)"
echo "Starting on:     $(date)"
echo "SLURM_JOB_ID:    ${SLURM_JOB_ID}"


# Add the library variable of the srcml tool
#NOTE: change this to match the path of srcmls lib in mlmfc (Also change srcmlpath in 0_srcmlast.py!)
LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/itet-stor/marcbo/net_scratch/srcml/build/lib
export LD_LIBRARY_PATH

shareddir=/itet-stor/${USER}/codesearch-attacks_itetnas04
#For testing
testdir=/itet-stor/marcbo/net_scratch/mlmfc

model=$1
dataset=$2
attack=$3
confused=$4

DATAPATH=$shareddir/datasets/$dataset/$attack
#TEMPPATH=$shareddir/tempdir_$SLURM_JOB_ID
TEMPPATH=/itet-stor/marcbo/net_scratch/astgrudata/tempdir_$SLURM_JOB_ID
mkdir ${TEMPPATH}

MODELPATH=$shareddir/saved_models/$model/$dataset/$attack
#For testing
#DATAPATH=/itet-stor/marcbo/net_scratch/astgrudata/preprocess/default/
#/itet-stor/marcbo/net_scratch/astgrudata/preprocess/outdir/

# Run the preparation scripts
# 1. Build ASTs and remove commas from comments
python3 $shareddir/models_sourcecode/astattendgru/preprocess/0_srcmlast.py ${DATAPATH}/ ${TEMPPATH}/
# 2. Remove special characters
python3 $shareddir/models_sourcecode/astattendgru/preprocess/1_specialchars.py ${TEMPPATH}/
# 3. Build the tokenizers
python3 $shareddir/models_sourcecode/astattendgru/preprocess/2_tokenize.py ${TEMPPATH}/ ${MODELPATH}/
# 4. Generate input file to be used by the model (dataset.pkl)
python3 $shareddir/models_sourcecode/astattendgru/preprocess/3_final.py ${TEMPPATH}/ ${MODELPATH}/

cp ${MODELPATH}/smls.tok ${MODELPATH}/dats.tok
cp ${TEMPPATH}/coms.test ${MODELPATH}/coms.test

#rm -r ${TEMPPATH}

#Proceed with training now that preprocessing is done
sbatch --gres=gpu:1 $testdir/src/mlmfc_ui_main.sh $model $dataset $attack "training" "testing" $confused

# Send more noteworthy information to the output log
echo "Finished at:     $(date)"

# End the script with exit code 0
exit 0
