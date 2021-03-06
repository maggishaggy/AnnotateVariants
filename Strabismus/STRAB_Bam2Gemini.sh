#!/bin/bash
#PBS -N STRAB_Bam2Gemini
#PBS -V
#PBS -o /mnt/causes-vnx2/TIDE/PROCESS/CYNTHIA_STRAB/STRAB.o
#PBS -e /mnt/causes-vnx2/TIDE/PROCESS/CYNTHIA_STRAB/STRAB.e
## Set the total memory for the job
#PBS -l mem=60G
## Set the max walltime for the job
#PBS -l walltime=240:00:00
## Set the total number of processors for the job
#PBS -l nodes=1:ppn=16
NSLOTS=$PBS_NUM_PPN
umask 0002
source /opt/tools/hpcenv.sh

FAMILY_ID='STRAB'
WORKING_DIR='/mnt/causes-vnx2/TIDE/PROCESS/CYNTHIA_STRAB/'
GENOME_FASTA='/mnt/causes-vnx1/GENOMES/GSC/GRCh37-lite.fa'
PED_FILE=$WORKING_DIR/STRAB.ped
TMPDIR=${WORKING_DIR}tmpdir/
mkdir $TMPDIR
SAMPLE1_VCF=STRAB-013_BWAmem_dupremoved_realigned_HaplotypeCaller.g.vcf
SAMPLE2_VCF=STRAB-011_BWAmem_dupremoved_realigned_HaplotypeCaller.g.vcf
SAMPLE3_VCF=STRAB-012_BWAmem_dupremoved_realigned_HaplotypeCaller.g.vcf

# Step 2: Merge gVCFs

/opt/tools/jdk1.7.0_79/bin/java -Djava.io.tmpdir=$TMPDIR -jar /opt/tools/GATK-3.4-46/GenomeAnalysisTK.jar -T GenotypeGVCFs -nt 4 \
-R $GENOME_FASTA \
--variant $WORKING_DIR${SAMPLE1_VCF} \
--variant $WORKING_DIR${SAMPLE2_VCF} \
--variant $WORKING_DIR${SAMPLE3_VCF} \
-o $WORKING_DIR${FAMILY_ID}.merged.hc.vcf 

#BGZIP that bad boy
/opt/tools/tabix/bgzip $WORKING_DIR${FAMILY_ID}.merged.hc.vcf 
/opt/tools/tabix/tabix $WORKING_DIR${FAMILY_ID}.merged.hc.vcf.gz 


# Step 3: Normalize merged VCF

# Define some variables

SNPEFFJAR=/opt/tools/snpEff/snpEff.jar
GEMINIDB=$WORKING_DIR${FAMILY_ID}.db
VCF=$WORKING_DIR${FAMILY_ID}.merged.hc.vcf
NORMVCF=$WORKING_DIR${FAMILY_ID}.merged.hc.norm.vcf.gz
zless $VCF \
	| sed 's/ID=AD,Number=./ID=AD,Number=R/' \
	| /opt/tools/vt/vt decompose -s - \
	| /opt/tools/vt/vt normalize -r $GENOME_FASTA - \
	| java -Xmx10g -jar $SNPEFFJAR GRCh37.75 \
	| /opt/tools/tabix/bgzip -c > $NORMVCF 
/opt/tools/tabix/tabix -p vcf $NORMVCF

# Step 4: Filter Merged, normalized VCF

NORMFILTERVCF=$WORKING_DIR${FAMILY_ID}.merged.hc.norm.filter.vcf.gz
/opt/tools/bcftools-1.8/bin/bcftools filter \
	 --include 'FORMAT/AD[*:1]>=10 && FORMAT/DP[*] < 300' \
	 -m + \
	 -s + \
	 -O z \
	 --output $NORMFILTERVCF \
	 $NORMVCF 

/opt/tools/tabix/tabix $NORMFILTERVCF \


## Step 5: VCFAnno - Turn your VCF file into an annotated VCF file
ANNOVCF=$WORKING_DIR${FAMILY_ID}.merged.hc.norm.vcfanno.vcf.gz 
/opt/tools/vcfanno/vcfanno -lua /mnt/causes-vnx1/PIPELINES/AnnotateVariants/VCFAnno/custom.lua \
-p $NSLOTS \
/mnt/causes-vnx1/PIPELINES/AnnotateVariants/VCFAnno/VCFANNO_Config_PlusGNOMAD_PlusInHouse_SplitByPop_gnomAD_Exome_VNX.toml \
$NORMFILTERVCF > $ANNOVCF 


# Step 6: VCF2DB - Turn your annotated VCF file into a GEMINI DB

python /opt/tools/vcf2db/vcf2db.py \
--expand gt_quals --expand gt_depths --expand gt_alt_depths --expand gt_ref_depths --expand gt_types \
 --a-ok InHouseDB_AC  --a-ok in_segdup --a-ok AF --a-ok AC --a-ok AN --a-ok MLEAC --a-ok MLEAF --a-ok gnomad_genome_hom_global --a-ok gnomad_genome_hom_afr --a-ok gnomad_genome_hom_amr --a-ok gnomad_genome_hom_asj --a-ok gnomad_genome_hom_eas --a-ok gnomad_genome_hom_fin --a-ok gnomad_genome_hom_nfe --a-ok gnomad_genome_hom_oth --a-ok gnomad_exome_hom_global --a-ok gnomad_exome_hom_afr --a-ok gnomad_exome_hom_amr --a-ok gnomad_exome_hom_asj --a-ok gnomad_exome_hom_eas --a-ok gnomad_exome_hom_fin --a-ok gnomad_exome_hom_nfe --a-ok gnomad_exome_hom_oth --a-ok cpg_island --a-ok common_pathogenic --a-ok cse-hiseq --a-ok DS --a-ok ConfidentRegion \
$ANNOVCF $PED_FILE $GEMINIDB 
