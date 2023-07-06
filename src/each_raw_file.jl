## ----------------  Individual files

# Convenience abbreviation
rf(ds :: DataSettings, baseFn, groups, selfTrans, area, momentType) = 
    RawDataFile(selfTrans, area, momentType,
        file_name(ds, baseFn, groups), ds);


# AFQT percentile by quality
raw_afqt_pct_qual(ds :: DataSettings; momentType = MtMean()) =
    RawDataFile(SelfReport(), :freshmen, momentType, 
        file_name(ds, "afqt_pctile", :qual), ds);

raw_frac_local_qual(ds :: DataSettings; momentType = MtMean()) =
    RawDataFile(Transcript(), :freshmen, momentType, 
        file_name(ds, "frac_loc_50", [:qual]), ds);

# raw_wage_fixed_effects(ds :: DataSettings, edLevel; momentType = MtMean()) = 
#     RawDataFile(SelfReport())


# ----------  By quality / gpa

rf_qg(ds :: DataSettings, baseFn, selfTrans, area, momentType) = 
    rf(ds, baseFn, [:qual, :afqt], selfTrans, area, momentType);

# Conditional on entry, fraction of students in each [quality, gpa] cell
raw_entry_qual_gpa(ds :: DataSettings; momentType = MtMean()) =
    rf_qg(ds, "jointdist", Transcript(), :freshmen, momentType);
        # file_name(ds, "jointdist", [:qual, :afqt]), ds);
    
# By year
raw_frac_drop_qual_gpa(ds :: DataSettings, year :: Integer; 
    momentType = MtMean()) =
    rf_qg(ds, "drop_rate_y$year", Transcript(), :progress, momentType);

raw_grad_rate_qual_gpa(ds :: DataSettings; momentType = MtMean()) = 
    rf_qg(ds, "grad_rate", Transcript(), :progress, momentType)
        # file_name(ds, "grad_rate", [:quality, :afqt]), ds);

raw_study_time_qual_gpa(ds :: DataSettings; momentType = MtMean()) = 
    rf_qg(ds, "studytime", SelfReport(), :progress, momentType);
        # file_name(ds, "studytime", [:quality, :afqt]), ds);

raw_class_time_qual_gpa(ds :: DataSettings; momentType = MtMean()) = 
    rf_qg(ds, "classtime", SelfReport(), :progress, momentType);
    #    file_name(ds, "classtime", [:quality, :afqt]), ds);
    
# Transcript time to drop contains a 0 in one cell
raw_time_to_drop_4y_qual_gpa(ds :: DataSettings; 
    momentType = MtMean()) = 
    rf_qg(ds, "time_to_drop_4Y", Transcript(), :progress, momentType);
        # file_name(ds, "time_to_drop_4Y", [:qual, :afqt]), ds);

raw_time_to_grad_4y_qual_gpa(ds :: DataSettings; 
    momentType = MtMean()) = 
    rf_qg(ds, "time_to_grad_4Y", Transcript(), :progress, momentType);
        # file_name(ds, "time_to_grad_4Y", [:qual, :afqt]), ds);
    
raw_work_hours_qual_gpa(ds :: DataSettings, year :: Integer; 
    momentType = MtMean()) = 
    RawDataFile(SelfReport(), :finance, momentType, 
        file_name(ds, "hours_y$year", [:qual, :afqt]), ds);

# raw_net_price_qual_gpa(ds :: DataSettings, year :: Integer; 
#     momentType = MtMean()) =
#     raw_net_price_xy(ds, [:qual, :gpa], year; momentType);
    # RawDataFile(Transcript(), :finance, momentType, 
    #     file_name(ds, "net_price_y$year", [:qual, :afqt]), ds);

raw_credits_taken_qual_gpa(ds :: DataSettings, year :: Integer;
    momentType = MtMean()) = 
    RawDataFile(Transcript(), :progress, momentType, 
        file_name(ds, "creds_att_y$year", [:qual, :afqt]), ds);


# function raw_transfers_qual_gpa(ds :: DataSettings, yr :: Integer; 
#         momentType = MtMean())

#     return raw_transfers_xy(ds, [:qual, :gpa], yr; momentType)
# end

function raw_transfers_xy(ds :: DataSettings, xyGroups, yr :: Integer; 
        momentType = MtMean())
    fn = file_name(ds, "par_trans_y$yr", xyGroups);
    return RawDataFile(SelfReport(), :finance, momentType, fn, ds);
end

function raw_net_price_xy(ds :: DataSettings, xyGroups, yr :: Integer; 
        momentType = MtMean())
    fn = file_name(ds, "net_price_y$yr", xyGroups);
    return RawDataFile(Transcript(), :finance, momentType, fn, ds);
end


# Can load for selected percentiles giving `percentile` input (e.g. 90)
function raw_cum_loans_qual_year(
    ds :: DataSettings, year :: Integer; 
    momentType = MtMean(), percentile = nothing
    )
    fn = file_name(ds, "cumloans_y$year", [:qual, :afqt]; 
        percentile = percentile);
    return RawDataFile(Transcript(), :finance, momentType, fn, ds);
end

# Conditional on entry, fraction of students in each [quality, gpa] cell
raw_mass_entry_qual_gpa(ds :: DataSettings; momentType = MtMean()) =
    RawDataFile(Transcript(), :freshmen, momentType, 
        file_name(ds, "jointdist", [:qual, :afqt]), ds);


# -------  By quality / grad outcome

raw_credits_taken_qual_grad_year(ds :: DataSettings, year :: Integer; 
    momentType = MtMean()) = 
    RawDataFile(Transcript(), :progress, momentType, 
        file_name(ds, "creds_att_y$year", [:qual, :gradDrop]), ds);
            
                
# -----  By quality / parental

rf_qp(ds :: DataSettings, baseFn, selfTrans, area, momentType) = 
    rf(ds, baseFn, [:qual, :yp], selfTrans, area, momentType);

raw_college_earnings_qual_parental(ds :: DataSettings; 
    momentType = MtMean(), year = 1) =
    rf_qp(ds, "earnings_y$year", SelfReport(), :finance, momentType);

raw_work_hours_qual_parental(ds :: DataSettings; 
    momentType = MtMean()) =
    rf_qp(ds, "hours_y1", SelfReport(), :finance, momentType);

# Conditional on entry, fraction of students in each [quality, parental] cell
raw_entry_qual_parental(ds :: DataSettings; momentType = MtMean()) =
    rf_qp(ds, "jointdist", Transcript(), :freshmen, momentType); 

raw_frac_grad_qual_parental(ds :: DataSettings; 
    momentType = MtMean()) =
    rf_qp(ds, "grad_rate", Transcript(), :progress, momentType);

raw_time_to_drop_4y_qual_parental(ds :: DataSettings; 
    momentType = MtMean()) =
    rf_qp(ds, "time_to_drop_4Y", Transcript(), :progress, momentType);

raw_time_to_grad_4y_qual_parental(ds :: DataSettings; 
    momentType = MtMean()) =
    rf_qp(ds, "time_to_grad_4Y", Transcript(), :progress, momentType);


# ------  by [gpa, parental]
# Data files have this transposed as [parental, gpa]

# Entry rates [gpa, parental], but TRANSPOSED in data files!
raw_entry_gpa_parental(ds :: DataSettings; momentType = MtMean()) =
    RawDataFile(Transcript(), :hsGrads, momentType, 
        file_name(ds, "entrants", [:yp, :afqt]), ds);

# Fraction by quality, by [gpa, parental], TRANSPOSED in data files.
# Conditional on entry.
raw_qual_entry_gpa_parental(ds :: DataSettings, iCollege; 
    momentType = MtMean()) =
    RawDataFile(Transcript(), :freshmen, momentType, 
        file_name(ds, "prob_ent_q$(iCollege)", [:yp, :afqt]), ds);

# Mass of HSG by [parental, hs gpa]
raw_mass_gpa_parental(ds :: DataSettings; momentType = MtMean()) =
    RawDataFile(Transcript(), :hsGrads, momentType, 
        file_name(ds, "jointdist_hsgrads", [:yp, :afqt]), ds);


# -----  Regressions

# Wage regression for graduates with college quality coefficients
# raw_wage_regr_grads(ds :: DataSettings) = 
#     RawDataFile(SelfReport(), :none, MtRegression(), "loginc_reg2.dat", ds);



# ---------