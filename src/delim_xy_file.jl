# Delimited data files by x,y

## ----------  DataFrames by (x,y) as read from delimited files

Base.size(d :: DataFrameXY) = Base.size(d.df);
Base.size(d :: DataFrameXY, dims) = Base.size(d.df, dims);

# This is where the actual data by (x,y) are stored
row_indices(d :: DataFrameXY) = 1 : (size(d,1) - 1);
col_indices(d :: DataFrameXY) = 2 : (size(d,2) - 1);
col_headers(d :: DataFrameXY) = propertynames(d.df)[col_indices(d)];
row_headers(d :: DataFrameXY) = d.df[row_indices(d), 1];
data_matrix(d :: DataFrameXY) = 
    convert(Matrix{Double}, d.df[row_indices(d), col_indices(d)]);

total(d :: DataFrameXY) = d.df[end, end];

# Column totals = last row of DataFrame
col_totals(d :: DataFrameXY) = convert(Vector{Double}, d.df[end, col_indices(d)]);
# Row totals = last column of DataFrame
row_totals(d :: DataFrameXY) = d.df[row_indices(d), end];


# """
# 	$(SIGNATURES)

# Delimited file by categories x and y.
# Categories are `:gpa`, `:quality`.
# """
# @with_kw struct DelimXyFile
#     fPath :: String
#     year :: Integer = 1
#     rowCat :: Symbol
#     colCat :: Symbol
# end



## -----------  Read file into Matrix

# make general read function; use it for reading files with specific row /col categories


"""
	$(SIGNATURES)

Read a delimited file with rows of category `xCat` and columns of category `yCat`.
Assumes that column 1 gives x categories (1 : n). Last column gives totals.
Last row gives totals.
Grand total is in last row / column 1.
"""
function read_by_xy(fPath :: AbstractString)
    df = read_delim_file_to_df(fPath);
    # No of rows does not include header
    nr, nc = size(df);
    @check nc > 3
    @check nr > 3
    return DataFrameXY(df);
end

read_by_xy(rf :: RawDataFile) = read_by_xy(data_file(rf));
read_matrix_by_xy(fPath :: AbstractString) = data_matrix(read_by_xy(fPath));
read_matrix_by_xy(rf :: RawDataFile) = read_matrix_by_xy(data_file(rf));

"""
	$(SIGNATURES)

Read a file by [x, y]. Return the y totals.
"""
read_col_totals(fPath :: AbstractString) = col_totals(read_by_xy(fPath));
read_col_totals(rf :: RawDataFile) = read_col_totals(data_file(rf));

"""
	$(SIGNATURES)

Read a file by [x, y]. Return the x totals.
"""
read_row_totals(fPath :: AbstractString) = row_totals(read_by_xy(fPath));
read_row_totals(rf :: RawDataFile) = read_row_totals(data_file(rf));

"""
	$(SIGNATURES)

Read a file by [x, y]. Return the grand total cell (bottom right).
"""
read_total(fPath :: AbstractString) = total(read_by_xy(fPath));
read_total(rf :: RawDataFile) = read_total(data_file(rf));


# ------------