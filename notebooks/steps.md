# A summary of my steps on the ReDiverse project
## Genotypes
The genotypes I received were stored in `data/genotypes/{dutch,german,norge}`. Then each folder of below:
- **Step-1.plk**: Merged final reports to plink.ped, using `Top` fields.
  - Chromosome and bp info were also updated with $v_3$.map.
  - Used `Top` columns in the final reports.
  - `AB` are illegel to beagle.jar
  - Don't know if there is a way to convert `AB` to `ACGT`.
- **Step-2.plk**: Removed non-autosomal SNP. Only loci on chr 1-29 left, according to $v-3$.map.
- **Step-3.plk**: Filtered loci of geno<0.9, maf<0.01, $P_{\mathrm{hwe}}<10^{-4}$
- **Step-4.plk**: Filtered ID with mind<0.95.
- **Step-5.plk**: Removed dupicated loci.
  - **Step-5.1.plk**: Unify allele order of all platforms
- **Step-6.plk**: Merged all platforms into 3 country sets.
- **Step-7.plk**: Imputed results.
- **Step-8.plk**: Remove country specific loci, and ready for $\mathbf{G}$-matrix.
  - Changed ID names in German data at this step.
- **Step-9.plk**: For GRM calculation
  - unified pedigree
  - dictionary of ID and recoded (integer) ID
  - ordered ID in 3 countries with dictionary above.
  