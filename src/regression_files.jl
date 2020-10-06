# Handling regression files

"""
    $(SIGNATURES)

Retrieve a regression coefficient of the form `:afqt3`. 
Ignores default dummies (j < 2). 
Optional: allow for missing regressors.
Assumes that regressors have been renamed.

## Example
```
get_regr_coef(rt, :afqt, 2) # -> coefficient value for `:afqt2`
get_regr_coef(rt, :parental, 1) == 0.0
```
"""
function get_regr_coef(rt :: RegressionTable, colCat :: Symbol, j :: Integer;
    errorIfMissing :: Bool = true)

    if j < 2
        rCoef = 0.0;
    else
        rName = regressor_name(colCat, j);
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


## ----------  Regressor names

"""
	$(SIGNATURES)

Column headers for RegressionTable objects. Regardless of names in regression files (which have a tendency to change over time), this is what will be returned.

## Example
```
regressor_name(:gpa, 2) == :afqt2
```
"""
function regressor_name(colCat :: Symbol, j :: Integer)
    return Symbol(regressor_string(colCat, j))
end


"""
	$(SIGNATURES)

Retrieve regressor names as Symbols for indices `1 : jMax`.
"""
regressor_names(varName :: Symbol, jMax :: Integer) = 
    [regressor_name(varName, j)  for j = 1 : jMax];

regressor_names(varName :: Symbol, jV :: AbstractVector) = 
    [regressor_name(varName, j)  for j ∈ jV];


"""
	$(SIGNATURES)

Make name of a dummy regressor, such as `:school2`.

## Example
```
    regressor_string(:gpa, 2) == "afqt2"
```
"""
function regressor_string(varName :: Symbol, idx :: Integer)
    if varName ∈ (:gpa, :afqt)
        regName = "afqt$idx";
    elseif varName == :parental
        regName = "parental$idx"
    elseif varName ∈ (:quality, :school)
        regName = "$varName$idx";
    elseif varName == :lastColl
        regName = "last_type$idx";
    elseif varName == :const
        @assert idx <= 0  "Constant does not have index"
        regName = "cons"
    else
        error("Invalid varName: $varName")
    end
    return regName
end

regressor_strings(varName :: Symbol, idx) = 
    [regressor_string(varName, idx1)  for idx1 in idx];

intercept_name() = :cons;

# All regressors for given fields. As returned to the outside, not as loaded from disk.
group_regressors(ds :: DataSettings, group :: Symbol) =
    regressor_names(group,  1 : n_groups(ds, group));

gpa_regressors(ds :: DataSettings) = 
    group_regressors(ds, :gpa);
parental_regressors(ds :: DataSettings) = 
    group_regressors(ds, :parental);
quality_regressors(ds :: DataSettings) = 
    group_regressors(ds, :quality);
school_regressors(ds :: DataSettings) = 
    group_regressors(ds, :school);


## ----------  Names in original files
# collected here because they tend to change over time.


"""
    $(SIGNATURES)

Column headers for regression files. These are the headers that are in the raw files. What is returned is determined by `regressor_name`.
Different from cross-tabs.
"""
function regr_col_header(colCat :: Symbol, j :: Integer)
    if colCat ∈ (:gpa, :afqt)
        hd = "afqt$j";  # was "quartile" +++++
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

# Valid column headers (without indices) in original files.
# Some files have :afqt; others have :quartile.
valid_col_headers() = 
    [:afqt, :quartile, :inc_quartile, :quality, :school, :last_type, :exp, :cons];

# Check that regressor names in a loaded file are valid.
# Before renaming.
function validate_regressor_names(nameV :: AbstractVector{Symbol})
    isValid = true;
    for rName ∈ nameV
        isValid = isValid  &&  validate_regressor_name(rName);
    end
    return isValid
end

function validate_regressor_name(rName :: Symbol)
    isValid = true;
    group, idx = break_regressor_name(rName);
    if !(Symbol(group) ∈ valid_col_headers())
        isValid = false;
        @warn "Invalid column header: $rName"
    end
    return isValid
end


# Break a regressor name of the form `:afqt3` into "afqt" and 3.
# The index is `nothing` if it is missing
function break_regressor_name(rName)
    rStr = string(rName);
    m = match(r"([A-Za-z_]*)([0-9]*)",  rStr);
    group = m.captures[1];
    if isempty(m.captures[2])
        idx = nothing;
    else
        idx = parse(Int, m.captures[2]);
    end
    return group, idx
end


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