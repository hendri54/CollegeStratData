"""
    $(SIGNATURES)
    
Experience log-wage profiles, read from regression file.
Zero for first year of experience.

Most robust to simply store the profile (0 intercept) as a vector
by schooling.
"""
function exper_profile(s :: EdLevel; T :: Integer = 60)
    fPath = data_file(raw_wage_regr());
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
function exper_profile(s :: Integer; T :: Integer = 60)
    return exper_profile(ed_level(s), T = T)
end


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
function wage_regr_intercepts(ds :: DataSettings)
    rt = load_regr_intercepts();
    return RegressionDeviation{Double}(name = :wageRegrIntercepts, dataV = rt, modelV = rt,
        scalarWt = 0.2,
        shortStr = "wageRegrInter", longStr = "Intercepts of wage regressions",
        showPath = "wageRegrIntercepts.txt")
end


function load_regr_intercepts()
    # Regression deviations use RegressionTables as inputs
    fPath = data_file(raw_wage_regr());
    rt = read_regression_file(fPath);
    # Now we just have intercept and school dummies (HSG = default)
    drop_regressors!(rt, [:exp, :exp2_over10]);

    # Adjust constant to match model units
    # S.e. is in "percent" and does not change
    inter = get_coefficient(rt, :cons);
    newInter = log(dollars_data_to_model(exp(inter), :perYear));
    se = get_std_error(rt, :cons);
    newRi = RegressorInfo(:cons, newInter, se);
    change_regressor!(rt, newRi);
    return rt
end


# Predicted earnings at given experience and worker characteristics (at work start)
# Also works for regression for grads. Just set `iSchool = 0` because that regressor is not available for grads.
function workstart_earnings(rt :: RegressionTable, afqtGroup :: Integer, iSchool :: Integer;
    quality :: Integer = 0,  modelUnits :: Bool = true)

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
    if !modelUnits
        earn = dollars_model_to_data(earn, :perYear);
    end
    return earn
end

function workstart_earnings(m :: Model, afqtGroup :: Integer, iSchool :: Integer;
    modelUnits :: Bool = true)

    wageRegrDev = ModelParams.retrieve(m.devV, :wageRegrIntercepts);
    rt = wageRegrDev.dataV;
    return workstart_earnings(rt, afqtGroup, iSchool);
end


## ------------  Wage regressions; grads; with quality dummies

function wage_regr_grads(ds :: DataSettings)
    rt = load_regr_grads();
    return RegressionDeviation{Double}(name = :wageRegrGrads, dataV = rt, modelV = rt,
        scalarWt = 0.1,
        shortStr = "wageRegrGrads", longStr = "Wage regressions; grads; quality dummies",
        showPath = "wageRegrGrads.txt")
end

function load_regr_grads()
    # Regression deviations use RegressionTables as inputs
    fPath = data_file(raw_wage_regr_grads());
    rt = read_regression_file(fPath);
    # Now we just have intercept and school dummies (HSG = default)
    drop_regressors!(rt, [:exp, :exp2_over10, :started_2y]);

    # Adjust constant to match model units
    # S.e. is in "percent" and does not change
    inter = get_coefficient(rt, :cons);
    newInter = log(dollars_data_to_model(exp(inter), :perYear));
    se = get_std_error(rt, :cons);
    newRi = RegressorInfo(:cons, newInter, se);
    change_regressor!(rt, newRi);
    return rt
end


## Penalty: earnings at work start by [quality, grad status]
function pen_earn_qual_grad(ds :: DataSettings)
    target = :earnWorkStart_qgM;
    dFactor = dollars_data_to_model(1000.0, :perYear);
    lbM = repeat([4.0 10.0],  outer = n_colleges(ds));
    # There are no graduates from two year colleges
    lbM[1, 2] = 0.0;
    ubM = repeat([30.0 50.0], outer = n_colleges(ds));
    return BoundsDeviation{Double}(name = target, 
        lbV = lbM, ubV = ubM, modelV = (lbM .+ ubM) .* 0.5,
        scalarWt = 0.35,
        shortStr = "penEarn_qg");
end


## Penalty: lifetime earnings gaps by schooling too large
function pen_lty_school(ds :: DataSettings)
    return PenaltyDeviation{Double}(name = :penLtySchool,
        scalarDevFct = dev_pen_lty_school,  showFct = nothing);
end

function dev_pen_lty_school(ltyMean_sV; doShow :: Bool = false, io = stdout)
    # We don't have data moments for this
    gapV = ltyMean_sV ./ max(0.1, ltyMean_sV[1]);
    lbV = [0.99, 1.0, 1.4];
    ubV = [1.1, 1.3, 2.0];
    scalarDev = bounds_penalty(gapV, lbV, ubV, "lifetime earnings by school";
        scaleFactor = 1.0, doShow = doShow, io = io);
    # scalarDev = sum(max.(0.0, lbV .- gapV)) + sum(max.(0.0, gapV .- ubV));

    # if doShow  &&  (scalarDev > 0.01)
    #     devStr = round(scalarDev, digits = 1);
    #     lbStr = round.(lbV, digits = 2);
    #     modelStr = round.(gapV, digits = 2);
    #     ubStr = round.(ubV, digits = 2);
    #     println(io, "Penalty lifetime earnings by school:  $devStr");
    #     println(io, "Lower bounds:    $lbStr");
    #     println(io, "Model:           $modelStr");
    #     println(io, "Upper bounds:    $ubStr");
    # end
    return scalarDev
end


## Penalty: human capital gains too large
function pen_h_gains(ds :: DataSettings)
    return PenaltyDeviation{Double}(name = :penHGains,
        scalarDevFct = dev_pen_h_gains,  showFct = nothing);
end

function dev_pen_h_gains(hGain_sV)
    lbV = [0.99, 1.05, 1.1];
    ubV = [1.1,  1.3,  2.0];
    scalarDev = sum(max.(0.0, lbV .- hGain_sV)) + sum(max.(0.0, hGain_sV .- lbV));
    return scalarDev
end

# -----------
