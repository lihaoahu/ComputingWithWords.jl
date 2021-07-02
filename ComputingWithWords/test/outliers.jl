Pkg.activate(".")
using ComputingWithWords
using PyCall
stats = pyimport("scipy.stats")

vocabulary = vocabulary_loader("../data/174subjects.xls")

little_intervalset = vocabulary[:Sizeable]

little_intervalset = little_intervalset |> bad_data_processor |>
 outliers_processor |> tolerance_limit_processor |>  reasonable_processor

t1fs_plot(little_intervalset)
ms_plot(little_intervalset)
