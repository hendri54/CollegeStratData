"""
    $(SIGNATURES)
    
Experience log-wage profiles, read from regression file.
Zero for first year of experience.

Most robust to simply store the profile (0 intercept) as a vector
by schooling.
"""
function exper_profile(ds :: DataSettings, s :: Symbol; T :: Integer = 60)
    wr = wage_regr_settings(ds);
    # @assert 1 ≤ s ≤ n_school(ds);
    @assert n_school(wr) == n_school(ds)

    bExpV = read_exper_coefficients(ds, s);

    outV = zeros(T);
    # Estimated on about 12 years of experience
    expMax = max_exper(wr);
    xV = 0 : (expMax - 1);
    for j = 1 : length(bExpV)
        outV[1 : expMax] .+= bExpV[j] .* (xV .^ j) ./ (10.0 ^ (j-1));
    end
    # Assumed constant after `expMax` years of experience
    outV[(expMax + 1) : end] .= outV[expMax];

    @assert outV[1] == 0.0
    @assert maximum(outV) < 1.2
    return outV :: Vector{Float64}
end


# Read experience coefficients from "dat" file
function read_exper_coefficients(ds :: DataSettings, s :: Symbol)
    # File name with regression coefficients for this case
    rf = exper_raw_file(ds, s);
    rt = read_regression_file(rf);

    wr = wage_regr_settings(ds);
    nx = max_exper_exponent(wr);
    rNameV = regr_col_headers(:exper, nx);
    bExpV = [get_coefficient(rt, rNameV[j])  for j = 1 : nx];
    @assert all(-0.5 .< bExpV .< 0.5)
    return bExpV
end    


# File name with experience coefficients
function exper_raw_file(ds :: DataSettings, s :: Symbol)
    wr = wage_regr_settings(ds);
    if length(exper_groups(wr)) == 1
        suffix = "_all--same";
    elseif exper_groups(wr) == [[:HSG, :CD], [:CG]]
        if s ∈ (:HSG, :CD, :SC)
            suffix = "_noncol--dif";
        elseif s == :CG
            suffix = "_colgrad--dif";
        else
            error("Invalid $s");
        end
    else
        error("Invalid $wr");
    end
    
    rf = RawDataFile(:selfReport, :none, :regression, 
        "loginc_st1" * suffix * ".dat", ds);
    return rf
end



## -------------  Intercepts

"""
    $(SIGNATURES)

Intercepts of log wage regressions
In data units.
Regression contains intercept, school dummies (HSG = default), HS GPA dummies (1 = default), experience (dropped here).
RegressionDeviation contains `:cons` as intercept and school dummies.

Log wage = intercept + experience profile(experience)
It is legitimate to match these intercepts to model wages of workers with experience 1.
Substantive test is plotting the implied wage profiles.
"""
function wage_regr_intercepts(ds :: DataSettings)
    wr = wage_regr_settings(ds);
    @assert n_school(wr) == n_school(ds)

    fn = "loginc_st2_3" * regr_file_suffix(wr) * ".dat";
    rf = RawDataFile(:selfReport, :none, :regression, fn, ds);
    rt = read_regression_file(rf);
    rename_regressors(rt);
    return rt
end


"""
    $(SIGNATURES)

Predicted earnings at given experience and worker characteristics (at work start)
Also works for regression for grads. Just set `iSchool = 0` because that regressor is not available for grads.

# Arguments
- `quality`: last college quality. Not available for all regressions. Then ignored.
- `parental`: parental income group. Not available for all regressions. Then ignored.
"""
function workstart_earnings(rt :: RegressionTable, afqtGroup :: Integer, 
    iSchool :: Integer;   quality :: Integer = 0,  parental :: Integer = 0)

    logEarn = get_intercept(rt) +
        get_regr_coef(rt, :afqt, afqtGroup) +
        get_regr_coef(rt, :school, iSchool) +
        get_regr_coef(rt, :parental, parental; errorIfMissing = false) +
        get_regr_coef(rt, :lastColl, quality; errorIfMissing = false);
    # end
    earn = exp(logEarn);
    return earn
end


## ------------  Wage regressions; grads; with quality dummies

function wage_regr_grads(ds :: DataSettings)
    wr = wage_regr_settings(ds);
    @assert n_school(wr) == n_school(ds)

    fn = "loginc_st2_2" * regr_file_suffix(wr) * ".dat";
    rf = RawDataFile(:selfReport, :none, :regression, fn, ds);
    rt = read_regression_file(rf);
    rename_regressors(rt);
    return rt
end

# -----------
