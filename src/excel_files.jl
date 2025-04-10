export open_excel_data_file, excel_data_path;

"""
	$(SIGNATURES)

Open Excel data file.
"""  
function open_excel_data_file(ds :: DataSettings, trOrSelfReport)
    fPath = excel_data_path(ds, trOrSelfReport);
    @argcheck isfile(fPath)  "Not found: $fPath";
    run(`open $fPath`);
end

function excel_data_path(ds :: DataSettings, trOrSelfReport)
    subDir = sub_dir(trOrSelfReport);
    if trOrSelfReport == Transcript()
        suffix = "transcripts";
    elseif trOrSelfReport == SelfReport()
        suffix = "selfreport";
    else
        error("Invalid");
    end
    joinpath(DataCollegeStrat.data_dir(), data_sub_dir(ds), subDir, 
        "results97_afqt_$suffix.xlsx");
end


# -----------------------