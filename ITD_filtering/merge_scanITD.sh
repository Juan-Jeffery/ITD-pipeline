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

conda activate GenomonITD
cd ${cwd}

Normal_file_ID=${1}  # [1] Normal File ID
Tumor_file_ID=${2}   # [2] Tumor File ID
Norma_sample_ID=${3}  # [3] Normal Sample ID
Tumor_sample_ID=${4}   # [4] Tumor Sample ID

# Create an array of file and case IDs
IDs=("${Normal_file_ID},${Norma_sample_ID}" "${Tumor_file_ID},${Tumor_sample_ID}")

############### Main ###############
for entry in "${IDs[@]}"; 
do
  IFS=',' read -r file_ID sample_ID <<< "$entry"
  cd ${cwd}
  
  if [[ -f "scanITD/${sample_ID}.ITD.vcf" ]]; then
    tail -n +16 tmp/scanITD/${file_ID}/${sample_ID}.itd.vcf >> scanITD/${sample_ID}.ITD.vcf
    echo -e "Merge ${file_ID} to ${sample_ID}.ITD.output.vcf" >> ${cwd}/tmp/scanITD.out
  else
    mv tmp/scanITD/${file_ID}/${sample_ID}.itd.vcf scanITD/${sample_ID}.ITD.vcf
  fi
  # Clean up
  #rm -r tmp/genomon_ITD/${file_ID}/

  ############### .out File ###############
  # Create the .out file if it does not exist
  [[ ! -f ${cwd}/tmp/scanITD.out ]] && touch ${cwd}/tmp/scanITD.out
  echo -e "${file_ID}\t${sample_ID}" >> ${cwd}/tmp/scanITD.out
done
