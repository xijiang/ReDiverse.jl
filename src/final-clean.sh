#!/usr/bin/env bash
# This is just a general record of the command used for the final data cleaning
# before imputation.  I don't have to literially run this.
# or run in the ReDiverse directory like blow
#  bash src/final-clean.sh

countries="dutch german norge"
lqt=0.1				# low quality loci threshold
# remove duplicates
for c in $countries; do
    cat data/genotypes/final-vcf/$c.vcf |
	bin/merge-dup data/maps/duplicated.snp |
	bin/rm-low-Q-loci
	pigz > tmp/$c.vcf.gz
done


