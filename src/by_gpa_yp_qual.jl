# Plot deviation by (gpa, yp, quality).
# One plot per quality. One subplot per parental.
# function plot_gpa_yp_qual(ds :: DataSettings, 
# 	dev :: ModelParams.Deviation,  plotModel :: Bool,  filePath :: String)

# 	xStrV = gpa_labels(ds);
# 	yStrV = parental_labels(ds);
#     dataM = get_data_values(dev);
#     modelM = get_model_values(dev; matchData = true);
#     nc = size(dataM, 3)

#     for ic = 1 : nc
#         qualPath = make_fpath_by_quality(filePath, ic);
#         plot_model_data_xy(modelM[:,:,ic], dataM[:,:,ic],  
#             xStrV,  yStrV,  plotModel,  qualPath);
#     end
# 	return nothing
# end

# function make_fpath_by_quality(fPathIn, ic)
#     fPath, fExt = splitext(fPathIn);
#     return fPath * "_qual$ic" * fExt
# end


## ---------------  Individual moments

# Fraction in each quality (not conditional on entry), by GPA, parental
# Matches `StatsByXYQ.fracEnter_xyqM`.
# function dm_qual_entry_gpa_yp()
#     target = :fracEnter_gpqM;
#     return DataMoment(target, model_stat(target),  
#         file_name("fracEnterQual", [:gpa, :parental], ".dat"), nothing,  
#         qual_entry_gpa_yp, plot_gpa_yp_qual)
# end

## Fraction by quality, given [gpa, yp]
# Not conditional on entry. As a matrix by [gpa, yp, quality] that matches
# `StatsByXYQ.fracEnter_xyqM`
# function qual_entry_gpa_yp(ds :: DataSettings)
# 	target = :fracEnter_gpqM;
# 	m = load_qual_entry_gpa_yp_all(ds; conditionalOnEntry = false);
# 	n = length(m);

# 	return Deviation{Double}(name = target, dataV = m, modelV = m,
# 		scalarWt = 8.0 ./ n,
# 		shortStr = string(target),
# 		longStr = "Frac quality by [gpa, parental], not conditional",
# 		showPath = "fracEnterQualByGpaYp.txt")
# end


# Load fraction by quality | [gpa, yp]
# Not conditional on entry. As a matrix by [gpa, yp, quality] that matches
# `StatsByXYQ.fracEnter_xyqM`

# how to handle this? +++++++++
function load_qual_entry_gpa_yp_all(ds :: DataSettings;
	conditionalOnEntry :: Bool = false)
	nc = n_colleges(ds);
	fracEnter_xyqM = zeros(Double, n_gpa(ds), n_parental(ds), nc);
	for ic = 1 : nc
		fracEnter_xyqM[:,:,ic] = load_qual_entry_gpa_yp(ds, ic; 
			conditionalOnEntry = conditionalOnEntry);
	end
	if conditionalOnEntry
		# Should sum to 1 across qualities
		qSumM = sum(fracEnter_xyqM, dims = 3);
		check_float_array(qSumM, 0.998, 1.002)
	end
	return fracEnter_xyqM
end


# how to handle this? ++++++++++
# Load fraction by quality | [gpa, yp]. Conditional on entry or not.
function load_qual_entry_gpa_yp(ds :: DataSettings, iCollege;
	conditionalOnEntry :: Bool = false)
	fPath = data_file(raw_qual_entry_gpa_parental(iCollege));
	m = read_by_gpa_yp(ds, fPath);
    @assert all(m .< 1.0)  &&  all(m .>= 0.0)
	@assert size(m) == (n_gpa(ds), n_parental(ds))

	if !conditionalOnEntry
		entryM = load_entry_gpa_yp(ds);
		m .*= entryM;
	end
	return m
end

# ----------------