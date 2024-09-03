#!/bin/sh

#!/bin/sh

#SBATCH -A MST109178       # Account name/project number
#SBATCH -J genomonITD         # Job name
#SBATCH -p ngs186G           # Partition Name ���PPBS�̭��� -q Queue name
#SBATCH -c 28           # �ϥΪ�core�� �аѦ�Queue�귽�]�w
#SBATCH --mem=186g           # �ϥΪ��O����q �аѦ�Queue�귽�]�w
#SBATCH --mail-user=hiiluann99.dump@gmail.com    # email
#SBATCH --mail-type=ALL              # ���w�e�Xemail�ɾ� �i��NONE, BEGIN, END, FAIL, REQUEUE, ALL


############### Preprocessing ############### 
source /home/data/data_Jeffery/ITD-detection/script/ITD_pipeline/parameters.config

conda activate Pindel
cd ${cwd}

Normal_file_ID=${1}  # [1] Normal File ID
Tumor_file_ID=${2}   # [2] Tumor File ID
case_ID=${3}         # [3] Case ID

config_file=config/${Tumor_file_ID}_${Normal_file_ID}_bam_config.txt
sample_directory=${cwd}/tmp/pindel/${Tumor_file_ID}_${Normal_file_ID}

############### Main ###############
if [[ -f "${cwd}/pindel/${case_ID}.ITD.filter.output" ]]; then
  # Append starting from line 15
  tail -n +17 ${sample_directory}/indel.filter.output >> ${cwd}/pindel/${case_ID}.ITD.filter.output
  echo -e "Merge ${Tumor_file_ID} and ${Normal_file_ID} to ${case_ID}.ITD.filter.output" >> ${cwd}/tmp/pindel.out
else
  mv ${sample_directory}/indel.filter.output ${cwd}/pindel/${case_ID}.ITD.filter.output
fi

############### .out File ###############
# Create the .out file if it does not exist
[[ ! -f ${cwd}/tmp/genomonITD.out ]] && touch ${cwd}/tmp/genomonITD.out
echo -e "${file_ID}\t${sample_ID} merge down" >> ${cwd}/tmp/genomonITD.out

