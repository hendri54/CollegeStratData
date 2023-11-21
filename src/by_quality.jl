## --------  By college quality
# Since there is no switching in the model, several statstics do not make sense for two year colleges. They are set to 0 in model and data.


# Read a percentile vector (values between 0 and 100).
# Std deviations are constructed from counts.
function read_pct_by_quality(ds :: DataSettings, rawFileFct)
    m = read_vector_by_x(data_file(rawFileFct(MtMean()))) ./ 100.0;
    @assert isa(m, Vector{Double})
	@argcheck size(m) == (n_colleges(ds), )
	@assert all(m .> 0.0)  &&  all(m .< 1.0)

    cnts = read_vector_by_x(data_file(rawFileFct(MtCount())));
    cnts = clean_cnts(cnts);
    @assert all(cnts .> 100);
    @assert size(m) == size(cnts)

    ses = m ./ (cnts .^ 0.5);
    return m, ses, cnts
end


# -------------  Individual moments


## Tuition (out of pocket). Average by college type
function college_tuition(ds :: DataSettings)
    load_fct =  mt -> read_row_totals(
        raw_net_price_xy(ds, [:qual, :gpa], ds.tuitionYear; momentType = mt));
    tuitionV, ses, cnts = load_mean_ses_counts(load_fct);
    @assert all(tuitionV .> 400.0)  &&  all(tuitionV .< 20000.0)
    @assert length(tuitionV) == n_colleges(ds)
    return tuitionV, ses, cnts
end


# Mean work hours PER YEAR
function work_hours_by_qual(ds :: DataSettings)
    load_fct = 
        mt -> read_row_totals(raw_work_hours_qual_parental(ds; momentType = mt));
    m, ses, cnts = load_mean_ses_counts(load_fct);
    # m, ses, cnts = mean_from_row_total(ds, :workTime_qV);
    # rf = raw_work_hours_qual_gpa(ds, ds.workTimeYear);
    # m = read_row_totals(data_file(rf));
    @assert all(m .> 400.0)  &&  all(m .< 1800.0)
    @assert length(m) == n_colleges(ds)
    @assert all(cnts .> 100)
    return m, ses, cnts
end


## Graduation rate by quality
function frac_gradc_by_quality(ds :: DataSettings)
    load_fct = 
        mt -> read_row_totals(raw_frac_gradc_qual_gpa(ds; momentType = mt));
    m, ses, cnts = choice_prob_from_xy(load_fct);
    # m, ses, cnts = choice_prob_from_row_total(ds, :fracGrad_qV);
    # rf = raw_grad_rate_qual_gpa(ds);
    # m = read_row_totals(data_file(rf));
    # @assert all(m .> 0.0)  &&  all(m .< 1.0)
    @assert length(m) == n_colleges(ds)
    # Set to 0 for 2 year colleges
    m[no_grad_idx(ds)] .= 0.0;
    cnts[no_grad_idx(ds)] .= 0.0;
    return m, ses, cnts
end


## Mean time to drop out by quality. 4y only
function time_to_drop_4y_by_quality(ds :: DataSettings)
    load_fct = 
        mt -> read_row_totals(ds, :timeToDrop4y_qgM, mt);
    m, ses, cnts = load_mean_ses_counts(load_fct);
    @assert all(m .> 1.4)  &&  all(m .< 4.0)
    @assert length(m) == (n_colleges(ds) - n_2year(ds))
    return m, ses, cnts
end


## Mean time to graduate by quality (conditional on graduation)
# Only 4y colleges (output length = no of 4y colleges).
function time_to_grad_4y_by_quality(ds :: DataSettings)
    load_fct = 
        mt -> read_row_totals(ds, :timeToGrad4y_qV, mt);
    m, ses, cnts = load_mean_ses_counts(load_fct);
    @assert all(m .> 3.0)  &&  all(m .< 7.0)
    @assert length(m) == n_4year(ds);
    return m, ses, cnts
end


## Mean AFQT percentile
function afqt_mean_by_quality(ds :: DataSettings)
    # target = :gpaMean_qV;
    rawFileFct = mt -> raw_afqt_pct_qual(ds; momentType = mt);
    m, ses, cnts = read_pct_by_quality(ds :: DataSettings, rawFileFct);

    # rf = raw_afqt_pct_qual(ds);
    # m = read_vector_by_x(data_file(rawFileFct(MtMean()))) ./ 100.0;
    # @assert isa(m, Vector{Double})
	@argcheck size(m) == (n_colleges(ds), )
	@assert all(m .> 0.0)  &&  all(m .< 1.0)

    # rfCnts = raw_afqt_pct_qual(ds; momentType = MtCount());
    # cnts = read_vector_by_x(data_file(rawFileFct(MtCount())));
    # @assert all(cnts .> 100)

    # ses = m ./ (cnts .^ 0.5);
    # cnts = round.(Int, cnts);
    # m = read_by_quality(ds, data_file(rf)) ./ 100.0;
	return m, ses, cnts
end


# Enrollment by quality, sums to 1
function frac_enroll_by_qual(ds :: DataSettings)
    load_fct = 
        mt -> read_row_totals(raw_entry_qual_parental(ds; momentType = mt));
    m, ses, cnts = choice_prob_from_xy(load_fct);
    # dataV, ses, cnts = choice_prob_from_row_total(ds, :fracEnroll_qV);
    # rf = raw_entry_qual_parental(ds);
    # dataV = read_row_totals(data_file(rf));
    @assert check_float_array(m, 0.05, 1.0);
    @check sum(m) ≈ 1.0
    return m, ses, cnts
end


# Fraction of HSG who enter each quality, unconditional.
function frac_enroll_uncond_by_qual(ds :: DataSettings)
    fracEnter, _ = load_moment(ds, :fracEnter);
    fracEnroll_qV, ses, cnts = load_moment(ds, :fracEnroll_qV);
    @assert sum(fracEnroll_qV) ≈ 1.0
    fracEnter_qV = fracEnroll_qV .* fracEnter;
    ses .*= fracEnter;
    @assert isapprox(sum(fracEnter_qV), fracEnter, rtol = 0.001)
    return fracEnter_qV, ses, cnts
end


function frac_local_by_quality(ds :: DataSettings)
    rawFileFct = mt -> raw_frac_local_qual(ds; momentType = mt);
    # Cannot use this b/c std errors are constructed differently
    # m, ses, cnts = read_pct_by_quality(ds :: DataSettings, rawFileFct);

    m = read_vector_by_x(data_file(rawFileFct(MtMean())));
    cnts = read_vector_by_x(data_file(rawFileFct(MtCount())));
    cnts = round.(Int, cnts);
    ses = ses_from_choice_probs(m, cnts);
    # ses = read_vector_by_x(data_file(rawFileFct(MtStd())));

    @assert isa(m, Vector{Double})
	@argcheck size(m) == (n_colleges(ds), )
	@assert all(m .> 0.0)  &&  all(m .< 1.0)
    @assert all(cnts .> 100)
    @assert size(m) == size(cnts)
    @assert size(ses) == size(m)

    return m, ses, cnts
end



## --------------  By quality / year
# Multiple raw data files

# No std errors
cum_loans90_qual_year(ds :: DataSettings) = 
    cum_loans_qual_year(ds; percentile = 90);

# Cumulative loans by [quality, year]
# No std errors for percentiles
function cum_loans_qual_year(ds :: DataSettings; percentile = nothing)
    T = ds.Tmax;
    outM = zeros(n_colleges(ds), T);
    sesM = zeros(n_colleges(ds), T);
    cntM = zeros(Int, n_colleges(ds), T);
    for t = 1 : T
        if isnothing(percentile)
            outM[:, t], sesM[:,t], cntM[:,t] = 
                cum_loans_qual(ds, t);
        else
            outM[:, t] = cum_loans_qual_percentile(ds, t, percentile);
        end
    end

    # Ignore 2 year colleges after year 2 while there is no switching
    outM[two_year_colleges(ds), 3 : end] .= 0.0;
    cntM[two_year_colleges(ds), 3 : end] .= 0;
    return outM, sesM, cntM
end

# The same for one year. Means only.
function cum_loans_qual(ds :: DataSettings,  t :: Integer)
    load_fct = 
        mt -> read_row_totals(raw_cum_loans_qual_year(ds, t; 
            momentType = mt));
    m, ses, cnts = load_mean_ses_counts(load_fct);
    return m, ses, cnts
end

# The same for percentiles. No std errors.
function cum_loans_qual_percentile(ds :: DataSettings, t :: Integer, 
    percentile :: Integer)

    outM = read_row_totals(raw_cum_loans_qual_year(ds, t; 
        momentType = MtMean(), percentile = percentile));
    return outM
end


## ----------  Dropout rates

# Fraction of initial entrants dropping out at end of each year.
# Dropout rates for 2y starters only sum to about 0.9. But 1/3 occur after year 1.
function frac_drop_qual_year(ds :: DataSettings; T = 3)
    # T = 3; # could calculate for higher years
    outM = zeros(n_colleges(ds), T);
    sesM = zeros(n_colleges(ds), T);
    cntsM = zeros(Int, n_colleges(ds), T);
    for t = 1 : T
        outM[:, t], sesM[:,t], cntsM[:,t] = frac_drop_qual_one_year(ds, t);
    end

    @assert check_float_array(outM, 0.0, 0.5);
    @assert all(outM[end, :] .< 0.1);

    # Ignore 2 year colleges after year 2 while there is no switching
    # outM[two_year_colleges(ds), 3 : end] .= 0.0;
    # cntsM[two_year_colleges(ds), 3 : end] .= 0.0;
    return outM, sesM, cntsM
end


"""
Fraction of initial entrants in each quality who drop out by end of year `t`.
Sums to total dropout rate for quality.
"""
function frac_drop_qual_one_year(ds :: DataSettings, t :: Integer)
    load_fct = 
        mt -> read_row_totals(raw_frac_drop_qual_gpa(ds, t; momentType = mt));
    m, ses, cnts = choice_prob_from_xy(load_fct);
    @assert check_float_array(m, 0.0, 1.0);
    @assert length(m) == n_colleges(ds);
    return m, ses, cnts
end

# function frac_drop_qual(ds :: DataSettings, t :: Integer)
#     nc = n_colleges(ds);
#     # Rows are years, cols are colleges + dropouts + grads
#     m, _, cnts = load_moment(ds, :statusByYear);
#     @assert size(m, 2) == (nc + 2)  "Invalid size: $(size(m))"

#     massEnter_qV = m[1, 1:nc];    
#     # Assumes all who leave drop out.
#     massDrop_qV = m[t, 1:nc] .- m[t+1, 1:nc];
#     @assert all(massDrop_qV .>= 0.0)
#     fracDrop_qV = massDrop_qV ./ massEnter_qV;

#     # Standard errors are computed using counts for date `t`
#     # This is approximate, but best that we can do.
#     cnts_qV = cnts[t, 1 : nc];
#     ses_qV = ses_from_choice_probs(fracDrop_qV, cnts_qV);

#     @assert check_float_array(fracDrop_qV, 0.0, 1.0)
#     @assert length(fracDrop_qV) == n_colleges(ds)
#     return fracDrop_qV, ses_qV, cnts_qV
# end


# Courses attempted by quality, one year
# function dm_courses_tried_qual_year()
#     return DataMoment(:coursesTried_qtM, 
#         ModelStatistic(:nTriedMean_gtM, :qualYearS),
#             file_name("coursesTried", [:quality, :year], ".dat"), nothing,
#         courses_tried_qual_year, plot_quality_year);
# end


## -----------  Courses attempted by quality / year
# Sets two year colleges to 0 after year 2

function courses_tried_qual_year(ds :: DataSettings)
    target = :coursesTried_qtM;

    T = ds.Tmax;
    outM = zeros(n_colleges(ds), T);
    sesM = zeros(n_colleges(ds), T);
    cntsM = zeros(Int, n_colleges(ds), T);
    for t = 1 : T
        outM[:, t], sesM[:,t], cntsM[:,t] = courses_tried_qual(ds, t);
    end

    # Ignore 2 year colleges after year 2 while there is no switching
    outM[two_year_colleges(ds), 3 : end] .= 0.0;
    cntsM[two_year_colleges(ds), 3 : end] .= 0.0;
    return outM, sesM, cntsM
end


function courses_tried_qual(ds :: DataSettings, t :: Integer)
    load_fct = 
        mt -> read_row_totals(raw_credits_taken_qual_gpa(ds, t; momentType = mt));
    m, ses, cnts = load_mean_ses_counts(load_fct);
    @assert check_float_array(m, 1.0, 50.0)
    @assert length(m) == n_colleges(ds)
    m = credits_to_courses(ds, m);
    ses = credits_to_courses(ds, ses);
    return m, ses, cnts
end


# CDF of HS GPA by college quality
# Each row is a percentile (e.g. p10 is the 10th percentile of GPA in each college).
# Each entry means: The p10-th percentile in this college is the X-th percentile in the population.
# Numbers are between 0 and 100
function read_cdf_gpa_by_qual(ds :: DataSettings; momentType = MtMean())
    rawFn = RawDataFile(Transcript(), GrpFreshmen(), momentType, 
        file_name(ds, "inv_cdf", [:afqt, :qual]), ds);
    fPath = data_file(rawFn);
    df = read_delim_file_to_df(fPath);
    if momentType == MtMean()
        @check all_greater(df.quality2, 1)
        @check all_at_most(df.quality4, 100)
    end
    return df
end


# Returns a matrix of afqt percentiles by [percentile, quality]
# Element [j, k] means: In College of quality k, the percentile[j]-th GPA percentile corresponds to the outM[j,k] percentile in the data.
# Currently only works for percentiles in the data file. Should interpolate +++++
function cdf_gpa_by_qual(ds :: DataSettings, 
    percentileV :: AbstractVector, qualityV :: AbstractVector)

    df = read_cdf_gpa_by_qual(ds; momentType = MtMean());
    pctColV = parse_pct_column(df[!, :pctile]);
    np = length(percentileV);
    nq = length(qualityV);
    outM = zeros(np, nq);
    for iq = 1 : nq
        dataV = df[!, Symbol("quality$(qualityV[iq])")];
        for ip = 1 : np
            # rIdx = findfirst(x -> x == "p$(percentileV[ip])", pctColV);
            rIdx = findfirst(x -> x == percentileV[ip], pctColV);
            @assert (!isnothing(rIdx)  && (rIdx > 0))  """
                $(percentileV[ip]) not found in $pctColV
                """;
            outM[ip, iq] = dataV[rIdx];
        end
    end
    @assert all_greater(outM, 1.0);
    @assert all_at_most(outM, 100.0)
    return outM
end

# Parse "p05" to integer 5 etc.
function parse_pct_column(pctStrV)
    pctV = zeros(Int, size(pctStrV));
    for (j, pctStr) in enumerate(pctStrV)
        pctV[j] = parse(Int, pctStr[2 : end]);
    end
    @assert all(0 .<= pctV .<= 100);
    return pctV
end


# ---------------