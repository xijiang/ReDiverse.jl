function sandbox()
    batches = ["dutch-10690",
               "dutch-10993",
               "dutch-11483",
               "dutch-777k",
               "dutch-v2",
               "dutch-v3",
               "german-v2",
               "german-v3",
               "norge-777k",
               "norge-v1",
               "norge-v2"]
    src = "data/plink"
    tgt = "data/qc"
    isdir(tgt) || mkdir(tgt)
    
    println("The plink logs can be found in data/qc")
    println("Only warnings and errors are shown in Julia REPL")
    #curTime = Dates.format(Dates.now(), "yyyy-mm-dd--HH:MM:SS")
    for batch in batches
        print_header("Dealing with data batch: $batch")

        # HWE
        println(repeat('-', 80))
        _ = read(`bin/plink --cow --bfile $src/$batch --hardy --out $tgt/$batch`, String);
    end
end
