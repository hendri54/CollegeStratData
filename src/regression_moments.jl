## ---------  Transfer regression

function transfer_regr(ds :: DataSettings)
    # Regression deviations use RegressionTables as inputs
    fPath = data_file(raw_transfer_regr(ds));
    rt = read_regression_file(fPath);
    rename_regressors(rt);
    return rt
end



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


# -----------------