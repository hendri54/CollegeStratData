# Map moment names into functions that make raw file paths
raw_file_map() = Dict([
    # :fracDrop_qtM => raw_frac_drop_qual_gpa,
    :collEarn_qpM => raw_college_earnings_qual_parental,
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
    :timeToDrop4y_gV => raw_time_to_drop_4y_qual_gpa,
    :timeToDrop4y_qV => raw_time_to_drop_4y_qual_gpa,
    :timeToDrop4y_qgM => raw_time_to_drop_4y_qual_gpa,
    :timeToGrad4y_qV => raw_time_to_grad_4y_qual_gpa,
    :timeToGrad4y_gV => raw_time_to_grad_4y_qual_gpa,
    :timeToGrad4y_pV => raw_time_to_grad_4y_qual_parental,
    :timeToGrad4y_qgM => raw_time_to_grad_4y_qual_gpa,
    :timeToGrad4y_qpM => raw_time_to_grad_4y_qual_parental,
    # :transfer_qgM => raw_transfers_qual_gpa,
    :workTime_pV => raw_work_hours_qual_parental,
    :workTime_qV => raw_work_hours_qual_parental,
    :workTime_qpM => raw_work_hours_qual_parental
]);




## ---------  Methods

# Mapping from characteristics to directory names
# dSelfTranscript = Dict([SelfReport() => "SelfReport",  Transcript() => "Transcripts"]);



data_settings(rf :: RawDataFile) = rf.ds;
set_moment_type(rf :: RawDataFile, momentType) = 
    rf.momentType = momentType;


## ---------  Mapping moments to raw data files

"""
    $(SIGNATURES)

Retrieve raw file path from moment name. The optional `momentType` argument allows the user to load counts or std deviations instead of means for moments where those exist.
"""
function raw_file_path(ds :: DataSettings, mName :: Symbol; momentType = nothing)
    rf = raw_file(ds, mName; momentType);
    return data_file(rf)
end


# Make a RawDataFile from a moment name
function raw_file(ds :: DataSettings, mName :: Symbol; momentType = nothing)
    fileMap = raw_file_map();
    rf_fct = fileMap[mName];
    rf = rf_fct(ds; momentType = momentType);
    return rf
end

# File with counts for a given data moment
function count_file(ds :: DataSettings, mName :: Symbol)
    rf = raw_file(ds, mName);
    set_moment_type(rf, MtCount());
    return rf
end

function std_file(ds :: DataSettings, mName :: Symbol)
    rf = raw_file(ds, mName);
    set_moment_type(rf, MtStd());
    return rf
end
    

"""
	$(SIGNATURES)

Make a list of missing data files. Returns a String vector.
Only handles files in `raw_file_map`.
This is not perfect. It only checks for files containing means (not counts or std deviations). But useful for spotting that files have been unexpectedly renamed.
"""
function missing_file_list(ds)
    missList = Vector{String}();
    # Mapping of moments to files
    rawMap = raw_file_map();
    for mName in keys(rawMap)
        rf = raw_file(ds, mName; momentType = MtMean());
        @assert isa(rf, CollegeStratData.RawDataFile)
        fPath = raw_file_path(ds, mName; momentType = MtMean());
        if !isfile(fPath)
            push!(missList, fPath);
        end
    end
    return missList
end


"""
	$(SIGNATURES)

Generate a list of files that differ (in name only) between existing data (as stored in `DataCollegeStrat` somewhere in `.julia`) and new data (in `Dropbox`).
This should be run before importing the new data files.

Excludes files that refer to public or private colleges.
"""
function file_name_differences(ds :: DataSettings)
    newDir = dropbox_dir(ds);
    @assert isdir(newDir);

    fName = "file_name_differences.txt";
    logFn = joinpath(out_dir(ds), fName);
    open(logFn, "w") do io
        println(io, "\nFile name differences for $ds:");
        println(io, "  Comparing existing data dir with new data in Dropbox.");
        println(io, "  Old:  $(data_dir(ds))");
        println(io, "  New:  $newDir");
        dir_diff_report(data_dir(ds), newDir; io = io,
            exclude = ["_PRI", "_PUB"]);  # add io argument
    end

    # Mirror on screen
    for line in eachline(logFn)
        println(line);
    end
    println("Results written to $logFn");
    return nothing
end

# Base dir for new data files in dropbox. Only used for checking new files before import.
dropbox_base_dir() = "/Users/lutz/Dropbox/Dropout Policies/Data/empiricaltargets";

dropbox_dir(ds :: DataSettings) = joinpath(dropbox_base_dir(), data_sub_dir(ds));


"""
	$(SIGNATURES)

Compare all `dat` files in existing data directory with the corresponding `Dropbox` directory. Useful before new data files are imported.
"""
function compare_dirs(ds :: DataSettings)
    fName = "compare_dirs.txt";
    logFn = joinpath(out_dir(ds), fName);
    open(logFn, "w") do io
        compare_dirs(data_dir(ds), dropbox_dir(ds); io = io);
    end

    # Mirror on screen
    for line in eachline(logFn)
        println(line);
    end
    println("Results written to $logFn");
end


"""
	$(SIGNATURES)

Compare all `dat` files for two base directories. Report files where headers do not match. Useful for checking new data files before importing.
"""
function compare_dirs(dir1 :: AbstractString, dir2 :: AbstractString; 
    io = stdout)

    @assert isdir(dir1)
    @assert isdir(dir2)
    fList = files_in_dir(dir1);
    if isempty(fList)
        println(io, "Empty directory");
        return nothing
    end

    allValid = true;
    for f ∈ fList
        _, fExt = splitext(f);
        if fExt ∈ (".dat", )
            newFile = joinpath(dir2, f);
            if !isfile(newFile)
                println(io, "Not found: $newFile");
            else
                isValid = compare_delim_files(joinpath(dir1, f), newFile; io = io);
                if !isValid
                    allValid = false;
                    println(io, "  in $f");
                end
            end
        end
    end
    return allValid
end


"""
	$(SIGNATURES)

Compare two delimited files. Report discrepancies in headers and dimensions.
Useful for checking new data files before importing.
Tries to never error. Just report.
"""
function compare_delim_files(fn1, fn2; io = stdout)
    isValid = true;
    if !isfile(fn1)
        println(io, "Not found: $fn1");
        isValid = false;
    elseif !isfile(fn2)
        println(io, "Not found: $fn2");
        isValid = false;
    end
    if isValid
        m1 = readdlm(fn1);
        m2 = readdlm(fn2);
        if !isequal(m1[1,:], m2[1,:])
            println(io, "Col header mismatch");
            println(io, "    Old: ", m1[1,:]);
            println(io, "    New: ", m2[1,:]);
            isValid = false;
        elseif !isequal(m1[:,1], m2[:, 1])
            println(io, "Row header mismatch");
            isValid = false;
        end
    end
    return isValid
end


## --------  Directories


# Raw data dir with characteristics of each moment
# raw_data_dir(rf :: RawDataFile) = 
# 	raw_data_dir(rf.selfOrTranscript, rf.momentType, rf.group);

# function raw_data_dir(ds :: DataSettings, selfReportOrTranscript :: Symbol,  
#     momentType, 	momentGroup :: Symbol)
	
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

function data_sub_dir(selfReportOrTranscript :: AbstractSelfOrTranscript,  
        momentType, momentGroup :: AbstractGroup)
    return joinpath(sub_dir(selfReportOrTranscript),  "dat_files", 
		sub_dir(momentType),  sub_dir(momentGroup))
end

function file_name(rf :: RawDataFile)
    fn = rf.rawFile;
    if rf.momentType == MtCount()
        # `_N` appended to name (why??)
        fn2, fExt = splitext(fn);
        fn = fn2 * "_N" * fExt;
    elseif rf.momentType == MtStd()
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