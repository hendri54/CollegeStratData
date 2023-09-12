## ---------------  Input Regression files

"""
	$(SIGNATURES)

Read file with regression. Return RegressionTable.
By default renames regressors so they are consistent across files (and reasonable looking).

Interaction terms are simply named `interaction3` for `afqt3/qual4` interaction.

File format:
Row 1: header with variable names
Row 2: coefficients
Row 3: std errors
Col 1: header (omit)

IN
	target :: Symbol
		an entry in `MomentTable`
OUT
	coeff :: DataFrame
		coeff.b1 is the value of coefficient b1
	se :: DataFrame
		se.b1 is the std error of b1
"""
function read_regression_file(fPath :: String; 
        renameRegr = true, renameInteractions = true)
    @assert isfile(fPath)  "File not found: $fPath"
    csvFile = CSV.File(fPath, header = true,  delim = '\t', comment = commentStr);
	df = (csvFile |> DataFrame);

	cStat = 1;
	iCoeff = 1;
	@assert df[iCoeff, cStat] == "coeff";
	# This is a DataFrameRow
	coeffV = df[iCoeff, 2:end];

	iSe = 2
	@assert df[iSe, cStat] == "se";
	seV = df[iSe, 2:end];

	# Regressor names
	nameV = propertynames(df)[2 : end];
	@assert validate_regressor_names(nameV)
	rt = RegressionTable(nameV, Vector{Float64}(coeffV), Vector{Float64}(seV));
    renameRegr  &&  rename_regressors(rt; renameInteractions);
	return rt
end

read_regression_file(rf :: RawDataFile; renameRegr = true, renameInteractions = true) = 
	read_regression_file(data_file(rf); renameRegr, renameInteractions);


"""
    $(SIGNATURES)

Column headers for regression files. These are the headers that are in the raw files. What is returned is determined by `regressor_name`.
Different from cross-tabs.
"""
function regr_col_header(colCat, j :: Integer)
    if colCat ∈ (:gpa, :afqt)
        hd = regr_col_header(ClassHsGpa(), j); 
    elseif colCat == :parental
        hd = regr_col_header(ClassParental(), j);
    elseif colCat == :school
        hd = regr_col_header(ClassSchooling(), j);
    elseif colCat == :lastColl
        hd = regr_col_header(ClassQuality(), j);
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

regr_col_header(::ClassHsGpa, j :: Integer) = Symbol("afqt$j");
regr_col_header(::ClassParental, j :: Integer) = Symbol("inc_quartile$j");
regr_col_header(::ClassQuality, j :: Integer) = Symbol("last_type$j");
regr_col_header(::ClassSchooling, j :: Integer) = Symbol("school$j");

regr_col_headers(colCat, jMax :: Integer) = 
    [regr_col_header(colCat, j)  for j = 1 : jMax];

# Valid column headers (without indices) in original files.
# Some files have :afqt; others have :quartile.
valid_raw_col_headers() = 
    [RegrGpaVar, :quartile, RegrParentalVar, :inc_pctile, :quality, :school, 
        :last_type, :interaction, :exp, :cons];

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
    if !(Symbol(group) ∈ valid_raw_col_headers())
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


# Ensure that all regressors match output regressor names
function rename_regressors(rt :: RegressionTable; renameInteractions = true)
    for colCat ∈ (ClassHsGpa(), ClassParental(), ClassSchooling(), ClassQuality())
        rename_regressors(rt, colCat);
        renameInteractions && rename_interactions!(rt);
    end
end

# Rename regressors so that output names match loaded names
# Does nothing if regressor does not exist or does not need to be renamed.
function rename_regressors(rt :: RegressionTable, colCat)
    # oldName = regr_col_header(colCat, 2);
    # newName = regressor_name(colCat, 2);
    # if (oldName != newName)  &&  has_regressor(rt, oldName)
        for j = 1 : 10
            oldName = regr_col_header(colCat, j);
            newName = regressor_name(colCat, j);
            if (oldName != newName)  &&  has_regressor(rt, oldName)
                EconometricsLH.rename_regressor(rt, oldName, newName);
            end
        end
    # end
    return nothing
end


"""
Rename afqt/quality interactions that are simply named `interaction3` or (sometimes) `afqt3/qual4`.
"""
function rename_interactions!(rt :: RegressionTable)
    iQualV = [3, 4]; # Hard wired in the data file.
    iAfqtV = [3, 4];  # Also hard wired.
    for iQual in iQualV
        for iAfqt in iAfqtV
            newName = interaction_name(ClassHsGpa(), iAfqt, ClassQuality(), iQual);
            for oldName in (
                    Symbol("interaction$iAfqt"), 
                    raw_afqt_qual_interaction_name(iAfqt, iQual)
                    ) 
                # @show oldName, has_regressor(rt, oldName)
                if has_regressor(rt, oldName)  &&  (oldName != newName)
                    EconometricsLH.rename_regressor(rt, oldName, newName);
                end
            end
        end
    end
end

# But sometimes the regressor is simply named `interaction3`.
function raw_afqt_qual_interaction_name(iAfqt, iQual)
    return Symbol("afqt$(iAfqt)_q$(iQual)")
end


## ----------  Handling regression files
# with renamed regressors

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
function get_regr_coef(rt :: RegressionTable, colCat, j :: Integer;
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


function get_interaction_coef(rt :: RegressionTable, cat1, j1 :: Integer, 
        cat2, j2 :: Integer; errorIfMissing :: Bool = true)

    if (j1 < 2)  ||  (j2 < 2)
        rCoef = 0.0;
    else
        rName = interaction_name(cat1, j1, cat2, j2);
        if has_regressor(rt, rName)
            rCoef = get_coefficient(rt, rName);
        elseif errorIfMissing
            error("Cannot retrieve $rName from $rt");
        else
            rCoef = 0.0;
        end
    end
    return rCoef;
end

function interaction_name(cat1, j1, cat2, j2)
    @check (j1 > 1)  &&  (j2 > 1);
    rName1 = interaction_substring(cat1, j1);
    rName2 = interaction_substring(cat2, j2);
    rName = Symbol(rName1 * "-" * rName2);
    return rName
end


has_intercept(rt :: RegressionTable) = has_regressor(rt, RegrInter);

function get_intercept(rt :: RegressionTable; defaultValue = missing)
    if has_intercept(rt)
        return get_coefficient(rt, RegrInter);
    else
        return defaultValue;
    end
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
function regressor_name(colCat, j :: Integer)
    return Symbol(regressor_string(colCat, j))
end

regressor_name(colCat) = Symbol(regressor_string(colCat));


"""
	$(SIGNATURES)

Retrieve regressor names as Symbols for indices `1 : jMax`.
"""
regressor_names(varName, jMax :: Integer) = 
    [regressor_name(varName, j)  for j = 1 : jMax];

regressor_names(varName, jV :: AbstractVector) = 
    [regressor_name(varName, j)  for j ∈ jV];


"""
	$(SIGNATURES)

Make name of a dummy regressor, such as `:school2`. Purpose is to harmonize names that tend to vary across raw data files. Inputs are names found in raw data files.
Interaction terms use different abbreviations for quality.
If `interaction == true`, only a substring is returned that can be assembled into a complete regressor.

## Example
```
    regressor_string(:gpa, 2) == "afqt2"
```
"""
function regressor_string(varName :: Symbol, idx :: Integer)
    if varName == :const
        @assert idx <= 0  "Constant does not have index"
    end
    if idx > 0
        idxStr = "$idx";
    else
        idxStr = "";
    end
    regName = regressor_string(varName) * idxStr;
    return regName
end

function regressor_string(varName :: Symbol) 
    if varName ∈ (:gpa, DataAfqtVar)
        regName = regressor_string(ClassHsGpa());
    elseif varName == DataParentalVar
        regName = regressor_string(ClassParental());
    elseif varName == DataSchoolVar
        regName = regressor_string(ClassSchooling());
    elseif varName ∈ (:quality, :lastColl, DataQualityVar)
        regName = regressor_string(ClassQuality());
    elseif varName == :interaction
        regName = "interaction";
    elseif varName == :const
        regName = "cons";
    else
        error("Invalid varName: $varName")
    end
    return regName
end

regressor_string(grpVar :: AbstractClassification, idx :: Integer) = 
    regressor_string(grpVar) * "$idx";

regressor_string(grpVar :: AbstractClassification) = short_label(grpVar);

regressor_strings(varName, idx) = 
    [regressor_string(varName, idx1)  for idx1 in idx];


"""
Part of a regressor to assemble a name with interactions.
"""
function interaction_substring(varName, idx :: Integer)
    regName = regressor_string(varName, idx);
    # if varName ∈ (:quality, DataSchoolVar)
    #     regName = "q$idx";
    # else
    #     error("Invalid varName: $varName")
    # end
    return regName
end

# """
# 	$(SIGNATURES)

# Name of intercept regressor in raw data files.
# """
# intercept_name() = :cons;

# All regressors for given fields. As returned to the outside, not as loaded from disk.
group_regressors(ds :: DataSettings, group; startIdx = 1) =
    regressor_names(group,  startIdx : n_groups(ds, group));

gpa_regressors(ds :: DataSettings; startIdx = 1) = 
    group_regressors(ds, ClassHsGpa(); startIdx);
parental_regressors(ds :: DataSettings; startIdx = 1) = 
    group_regressors(ds, ClassParental(); startIdx);
quality_regressors(ds :: DataSettings; startIdx = 1) = 
    group_regressors(ds, ClassQuality(); startIdx);
school_regressors(ds :: DataSettings; startIdx = 1) = 
    group_regressors(ds, ClassSchooling(); startIdx);



# -------------