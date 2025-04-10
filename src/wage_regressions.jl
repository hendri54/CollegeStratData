# Code for `WageRegressions` type

max_exper(wr :: WageRegressions) = wr.maxExper
exper_groups(wr :: WageRegressions) = wr.experGroupV;
max_exper_exponent(wr :: WageRegressions) = wr.maxExperExponent;
# School groups that are recognized
BaseMM.ed_symbols(wr :: WageRegressions) = vcat(exper_groups(wr)...);
BaseMM.n_school(wr :: WageRegressions) = length(ed_symbols(wr));
use_parental_dummies(wr :: WageRegressions) = wr.useParentalDummies;

default_wage_regressions(; useParentalDummies = true, 
        useAfqtQualityInteractions :: Bool = false) = 
    WageRegressions(; maxExperExponent = 4, maxExper = 14, 
        useParentalDummies, useAfqtQualityInteractions);

# Two school groups
wage_regressions_two(; useParentalDummies = true, 
        useAfqtQualityInteractions :: Bool = false) = 
    WageRegressions(; experGroupV = [[SchoolHSG, SchoolSC], [SchoolCG]], 
        maxExperExponent = 4, useParentalDummies, useAfqtQualityInteractions);


"""
Suffix for a regression file, such as "_inc--same"
"_inc" determines whether parental income is a regressor.
"_interactions" determines whether AFQT / quality interactions are there.
"_same" or "_dif" refers to same or different experience profile by schooling.
"""
function regr_file_suffix(wr :: WageRegressions)
    if use_parental_dummies(wr)
        incSuffix = "_inc";
    else
        incSuffix = "";
    end

    if length(exper_groups(wr)) == 1
        groupSuffix = "--same";
    elseif exper_groups(wr) == [[SchoolHSG, SchoolSC], [SchoolCG]]
        groupSuffix = "--dif";
    else
        error("Invalid $wr");
    end

    if wr.useAfqtQualityInteractions
        interSuffix = "_interaction";
    else
        interSuffix = "";
    end

    return incSuffix * interSuffix * groupSuffix  
end



# -------------