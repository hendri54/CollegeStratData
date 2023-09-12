# ------------ Fixed effects (wages)

"""
By [school, grpVar]. If no grouping, just by school.
Zeros for missing values (such as CGs from 2y colleges).
"""
function wage_fixed_effects(ds :: DataSettings, grpVar)
    sizeV = (length(EdLevels), n_groups(ds, grpVar));
    m = zeros(sizeV);
    ses = zeros(sizeV);
    cnts = zeros(Int, sizeV);
    for (iEd, edLevel) in enumerate(EdLevels)
        mEd, sesEd, cntsEd = 
            load_wage_fixed_effects(ds, edLevel, grpVar);
        if !isnothing(mEd)
            m[iEd, :] .= mEd;
            ses[iEd, :] .= sesEd;
            cnts[iEd, :] .= cntsEd;
        end
    end
    if sizeV[2] == 1
        m = vec(m);
        ses = vec(ses);
        cnts = vec(cnts);
    end
    return m, ses, cnts
end


"""
For one school level.
"""
function load_wage_fixed_effects(ds :: DataSettings, edLevel, grpVar;
        minCnts = 30)
    if edLevel == SchoolHSG
        return load_wage_fixed_effects_hsg(ds, grpVar);
    end

    fPath(mt) = wage_fixed_effects_fn(ds, edLevel; momentType = mt);
    if grpVar isa ClassHsGpa
        # In a branch, need unique fct names.
        load_fct_gpa(mt) = read_row_totals(fPath(mt));
        m, ses, cnts = load_mean_ses_counts(load_fct_gpa);
        @assert length(m) == n_gpa(ds);
    elseif grpVar isa ClassQuality
        load_fct_qual(mt) = read_col_totals(fPath(mt));
        m, ses, cnts = load_mean_ses_counts(load_fct_qual);
        @assert length(m) == n_colleges(ds);
    elseif grpVar isa ClassAll
        load_fct_all(mt) = read_total(fPath(mt));
        m, ses, cnts = load_mean_ses_counts(load_fct_all);
    elseif grpVar == [ClassQuality(), ClassHsGpa()]
        # Note that no of obs is very small for SC and top quality
        load_fct_2(mt) = Matrix(transpose(read_matrix_by_xy(fPath(mt))));
        m, ses, cnts = load_mean_ses_counts(load_fct_2);
    else
        error("Invalid $grpVar");
    end
    # There are 0 values for CGs
    @assert (all((m .> 7.0)  .|  (m .== 0.0))  &&  all(m .< 12.0))  "Out of bounds: \n $m";
    @assert all((cnts .>= minCnts) .| (cnts .== 0))  "Low counts: $cnts";
    return m, ses, cnts
end

"""
HSGs require a separate load fct. The file structure is very different.
"""
function load_wage_fixed_effects_hsg(ds :: DataSettings, grpVar)
    fn = wage_fixed_effects_fn(ds, SchoolHSG);
    df = read_delim_file_to_df(fn);
    @check nrow(df) == (n_gpa(ds) + 1);
    @assert df[nrow(df), "gpa_quartile"] == nrow(df)  "Last row is not ALL";
    if grpVar isa ClassAll
        iRow = nrow(df);
    elseif grpVar isa ClassHsGpa
        iRow = 1 : n_gpa(ds);
    else
        iRow = nothing;
    end
    if !isnothing(iRow)
        m = df[iRow, "coeff"];
        ses = df[iRow, "ste"];
        cnts = df[iRow, "number"];
    else
        m = ses = cnts = nothing;
    end
    return m, ses, cnts
end



"""
Wage fixed effects by AFQT / quality. For one education level.
Non-standard file name location.
Format of HSG file is different from that of other files.
"""
function wage_fixed_effects_fn(ds, edLevel; momentType = MtMean())
    prefix = wage_fe_prefix(momentType);
    subDirMt = momentType;
    if edLevel == SchoolSC
        edStr = "CD"; # for this type of file only!
    elseif edLevel == SchoolHSG
        # For HSGs, all moments are in the same file
        edStr = "HS";
        prefix = "moments";
        subDirMt = MtMean();
    else
        edStr = "CG";
    end
    fn = prefix * "_$(edStr)_fe_same.dat";
    fDir = joinpath(data_dir(ds), data_sub_dir(SelfReport(), subDirMt, GrpNone()), "Reg");
    return joinpath(fDir, fn)
end


"""
Wage fixed effects by [quality, AFQT]. Means only

test this +++++
"""
function wage_fixed_effects_qual_gpa(ds)
    # Sums to 1 for each AFQT group
    # fracQual_qgM, _ = load_moment(ds, :fracQual_qgM);
    # @assert all(isapprox.(sum(fracQual_qgM; dims = 1), 1.0))  "Does not sum to 1";

    fracGrad_qgM, _ = load_moment(ds, :fracGrad_qgM);
    nc = n_colleges(ds);
    # Temporary fix: replace the `1` entry for AFQT 1 / q 4 +++++
    if isapprox(fracGrad_qgM[nc, 1], 1.0)
        fracGrad_qgM[nc, 1] = (fracGrad_qgM[nc, 2] + fracGrad_qgM[nc-1, 1]) / 2;
    end

    grpVars = [ClassQuality(), ClassHsGpa()];
    # Keeping small counts is fine. They get low weight in averaging over education.
    minCnts = 1;
    feSC_qgM, _ = load_wage_fixed_effects(ds, SchoolSC, grpVars; minCnts);
    feCG_qgM, _ = load_wage_fixed_effects(ds, SchoolCG, grpVars; minCnts);

    fe_qgM = fracGrad_qgM .* feCG_qgM .+ (1.0 .- fracGrad_qgM) .* feSC_qgM;
    return fe_qgM
end


# -------------------