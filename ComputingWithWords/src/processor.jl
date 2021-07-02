function bad_data_processor(intervalset::Array{Interval})
    not_bad_data_index = map(
        interval ->
            interval.lo < interval.hi && interval.hi - interval.lo < 10,
        intervalset,
    )
    return intervalset[not_bad_data_index]
end

function _not_outliers(array)
    pq25 = quantile(array, 0.25)
    pq75 = quantile(array, 0.75)
    pqr = pq75 - pq25
    index = [pq25 - 1.5 * pqr < ele < pq75 + 1.5 * pqr for ele in array]
    return index
end

function outliers_processor(intervalset::Array{Interval})
    low = map(interval -> interval.lo, intervalset)
    high = map(interval -> interval.hi, intervalset)
    low_not_outliers = _not_outliers(low)
    high_not_outliers = _not_outliers(high)
    endpints_not_outliers = map(&, low_not_outliers, high_not_outliers)
    intervalset = intervalset[endpints_not_outliers]
    len = map(interval -> interval.hi - interval.lo, intervalset)
    len_not_outliers = _not_outliers(len)
    return intervalset[len_not_outliers]
end

tolerance_factors =
    [32.019 32.019 8.380 5.369 4.275 3.712 3.369 3.136 2.967 2.839 2.737 2.655 2.587 2.529 2.48 2.437 2.4 2.366 2.337 2.31 2.31 2.31 2.31 2.31 2.208]

function _in_tolerance_limit(array)
    n = min(length(array),25)
    k = tolerance_factors[n]
    μ = mean(array)
    σ = std(array)
    index = map(ele -> μ - k*σ < ele < μ + k*σ, array)
    return index
end

function tolerance_limit_processor(intervalset::Array{Interval})
    low = map(interval -> interval.lo, intervalset)
    high = map(interval -> interval.hi, intervalset)
    low_in_tolerance_limit = _in_tolerance_limit(low)
    high_in_tolerance_limit = _in_tolerance_limit(high)
    endpionts_in_tolerance_limit = map(&, low_in_tolerance_limit, high_in_tolerance_limit)
    intervalset = intervalset[endpionts_in_tolerance_limit]
    len = map(interval -> interval.hi - interval.lo, intervalset)
    len_in_tolerance_limit = _in_tolerance_limit(len)
    return intervalset[len_in_tolerance_limit]
end

function reasonable_processor(intervalset::Array{Interval})
    low = map(interval -> interval.lo, intervalset)
    high = map(interval -> interval.hi, intervalset)
    μ_low = mean(low)
    σ_low = std(low)
    μ_high = mean(high)
    σ_high = std(high)
    if σ_high + σ_low == 0 || σ_high == σ_low
        barrier = (μ_high + μ_low)/2
    elseif σ_low == 0
        barrier = μ_low + 0.01
    elseif σ_high == 0
        barrier = μ_high - 0.01
    else
        barrier1 = ((μ_high*σ_low^2 - μ_low*σ_high^2)+σ_low*σ_high*((μ_low-μ_high)^2+2*(σ_low^2-σ_high^2)*log(σ_low/σ_high))^0.5)/(σ_low^2-σ_high^2)
        barrier2 = ((μ_high*σ_low^2 - μ_low*σ_high^2)-σ_low*σ_high*((μ_low-μ_high)^2+2*(σ_low^2-σ_high^2)*log(σ_low/σ_high))^0.5)/(σ_low^2-σ_high^2)
        if μ_low < barrier1 < μ_high
            barrier = barrier1
        else
            barrier = barrier2
        end
    end
    reasonable = map(i -> i.lo <= barrier <= i.hi, intervalset)
    return intervalset[reasonable]
end
