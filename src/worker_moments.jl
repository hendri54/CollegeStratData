"""
    $(SIGNATURES)
    
Experience log-wage profiles, read from regression file.
Zero for first year of experience.

Most robust to simply store the profile (0 intercept) as a vector
by schooling.
"""
function exper_profile(ds :: DataSettings, s :: Integer; T :: Integer = 60)
    fPath = data_file(raw_wage_regr(ds));
    rt = read_regression_file(fPath);
    bExp = get_coefficient(rt, "exp");
    bExp2 = get_coefficient(rt, "exp2_over10");

    outV = zeros(T);
    # Estimated on 15 years of experience
    expMax = 15;
    xV = 0 : (expMax - 1);
    outV[1 : expMax] = bExp .* xV .+ bExp2 .* (xV .^ 2) ./ 10.0;
    # Assumed constant after 15 years of experience
    outV[(expMax + 1) : end] .= outV[15];
    return outV :: Vector{Float64}
end

# Same with integer indexing
# function exper_profile(ds :: DataSettings, s :: Integer; T :: Integer = 60)
#     return exper_profile(ed_level(s), T = T)
# end


"""
    $(SIGNATURES)

Intercepts of log wage regressions
In model units.
Regression contains intercept, school dummies (HSG = default), HS GPA dummies (1 = default), experience (dropped here).
RegressionDeviation contains `:cons` as intercept and school dummies.

Log wage = intercept + experience profile(experience)
It is legitimate to match these intercepts to model wages of workers with experience 1.
Substantive test is plotting the implied wage profiles.
"""
# function wage_regr_intercepts(ds :: DataSettings)
#     rt = load_regr_intercepts(ds);
    # return RegressionDeviation{Double}(name = :wageRegrIntercepts, dataV = rt, modelV = rt,
    #     scalarWt = 0.2,
    #     shortStr = "wageRegrInter", longStr = "Intercepts of wage regressions",
    #     showPath = "wageRegrIntercepts.txt")
# end


function wage_regr_intercepts(ds :: DataSettings)
    # Regression deviations use RegressionTables as inputs
    fPath = data_file(raw_wage_regr(ds));
    rt = read_regression_file(fPath);
    # Now we just have intercept and school dummies (HSG = default)
    drop_regressors!(rt, [:exp, :exp2_over10]);

    # Adjust constant to match model units
    # S.e. is in "percent" and does not change
    # inter = get_coefficient(rt, :cons);
    # newInter = log(dollars_data_to_model(exp(inter), :perYear));
    # se = get_std_error(rt, :cons);
    # newRi = RegressorInfo(:cons, newInter, se);
    # change_regressor!(rt, newRi);
    return rt
end


# Predicted earnings at given experience and worker characteristics (at work start)
# Also works for regression for grads. Just set `iSchool = 0` because that regressor is not available for grads.
function workstart_earnings(rt :: RegressionTable, afqtGroup :: Integer, iSchool :: Integer;   quality :: Integer = 0)

    logEarn = get_coefficient(rt, :cons)
    if afqtGroup > 1
        logEarn += get_coefficient(rt, Symbol("afqt$afqtGroup"));
    end
    if iSchool > 1
        logEarn += get_coefficient(rt, Symbol("school$iSchool"));
    end
    if quality > 1
        logEarn += get_coefficient(rt, Symbol("last_type$quality"));
    end
    earn = exp(logEarn);
    # if !modelUnits
    #     earn = dollars_model_to_data(earn, :perYear);
    # end
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
