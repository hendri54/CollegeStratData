

## ----------  Row headers
# are simply 1:n or ALL

raw_data_row_header(j :: Integer) = "$j";


## ----------  Column Headers in cross-tab files
# Regression files have different headers.
# This determines what is read from disk. Output cross-tabs do not have headers.

# function all_col_header(colCat :: Symbol)
#     if colCat == :gpa
#         hd = all_col_header_gpa();
#     else
#         error("Not implemented: $colCat")
#     end
#     return hd
# end


# This does NOT apply to regression files!
function raw_col_header(colCat :: Symbol, j :: Integer)
    if colCat == :gpa
        hd = Symbol("afqt_quartile$j");
    elseif colCat == :parental
        hd = Symbol("inc_quartile$j");
    else
        error("Invalid: $colCat")
    end
    return hd
end

raw_col_headers(colCat :: Symbol, idxV) = [raw_col_header(colCat, j) for j in idxV];
raw_col_headers(ds :: DataSettings, colCat :: Symbol) = 
	raw_col_headers(colCat, 1 : n_cat(ds, colCat));

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
	df = (csvFile |> DataFrame);
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
	if isa(x, AbstractFloat)
		@assert check_float(x)
	else
		@assert isa(x, Integer)
	end
	return x
end

read_all_from_delim_file(rf :: RawDataFile) = 
	read_all_from_delim_file(data_file(rf));


"""
	$(SIGNATURES)

Extract "All" row as vector from a DataFrame.
"""
function all_row_to_vector(df :: DataFrame, colV)
	allRow = select_all_row(df);
	df2 = df[allRow, colV];
	m = Vector{Double}(df2);
	return m
end


function select_all_column(df)
	allCol = findfirst(propertynames(df) .== Symbol(AllColHeaderGpa));
	@assert allCol > 0  "Must be extended to other column headers";
	return allCol
end


function select_all_row(df)
	allRow = findfirst(df[:,1] .== string(AllRowHeader));
	@assert allRow > 0
	return allRow
end


# Indices of all rows with categories (based on values of first column), which are expected to have headers of the form `raw_data_row_header(j)`.
# Returns a `Vector{Bool}` with true/false for each row.
function select_rows(df :: DataFrame, idxV = nothing)
	if isnothing(idxV)
		rIdxV = 1 : size(df, 1);
	else
		rIdxV = idxV;
	end
	rowV = map(x -> x ∈ raw_data_row_header.(rIdxV),  df[!, 1]);
	return rowV
end


# --------------
