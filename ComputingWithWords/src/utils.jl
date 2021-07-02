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
                # println(e)
            end
        end
        intervalset[word] = intervals
    end
    return intervalset
end

function ms_plot(intervalset::Array{Interval})
    μ = map(i -> (i.hi + i.lo)/2, intervalset)
    σ = map(i -> (i.hi - i.lo)/2/sqrt(6), intervalset)
    set_default_plot_size(21cm, 14cm)
    plot(x=μ,y=σ)
end

function t1fs_plot(intervalset::Array{Interval})
    x = Float16[]
    u = Float16[]
    for interval in intervalset
        μ = (interval.hi+interval.lo)/2
        σ = (interval.hi-interval.lo)/2/sqrt(6)
        xi = collect(range(0,10,length=100))
        ui = exp.(-(xi.-μ).^2/2/σ^2)
        x = vcat(x,xi)
        u = vcat(u,ui)
    end
    plot(x=x,y=u)
end
