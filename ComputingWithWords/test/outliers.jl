using ComputingWithWords
using IntervalArithmetic: Interval
using ExcelFiles, DataFrames
using Statistics: quantile


vocabulary = vocabulary_loader("data/28subjects.xls")

little_intervalset = vocabulary[:Little]

low = map(interval -> interval.lo,little_intervalset)
high = map(interval -> interval.hi,little_intervalset)

index = map(<,low,high)

function bad_data_processor(intervalset::Array{Interval})
    not_bad_data_index = map(
        interval -> interval.lo < interval.hi &&
                    interval.hi-interval.lo<10,
        intervalset)
    return intervalset[index]
end

function _not_outliers(array)
    pq25 = quantile(array,0.25)
    pq75 = quantile(array,0.75)
    pqr = pq75 - pq25
    index = [pq25 - 1.5*pqr < ele < pq75 + 1.5*pqr for ele in array]
    return index
end

function outliers_processor(intervalset::Array{Interval})
    low = map(interval -> interval.lo,intervalset)
    high = map(interval -> interval.hi,intervalset)
    low_not_outliers = _not_outliers(low)
    high_not_outliers = _not_outliers(high)
    not_outliers = map(&, low_not_outliers, high_not_outliers)
    intervalset = intervalset[not_outliers]
    len = map(interval -> interval.hi - interval.lo,intervalset)
    len_not_outliers = _not_outliers(len)
    return intervalset[len_not_outliers]
end
