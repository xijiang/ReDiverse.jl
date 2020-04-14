################################################################################
"""
    read_3c_map_file(file::String)
This is to read a 3-column map files, to use with merge_final_report_2_plink_fam(lmap, ID)
funciton, to create a plink fam file. The file must has the first 3 column as:
1. SNP name
2. chromosome name
3. base pair position

# Note:
The three columns *must be tab separated*

# Example
    ```juliarepl
    julia> read_3c_map_file(file)
    ```
"""
function read_3c_map_file(file::String)
    println("To be validated")
end

################################################################################
"""
    read_a_final_report()

Given a file name of genotypes in Illumina final report format, this funciton
only reads ID name, and genotypes into a string.

# Example
    ```juliarepl
    julia> read_final_report("data/genotypes/german/ld/276000122071617_LD.txt")
    ID genotypes
    ```
"""
function read_a_final_report(file::String)
    id = ""::String
    genotypes = ""::String
    
    open(file, "r") do io
        line = "pattern"
        while line[1:6] ≠ "[Data]"
            line = readline(io)
        end
        _ = readline(io)        # skip header line below '[Data]'

        while !eof(io)
            line = strip(readline(io))
            if length(line) > 10 # 0 is enough to avoid an empty line
                id, a, b = [split(line)[i] for i in [2, 3, 4]]
                genotypes *= a
                genotypes *= b
            end
        end
    end
    
    return id, genotypes
end

################################################################################
"""
    write_to_plink_ped(ID::String, genotype::String)

---

# Introduction
This is a simple covertion program from Illumina final report to plink bed.
I simply put the pa, ma ID and sex as `0`.
No phenotype is provided, hence `-9` for the phenotype column.
I put a default family name as `famDum`.

# Notes
Plink map:
1. 
"""
function merge_to_plink_bed(dir::String, ref::String, prefix::String)
    println("\nDealing with $dir")
    isdir("tmp") || mkdir("tmp")

    open("tmp/tmp.ped", "w") do ped
        cnt = 0
        for f in readdir(dir)
            ID, genotype = read_a_final_report(dir * f)
            cnt += 1
            print("\rDealing with ID $dir$f,  number ", cnt)
            write(ped, join(["famDum", ID, "\t0\t0\t0\t-9"], '\t'))
            
            for allele in genotype
                write(ped, '\t', allele)
            end
            write(ped, '\n')
        end
    end
    println("\nMerged data written to tmp.ped")

    println("\nRead the reference physical map")
    psnp = Dict()
    open(ref, "r") do io
        while !eof(io)
            snp, chr, bp = split(readline(io))
            psnp[snp] = [chr, bp]
        end
    end
    
    println("Create a map from referernce in the order of the final report")
    foo = open("tmp/tmp.map", "w")
    open(dir*readdir(dir)[1], "r") do io
        line = "duuuummy"
        while line[1:6] ≠ "[Data]"
            line = readline(io)
        end
        _ = readline(io)
        while !eof(io)
            line = strip(readline(io))
            snp = split(line)[1]
            chr, bp = psnp[snp]
            write(foo, join([chr, snp, 0, bp], '\t'), '\n')
        end
    end
    close(foo)
end
