"""
	$(SIGNATURES)

Make name of a dummy regressor, such as `:school2`

Example:
    `regressor_name(:gpa, 2)` -> "afqt2"
"""
function regressor_string(varName :: Symbol, idx :: Integer)
    if varName ∈ (:gpa, :afqt)
        regName = "afqt$idx";
    elseif varName == :parental
        regName = "inc_quartile$idx"
    elseif varName ∈ (:quality, :school)
        regName = "$varName$idx";
    else
        error("Invalid varName: $varName")
    end
    return regName
end

regressor_strings(varName :: Symbol, idx) = 
    [regressor_string(varName, idx1)  for idx1 in idx];

# Symbol output
regressor_name(varName :: Symbol, idx :: Integer) = 
    Symbol(regressor_string(varName, idx));
const_regressor_name() = :cons;

# All regressors for given fields
gpa_regressors(ds :: DataSettings) = 
    regressor_strings(:gpa, 1 : n_gpa(ds));
parental_regressors(ds :: DataSettings) = 
    regressor_strings(:parental, 1 : n_parental(ds));
quality_regressors(ds :: DataSettings) = 
    regressor_strings(:quality, 1 : n_colleges(ds));
school_regressors(ds :: DataSettings) = 
    regressor_strings(:school, 1 : n_school(ds));
const_regressor() = "cons";

"""
	$(SIGNATURES)

Convert a `csv` file to a matrix.
"""
function csv_to_matrix(csvFile)
    return convert(Matrix{Float64}, csvFile |> DataFrame!)
end



# -------------------