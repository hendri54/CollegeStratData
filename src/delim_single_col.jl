# Delimited files with a single column

Base.length(d :: DataFrameX) = size(d.df, 1);
row_indices(d :: DataFrameX) = 1 : (length(d) - 1);
# This is where the actual data are expected
col_index(d :: DataFrameX) = 2;
data_vector(d :: DataFrameX) = 
    Vector{Double}(d.df[row_indices(d), col_index(d)]);


## -------------  Read delimited file

function read_by_x(fPath :: AbstractString)
    df = read_delim_file_to_df(fPath);
    # No of rows does not include header
    nr, nc = size(df);
    @check nc == 2
    @check nr > 3
    return DataFrameX(df);
end

read_vector_by_x(fPath) = data_vector(read_by_x(fPath));

# ----------------------