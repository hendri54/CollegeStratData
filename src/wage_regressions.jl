max_exper(wr :: WageRegressions) = wr.maxExper
exper_groups(wr :: WageRegressions) = wr.experGroupV;
max_exper_exponent(wr :: WageRegressions) = wr.maxExperExponent;
# School groups that are recognized
s_groups(wr :: WageRegressions) = vcat(exper_groups(wr)...);
n_school(wr :: WageRegressions) = length(s_groups(wr));
use_parental_dummies(wr :: WageRegressions) = wr.useParentalDummies;

default_wage_regressions() = 
    WageRegressions(maxExperExponent = 4, maxExper = 14);

# Two school groups
wage_regressions_two() = 
    WageRegressions(experGroupV = [[:HSG, :CD], [:CG]], 
        maxExperExponent = 4);


# Suffix for a regression file, such as "_inc--same"
# "_inc" determines whether parental income is a regressor.
# "_same" or "_dif" refers to same or different experience profile by schooling.
function regr_file_suffix(wr :: WageRegressions)
    if use_parental_dummies(wr)
        incSuffix = "_inc";
    else
        incSuffix = "";
    end

    if length(exper_groups(wr)) == 1
        groupSuffix = "--same";
    elseif exper_groups(wr) == [[:HSG, :CD], [:CG]]
        groupSuffix = "--dif";
    else
        error("Invalid $wr");
    end

    return incSuffix * groupSuffix
end


"""
    $(SIGNATURES)

Column headers for regression files. These are the headers that are in the raw files. What is returned is determined by `regressor_name`.
Different from cross-tabs.
"""
function regr_col_header(colCat :: Symbol, j :: Integer)
    if colCat ∈ (:gpa, :afqt)
        hd = "quartile$j";
    elseif colCat == :parental
        hd = "inc_quartile$j";
    elseif colCat == :school
        hd = "school$j";
    elseif colCat == :lastColl
        hd = "last_type$j";
    elseif colCat == :exper
        if j == 1
            hd = "exp";
        else
            hd = "exp$j";
        end
    else
        error("Invalid: $colCat")
    end
    return Symbol(hd)
end

regr_col_headers(colCat :: Symbol, jMax :: Integer) = 
    [regr_col_header(colCat, j)  for j = 1 : jMax];


# Rename regressors so that output names match loaded names
# Does nothing if regressor does not exist or does not need to be renamed.
function rename_regressors(rt :: RegressionTable, colCat :: Symbol)
    oldName = regr_col_header(colCat, 2);
    newName = regressor_name(colCat, 2);
    if (oldName != newName)  &&  has_regressor(rt, oldName)
        for j = 1 : 10
            oldName = regr_col_header(colCat, j);
            newName = regressor_name(colCat, j);
            if has_regressor(rt, oldName)
                EconometricsLH.rename_regressor(rt, oldName, newName);
            end
        end
    end
    return nothing
end

# Ensure that all regressors match output regressor names
function rename_regressors(rt :: RegressionTable)
    for colCat ∈ (:afqt, :parental, :school)
        rename_regressors(rt, colCat);
    end
end


# -------------