# Given choice probs and cell counts, compute std error of the mean choice probs.
# This is correct when each cell contains the prob of choosing `1` given that cell.
# Also correct when each cell contains `Prob(j | k)` and counts are `n(k)`. I.e., a multinomial choice.
# test this +++++
function ses_from_choice_probs(probs, cnts)
    @assert all(0.0 .<= probs .<= 1.0)
    ses = (probs .* (1.0 .- probs) ./ max.(1.0, cnts)) .^ 0.5;
    return ses
end


# Given a function that loads moments by (x,y), compute cell mean, its std error, and cell counts. Each cell contains the fraction that chooses "yes".
# test this +++++
function choice_prob_from_xy(load_fct)
	m = load_fct(:mean);
	cnts = load_fct(:count);
	ses = ses_from_choice_probs(m, cnts);
	cnts = round.(Int, cnts);
	@assert all(m .<= 1.0)  &&  all(m .>= 0.0)
    return m, ses, cnts
end

# Process a moment that is a choice prob from a column total
# function choice_prob_from_col_total(ds, target)
#     m = read_col_totals(raw_file_path(ds, target));
#     @assert all(m .>= 0.0)  &&  all(m .<= 1.0)

#     cnts = read_col_totals(raw_file_path(ds, target; momentType = :count));
#     ses = ses_from_choice_probs(m, cnts);
#     cnts = round.(Int, cnts);
#     return m, ses, cnts
# end

# function choice_prob_from_row_total(ds, target)
#     m = read_row_totals(raw_file_path(ds, target));
#     @assert all(m .>= 0.0)  &&  all(m .<= 1.0)

#     cnts = read_row_totals(raw_file_path(ds, target; momentType = :count));
#     ses = ses_from_choice_probs(m, cnts);
#     cnts = round.(Int, cnts);
#     return m, ses, cnts
# end

# function choice_prob_xy(ds, target)
# 	@assert all(m .< 1.0)  &&  all(m .> 0.0)
# end

# Compute cell mean and its std error, given a function that loads data by (x,y).
# Or by x as a vector.
# test this +++++
function mean_from_xy(load_fct)
    m = load_fct(:mean);
    cnts = load_fct(:count);
    stdV = load_fct(:std);
    ses = stdV ./ (max.(cnts, 1.0) .^ 0.5);
    cnts = round.(Int, cnts);
    return m, ses, cnts
end

# function mean_from_col_total(ds :: DataSettings, target :: Symbol)
#     m = read_col_totals(raw_file_path(ds, target));
#     cnts = read_col_totals(raw_file_path(ds, target; momentType = :count));
#     stdV = read_col_totals(raw_file_path(ds, target; momentType = :std));
#     ses = stdV ./ (max.(cnts, 1.0) .^ 0.5);
#     cnts = round.(Int, cnts);
#     return m, ses, cnts
# end

# This version takes as input a function that generates a raw file path
# This is useful when the load function takes additional args, such as dates.
# function mean_from_row_total(load_fct)
#     m = read_row_totals(load_fct(:mean));
#     cnts = read_row_totals(load_fct(:count));
#     stdV = read_row_totals(load_fct(:std));
#     @assert size(m) == size(cnts) == size(stdV)
#     ses = stdV ./ (max.(cnts, 1.0) .^ 0.5);
#     cnts = round.(Int, cnts);
#     return m, ses, cnts
# end

# function mean_from_row_total(ds :: DataSettings, target :: Symbol)
#     m = read_row_totals(raw_file_path(ds, target));
#     cnts = read_row_totals(raw_file_path(ds, target; momentType = :count));
#     stdV = read_row_totals(raw_file_path(ds, target; momentType = :std));
#     ses = stdV ./ (max.(cnts, 1.0) .^ 0.5);
#     cnts = round.(Int, cnts);
#     return m, ses, cnts
# end


## -------------  Regressions


## ------------  Other

"""
	$(SIGNATURES)

Convert a `csv` file to a matrix.
"""
function csv_to_matrix(csvFile)
    return convert(Matrix{Float64}, csvFile |> DataFrame!)
end


# Sub-dir for test files, relative to `test`
test_sub_dir() = "test_files";

# -------------------