## ----------------  Individual files

# AFQT percentile by quality
raw_afqt_pct_qual(ds :: DataSettings) =
    RawDataFile(:selfReport, :freshmen, :mean, "pctile_afqt.dat", ds);

# By quality / gpa
# Conditional on entry, fraction of students in each [quality, gpa] cell
raw_entry_qual_gpa(ds :: DataSettings) =
    RawDataFile(:transcript, :freshmen, :mean, "jointdist_qual_afqt.dat", ds);
raw_grad_rate_qual_gpa(ds :: DataSettings) = 
    RawDataFile(:transcript, :progress, :mean, "grad_rate.dat", ds);
# Transcript time to drop contains a 0 in one cell
raw_time_to_drop_qual_gpa(ds :: DataSettings) = 
    RawDataFile(:transcript, :progress, :mean, "time_to_drop.dat", ds);
raw_time_to_grad_qual_gpa(ds :: DataSettings) = 
    RawDataFile(:transcript, :progress, :mean, "time_to_grad.dat", ds);
raw_work_hours_qual_gpa(ds :: DataSettings, year :: Integer) = 
    RawDataFile(:selfReport, :finance, :mean, "hours$year.dat", ds)
raw_net_price_qual_gpa(ds :: DataSettings, year :: Integer) =
    RawDataFile(:transcript, :finance, :mean, "net_price$year.dat", ds);
raw_credits_taken_qual_gpa(ds :: DataSettings, year :: Integer) = 
    RawDataFile(:transcript, :progress, :mean, "creds_att$year.dat", ds);

# -----  By quality / parental

raw_work_hours_qual_parental(ds :: DataSettings) =
    RawDataFile(:selfReport, :finance, :mean, "hours_byfaminc1.dat", ds);
# Conditional on entry, fraction of students in each [quality, parental] cell
raw_entry_qual_parental(ds :: DataSettings) =
    RawDataFile(:transcript, :freshmen, :mean, "jointdist_qual_inc.dat", ds);
raw_frac_grad_qual_parental(ds :: DataSettings) =
    RawDataFile(:transcript, :progress, :mean, "grad_rate_inc.dat", ds);
raw_time_to_grad_qual_parental(ds :: DataSettings) =
    RawDataFile(:transcript, :progress, :mean, "time_to_grad_inc.dat", ds);


# ------  by [gpa, parental]
# Data files have this transposed as [parental, gpa]

# Entry rates [gpa, parental], but TRANSPOSED in data files!
raw_entry_gpa_parental(ds :: DataSettings) =
    RawDataFile(:transcript, :hsGrads, :mean, "entrants.dat", ds);
# Fraction by quality, by [gpa, parental], TRANSPOSED in data files.
# Conditional on entry.
raw_qual_entry_gpa_parental(ds :: DataSettings, iCollege) =
    RawDataFile(:transcript, :freshmen, :mean, "prob_ent_$(iCollege).dat", ds);
# Mass of HSG by [parental, hs gpa]
raw_mass_gpa_parental(ds :: DataSettings) =
    RawDataFile(:transcript, :hsGrads, :mean, "jointdist_inc_afqt_hsgrads.dat", ds);

raw_cum_loans_qual_year(ds :: DataSettings, year :: Integer) = 
    RawDataFile(:transcript, :finance, :mean, "cumloans$year.dat", ds);

# Conditional on entry, fraction of students in each [quality, gpa] cell
raw_mass_entry_qual_gpa(ds :: DataSettings) =
    RawDataFile(:transcript, :freshmen, :mean, "jointdist_qual_afqt.dat", ds);


# -----  Regressions

# Wage regressions pooling school groups. Self reports only.
raw_wage_regr(ds :: DataSettings) = 
    RawDataFile(:selfReport, :none, :regression, "loginc_reg3.dat", ds);

# Wage regression for graduates with college quality coefficients
raw_wage_regr_grads(ds :: DataSettings) = 
    RawDataFile(:selfReport, :none, :regression, "loginc_reg2.dat", ds);

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
function raw_file_path(ds :: DataSettings, mName :: Symbol)
    return data_file(raw_file(ds, mName));
end

# Map moment names into functions that make raw file paths
raw_file_map() = Dict([
    :fracEnter_gV => raw_entry_gpa_parental,
    :fracEnter_pV => raw_entry_gpa_parental,
    :fracEnter_gpM => raw_entry_gpa_parental,
    :fracGrad_gV => raw_grad_rate_qual_gpa,
    :fracGrad_gpM => raw_frac_grad_qual_parental,
    :fracGrad_qgM => raw_grad_rate_qual_gpa,
    :mass_gpM => raw_mass_gpa_parental,
    :massEntry_qgM => raw_mass_entry_qual_gpa,
    :timeToDrop_gV => raw_time_to_drop_qual_gpa,
    :timeToDrop_qgM => raw_time_to_drop_qual_gpa,
    :timeToGrad_qV => raw_time_to_grad_qual_gpa,
    :timeToGrad_gV => raw_time_to_grad_qual_gpa,
    :timeToGrad_ggM => raw_time_to_grad_qual_gpa,
    :timeToGrad_qpM => raw_time_to_grad_qual_parental,
    :workTime_pV => raw_work_hours_qual_parental,
    :workTime_qpM => raw_work_hours_qual_parental
]);

# Make a RawDataFile from a moment name
function raw_file(ds :: DataSettings, mName :: Symbol)
    fileMap = raw_file_map();
    rf = fileMap[mName](ds);
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


"""
    $(SIGNATURES)

Copy raw data files from Dropbox to local dir.
This only needs to be done when data files get updated.
Not all moments have raw data files. Those are skipped.
"""
function copy_raw_data_files(ds :: DataSettings; trialRun :: Bool = false)
    println("\nCopying raw data files to local dir");
    srcDir = raw_data_base_dir(ds);
    tgDir = data_dir(ds);
    rsync_dir(srcDir, tgDir;  trialRun = trialRun,  doDelete = false);
end

# ---------------