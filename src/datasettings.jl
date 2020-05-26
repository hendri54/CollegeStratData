

n_school(ds :: DataSettings) = ds.nSchool;
n_colleges(ds :: DataSettings) = ds.nColleges;
n_2year(ds :: DataSettings) = ds.n2Year;
n_gpa(ds :: DataSettings) = length(hsgpa_ub(ds));
n_parental(ds :: DataSettings) = length(parental_ub(ds));
hsgpa_ub(ds :: DataSettings) = ds.hsGpaUbV;
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
mean_by_qual(x_qV :: AbstractVector{T1}, ds :: DataSettings) where T1 <: Number =
	sum(x_qV .* frac_enroll_by_qual(ds));
mean_by_gpa_yp(x_gpM :: Matrix{T1}, ds :: DataSettings) where T1 <: Number =
    sum(x_gpM .* mass_gpa_yp(ds));


# Given college indices, which ones are two year colleges
is_two_year(ds :: DataSettings, cIdx :: Integer) = (cIdx .<= n_2year(ds))

# Returns a range, so that assignments of the form 
#	`m[two_year_colleges(ds)] .= 0.0`
# work
two_year_colleges(ds :: DataSettings) = (1 : n_2year(ds));
four_year_colleges(ds :: DataSettings) = (n_2year(ds) + 1) : n_colleges(ds);

# Can one graduate from this college?
can_graduate(ds :: DataSettings, cIdx :: Integer) = !is_two_year(ds, cIdx);
# List of colleges from which one cannot graduate
no_grad_idx(ds :: DataSettings) = two_year_colleges(ds);
grad_idx(ds :: DataSettings) =
	findall(cIdx -> can_graduate(ds, cIdx),  1 : n_colleges(ds))

courses_data_to_model(nCourses) = 
	nCourses ./ dataCoursesPerCourse;
courses_model_to_data(ds :: DataSettings, nCourses) = 
	nCourses .* dataCoursesPerCourse;

credits_to_courses(ds :: DataSettings, nCredits) = 
	nCredits ./ ds.creditsPerCourse;
courses_to_credits(ds :: DataSettings, nCourses) = 
	nCourses .* ds.creditsPerCourse;


"""
	$(SIGNATURES)

Make named data settings.
"""
function make_data_settings(dsName :: Symbol)
	if dsName == :default
		return DataSettings()
	elseif dsName == :test
		return DataSettings()
	else
		error("Invalid name: $dsName")
	end
end

# Default data settings
default_data_settings() = make_data_settings(:default);
test_data_settings() = make_data_settings(:test);

# --------------