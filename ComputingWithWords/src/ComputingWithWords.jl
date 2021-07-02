module ComputingWithWords

using IntervalArithmetic: Interval
using ExcelFiles, DataFrames
using Statistics: quantile, std, mean
using Gadfly


include("utils.jl")
include("processor.jl")


export Interval, vocabulary_loader, bad_data_processor, outliers_processor,tolerance_limit_processor,reasonable_processor
export ms_plot,t1fs_plot
end
