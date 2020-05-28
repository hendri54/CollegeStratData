
# This cannot hang off CollegeStratData b/c that directory may not be available on the server.
# @noinline base_dir() = normpath(joinpath(@__DIR__,  "..", ".."));

base_dir() = joinpath(homedir(), "Documents", "projects", 
	# "p2019", "college_stratification");


project_dir() = joinpath(base_dir(), "CollegeStratData");

# Data files are stored here
# Subdirs are the same as for raw data files
function data_dir(ds :: DataSettings)
    return joinpath(base_dir(), data_sub_dir(ds))
end

# function data_sub_dir(ds :: DataSettings)
# 	if name(ds) == :default  ||  name(ds) == :test
# 		d = "data";
# 	else
# 		error("Invalid: $ds");
# 	end
# 	return d
# end


## ---------------  Regression files

"""
	$(SIGNATURES)

Read file with regression
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
function read_regression_file(fPath :: String)
    @assert isfile(fPath)  "File not found: $fPath"
    csvFile = CSV.File(fPath, header = true,  delim = '\t', comment = commentStr);
	df = (csvFile |> DataFrame!);

	cStat = 1;
	iCoeff = 1;
	@assert df[iCoeff, cStat] == "coeff"
	# This is a DataFrameRow
	coeffV = df[iCoeff, 2:end];

	iSe = 2
	@assert df[iSe, cStat] == "se"
	seV = df[iSe, 2:end];

	nameV = propertynames(df)[2 : end];
	rt = RegressionTable(nameV, Vector{Float64}(coeffV), Vector{Float64}(seV));
	return rt
end


# function read_regression_file(dm :: DataMoment)
# 	return read_regression_file(data_file(dm))
# end

# function read_regression_file(target :: Symbol)
#     fPath = data_file(target);
# 	return read_regression_file(fPath)
# end


## ----------  Row headers
# are simply 1:n or ALL

row_header(j :: Integer) = "$j";
all_row_header() = "All";


## ----------  Column Headers

# all_col_header(dxy :: DelimXyFile) = all_col_header(dxy.colCat);

function all_col_header(colCat :: Symbol)
    if colCat == :gpa
        hd = all_col_header_gpa();
    else
        error("Not implemented: $colCat")
    end
    return hd
end

all_col_header_gpa() = :afqt_quartileALL;

function col_header(colCat :: Symbol, j :: Integer)
    if colCat == :gpa
        hd = Symbol("afqt_quartile$j");
    elseif colCat == :parental
        hd = Symbol("inc_quartile$j");
    else
        error("Invalid: $colCat")
    end
    return hd
end

col_headers(colCat :: Symbol, idxV) = [col_header(colCat, j) for j in idxV];
col_headers(ds :: DataSettings, colCat :: Symbol) = col_headers(colCat, 1 : n_cat(ds, colCat));

function n_cat(ds :: DataSettings, colCat :: Symbol)
    if colCat == :gpa
        nCat = n_gpa(ds);
    else
        error("Invalid $colCat");
    end
    return nCat
end



## --------------------  Delimited moment files


# """
# 	$(SIGNATURES)

# Read delimited file into a DataFrame.
# """
# function read_delim_file_to_df(target :: Symbol)
# 	return read_delim_file_to_df(data_file(target));
# end

function read_delim_file_to_df(fPath :: String)
	@assert isfile(fPath)  "File not found: $fPath"
	csvFile = CSV.File(fPath, header = true,  delim = '\t', comment = commentStr);
	df = (csvFile |> DataFrame!);
	return df
end


# Read the 
# read_all_from_delim_file(target :: Symbol) = 
# 	read_all_from_delim_file(data_file(target));

function read_all_from_delim_file(fPath :: String)
	df = read_delim_file_to_df(fPath);
	r = select_all_row(df);
	c = select_all_column(df);
	x = df[r, c];
	@assert check_float(x)
	return x
end


"""
	$(SIGNATURES)

Extract "All" row as vector from a DataFrame.
"""
function all_row_to_vector(df :: DataFrame, colV)
	allRow = select_all_row(df);
	df2 = df[allRow, colV];
	m = convert(Vector{Double},  df2);
	return m
end


function select_all_column(df)
	allCol = findfirst(propertynames(df) .== all_col_header_gpa());
	@assert allCol > 0  "Must be extended to other column headers"
	return allCol
end


function select_all_row(df)
	allRow = findfirst(df[:,1] .== all_row_header());
	@assert allRow > 0
	return allRow
end


# Indices of all rows with categories (based on values of first column), which are expected to have headers of the form `row_header(j)`.
# Returns a `Vector{Bool}` with true/false for each row.
function select_rows(df :: DataFrame, idxV = nothing)
	if isnothing(idxV)
		rIdxV = 1 : size(df, 1);
	else
		rIdxV = idxV;
	end
	rowV = map(x -> x ∈ row_header.(rIdxV),  df[!, 1]);
	return rowV
end


# --------------
