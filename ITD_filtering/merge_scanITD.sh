#!/bin/sh

#!/bin/sh

#SBATCH -A MST109178       # Account name/project number
#SBATCH -J genomonITD         # Job name
#SBATCH -p ngs186G           # Partition Name 等同PBS裡面的 -q Queue name
#SBATCH -c 28           # 使用的core數 請參考Queue資源設定
#SBATCH --mem=186g           # 使用的記憶體量 請參考Queue資源設定
#SBATCH --mail-user=hiiluann99.dump@gmail.com    # email
#SBATCH --mail-type=ALL              # 指定送出email時機 可為NONE, BEGIN, END, FAIL, REQUEUE, ALL


############### Preprocessing ############### 
source /home/data/data_Jeffery/ITD-detection/script/ITD_pipeline/parameters.config

Normal_file_ID=${1}  # [1] Normal File ID
Tumor_file_ID=${2}   # [2] Tumor File ID
Norma_sample_ID=${3}  # [3] Normal Sample ID
Tumor_sample_ID=${4}   # [4] Tumor Sample ID

# Create an array of file and case IDs
IDs=("${Normal_file_ID},${Norma_sample_ID}" "${Tumor_file_ID},${Tumor_sample_ID}")
cd ${cwd}
############### Main ###############
for entry in "${IDs[@]}"; 
do
  IFS=',' read -r file_ID sample_ID <<< "$entry"
  cd ${cwd}
  
  if [[ -f "${cwd}/scanITD/${sample_ID}.itd.filter.de.tsv" ]]; then
    tail -n +16 ${cwd}/tmp/scanITD/${file_ID}/itd.filter.de.tsv >> ${cwd}/scanITD/${sample_ID}.itd.filter.de.tsv
    #echo -e "Merge ${file_ID} to ${sample_ID}.ITD.output.vcf" >> ${cwd}/tmp/scanITD.out
  else
    mv ${cwd}/tmp/scanITD/${file_ID}/itd.filter.de.tsv ${cwd}/scanITD/${sample_ID}.itd.filter.de.tsv
  fi
  # Clean up
  #rm -r tmp/scanITD/${file_ID}/

  ############### .out File ###############
  # Create the .out file if it does not exist
  [[ ! -f ${cwd}/tmp/scanITD.out ]] && touch ${cwd}/tmp/scanITD.out
  echo -e "${file_ID}\t${sample_ID}" >> ${cwd}/tmp/scanITD.out
done
