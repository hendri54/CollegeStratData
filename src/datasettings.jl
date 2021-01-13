name(ds :: DataSettings) = ds.name;
# Returns the object defining school groups
school_groups(ds :: DataSettings) = ds.sGroups;
# Returns the defined school groups as symbols
s_groups(ds :: DataSettings) = s_groups(school_groups(ds));
wage_regr_settings(ds :: DataSettings) = ds.wageRegressions;
use_parental_dummies(ds :: DataSettings) = use_parental_dummies(ds.wageRegressions);

"""
$(SIGNATURES)

Number of school groups (e.g. HSG, SC, CG). For wage regressions.
"""
n_school(ds :: DataSettings) = n_school(school_groups(ds));

"""
	$(SIGNATURES)

Number of college quality groups.
"""
n_colleges(ds :: DataSettings) = ds.nColleges;

"""
	$(SIGNATURES)

Number of two year colleges.
"""
n_2year(ds :: DataSettings) = ds.n2Year;

"""
	$(SIGNATURES)

Number of HS GPA or AFQT groups.
"""
n_gpa(ds :: DataSettings) = length(hsgpa_ub(ds));

"""
	$(SIGNATURES)

Number of parental background groups.
"""
n_parental(ds :: DataSettings) = length(parental_ub(ds));

"""
	$(SIGNATURES)

Percentile upper bounds for GPA groups.
"""
hsgpa_ub(ds :: DataSettings) = ds.hsGpaUbV;

"""
	$(SIGNATURES)

Percentile upper bounds for parental groups.
"""
parental_ub(ds :: DataSettings) = ds.parentalUbV;

hsgpa_edges(ds :: DataSettings) = vcat(0.0, hsgpa_ub(ds));
hsgpa_masses(ds :: DataSettings) = diff(hsgpa_edges(ds));
parental_edges(ds :: DataSettings) = vcat(0.0, parental_ub(ds));
parental_masses(ds :: DataSettings) = diff(parental_edges(ds));
mass_gpa_yp(ds :: DataSettings) = hsgpa_masses(ds) * parental_masses(ds)';

# Mean of a Vector by HS GPA
mean_by_gpa(x_pV :: Vector{T1}, ds :: DataSettings) where T1 <: Number = 
	sum(x_pV .* hsgpa_masses(ds));
mean_by_parental(x_pV :: Vector{T1}, ds :: DataSettings) where T1 <: Number = 
	sum(x_pV .* parental_masses(ds));

function mean_by_qual(x_qV :: AbstractVector{T1}, 
	ds :: DataSettings) where T1 <: Number
	
	enroll_qV, _ = frac_enroll_by_qual(ds);
	return sum(x_qV .* enroll_qV);
end

mean_by_gpa_yp(x_gpM :: Matrix{T1}, ds :: DataSettings) where T1 <: Number =
    sum(x_gpM .* mass_gpa_yp(ds));


"""
	$(SIGNATURES)

Given college indices, which ones are two year colleges?
"""
is_two_year(ds :: DataSettings, cIdx :: Integer) = (cIdx .<= n_2year(ds))


"""
	$(SIGNATURES)

Set of two year college indices.
Returns a range, so that assignments of the form 
	`m[two_year_colleges(ds)] .= 0.0`
work.
"""
two_year_colleges(ds :: DataSettings) = (1 : n_2year(ds));

"""
	$(SIGNATURES)

Set of four year college indices.
"""
four_year_colleges(ds :: DataSettings) = (n_2year(ds) + 1) : n_colleges(ds);

"""
	$(SIGNATURES)

Can one graduate from this college?
"""
can_graduate(ds :: DataSettings, cIdx :: Integer) = !is_two_year(ds, cIdx);

"""
	$(SIGNATURES)

List of colleges from which one cannot graduate.
"""
no_grad_idx(ds :: DataSettings) = two_year_colleges(ds);

"""
	$(SIGNATURES)

List of colleges from which students can graduate.
"""
grad_idx(ds :: DataSettings) =
	findall(cIdx -> can_graduate(ds, cIdx),  1 : n_colleges(ds))

credits_to_courses(ds :: DataSettings, nCredits) = 
	nCredits ./ ds.creditsPerCourse;
courses_to_credits(ds :: DataSettings, nCourses) = 
	nCourses .* ds.creditsPerCourse;


## --------------  Files

# Return gpa or afqt suffix for files, whichever is used
afqt_string(ds :: DataSettings) = ds.afqtGpa;
afqt_suffix(ds :: DataSettings) = "_" * afqt_string(ds);
parental_suffix(ds :: DataSettings) = "_inc";
quality_suffix(ds :: DataSettings) = "_q";
grad_drop_suffix(ds :: DataSettings) = "_outcome";

function file_suffix(ds :: DataSettings, suffix :: Symbol)
	if suffix ∈ (:gpa, :afqt)
		return afqt_suffix(ds);
	elseif suffix ∈ (:parental, :yp)
		return parental_suffix(ds);
	elseif suffix ∈ (:qual, :quality)
		return quality_suffix(ds);
	elseif suffix ∈ (:outcome, :gradDrop)
		return grad_drop_suffix(ds);
	else
		error("Invalid suffix: $suffix")
	end
end

function file_suffix(ds :: DataSettings, suffixV :: AbstractVector{Symbol})
	return *([file_suffix(ds, suffixV[j])  for j = 1 : length(suffixV)]...)
end


"""
	$(SIGNATURES)

Construct file name with suffix

# Example: 
```julia
file_name(ds, "cumLoans", (:qual, :year), ".dat"; percentile = 90)
```
"""
function file_name(ds :: DataSettings, baseName :: String, 
	suffix, fExt :: String = ".dat";
	percentile = nothing)

	fn = baseName * file_suffix(ds, suffix);
	if !isnothing(percentile)
		fn = fn * "_$(percentile)PI";
	end
	fn = fn * fExt;
	return fn
end

## --------------  Individual settings

# List of data settings names. Useful for testing.
data_settings_list() = [:default, :uneven, :twoProfiles];


"""
	$(SIGNATURES)

Make named data settings. Each defines at least:

- `dataSubDir`: sub directory where copied data files are stored.

The optional argument `baseDir` points to the directory where the data files live. This defaults to `DataCollegeStrat.data_dir()` so that the data travel with the main repo.
Other than this setting, the code is location independent.
"""
function make_data_settings(dsName :: Symbol; baseDir :: String = "")
	if isempty(baseDir)
		baseDir = DataCollegeStrat.data_dir();
		# baseDir = joinpath(homedir(), "Documents", "projects", "p2019", 
		# 	"college_stratification", "CollegeStrat", "data");
	end
	srcDir = "NLSY 97 moments by AFQT";

	if dsName ∈ (:default, :test)
		subDir = "Updated Types";
	elseif dsName ∈ (:uneven, :twoProfiles)
		subDir = "Uneven Types";
	else
		error("Invalid name: $dsName")
	end
	
	if dsName == :twoProfiles
		wageRegr = wage_regressions_two();
	else
		wageRegr = default_wage_regressions();
	end
	
	ds = DataSettings(name = dsName, dataSubDir = joinpath(subDir, srcDir),
		baseDir = baseDir,
		wageRegressions = wageRegr)
	@assert validate_ds(ds);
	return ds
end

test_data_settings() = make_data_settings(:test);


function validate_ds(ds :: DataSettings) 
	isValid = true;
	wr = wage_regr_settings(ds);
	sg = school_groups(ds);
	if !isequal(s_groups(wr), s_groups(sg))
		@warn """
			School groups and wage regression settings do not match
			$sg
			$wr
			"""
		isValid = false;
	end
	return isValid;
end


## --------  Directories

# Data files are stored here
function data_dir(ds :: DataSettings)
    return joinpath(base_dir(ds), data_sub_dir(ds))
end

# This lives in DataCollegeStrat package.
base_dir(ds :: DataSettings) = ds.baseDir;
	# joinpath(homedir(), "Documents", "projects", "p2019", "college_stratification");

data_sub_dir(ds :: DataSettings) = ds.dataSubDir;

pkg_dir() = normpath(joinpath(@__DIR__, ".."));

# Diagnostic output reports go here
out_dir(ds :: DataSettings) = joinpath(pkg_dir(), "out");


## ----------  Show

function Base.show(io :: IO, ds :: DataSettings)
	print(io,  "DataSettings ", name(ds), " with ", n_colleges(ds), " colleges.")
end

function settings_table(ds :: DataSettings)
    # borrowLimitV = borrow_limits(ds, modelUnits = false);
	# borrowLimitV = round.(borrowLimitV, digits = 0);
	gpaUbV = round.(hsgpa_ub(ds), digits = 2);
	pUbV = round.(parental_ub(ds), digits = 2);
    return [
		"DataSettings"  " ";
		"GPA classes"  "$gpaUbV";
		"Parental classes"  "$pUbV"
        # "Borrowing limits"  "$borrowLimitV"
    ]
end


## -----------  Other

function n_groups(ds :: DataSettings, group :: Symbol)
	if group ∈ (:gpa, :afqt)
		n = n_gpa(ds);
	elseif group == :parental
		n = n_parental(ds);
	elseif group == :quality
		n = n_colleges(ds);
	elseif group == :school
		n = n_school(ds);
	else
		error("Unknown group $group");
	end
	return n
end

# --------------