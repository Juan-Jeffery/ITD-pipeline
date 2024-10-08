#! /bin/bash

configfile=./config.env
if [ ! -f $configfile ]; then
  echo "$configfile does not exists."
  exit 1
fi
source $configfile

refGene=db/hg38.refGene.gtf
knownGene=db/hg38.knownGene.gtf
ensGene=db/hg38.ensGene.gtf
sRepeat=db/simpleRepeat.txt

if [ ! -f $refGene ]; then
  echo "$refGene does not exists."
  exit 1
fi
if [ ! -f $knownGene ]; then
  echo "$knownGene does not exists."
  exit 1
fi
if [ ! -f $ensGene ]; then
  echo "$ensGene does not exists."
  exit 1
fi
if [ ! -f $sRepeat ]; then
  echo "$sRepeat does not exists."
  exit 1
fi

#perl db/coding_RefSeq.pl $refGene db/hg38.refGene.coding.exon.bed.unsorted db/refGene.coding.intron.bed.unsorted db/refGene.coding.5putr.bed.unsorted db/refGene.coding.3putr.bed.unsorted
#perl db/noncoding_RefSeq.pl $refGene db/refGene.noncoding.exon.bed.unsorted db/refGene.noncoding.intron.bed.unsorted

perl db/coding_and_noncoding_RefSeq.pl db/hg38.refGene.gtf db/refGene.coding.exon.bed.unsorted db/refGene.coding.intron.bed.unsorted db/refGene.coding.5putr.bed.unsorted db/refGene.coding.3putr.bed.unsorted db/refGene.noncoding.exon.bed.unsorted db/refGene.noncoding.intron.bed.unsorted

echo "perform sorting for coding genes"
sort db/refGene.coding.exon.bed.unsorted -k 1 -V > db/refGene.coding.exon.bed
sort db/refGene.coding.intron.bed.unsorted -k 1 -V > db/refGene.coding.intron.bed
sort db/refGene.coding.5putr.bed.unsorted -k 1 -V > db/refGene.coding.5putr.bed
sort db/refGene.coding.3putr.bed.unsorted -k 1 -V > db/refGene.coding.3putr.bed
echo "perform sorting for noncoding genes"
sort db/refGene.noncoding.exon.bed.unsorted -k 1 -V > db/refGene.noncoding.exon.bed
sort db/refGene.noncoding.intron.bed.unsorted -k 1 -V > db/refGene.noncoding.intron.bed

echo "perform bedtools for coding genes"
${PATH_TO_BEDTOOLS}/mergeBed -i db/refGene.coding.exon.bed -nms | ${PATH_TO_BEDTOOLS}/sortBed -i stdin > db/refGene.merged.coding.exon.bed
${PATH_TO_BEDTOOLS}/mergeBed -i db/refGene.coding.intron.bed -nms | ${PATH_TO_BEDTOOLS}/sortBed -i stdin > db/refGene.merged.coding.intron.bed
${PATH_TO_BEDTOOLS}/mergeBed -i db/refGene.coding.5putr.bed -nms | ${PATH_TO_BEDTOOLS}/sortBed -i stdin > db/refGene.merged.coding.5putr.bed
${PATH_TO_BEDTOOLS}/mergeBed -i db/refGene.coding.3putr.bed -nms | ${PATH_TO_BEDTOOLS}/sortBed -i stdin > db/refGene.merged.coding.3putr.bed
echo "perform bedtools for noncoding genes"
${PATH_TO_BEDTOOLS}/mergeBed -i db/refGene.noncoding.exon.bed -nms | ${PATH_TO_BEDTOOLS}/sortBed -i stdin > db/refGene.merged.noncoding.exon.bed
${PATH_TO_BEDTOOLS}/mergeBed -i db/refGene.noncoding.intron.bed -nms | ${PATH_TO_BEDTOOLS}/sortBed -i stdin > db/refGene.merged.noncoding.intron.bed

echo "start knownGene.bed"

perl db/known_gene_format_changer.pl $knownGene > db/knownGene.bed
${PATH_TO_BEDTOOLS}/mergeBed -i db/knownGene.bed -nms | ${PATH_TO_BEDTOOLS}/sortBed -i stdin > db/knownGene.merged.bed

echo "start ensGene.bed"

perl db/ens_gene_format_changer.pl $ensGene > db/ensGene.bed
${PATH_TO_BEDTOOLS}/mergeBed -i db/ensGene.bed -nms | ${PATH_TO_BEDTOOLS}/sortBed -i stdin > db/ensGene.merged.bed

echo "start simpleRepeat.bed"

perl db/s_repeat_format_changer.pl $sRepeat > db/simpleRepeat.bed 
${PATH_TO_BEDTOOLS}/mergeBed -i db/simpleRepeat.bed -nms | ${PATH_TO_BEDTOOLS}/sortBed -i stdin > db/simpleRepeat.merged.bed
