## Define variables
WORKING_DIR='/mnt/causes-data04/PROCESS/EXOME_TIDEX/G0340/'
GEMINIDB='G0340.db'
FAMILY_ID='G0340'
TableAnnotator=/mnt/causes-data01/data/RICHMOND/AnnotateVariants/GeminiTable2CVL.py

source /opt/tools/hpcenv.sh

## Change to working directory
cd $WORKING_DIR

# Define Inheritance Model Variant Files
# Phase 1
AUTODOM_OUT=$WORKING_DIR${FAMILY_ID}_autoDom
DENOVO_OUT=$WORKING_DIR${FAMILY_ID}_deNovo
RECESSIVE_OUT=$WORKING_DIR${FAMILY_ID}_recessive
COMPOUND_HET_OUT=$WORKING_DIR${FAMILY_ID}_compoundHet
X_RECESSIVE_OUT=$WORKING_DIR${FAMILY_ID}_Xrecessive
X_DOMINANT_OUT=$WORKING_DIR${FAMILY_ID}_Xdominant
X_DENOVO_OUT=$WORKING_DIR${FAMILY_ID}_Xdenovo

# Phase 2
AUTODOM_OUT_LOOSE=$WORKING_DIR${FAMILY_ID}_autoDom_loose
DENOVO_OUT_LOOSE=$WORKING_DIR${FAMILY_ID}_deNovo_loose
RECESSIVE_OUT_LOOSE=$WORKING_DIR${FAMILY_ID}_recessive_loose
COMPOUND_HET_OUT_LOOSE=$WORKING_DIR${FAMILY_ID}_compoundHet_loose
X_RECESSIVE_OUT_LOOSE=$WORKING_DIR${FAMILY_ID}_Xrecessive_loose
X_DOMINANT_OUT_LOOSE=$WORKING_DIR${FAMILY_ID}_Xdominant_loose
X_DENOVO_OUT_LOOSE=$WORKING_DIR${FAMILY_ID}_Xdenovo_loose

# Phase 3
DBSTATFILE=${FAMILY_ID}_GeminiDB_Stats.txt

# Phase 4
GENERAL_DAMAGING=${FAMILY_ID}_GeneralDamaging.txt
COLUMNS="chrom, start, end, ref, alt, gene, exon, aa_change, impact, impact_severity, rs_ids, inhousedb_ac, aaf_gnomAD_genome_all, gnomAD_genome_num_hom_alt, gts, gt_ref_depths, gt_alt_depths, gt_quals, in_segdup, confidentregion, cadd, pp2hdiv, pp2hvar, fitcons, fathmm_xf, sift_pred, sift_score, clinvar_disease_name, clinvar_pathogenic, clinvar_sig"


##########################################################################################

#####################
#       Phase 1     #
#####################
# Inheritance models
## Recessive
gemini autosomal_recessive \
	--columns "$COLUMNS" \
	--filter "(aaf_gnomAD_genome_all <= 0.01) and (confidentregion = 1) and (inhousedb_ac <= 3 or inhousedb_ac is NULL) and (impact_severity == 'HIGH' or impact_severity=='MED')" \
	-d 20 \
	--min-gq 30 \
	$GEMINIDB > $RECESSIVE_OUT
python $TableAnnotator -i $RECESSIVE_OUT -o ${RECESSIVE_OUT}_annotated.txt

# Compound Het Variants
gemini comp_hets \
	--columns "$COLUMNS" \
	--filter "(aaf_gnomAD_genome_all <= 0.01) and (confidentregion = 1) and (inhousedb_ac <= 3 or inhousedb_ac is NULL) and (impact_severity == 'HIGH' or impact_severity=='MED')" \
	-d 20 \
	--min-gq 30 \
	$GEMINIDB > $COMPOUND_HET_OUT
python $TableAnnotator -i $COMPOUND_HET_OUT -o ${COMPOUND_HET_OUT}_annotated.txt

# De novo
gemini de_novo \
	--columns "$COLUMNS" \
	--filter "(aaf_gnomAD_genome_all <= 0.01) and (confidentregion = 1) and (inhousedb_ac <= 3 or inhousedb_ac is NULL) and (impact_severity == 'HIGH' or impact_severity=='MED')" \
	-d 20 \
	--min-gq 30 \
	$GEMINIDB > $DENOVO_OUT
python $TableAnnotator -i $DENOVO_OUT -o ${DENOVO_OUT}_annotated.txt


# X Dominant
gemini x_linked_dominant  \
	--columns "$COLUMNS" \
	--filter "(aaf_gnomAD_genome_all <= 0.01) and (confidentregion = 1) and (inhousedb_ac <= 3 or inhousedb_ac is NULL) and (impact_severity == 'HIGH' or impact_severity=='MED')" \
	-d 20 \
	--min-gq 30 \
	$GEMINIDB > $X_DOMINANT_OUT
python $TableAnnotator -i $X_DOMINANT_OUT -o ${X_DOMINANT_OUT}_annotated.txt

# X De Novo
gemini x_linked_de_novo \
	--columns "$COLUMNS" \
	--filter "(aaf_gnomAD_genome_all <= 0.01) and (confidentregion = 1) and (inhousedb_ac <= 3 or inhousedb_ac is NULL) and (impact_severity == 'HIGH' or impact_severity=='MED')" \
	-d 20 \
	--min-gq 30 \
	$GEMINIDB > $X_DENOVO_OUT
python $TableAnnotator -i $X_DENOVO_OUT -o ${X_DENOVO_OUT}_annotated.txt

# X Recessive
gemini x_linked_recessive \
        --columns "$COLUMNS" \
        --filter "(aaf_gnomAD_genome_all <= 0.01) and (confidentregion = 1) and (inhousedb_ac <= 3 or inhousedb_ac is NULL) and (impact_severity == 'HIGH' or impact_severity=='MED')" \
        -d 20 \
        --min-gq 30 \
        $GEMINIDB > $X_RECESSIVE_OUT
python $TableAnnotator -i $X_RECESSIVE_OUT -o ${X_RECESSIVE_OUT}_annotated.txt

# Autosomal Dominant
gemini autosomal_dominant \
	--columns "$COLUMNS" \
	--filter "(aaf_gnomAD_genome_all <= 0.01) and (confidentregion = 1) and (inhousedb_ac <= 3 or inhousedb_ac is NULL) and (impact_severity == 'HIGH' or impact_severity=='MED')" \
	-d 10 \
	--min-gq 30 \
	$GEMINIDB > $AUTODOM_OUT
python $TableAnnotator -i $AUTODOM_OUT -o ${AUTODOM_OUT}_annotated.txt


##########################################################################################

#####################
#       Phase 2     #
#####################
# Repeat but with Looser filters, specifically on genotype quality, depth, and whether or not it's in a segdup

# Inheritance models
## Recessive
gemini autosomal_recessive \
	--columns "$COLUMNS" \
	--filter "(aaf_gnomAD_genome_all <= 0.01)  and (inhousedb_ac <= 5 or inhousedb_ac is NULL) and (impact_severity == 'HIGH' or impact_severity=='MED' )" \
	-d 10 \
	--min-gq 30 \
	$GEMINIDB > $RECESSIVE_OUT_LOOSE
python $TableAnnotator -i $RECESSIVE_OUT_LOOSE -o ${RECESSIVE_OUT_LOOSE}_annotated.txt


# Compound Het Variants
gemini comp_hets \
	--columns "$COLUMNS" \
	--filter "(aaf_gnomAD_genome_all <= 0.01)  and (inhousedb_ac <= 5 or inhousedb_ac is NULL) and (impact_severity == 'HIGH' or impact_severity=='MED' )" \
	-d 10 \
	--min-gq 30 \
	$GEMINIDB > $COMPOUND_HET_OUT_LOOSE
python $TableAnnotator -i $COMPOUND_HET_OUT_LOOSE -o ${COMPOUND_HET_OUT_LOOSE}_annotated.txt

# De novo
gemini de_novo \
	--columns "$COLUMNS" \
	--filter "(aaf_gnomAD_genome_all <= 0.01)  and (inhousedb_ac <= 5 or inhousedb_ac is NULL) and (impact_severity == 'HIGH' or impact_severity=='MED' )" \
	-d 10 \
	--min-gq 30 \
	$GEMINIDB > $DENOVO_OUT_LOOSE
python $TableAnnotator -i $DENOVO_OUT_LOOSE -o ${DENOVO_OUT_LOOSE}_annotated.txt

# X Dominant
gemini x_linked_dominant  \
	--columns "$COLUMNS" \
	--filter "(aaf_gnomAD_genome_all <= 0.01)  and (inhousedb_ac <= 5 or inhousedb_ac is NULL) and (impact_severity == 'HIGH' or impact_severity=='MED' )" \
	-d 10 \
	--min-gq 30 \
	$GEMINIDB > $X_DOMINANT_OUT_LOOSE
python $TableAnnotator -i $X_DOMINANT_OUT_LOOSE -o ${X_DOMINANT_OUT_LOOSE}_annotated.txt

# X De Novo
gemini x_linked_de_novo \
	--columns "$COLUMNS" \
	--filter "(aaf_gnomAD_genome_all <= 0.01)  and (inhousedb_ac <= 5 or inhousedb_ac is NULL) and (impact_severity == 'HIGH' or impact_severity=='MED' )" \
	-d 10 \
	--min-gq 30 \
	$GEMINIDB > $X_DENOVO_OUT_LOOSE
python $TableAnnotator -i $X_DENOVO_OUT_LOOSE -o ${X_DENOVO_OUT_LOOSE}_annotated.txt

# X Recessive
gemini x_linked_recessive \
        --columns "$COLUMNS" \
        --filter "(aaf_gnomAD_genome_all <= 0.01)  and (inhousedb_ac <= 5 or inhousedb_ac is NULL) and (impact_severity == 'HIGH' or impact_severity=='MED' )" \
        -d 10 \
        --min-gq 30 \
        $GEMINIDB > $X_RECESSIVE_OUT_LOOSE
python $TableAnnotator -i $X_RECESSIVE_OUT_LOOSE -o ${X_RECESSIVE_OUT_LOOSE}_annotated.txt

# Autosomal Dominant
gemini autosomal_dominant \
	--columns "$COLUMNS" \
	--filter "(aaf_gnomAD_genome_all <= 0.01)  and (inhousedb_ac <= 5 or inhousedb_ac is NULL) and (impact_severity == 'HIGH' or impact_severity=='MED' )" \
	-d 10 \
	--min-gq 30 \
	$GEMINIDB > $AUTODOM_OUT_LOOSE
python $TableAnnotator -i $AUTODOM_OUT_LOOSE -o ${AUTODOM_OUT_LOOSE}_annotated.txt

##########################################################################################

#####################
#       Phase 3     #
#####################


##########################################################################################

#####################
#       Phase 4     #
#####################
# General Queries to the database:

# Define Variant Annotation Cutoffs
GNOMAD_RARE='aaf_gnomAD_genome_all <= 0.01'
GNOMAD_COMMON='aaf_gnomAD_genome_all > 0.01'
SEGDUP='in_segdup=0'
CODING='is_coding=1'
EXONIC='is_exonic=1'
SPLICING='is_splicing=1'
LOF='is_lof=1'
IMPACT_HIGH="impact_severity=='HIGH'"
IMPACT_MED="impact_severity=='MED'"
IMPACT_LOW="impact_severity=='LOW'"
GENEHANCER="genehancer is not NULL"
DBSNP="rs_ids is not NULL"


# Check your sample info
gemini query -q "SELECT * FROM samples" $GEMINIDB > $DBSTATFILE


#I will print out a table
echo "Annotation	Total	Common	Rare" >> $DBSTATFILE

# Total number of variants in the file
TOTAL_VARS=`gemini query -q "SELECT COUNT(*) FROM variants WHERE $SEGDUP" $GEMINIDB`
rareTOTAL_VARS=`gemini query -q "SELECT COUNT(*) FROM variants WHERE $SEGDUP AND $GNOMAD_RARE" $GEMINIDB`
commonTOTAL_VARS=`gemini query -q "SELECT COUNT(*) FROM variants WHERE $SEGDUP AND $GNOMAD_COMMON" $GEMINIDB`

echo "TOTAL	$TOTAL_VARS	$commonTOTAL_VARS	$rareTOTAL_VARS" >> $DBSTATFILE

# Exonic variants
EXONIC_VARS=`gemini query -q "SELECT COUNT(*) FROM variants \
	WHERE $EXONIC AND $SEGDUP" $GEMINIDB`
rareEXONIC_VARS=`gemini query -q "SELECT COUNT(*) FROM variants \
	WHERE $EXONIC AND $SEGDUP AND $GNOMAD_RARE"  $GEMINIDB`
commonEXONIC_VARS=`gemini query -q "SELECT COUNT(*) FROM variants \
	WHERE $EXONIC AND $SEGDUP AND $GNOMAD_COMMON"  $GEMINIDB`

echo "EXONIC	$EXONIC_VARS	$commonEXONIC_VARS	$rareEXONIC_VARS" >> $DBSTATFILE

# Coding Variants
CODING_VARS=`gemini query -q "SELECT COUNT(*) FROM variants \
	WHERE $CODING AND $SEGDUP" $GEMINIDB`
rareCODING_VARS=`gemini query -q "SELECT COUNT(*) FROM variants \
	WHERE $CODING AND $SEGDUP AND $GNOMAD_RARE"  $GEMINIDB`
commonCODING_VARS=`gemini query -q "SELECT COUNT(*) FROM variants \
	WHERE $CODING AND $SEGDUP AND $GNOMAD_COMMON"  $GEMINIDB`

echo "CODING	$CODING_VARS	$commonCODING_VARS	$rareCODING_VARS" >> $DBSTATFILE

#Splicing variants 
SPLICING_VARS=`gemini query -q "SELECT COUNT(*) FROM variants \
	WHERE $SPLICING AND $SEGDUP" $GEMINIDB`
rareSPLICING_VARS=`gemini query -q "SELECT COUNT(*) FROM variants \
	WHERE $SPLICING AND $SEGDUP AND $GNOMAD_RARE"  $GEMINIDB`
commonSPLICING_VARS=`gemini query -q "SELECT COUNT(*) FROM variants \
	WHERE $SPLICING AND $SEGDUP AND $GNOMAD_COMMON"  $GEMINIDB`

echo "SPLICING	$SPLICING_VARS	$commonSPLICING_VARS	$rareSPLICING_VARS" >> $DBSTATFILE

# LOF variants
LOF_VARS=`gemini query -q "SELECT COUNT(*) FROM variants \
	WHERE $LOF AND $SEGDUP" $GEMINIDB`
rareLOF_VARS=`gemini query -q "SELECT COUNT(*) FROM variants \
	WHERE $LOF AND $SEGDUP AND $GNOMAD_RARE"  $GEMINIDB`
commonLOF_VARS=`gemini query -q "SELECT COUNT(*) FROM variants \
	WHERE $LOF AND $SEGDUP AND $GNOMAD_COMMON"  $GEMINIDB`

echo "LOF	$LOF_VARS	$commonLOF_VARS	$rareLOF_VARS" >> $DBSTATFILE

# GeneHancer Variants
GENEHANCER_VARS=`gemini query -q "SELECT COUNT(*) FROM variants \
	WHERE $GENEHANCER AND $SEGDUP" $GEMINIDB`
rareGENEHANCER_VARS=`gemini query -q "SELECT COUNT(*) FROM variants \
	WHERE $GENEHANCER AND $SEGDUP AND $GNOMAD_RARE"  $GEMINIDB`
commonGENEHANCER_VARS=`gemini query -q "SELECT COUNT(*) FROM variants \
	WHERE $GENEHANCER AND $SEGDUP AND $GNOMAD_COMMON"  $GEMINIDB`

echo "GENEHANCER	$GENEHANCER_VARS	$commonGENEHANCER_VARS	$rareGENEHANCER_VARS" >> $DBSTATFILE


# NOTE: Not much use for this, just takes up space at the moment
## Repeat Above, but use a genotype quality cutoff
#echo "Filtered:" >> $DBSTATFILE
##I will print out a table
#echo "Annotation	Total	Common	Rare" >> $DBSTATFILE
#
## Total number of variants in the file
#TOTAL_VARS=`gemini query -q "SELECT COUNT(*) FROM variants WHERE $SEGDUP" $GEMINIDB`
#rareTOTAL_VARS=`gemini query -q "SELECT COUNT(*) FROM variants WHERE $SEGDUP AND $GNOMAD_RARE" $GEMINIDB`
#commonTOTAL_VARS=`gemini query -q "SELECT COUNT(*) FROM variants WHERE $SEGDUP AND $GNOMAD_COMMON" $GEMINIDB`
#
#echo "TOTAL	$TOTAL_VARS	$commonTOTAL_VARS	$rareTOTAL_VARS" >> $DBSTATFILE
#
## Exonic variants
#EXONIC_VARS=`gemini query -q "SELECT COUNT(*) FROM variants \
#	WHERE $EXONIC AND $SEGDUP" $GEMINIDB`
#rareEXONIC_VARS=`gemini query -q "SELECT COUNT(*) FROM variants \
#	WHERE $EXONIC AND $SEGDUP AND $GNOMAD_RARE"  $GEMINIDB`
#commonEXONIC_VARS=`gemini query -q "SELECT COUNT(*) FROM variants \
#	WHERE $EXONIC AND $SEGDUP AND $GNOMAD_COMMON"  $GEMINIDB`
#
#echo "EXONIC	$EXONIC_VARS	$commonEXONIC_VARS	$rareEXONIC_VARS" >> $DBSTATFILE
#
## Coding Variants
#CODING_VARS=`gemini query -q "SELECT COUNT(*) FROM variants \
#	WHERE $CODING AND $SEGDUP" $GEMINIDB`
#rareCODING_VARS=`gemini query -q "SELECT COUNT(*) FROM variants \
#	WHERE $CODING AND $SEGDUP AND $GNOMAD_RARE"  $GEMINIDB`
#commonCODING_VARS=`gemini query -q "SELECT COUNT(*) FROM variants \
#	WHERE $CODING AND $SEGDUP AND $GNOMAD_COMMON"  $GEMINIDB`
#
#echo "CODING	$CODING_VARS	$commonCODING_VARS	$rareCODING_VARS" >> $DBSTATFILE
#
##Splicing variants 
#SPLICING_VARS=`gemini query -q "SELECT COUNT(*) FROM variants \
#	WHERE $SPLICING AND $SEGDUP" $GEMINIDB`
#rareSPLICING_VARS=`gemini query -q "SELECT COUNT(*) FROM variants \
#	WHERE $SPLICING AND $SEGDUP AND $GNOMAD_RARE"  $GEMINIDB`
#commonSPLICING_VARS=`gemini query -q "SELECT COUNT(*) FROM variants \
#	WHERE $SPLICING AND $SEGDUP AND $GNOMAD_COMMON"  $GEMINIDB`
#
#echo "SPLICING	$SPLICING_VARS	$commonSPLICING_VARS	$rareSPLICING_VARS" >> $DBSTATFILE
#
## LOF variants
#LOF_VARS=`gemini query -q "SELECT COUNT(*) FROM variants \
#	WHERE $LOF AND $SEGDUP" $GEMINIDB`
#rareLOF_VARS=`gemini query -q "SELECT COUNT(*) FROM variants \
#	WHERE $LOF AND $SEGDUP AND $GNOMAD_RARE"  $GEMINIDB`
#commonLOF_VARS=`gemini query -q "SELECT COUNT(*) FROM variants \
#	WHERE $LOF AND $SEGDUP AND $GNOMAD_COMMON"  $GEMINIDB`
#
#echo "LOF	$LOF_VARS	$commonLOF_VARS	$rareLOF_VARS" >> $DBSTATFILE
#
## GeneHancer Variants
#GENEHANCER_VARS=`gemini query -q "SELECT COUNT(*) FROM variants \
#	WHERE $GENEHANCER AND $SEGDUP" $GEMINIDB`
#rareGENEHANCER_VARS=`gemini query -q "SELECT COUNT(*) FROM variants \
#	WHERE $GENEHANCER AND $SEGDUP AND $GNOMAD_RARE"  $GEMINIDB`
#commonGENEHANCER_VARS=`gemini query -q "SELECT COUNT(*) FROM variants \
#	WHERE $GENEHANCER AND $SEGDUP AND $GNOMAD_COMMON"  $GEMINIDB`
#
#echo "GENEHANCER	$GENEHANCER_VARS	$commonGENEHANCER_VARS	$rareGENEHANCER_VARS" >> $DBSTATFILE
#



#####################
#       Phase 5     #
#####################

# General Damaging Variant List for the proband
gemini query -q "SELECT $COLUMNS FROM variants WHERE $GNOMAD_RARE AND $SEGDUP AND ( $IMPACT_HIGH OR $IMPACT_MED)" \
	$GEMINIDB > $GENERAL_DAMAGING




#####################
#       Phase 6     #
#####################



# Integrate into single file
# Header 
CVL=$WORKING_DIR${FAMILY_ID}_CVL.tsv
DATE=`date`
echo "FAMILY:	$FAMILY_ID" > $CVL
echo "DATE CVL PRODUCED:	$DATE" >> $CVL

echo "------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------" >> $CVL

# General Stats
cat $DBSTATFILE >> $CVL

echo "------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------" >> $CVL

# De novo
echo "De Novo (Strict)" >> $CVL 
cat ${DENOVO_OUT}_annotated.txt >> $CVL


echo "De Novo (Loose)" >> $CVL
cat ${DENOVO_OUT_LOOSE}_annotated.txt >> $CVL

echo "---------------------------------------------------------------------------------------------------------------------" >> $CVL

echo "X De Novo (Strict)" >> $CVL
cat ${X_DENOVO_OUT}_annotated.txt >> $CVL

echo "X De Novo (Loose)" >> $CVL
cat ${X_DENOVO_OUT_LOOSE}_annotated.txt >> $CVL

echo "------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------" >> $CVL

# Compound Het
echo "Compound Het (Strict)" >> $CVL
cat ${COMPOUND_HET_OUT}_annotated.txt >> $CVL

echo "Compound Het (Loose)" >> $CVL
cat ${COMPOUND_HET_OUT_LOOSE}_annotated.txt >> $CVL


echo "------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------" >> $CVL

# Recessive
echo "Recessive (Strict)" >> $CVL
cat ${RECESSIVE_OUT}_annotated.txt >> $CVL


echo "Recessive (Loose)" >> $CVL
cat ${RECESSIVE_OUT_LOOSE}_annotated.txt >> $CVL

echo "---------------------------------------------------------------------------------------------------------------------" >> $CVL

echo "X Recessive (Strict)" >> $CVL
cat ${X_RECESSIVE_OUT}_annotated.txt >> $CVL

echo "X Recessive (Loose)" >> $CVL
cat ${X_RECESSIVE_OUT_LOOSE}_annotated.txt >> $CVL

echo "------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------" >> $CVL

# Dominant 
echo "Autosomal Dominant (Strict)" >> $CVL
cat ${AUTODOM_OUT}_annotated.txt >> $CVL


echo "Autosomal Dominant (Loose)" >> $CVL
cat ${AUTODOM_OUT_LOOSE}_annotated.txt >> $CVL

echo "---------------------------------------------------------------------------------------------------------------------" >> $CVL

echo "X Autosomal Dominant (Strict)" >> $CVL
cat ${X_DOMINANT_OUT}_annotated.txt >> $CVL

echo "X Autosomal Dominant (Loose)" >> $CVL
cat ${X_DOMINANT_OUT_LOOSE}_annotated.txt >> $CVL


echo "------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------" >> $CVL

# General Damaging
echo "General Damaging" >> $CVL
cat $GENERAL_DAMAGING >> $CVL


############

# Clean Up
rm $AUTODOM_OUT
rm $DENOVO_OUT
rm $RECESSIVE_OUT
rm $COMPOUND_HET_OUT
rm $X_RECESSIVE_OUT
rm $X_DOMINANT_OUT
rm $X_DENOVO_OUT
rm $AUTODOM_OUT_LOOSE
rm $DENOVO_OUT_LOOSE
rm $RECESSIVE_OUT_LOOSE
rm $COMPOUND_HET_OUT_LOOSE
rm $X_RECESSIVE_OUT_LOOSE
rm $X_DOMINANT_OUT_LOOSE
rm $X_DENOVO_OUT_LOOSE
rm $GENERAL_DAMAGING

