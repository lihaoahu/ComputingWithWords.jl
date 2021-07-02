module ComputingWithWords

using IntervalArithmetic:  Interval
using ExcelFiles, DataFrames

# 数据读取
function vocabulary_loader(filename::String)
    rawdata = load(filename,"Sheet1") |> DataFrame
    n_subjects, n_col = size(rawdata)
    n_words = n_col/2
    words = propertynames(rawdata)[1:2:64]
    intervalset = Dict()
    for (i,word) in enumerate(words)
        left = rawdata[!,2*i-1]
        right = rawdata[!,2*i]
        intervals = zeros(Interval, n_subjects)
        for j in range(1,n_subjects,step=1)
            try
                intervals[j] = Interval(left[j],right[j])
            catch e
                println(e)
            end
        end
        intervalset[word] = intervals
    end
    return intervalset
end

export Interval, vocabulary_loader
end
