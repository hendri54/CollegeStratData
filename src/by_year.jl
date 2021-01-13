# By year

# 90th percentile of cumulative loans by year.
# No counts or std errors.
function cum_loans90_year(ds :: DataSettings)
    outV = cum_loans_year(ds; percentile = 90);
    cntV = zeros(Int, size(outV));
    sesV = zeros(Double, size(outV));
    return outV, sesV, cntV
end

function cum_loans_year(ds :: DataSettings; percentile = nothing)
    T = ds.Tmax;
    outV = zeros(Double, T);
    for t = 1 : T
        outV[t] = cum_loans_year(ds, t; percentile = percentile);
    end
    @assert all(outV .>= 0.0)  "Negative loans";
    return outV
end


"""
	$(SIGNATURES)

Read cumulative loans for one year. Optionally a percentile. Otherwise the mean.
"""
function cum_loans_year(ds :: DataSettings, t :: Integer; percentile = nothing)
    rf = raw_cum_loans_qual_year(ds, t; momentType = :mean, percentile = percentile);
    return Double(read_total(rf));
end

# -------------