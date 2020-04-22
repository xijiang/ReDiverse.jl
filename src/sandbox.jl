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
    are_files_ready("data/plink", batches, "bed")
end
