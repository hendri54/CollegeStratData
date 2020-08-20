## ----------------  Individual files

# AFQT percentile by quality
raw_afqt_pct_qual(ds :: DataSettings; momentType :: Symbol = :mean) =
    RawDataFile(:selfReport, :freshmen, momentType, 
        file_name(ds, "afqt_pctile", :qual), ds);

raw_frac_local_qual(ds :: DataSettings; momentType :: Symbol = :mean) =
    RawDataFile(:transcript, :freshmen, momentType, 
        file_name(ds, "frac_loc_50", [:qual]), ds);

# ----------  By quality / gpa
# Conditional on entry, fraction of students in each [quality, gpa] cell
raw_entry_qual_gpa(ds :: DataSettings; momentType :: Symbol = :mean) =
    RawDataFile(:transcript, :freshmen, momentType, 
        file_name(ds, "jointdist", [:qual, :afqt]), ds);

raw_grad_rate_qual_gpa(ds :: DataSettings; momentType :: Symbol = :mean) = 
    RawDataFile(:transcript, :progress, momentType, 
        file_name(ds, "grad_rate", [:quality, :afqt]), ds);

# Transcript time to drop contains a 0 in one cell
raw_time_to_drop_qual_gpa(ds :: DataSettings; momentType :: Symbol = :mean) = 
    RawDataFile(:transcript, :progress, momentType, 
        file_name(ds, "time_to_drop", [:qual, :afqt]), ds);

raw_time_to_grad_qual_gpa(ds :: DataSettings; momentType :: Symbol = :mean) = 
    RawDataFile(:transcript, :progress, momentType, 
        file_name(ds, "time_to_grad", [:qual, :afqt]), ds);

raw_work_hours_qual_gpa(ds :: DataSettings, year :: Integer; 
    momentType :: Symbol = :mean) = 
    RawDataFile(:selfReport, :finance, momentType, 
        file_name(ds, "hours_y$year", [:qual, :afqt]), ds);

raw_net_price_qual_gpa(ds :: DataSettings, year :: Integer; 
    momentType :: Symbol = :mean) =
    RawDataFile(:transcript, :finance, momentType, 
        file_name(ds, "net_price_y$year", [:qual, :afqt]), ds);

raw_credits_taken_qual_gpa(ds :: DataSettings, year :: Integer;
    momentType :: Symbol = :mean) = 
    RawDataFile(:transcript, :progress, momentType, 
        file_name(ds, "creds_att_y$year", [:qual, :afqt]), ds);

raw_cum_loans_qual_year(ds :: DataSettings, year :: Integer; 
    momentType :: Symbol = :mean) = 
    RawDataFile(:transcript, :finance, momentType, 
        file_name(ds, "cumloans_y$year", [:qual, :afqt]), ds);

# Conditional on entry, fraction of students in each [quality, gpa] cell
raw_mass_entry_qual_gpa(ds :: DataSettings; momentType :: Symbol = :mean) =
    RawDataFile(:transcript, :freshmen, momentType, 
        file_name(ds, "jointdist", [:qual, :afqt]), ds);


# -------  By quality / grad outcome

raw_credits_taken_qual_grad_year(ds :: DataSettings, year :: Integer; 
    momentType :: Symbol = :mean) = 
    RawDataFile(:transcript, :progress, momentType, 
        file_name(ds, "creds_att_y$year", [:qual, :gradDrop]), ds);
            
                
# -----  By quality / parental

raw_work_hours_qual_parental(ds :: DataSettings; momentType :: Symbol = :mean) =
    RawDataFile(:selfReport, :finance, momentType, 
        file_name(ds, "hours_y1", [:quality, :yp]), ds);

# Conditional on entry, fraction of students in each [quality, parental] cell
raw_entry_qual_parental(ds :: DataSettings; momentType :: Symbol = :mean) =
    RawDataFile(:transcript, :freshmen, momentType, 
        file_name(ds, "jointdist", [:qual, :yp]), ds);

raw_frac_grad_qual_parental(ds :: DataSettings; momentType :: Symbol = :mean) =
    RawDataFile(:transcript, :progress, momentType, 
        file_name(ds, "grad_rate", [:qual, :yp]), ds);

raw_time_to_grad_qual_parental(ds :: DataSettings; momentType :: Symbol = :mean) =
    RawDataFile(:transcript, :progress, momentType, 
        file_name(ds, "time_to_grad", [:qual, :yp]), ds);


# ------  by [gpa, parental]
# Data files have this transposed as [parental, gpa]

# Entry rates [gpa, parental], but TRANSPOSED in data files!
raw_entry_gpa_parental(ds :: DataSettings; momentType :: Symbol = :mean) =
    RawDataFile(:transcript, :hsGrads, momentType, 
        file_name(ds, "entrants", [:yp, :afqt]), ds);

# Fraction by quality, by [gpa, parental], TRANSPOSED in data files.
# Conditional on entry.
raw_qual_entry_gpa_parental(ds :: DataSettings, iCollege; 
    momentType :: Symbol = :mean) =
    RawDataFile(:transcript, :freshmen, momentType, 
        file_name(ds, "prob_ent_q$(iCollege)", [:yp, :afqt]), ds);

# Mass of HSG by [parental, hs gpa]
raw_mass_gpa_parental(ds :: DataSettings; momentType :: Symbol = :mean) =
    RawDataFile(:transcript, :hsGrads, momentType, 
        file_name(ds, "jointdist_hsgrads", [:yp, :afqt]), ds);


# -----  Regressions

# Wage regression for graduates with college quality coefficients
# raw_wage_regr_grads(ds :: DataSettings) = 
#     RawDataFile(:selfReport, :none, :regression, "loginc_reg2.dat", ds);

raw_transfer_regr(ds :: DataSettings) = 
    RawDataFile(:transcript, :none, :regression, "parental_transfers1_reg1.dat", ds);

raw_tuition_regr(ds :: DataSettings) = 
    RawDataFile(:transcript, :none, :regression, "net_price1_reg1.dat", ds);


## ---------  Methods

# Mapping from characteristics to directory names
dSelfTranscript = Dict([:selfReport => "SelfReport",  :transcript => "Transcripts"]);

dMomentType = Dict([:mean => "Means",  :count => "Counts", 
    :std => "StandardDeviations", 
	:regression => "Regressions"]);

dGroup = Dict([:finance => "Financing",  :freshmen => "Fresh_Char",
	:hsGrads => "HS_Char",  :progress => "Progress",  :none => ""]);

data_settings(rf :: RawDataFile) = rf.ds;
set_moment_type(rf :: RawDataFile, momentType :: Symbol) = 
    rf.momentType = momentType;


## ---------  Mapping moments to raw data files

"""
    $(SIGNATURES)

Retrieve raw file path from moment name. The optional `momentType` argument allows the user to load counts or std deviations instead of means for moments where those exist.
"""
function raw_file_path(ds :: DataSettings, mName :: Symbol; momentType = nothing)
    if isnothing(momentType)
        rf = raw_file(ds, mName);
    else
        rf = raw_file(ds, mName; momentType = momentType);
    end
    return data_file(rf)
end

# Map moment names into functions that make raw file paths
raw_file_map() = Dict([
    :fracEnroll_qV => raw_entry_qual_parental,
    :fracEnter_gV => raw_entry_gpa_parental,
    :fracEnter_pV => raw_entry_gpa_parental,
    :fracEnter_gpM => raw_entry_gpa_parental,
    :fracGrad => raw_grad_rate_qual_gpa,
    :fracGrad_gV => raw_grad_rate_qual_gpa,
    :fracGrad_qV => raw_grad_rate_qual_gpa,
    :fracGrad_gpM => raw_frac_grad_qual_parental,
    :fracGrad_qgM => raw_grad_rate_qual_gpa,
    :mass_gpM => raw_mass_gpa_parental,
    :massEntry_qgM => raw_mass_entry_qual_gpa,
    :timeToDrop_gV => raw_time_to_drop_qual_gpa,
    :timeToDrop_qV => raw_time_to_drop_qual_gpa,
    :timeToDrop_qgM => raw_time_to_drop_qual_gpa,
    :timeToGrad_qV => raw_time_to_grad_qual_gpa,
    :timeToGrad_gV => raw_time_to_grad_qual_gpa,
    :timeToGrad_ggM => raw_time_to_grad_qual_gpa,
    :timeToGrad_qpM => raw_time_to_grad_qual_parental,
    :workTime_pV => raw_work_hours_qual_parental,
    :workTime_qV => raw_work_hours_qual_parental,
    :workTime_qpM => raw_work_hours_qual_parental
]);

# Make a RawDataFile from a moment name
function raw_file(ds :: DataSettings, mName :: Symbol; momentType = nothing)
    fileMap = raw_file_map();
    rf_fct = fileMap[mName];
    if isnothing(momentType)
        rf = rf_fct(ds);
    else
        rf = rf_fct(ds; momentType = momentType);
    end
    return rf
end

# File with counts for a given data moment
function count_file(ds :: DataSettings, mName :: Symbol)
    rf = raw_file(ds, mName);
    set_moment_type(rf, :count);
    return rf
end

function std_file(ds :: DataSettings, mName :: Symbol)
    rf = raw_file(ds, mName);
    set_moment_type(rf, :std);
    return rf
end
    


## Make a list of missing data files
function missing_file_list(ds)
    missList = Vector{String}();
    # Mapping of moments to files
    rawMap = raw_file_map();
    for mName in keys(rawMap)
        rf = raw_file(ds, mName);
        @assert isa(rf, CollegeStratData.RawDataFile)
        fPath = raw_file_path(ds, mName);
        if !isfile(fPath)
            push!(missList, fPath);
        end
    end
    return missList
end


## --------  Directories


# Raw data dir with characteristics of each moment
# raw_data_dir(rf :: RawDataFile) = 
# 	raw_data_dir(rf.selfOrTranscript, rf.momentType, rf.group);

# function raw_data_dir(ds :: DataSettings, selfReportOrTranscript :: Symbol,  
#     momentType :: Symbol, 	momentGroup :: Symbol)
	
# 	rawPath = joinpath(raw_data_base_dir(ds),  
# 		data_sub_dir(selfReportOrTranscript, momentType, momentGroup));
# 	@assert isdir(rawPath)  "Directory not found: $rawPath"
# 	return rawPath
# end

"""
	$(SIGNATURES)

Path for a raw data file.
"""
data_file(rf :: RawDataFile) =
	joinpath(data_dir(data_settings(rf)), data_sub_dir(rf), file_name(rf));

# Subdir relative to `raw_data_base_dir` or `data_dir`
data_sub_dir(rf :: RawDataFile) =
	data_sub_dir(rf.selfOrTranscript, rf.momentType, rf.group);

data_sub_dir(selfReportOrTranscript :: Symbol,  momentType :: Symbol, 
	momentGroup :: Symbol) =
    joinpath(dSelfTranscript[selfReportOrTranscript],  "dat_files", 
		dMomentType[momentType],  dGroup[momentGroup])

function file_name(rf :: RawDataFile)
    fn = rf.rawFile;
    if rf.momentType == :count
        # `_N` appended to name (why??)
        fn2, fExt = splitext(fn);
        fn = fn2 * "_N" * fExt;
    elseif rf.momentType == :std
        # `_SD` appended to name (why??)
        fn2, fExt = splitext(fn);
        fn = fn2 * "_SD" * fExt;
    end
    return fn
end


# """
#     $(SIGNATURES)

# Copy raw data files from Dropbox to local dir.
# This only needs to be done when data files get updated.
# Not all moments have raw data files. Those are skipped.
# """
# function copy_raw_data_files(ds :: DataSettings; trialRun :: Bool = false)
#     println("\nCopying raw data files to local dir");
#     srcDir = raw_data_base_dir(ds);
#     tgDir = data_dir(ds);
#     rsync_dir(srcDir, tgDir;  trialRun = trialRun,  doDelete = false);
# end

# ---------------