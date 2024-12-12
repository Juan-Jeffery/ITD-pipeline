#!/bin/sh

cancer=$1
start_number=$2
end_number=$3


for number in $(seq $start_number $end_number); do
    echo "Processing sample ${number} for cancer type ${cancer}..."
    
    # run ITD_pipeline_v3_1.sh
    bash ~/ITD-pipeline/ITD_pipeline_v3_1.sh -v 1 \
        -s ~/TCGA_sliced/${cancer}_samplesheet/${cancer}_sample_${number}.tsv \
        -i ~/TCGA_sliced/${cancer} \
        -o ~/TCGA_sliced/result/$cancer \
        -t ~/TCGA_sliced/result/$cancer > ~/log_dir/${cancer}.${number}.log

done