# By year

## ----------- Status by year (in college quality X; drop; grad)

raw_status_year(ds :: DataSettings; momentType :: Symbol = :mean) = 
    RawDataFile(:transcript, :progress, momentType, 
        "q_dist_by_y.dat", ds);

function status_by_year(ds :: DataSettings)
    load_fct = mt -> begin
        # Read into DataFrameXY
        d = read_by_xy(raw_status_year(ds; momentType = mt));
        nr, nc = size(d.df);
        # Drop header column. Keep the rest.
        convert(Matrix{Double}, d.df[1:nr, 2:nc]);
    end
    m, ses, cnts = choice_prob_from_xy(load_fct);
    @assert check_float_array(m, 0.0, 1.0);
    @assert size(m, 2) == n_colleges(ds) + 2  "Expecting columns for quality, drop, grad";
    return m, ses, cnts
end


## ----------  Fraction dropping out of 4y colleges by year
# Out of total entrants. First 3 years only.

# Return the fractions; std errors are not exactly right
function frac_drop_4y_by_year(ds :: DataSettings)
    m, _, cnts = load_moment(ds, :statusByYear);
    idx4yV = (n_2year(ds) + 1) : n_colleges(ds);
    m = m[:, idx4yV];
    cnts = cnts[:, idx4yV];

    T = 3;
    massEnter = sum(m[1, :]);
    @assert 0.3 < massEnter < 0.7
    fracDrop_tV = zeros(T);
    cnts_tV = zeros(Int, T);
    for t = 1 : T
        # Number in 4y in t
        cnts_tV[t] = sum(cnts[t, :]);
        massDrop = sum(m[t, :]) - sum(m[t+1, :]);
        @assert 0.0 < massDrop < 0.3;
        fracDrop_tV[t] = massDrop / massEnter;
    end
    @assert check_float_array(fracDrop_tV, 0.02, 0.15);

    # This is not exactly right, but the best we can do
    ses_tV = fracDrop_tV .* (1.0 .- fracDrop_tV) ./ (cnts_tV .^ 0.5);
    return fracDrop_tV, ses_tV, cnts_tV
end


## ----------  90th percentile of cumulative loans by year.
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