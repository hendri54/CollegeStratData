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

    if length(exper_groups(wr)) == 1
        # temporarily hard coded +++++
        bExpV = [0.1644, -0.202, 0.1395, -0.0371];
        # fPath = data_file(raw_wage_regr(ds));
        # rt = read_regression_file(fPath);
        # bExpV = [get_coefficient(rt, "exp"), 
        #     get_coefficient(rt, "exp2_over10")];
    elseif exper_groups(wr) == [[:HSG, :CD], [:CG]]
        # Hard coded. Update when new data files available +++++
        if s ∈ (:HSG, :CD, :SC)
            bExpV = [0.1802, -0.2323, 0.1618, -0.0424];
        elseif s == :CG
            bExpV = [0.1801, -0.3322, 0.3523, -0.1429];
        else
            error("Invalid $s");
        end
    else
        error("Invalid $wr");
    end
    @assert length(bExpV) == max_exper_exponent(wr);

    outV = zeros(T);
    # Estimated on about 12 years of experience
    expMax = max_exper(wr);
    xV = 0 : (expMax - 1);
    for j = 1 : length(bExpV)
        outV[1 : expMax] .+= bExpV[j] .* (xV .^ j) ./ (10.0 ^ (j-1));
    end
    # Assumed constant after 15 years of experience
    outV[(expMax + 1) : end] .= outV[expMax];
    return outV :: Vector{Float64}
end


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
    # @assert 1 ≤ s ≤ n_school(ds);
    @assert n_school(wr) == n_school(ds)

    if length(exper_groups(wr)) == 1
        # temporarily hard coded +++++
        fPath = joinpath(pkgdir(CollegeStratData), "wage_regression1_by_hand.dat");
        rt = read_regression_file(fPath);

        # Regression deviations use RegressionTables as inputs
        # fPath = data_file(raw_wage_regr(ds));
        # rt = read_regression_file(fPath);
        # # Now we just have intercept and school dummies (HSG = default)
        # drop_regressors!(rt, [:exp, :exp2_over10]);
    elseif exper_groups(wr) == [[:HSG, :CD], [:CG]]
        # temporarily hard coded +++++
        fPath = joinpath(pkgdir(CollegeStratData), "wage_regression_by_hand.dat");
        rt = read_regression_file(fPath);
    else
        error("Invalid $wr");
    end
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

    logEarn = get_coefficient(rt, :cons)
    if afqtGroup > 1
        logEarn += get_coefficient(rt, Symbol("afqt$afqtGroup"));
    end
    if iSchool > 1
        logEarn += get_coefficient(rt, Symbol("school$iSchool"));
    end
    cQuality = Symbol("last_type$quality");
    if quality > 1  &&  has_regressor(rt, cQuality)
        logEarn += get_coefficient(rt, cQuality);
    end
    cParental = Symbol("parental$parental");
    if parental > 1  &&  has_regressor(rt, cParental)
        logEarn += get_coefficient(rt, cParental);
    end
    earn = exp(logEarn);
    return earn
end

# function workstart_earnings(m :: Model, afqtGroup :: Integer, iSchool :: Integer;
#     modelUnits :: Bool = true)

#     wageRegrDev = ModelParams.retrieve(m.devV, :wageRegrIntercepts);
#     rt = wageRegrDev.dataV;
#     return workstart_earnings(rt, afqtGroup, iSchool);
# end


## ------------  Wage regressions; grads; with quality dummies

# function wage_regr_grads(ds :: DataSettings)
#     rt = load_regr_grads(ds);
#     return RegressionDeviation{Double}(name = :wageRegrGrads, dataV = rt, modelV = rt,
#         scalarWt = 0.1,
#         shortStr = "wageRegrGrads", longStr = "Wage regressions; grads; quality dummies",
#         showPath = "wageRegrGrads.txt")
# end

function wage_regr_grads(ds :: DataSettings)
    # Regression deviations use RegressionTables as inputs
    fPath = data_file(raw_wage_regr_grads(ds));
    rt = read_regression_file(fPath);
    # Now we just have intercept and school dummies (HSG = default)
    drop_regressors!(rt, [:exp, :exp2_over10]);
    if has_regressor(rt, :started_2y)
        drop_regressor!(rt, :started_2y);
    end

    # Adjust constant to match model units
    # S.e. is in "percent" and does not change
    # inter = get_coefficient(rt, :cons);
    # newInter = log(dollars_data_to_model(exp(inter), :perYear));
    # se = get_std_error(rt, :cons);
    # newRi = RegressorInfo(:cons, newInter, se);
    # change_regressor!(rt, newRi);
    return rt
end

# -----------
