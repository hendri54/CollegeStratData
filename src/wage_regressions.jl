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

Column headers for regression files. These are the headers that are in the raw files. What is returned is determined by `output_col_header`.
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


"""
	$(SIGNATURES)

Column headers for RegressionTable objects. Regardless of names in regression files (which have a tendency to change over time), this is what will be returned.

## Example
```
output_col_header(:gpa, 2) == :afqt2
```
"""
function output_col_header(colCat :: Symbol, j :: Integer)
    if colCat ∈ (:gpa, :afqt)
        hd = Symbol("afqt$j");
    elseif colCat == :parental
        hd = Symbol("parental$j");
    elseif colCat == :school
        hd = Symbol("school$j");
    else
        error("Invalid: $colCat")
    end
    return hd
end


# Rename regressors so that output names match loaded names
# Does nothing if regressor does not exist or does not need to be renamed.
function rename_regressors(rt :: RegressionTable, colCat :: Symbol)
    oldName = regr_col_header(colCat, 1);
    newName = output_col_header(colCat, 1);
    if (oldName != newName)  &&  has_regressor(rt, oldName)
        for j = 1 : 10
            oldName = regr_col_header(colCat, j);
            newName = output_col_header(colCat, j);
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


# Retrieve a regression coefficient. Ignores default dummies (j < 2). 
# Optional: allow for missing regressors
function get_regr_coef(rt :: RegressionTable, colCat :: Symbol, j :: Integer;
    errorIfMissing :: Bool = true)

    if j < 2
        rCoef = 0.0;
    else
        rName = regr_col_header(colCat, j);
        if has_regressor(rt, rName)
            rCoef = get_coefficient(rt, rName);
        elseif errorIfMissing
            error("Cannot retrieve $rName from $rt");
        else
            rCoef = 0.0;
        end
    end
    @assert isa(rCoef, Float64)
    return rCoef
end

function get_intercept(rt :: RegressionTable)
    return get_coefficient(rt, :cons)
end


# -------------