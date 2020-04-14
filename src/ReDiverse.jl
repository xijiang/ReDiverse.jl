"""
    pkg ReDiverse

# General description
This is a package to organize and analysis ReDiverse data. It follows the
following procedure:

1. [x] Genotype collection, and convert to `plink` format.
2. [x] Genotype data clean
3. Determine of SNP chip platforms, and final SNP set.
4. Imputation
5. GBLUP
6. Cross-validation strategy
"""
module ReDiverse
export myDebug

include("commonFunc.jl")
include("raw-genotype-org.jl")
include("prepare-maps.jl")
include("prepare-tools.jl")
include("sandbox.jl")

include("work-flow.jl")
end # module
