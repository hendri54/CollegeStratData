# Given choice probs and cell counts, compute std error of the mean choice probs.
# This is correct when each cell contains the prob of choosing `1` given that cell.
# Also correct when each cell contains `Prob(j | k)` and counts are `n(k)`. I.e., a multinomial choice.
# test this +++++
function ses_from_choice_probs(probs, cnts)
    @assert all(0.0 .<= probs .<= 1.0)
    ses = (probs .* (1.0 .- probs) ./ (max.(1.0, cnts)) .^ 0.5);
    return ses
end


# Given a function that loads moments by (x,y), compute cell mean, its std error, and cell counts. Each cell contains the fraction that chooses "yes".
# test this +++++
function choice_prob_from_xy(load_fct)
	m = load_fct(MtMean());
	cnts = load_fct(MtCount());
	ses = ses_from_choice_probs(m, cnts);
    cnts = clean_cnts(cnts);
	@assert all(m .<= 1.0)  &&  all(m .>= 0.0)
    return m, ses, cnts
end

function clean_cnts(cnts :: AbstractArray{F1}) where F1 <: Number
    @assert check_cnts(cnts);
    if (F1 isa Integer)
        cntsOut = copy(cnts);
    else
        cntsOut = round.(Int, cnts);
        @assert check_cnts(cnts);
    end
    return cntsOut
end

function clean_cnts(cnts :: Number)
    @check 0 <= cnts <= 20_000;
    return round(Int, cnts)
end

function check_cnts(cnts :: AbstractArray{F1}) where F1 <: Number
    isValid = true;
    if !all_at_least(cnts, 0)
        @warn "Negative counts";
        isValid = false;
    end
    if !all_at_most(cnts, 20_000)
        @warn "Counts too high";
        isValid = false;
    end
    if !isValid
        @warn """
            Invalid cnts
            $cnts
            """;
    end
    return isValid
end

# Process a moment that is a choice prob from a column total
# function choice_prob_from_col_total(ds, target)
#     m = read_col_totals(raw_file_path(ds, target));
#     @assert all(m .>= 0.0)  &&  all(m .<= 1.0)

#     cnts = read_col_totals(raw_file_path(ds, target; momentType = MtCount()));
#     ses = ses_from_choice_probs(m, cnts);
#     cnts = round.(Int, cnts);
#     return m, ses, cnts
# end

# function choice_prob_from_row_total(ds, target)
#     m = read_row_totals(raw_file_path(ds, target));
#     @assert all(m .>= 0.0)  &&  all(m .<= 1.0)

#     cnts = read_row_totals(raw_file_path(ds, target; momentType = MtCount()));
#     ses = ses_from_choice_probs(m, cnts);
#     cnts = round.(Int, cnts);
#     return m, ses, cnts
# end

# function choice_prob_xy(ds, target)
# 	@assert all(m .< 1.0)  &&  all(m .> 0.0)
# end


"""
	$(SIGNATURES)

Given a function that loads a moment (could be a matrix or vector) (load_fct):

* load mean, std devs, counts
* make sure counts are Int
* compute SES as std deviation of means

test this +++++
"""
function load_mean_ses_counts(load_fct)
    m = load_fct(MtMean());
    cnts = load_fct(MtCount());
    stdV = load_fct(MtStd());
    ses = std_dev_of_means(stdV, cnts);
    cnts = clean_cnts(cnts);
    return m, ses, cnts
end


# Computes std error from std deviations and counts
# As std error of mean: std dev / sqrt(n)
std_dev_of_means(stdV, cnts) = stdV ./ (max.(cnts, 1) .^ 0.5);


## ------------  Other

"""
	$(SIGNATURES)

Convert a `csv` file to a matrix.
"""
function csv_to_matrix(csvFile)
    return Matrix{Float64}(csvFile |> DataFrame)
end


# Sub-dir for test files, relative to `test`
test_sub_dir() = "test_files";

# -------------------