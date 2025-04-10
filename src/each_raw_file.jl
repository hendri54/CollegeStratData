## ----------------  Individual files

# Convenience abbreviation
rf(ds :: DataSettings, baseFn, groups, selfTrans, area, momentType) = 
    RawDataFile(selfTrans, area, momentType,
        file_name(ds, baseFn, groups), ds);


# AFQT percentile by quality
raw_afqt_pct_qual(ds :: DataSettings; momentType = MtMean()) =
    RawDataFile(Transcript(), GrpFreshmen(), momentType, 
        file_name(ds, "afqt_pctile", grpQuality), ds);

raw_frac_local_qual(ds :: DataSettings; momentType = MtMean()) =
    RawDataFile(Transcript(), GrpFreshmen(), momentType, 
        file_name(ds, "frac_loc_50", [grpQuality]), ds);

rf_qg(ds :: DataSettings, baseFn, selfTrans, area, momentType) = 
    rf(ds, baseFn, [grpQuality, grpGpa], selfTrans, area, momentType);


# ---------  Entry and graduation


# Conditional on entry, fraction of students in each [quality, gpa] cell
raw_mass_entry_qual_gpa(ds :: DataSettings; momentType = MtMean()) =
    RawDataFile(Transcript(), GrpFreshmen(), momentType, 
        file_name(ds, "jointdist", [grpQuality, grpGpa]), ds);

raw_mass_entry_qual_parental(ds :: DataSettings; momentType = MtMean()) =
    RawDataFile(Transcript(), GrpFreshmen(), momentType, 
        file_name(ds, "jointdist", [:qual, :yp]), ds);

# Conditional on entry, fraction of students in each [quality, gpa] cell
raw_entry_qual_gpa(ds :: DataSettings; momentType = MtMean()) =
    rf_qg(ds, "jointdist", Transcript(), GrpFreshmen(), momentType);
        # file_name(ds, "jointdist", [grpQuality, grpGpa]), ds);
    
# By year
raw_frac_drop_qual_gpa(ds :: DataSettings, year :: Integer; 
    momentType = MtMean()) =
    rf_qg(ds, "drop_rate_y$year", Transcript(), GrpProgress(), momentType);

raw_frac_gradc_qual_gpa(ds :: DataSettings; momentType = MtMean()) = 
    rf_qg(ds, "grad_rate", Transcript(), GrpProgress(), momentType)
        # file_name(ds, "grad_rate", [:quality, :afqt]), ds);
  
# Transcript time to drop contains a 0 in one cell
raw_time_to_drop_4y_qual_gpa(ds :: DataSettings;  momentType = MtMean()) = 
    rf_qg(ds, "time_to_drop_4Y", Transcript(), GrpProgress(), momentType);
        # file_name(ds, "time_to_drop_4Y", [grpQuality, grpGpa]), ds);

raw_time_to_grad_4y_qual_gpa(ds :: DataSettings; 
    momentType = MtMean()) = 
    rf_qg(ds, "time_to_grad_4Y", Transcript(), GrpProgress(), momentType);
        # file_name(ds, "time_to_grad_4Y", [grpQuality, grpGpa]), ds);
    
# raw_net_price_qual_gpa(ds :: DataSettings, year :: Integer; 
#     momentType = MtMean()) =
#     raw_net_price_xy(ds, [:qual, :gpa], year; momentType);
    # RawDataFile(Transcript(), GrpFinance, momentType, 
    #     file_name(ds, "net_price_y$year", [grpQuality, grpGpa]), ds);

raw_credits_taken_qual_gpa(ds :: DataSettings, year :: Integer;
    momentType = MtMean()) = 
    RawDataFile(Transcript(), GrpProgress(), momentType, 
        file_name(ds, "creds_att_y$year", [grpQuality, grpGpa]), ds);

raw_credits_taken_qual_grad_year(ds :: DataSettings, year :: Integer; 
    momentType = MtMean()) = 
    RawDataFile(Transcript(), GrpProgress(), momentType, 
        file_name(ds, "creds_att_y$year", [:qual, :gradDrop]), ds);
    
# function raw_transfers_qual_gpa(ds :: DataSettings, yr :: Integer; 
#         momentType = MtMean())

#     return raw_transfers_xy(ds, [:qual, :gpa], yr; momentType)
# end

# --------  Study and work times

study_time_src() = SelfReport();

raw_study_time_qual_gpa(ds :: DataSettings; momentType = MtMean()) = 
    rf_qg(ds, "studytime", study_time_src(), GrpProgress(), momentType);
        # file_name(ds, "studytime", [:quality, :afqt]), ds);

raw_class_time_qual_gpa(ds :: DataSettings; momentType = MtMean()) = 
    rf_qg(ds, "classtime", study_time_src(), GrpProgress(), momentType);
    #    file_name(ds, "classtime", [:quality, :afqt]), ds);

raw_work_hours_qual_gpa(ds :: DataSettings, year :: Integer; 
    momentType = MtMean()) = 
    RawDataFile(study_time_src(), GrpFinance(), momentType, 
        file_name(ds, "hours_y$year", [grpQuality, grpGpa]), ds);

raw_work_hours_qual_parental(ds :: DataSettings; 
    momentType = MtMean()) =
    rf_qp(ds, "hours_y1", SelfReport(), GrpFinance(), momentType);
    
    
# ---------  Financials

# Using SelfReport sample for larger sample size
fin_src() = SelfReport();

function raw_transfers_xy(ds :: DataSettings, xyGroups, yr :: Integer; 
        momentType = MtMean())
    fn = file_name(ds, "par_trans_y$yr", xyGroups);
    return RawDataFile(fin_src(), GrpFinance(), momentType, fn, ds);
end

function raw_net_price_xy(ds :: DataSettings, xyGroups, yr :: Integer; 
        momentType = MtMean())
    fn = file_name(ds, "net_price_y$yr", xyGroups);
    return RawDataFile(fin_src(), GrpFinance(), momentType, fn, ds);
end

# Can load for selected percentiles giving `percentile` input (e.g. 90)
function raw_cum_loans_qual_year(
    ds :: DataSettings, year :: Integer; 
    momentType = MtMean(), percentile = nothing
    )
    fn = file_name(ds, "cumloans_y$year", [grpQuality, grpGpa]; 
        percentile = percentile);
    return RawDataFile(fin_src(), GrpFinance(), momentType, fn, ds);
end

# Only means for this moment. No percentiles.
function raw_cum_loans_qual_yp_year(ds :: DataSettings, year :: Integer; 
        momentType = MtMean()
        )
    fn = file_name(ds, "cumloans_y$year", [:qual, :yp]; percentile = nothing);
    return RawDataFile(fin_src(), GrpFinance(), momentType, fn, ds);
end
 
raw_college_earnings_qual_parental(ds :: DataSettings; 
    momentType = MtMean(), year = 1) =
    rf_qp(ds, "earnings_y$year", fin_src(), GrpFinance(), momentType);

                
# -----  By quality / parental

rf_qp(ds :: DataSettings, baseFn, selfTrans, area :: AbstractGroup, momentType) = 
    rf(ds, baseFn, [:qual, :yp], selfTrans, area, momentType);

# Conditional on entry, fraction of students in each [quality, parental] cell
raw_entry_qual_parental(ds :: DataSettings; momentType = MtMean()) =
    rf_qp(ds, "jointdist", Transcript(), GrpFreshmen(), momentType); 

raw_frac_gradc_qual_parental(ds :: DataSettings; 
    momentType = MtMean()) =
    rf_qp(ds, "grad_rate", Transcript(), GrpProgress(), momentType);

raw_time_to_drop_4y_qual_parental(ds :: DataSettings; 
    momentType = MtMean()) =
    rf_qp(ds, "time_to_drop_4Y", Transcript(), GrpProgress(), momentType);

raw_time_to_grad_4y_qual_parental(ds :: DataSettings; 
    momentType = MtMean()) =
    rf_qp(ds, "time_to_grad_4Y", Transcript(), GrpProgress(), momentType);


# ------  by [gpa, parental]
# Data files have this transposed as [parental, gpa]

# Entry rates [gpa, parental], but TRANSPOSED in data files!
raw_entry_gpa_parental(ds :: DataSettings; momentType = MtMean()) =
    RawDataFile(Transcript(), GrpHsGrads(), momentType, 
        file_name(ds, "entrants", [:yp, :afqt]), ds);

# Fraction by quality, by [gpa, parental], TRANSPOSED in data files.
# Conditional on entry.
raw_qual_entry_gpa_parental(ds :: DataSettings, iCollege; 
    momentType = MtMean()) =
    RawDataFile(Transcript(), GrpFreshmen(), momentType, 
        file_name(ds, "prob_ent_q$(iCollege)", [:yp, :afqt]), ds);

# Mass of HSG by [parental, hs gpa]
raw_mass_gpa_parental(ds :: DataSettings; momentType = MtMean()) =
    RawDataFile(Transcript(), GrpHsGrads(), momentType, 
        file_name(ds, "jointdist_hsgrads", [:yp, :afqt]), ds);


# -----  Regressions

# Wage regression for graduates with college quality coefficients
# raw_wage_regr_grads(ds :: DataSettings) = 
#     RawDataFile(SelfReport(), GrpNone(), MtRegression(), "loginc_reg2.dat", ds);

# Regressions only exist for SelfReport sample.
function wage_regr_raw_fn(ds, fn)
    return RawDataFile(SelfReport(), GrpNone(), MtRegression(), fn, ds);
end


# ---------