# By graduation outcome, year

# Credits attempted by [grad status, year]
# Not cumulative
function courses_tried_grad_year(ds :: DataSettings)
    T = ds.Tmax;
    nr = 2;
    outM = zeros(nr, T);
    sesM = zeros(nr, T);
    cntM = zeros(Int, nr, T);
    for t = 1 : T
        outM[:, t], sesM[:,t], cntM[:,t] = courses_tried_grad(ds, t);
    end

    return outM, sesM, cntM
end

# The same for one year
function courses_tried_grad(ds :: DataSettings,  t :: Integer)
    load_fct = 
        mt -> read_col_totals(raw_credits_taken_qual_grad_year(ds, t; 
            momentType = mt));
    m, ses, cnts = mean_from_xy(load_fct);
    m = credits_to_courses(ds, m);
    ses = credits_to_courses(ds, ses);

    # Temporary fix: data files have too many columns +++++
    if (length(m) == 4)  ||  (length(ses) == 4)
        m = m[1 : 2];
        ses = ses[1 : 2];
        cnts = cnts[1 : 2];
    end
    @assert length(m) == 2  "Invalid $m"
    @assert length(ses) == 2  "Invalid $ses"
    @assert length(cnts) == 2  "Invalid $cnts"

    return m, ses, cnts
end


# -------------