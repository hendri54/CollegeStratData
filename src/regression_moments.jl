## ---------  Transfer regression

# function dev_transfer_regr(ds :: DataSettings)
#     rt = load_transfer_regr();
#     return RegressionDeviation{Double}(name = :transferRegr, dataV = rt, modelV = rt,
#         scalarWt = 0.5,
#         shortStr = "transferRegr", longStr = "Transfer regression",
#         showPath = "transferRegr.txt")
# end


function transfer_regr(ds :: DataSettings)
    # Regression deviations use RegressionTables as inputs
    fPath = data_file(raw_transfer_regr(ds));
    rt = read_regression_file(fPath);

    # Adjust all means and std errors to match model units 
    # convert_to_model_dollars!(rt);
    # dollarFactor = dollars_data_to_model(1.0, :perYear);
    # nameV = get_names(rt);
    # for name in nameV
    #     coeff, se = get_coeff_se(rt, name);
    #     newRi = RegressorInfo(name, coeff * dollarFactor, se * dollarFactor);
    #     change_regressor!(rt, newRi);
    # end
    return rt
end


# Convert all coefficients and std errors to model dollars
# function convert_to_model_dollars!(rt :: RegressionTable)
#     dollarFactor = dollars_data_to_model(1.0, :perYear);
#     nameV = get_names(rt);
#     for name in nameV
#         coeff, se = get_coeff_se(rt, name);
#         newRi = RegressorInfo(name, coeff * dollarFactor, se * dollarFactor);
#         change_regressor!(rt, newRi);
#     end
# end


## -----------  Tuition regression (net price)
# on quality, parental, gpa

# function dev_tuition_regr(ds :: DataSettings)
#     rt = load_tuition_regr(modelUnits = true);
#     return RegressionDeviation{Double}(name = :tuitionRegr, dataV = rt, modelV = rt,
#         scalarWt = 0.2,
#         shortStr = "tuitionRegr", longStr = "Tuition regression",
#         showPath = "tuitionRegr.txt")
# end


function tuition_regr(ds :: DataSettings)
    # Regression deviations use RegressionTables as inputs
    fPath = data_file(raw_tuition_regr(ds));
    rt = read_regression_file(fPath);

    # Adjust all means and std errors to match model units 
    # modelUnits  &&  convert_to_model_dollars!(rt);
    return rt
end


# -----------------