# Scalar moment file currently does not exist. Oksana needs to make it.

## Read scalar moments from a single dedicated file
# I currently created this as a dummy file
function read_scalar_moments(ds :: DataSettings)
    fPath = joinpath(data_dir(ds), "scalar_moments.csv");
    csvFile = CSV.File(fPath, header = [:name, :value],  
        delim = ',', comment = commentStr);
    return csvFile |> DataFrame
end


"""
	$(SIGNATURES)

Read one scalar moments from the scalar moments file.
"""
function read_scalar_moment(ds :: DataSettings, name :: String)
    df = read_scalar_moments(ds);
    outV = df[df.name .== name, :value];
    @assert length(outV) == 1
    outVal = outV[1];
    return outVal :: Float64
end


## Fraction entering college
function frac_enter(ds :: DataSettings)
    fracEnter = read_all_from_delim_file(raw_entry_gpa_parental(ds));
    cnt = read_all_from_delim_file(raw_entry_gpa_parental(ds; momentType = MtCount()));
    @assert check_float(fracEnter, lb = 0.45, ub = 0.65);
    ses = (fracEnter * (1.0 - fracEnter) / cnt) ^ 0.5;
    return fracEnter, ses, cnt
end

"""
Graduation rate (conditional on entry).
For consistency, constructed from joint entry mass of gpa and quality.
Constructing from entry mass by [quality, yp] produces slightly different overall grad rate. Because samples differ between the two moments.
"""
function frac_gradc(ds :: DataSettings)
    massM, _ = mass_entry_qual_gpa(ds);
    massGradM, _ = mass_grad_qual_gpa(ds);
    gradRate = sum(massGradM) / sum(massM);
    # gradRate = read_all_from_delim_file(raw_frac_gradc_qual_gpa(ds));
    cnt = read_all_from_delim_file(raw_frac_gradc_qual_gpa(ds; momentType = MtCount()));
    @assert check_float(gradRate, lb = 0.3, ub = 0.7);
    ses = (gradRate * (1.0 - gradRate) / cnt) ^ 0.5;
    return gradRate, ses, cnt
end



# Number of college entrants in the sample
# Useful for computing std errors
function n_entrants(ds :: DataSettings)
    cntM = read_matrix_by_xy(count_file(ds, :fracEnter_gpM));
    cnt = round(Int, sum(cntM));
    @assert 4000 < cnt < 7_000
    return cnt
end



# ------------