## ----------------  Individual files

# Convenience abbreviation
rf(ds :: DataSettings, baseFn, groups, selfTrans, area, momentType) = 
    RawDataFile(selfTrans, area, momentType,
        file_name(ds, baseFn, groups), ds);


# AFQT percentile by quality
raw_afqt_pct_qual(ds :: DataSettings; momentType :: Symbol = :mean) =
    RawDataFile(:selfReport, :freshmen, momentType, 
        file_name(ds, "afqt_pctile", :qual), ds);

raw_frac_local_qual(ds :: DataSettings; momentType :: Symbol = :mean) =
    RawDataFile(:transcript, :freshmen, momentType, 
        file_name(ds, "frac_loc_50", [:qual]), ds);


# ----------  By quality / gpa

rf_qg(ds :: DataSettings, baseFn, selfTrans, area, momentType) = 
    rf(ds, baseFn, [:qual, :afqt], selfTrans, area, momentType);

# Conditional on entry, fraction of students in each [quality, gpa] cell
raw_entry_qual_gpa(ds :: DataSettings; momentType :: Symbol = :mean) =
    rf_qg(ds, "jointdist", :transcript, :freshmen, momentType);
        # file_name(ds, "jointdist", [:qual, :afqt]), ds);
    
# By year
raw_frac_drop_qual_gpa(ds :: DataSettings, year :: Integer; 
    momentType :: Symbol = :mean) =
    rf_qg(ds, "drop_rate_y$year", :transcript, :progress, momentType);
        # file_name(ds, "drop_rate_y$year", [:qual, :afqt]), ds);

raw_grad_rate_qual_gpa(ds :: DataSettings; momentType :: Symbol = :mean) = 
    rf_qg(ds, "grad_rate", :transcript, :progress, momentType)
        # file_name(ds, "grad_rate", [:quality, :afqt]), ds);

raw_study_time_qual_gpa(ds :: DataSettings; momentType :: Symbol = :mean) = 
    rf_qg(ds, "studytime", :selfReport, :progress, momentType);
        # file_name(ds, "studytime", [:quality, :afqt]), ds);

raw_class_time_qual_gpa(ds :: DataSettings; momentType :: Symbol = :mean) = 
    rf_qg(ds, "classtime", :selfReport, :progress, momentType);
    #    file_name(ds, "classtime", [:quality, :afqt]), ds);
    
# Transcript time to drop contains a 0 in one cell
raw_time_to_drop_4y_qual_gpa(ds :: DataSettings; 
    momentType :: Symbol = :mean) = 
    rf_qg(ds, "time_to_drop_4Y", :transcript, :progress, momentType);
        # file_name(ds, "time_to_drop_4Y", [:qual, :afqt]), ds);

raw_time_to_grad_4y_qual_gpa(ds :: DataSettings; 
    momentType :: Symbol = :mean) = 
    rf_qg(ds, "time_to_grad_4Y", :transcript, :progress, momentType);
        # file_name(ds, "time_to_grad_4Y", [:qual, :afqt]), ds);
    
raw_work_hours_qual_gpa(ds :: DataSettings, year :: Integer; 
    momentType :: Symbol = :mean) = 
    RawDataFile(:selfReport, :finance, momentType, 
        file_name(ds, "hours_y$year", [:qual, :afqt]), ds);

raw_net_price_qual_gpa(ds :: DataSettings, year :: Integer; 
    momentType :: Symbol = :mean) =
    RawDataFile(:transcript, :finance, momentType, 
        file_name(ds, "net_price_y$year", [:qual, :afqt]), ds);

raw_credits_taken_qual_gpa(ds :: DataSettings, year :: Integer;
    momentType :: Symbol = :mean) = 
    RawDataFile(:transcript, :progress, momentType, 
        file_name(ds, "creds_att_y$year", [:qual, :afqt]), ds);

# Can load for selected percentiles giving `percentile` input (e.g. 90)
function raw_cum_loans_qual_year(
    ds :: DataSettings, year :: Integer; 
    momentType :: Symbol = :mean, percentile = nothing
    )
    fn = file_name(ds, "cumloans_y$year", [:qual, :afqt]; 
        percentile = percentile);
    return RawDataFile(:transcript, :finance, momentType, fn, ds);
end

# Conditional on entry, fraction of students in each [quality, gpa] cell
raw_mass_entry_qual_gpa(ds :: DataSettings; momentType :: Symbol = :mean) =
    RawDataFile(:transcript, :freshmen, momentType, 
        file_name(ds, "jointdist", [:qual, :afqt]), ds);


# -------  By quality / grad outcome

raw_credits_taken_qual_grad_year(ds :: DataSettings, year :: Integer; 
    momentType :: Symbol = :mean) = 
    RawDataFile(:transcript, :progress, momentType, 
        file_name(ds, "creds_att_y$year", [:qual, :gradDrop]), ds);
            
                
# -----  By quality / parental

rf_qp(ds :: DataSettings, baseFn, selfTrans, area, momentType) = 
    rf(ds, baseFn, [:qual, :yp], selfTrans, area, momentType);

raw_work_hours_qual_parental(ds :: DataSettings; 
    momentType :: Symbol = :mean) =
    rf_qp(ds, "hours_y1", :selfReport, :finance, momentType);

# Conditional on entry, fraction of students in each [quality, parental] cell
raw_entry_qual_parental(ds :: DataSettings; momentType :: Symbol = :mean) =
    rf_qp(ds, "jointdist", :transcript, :freshmen, momentType); 

raw_frac_grad_qual_parental(ds :: DataSettings; 
    momentType :: Symbol = :mean) =
    rf_qp(ds, "grad_rate", :transcript, :progress, momentType);

raw_time_to_drop_4y_qual_parental(ds :: DataSettings; 
    momentType :: Symbol = :mean) =
    rf_qp(ds, "time_to_drop_4Y", :transcript, :progress, momentType);

raw_time_to_grad_4y_qual_parental(ds :: DataSettings; 
    momentType :: Symbol = :mean) =
    rf_qp(ds, "time_to_grad_4Y", :transcript, :progress, momentType);


# ------  by [gpa, parental]
# Data files have this transposed as [parental, gpa]

# Entry rates [gpa, parental], but TRANSPOSED in data files!
raw_entry_gpa_parental(ds :: DataSettings; momentType :: Symbol = :mean) =
    RawDataFile(:transcript, :hsGrads, momentType, 
        file_name(ds, "entrants", [:yp, :afqt]), ds);

# Fraction by quality, by [gpa, parental], TRANSPOSED in data files.
# Conditional on entry.
raw_qual_entry_gpa_parental(ds :: DataSettings, iCollege; 
    momentType :: Symbol = :mean) =
    RawDataFile(:transcript, :freshmen, momentType, 
        file_name(ds, "prob_ent_q$(iCollege)", [:yp, :afqt]), ds);

# Mass of HSG by [parental, hs gpa]
raw_mass_gpa_parental(ds :: DataSettings; momentType :: Symbol = :mean) =
    RawDataFile(:transcript, :hsGrads, momentType, 
        file_name(ds, "jointdist_hsgrads", [:yp, :afqt]), ds);


# -----  Regressions

# Wage regression for graduates with college quality coefficients
# raw_wage_regr_grads(ds :: DataSettings) = 
#     RawDataFile(:selfReport, :none, :regression, "loginc_reg2.dat", ds);

raw_transfer_regr(ds :: DataSettings; momentType = nothing) = 
    RawDataFile(:transcript, :none, :regression, "parental_transfers1_reg1.dat", ds);

raw_tuition_regr(ds :: DataSettings; momentType = nothing) = 
    RawDataFile(:transcript, :none, :regression, "net_price1_reg1.dat", ds);


# ---------