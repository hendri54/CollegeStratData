## ---------  Transfer regression

function transfer_regr(ds :: DataSettings)
    # Regression deviations use RegressionTables as inputs
    fPath = data_file(raw_transfer_regr(ds));
    rt = read_regression_file(fPath);
    rename_regressors(rt);
    return rt
end

# Transfer regressions with AFQT, parental, quality dummies.
raw_transfer_regr(ds :: DataSettings; momentType = nothing) = 
    RawDataFile(Transcript(), :none, MtRegression(), "parental_transfers1_reg1.dat", ds);

# Transfer regression with quality dummies and quality / income percentile interactions
# (called interaction2 etc)
# `inc_pctile` regressor, scaled for percentiles in [0, 1]
function transfer_regr_w_qp_interactions(ds :: DataSettings)
    fPath = data_file(raw_transfer_regr_w_qp_interactions(ds));
    rt = read_regression_file(fPath);
    rename_regressors(rt);

    scale_percentile_regressor!(rt, :inc_pctile);
    for ic = 2 : n_colleges(ds)
        scale_percentile_regressor!(rt, regressor_name(:interaction, ic));
    end
    return rt
end

raw_transfer_regr_w_qp_interactions(ds :: DataSettings; momentType = nothing) = 
    RawDataFile(Transcript(), :none, MtRegression(), "parental_transfers1_reg_inc.dat", ds);


## -----------  Tuition regression (net price)
# on quality, parental, gpa

function tuition_regr(ds :: DataSettings)
    # Regression deviations use RegressionTables as inputs
    fPath = data_file(raw_tuition_regr(ds));
    rt = read_regression_file(fPath);
    rename_regressors(rt);
    # Adjust all means and std errors to match model units 
    # modelUnits  &&  convert_to_model_dollars!(rt);
    return rt
end

# Tuition regression with AFQT, parental, quality dummies.
raw_tuition_regr(ds :: DataSettings; momentType = nothing) = 
    RawDataFile(Transcript(), :none, MtRegression(), "net_price1_reg1.dat", ds);


# Tuition regression with quality dummies and quality / income percentile interactions
# (called interaction2 etc)
# `inc_pctile` regressor, scaled for percentiles in [0, 1]
function tuition_regr_w_qp_interactions(ds :: DataSettings)
    fPath = data_file(raw_tuition_regr_w_qp_interactions(ds));
    rt = read_regression_file(fPath);
    rename_regressors(rt);

    scale_percentile_regressor!(rt, :inc_pctile);
    for ic = 2 : n_colleges(ds)
        scale_percentile_regressor!(rt, regressor_name(:interaction, ic));
    end
    return rt
end

raw_tuition_regr_w_qp_interactions(ds :: DataSettings; momentType = nothing) = 
    RawDataFile(Transcript(), :none, MtRegression(), "net_price1_reg_inc.dat", ds);

# Scale from percentile in [0, 100] to percentile in [0, 1].
# Just multiplies regressor and se by 100.
function scale_percentile_regressor!(rt, rName)
    coeff, se = get_coeff_se(rt, rName);
    newRi = RegressorInfo(rName, coeff * 100, se * 100);
    change_regressor!(rt, newRi);
end

# -----------------