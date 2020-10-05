# Code for `WageRegressions` type

max_exper(wr :: WageRegressions) = wr.maxExper
exper_groups(wr :: WageRegressions) = wr.experGroupV;
max_exper_exponent(wr :: WageRegressions) = wr.maxExperExponent;
# School groups that are recognized
s_groups(wr :: WageRegressions) = vcat(exper_groups(wr)...);
n_school(wr :: WageRegressions) = length(s_groups(wr));
use_parental_dummies(wr :: WageRegressions) = wr.useParentalDummies;

default_wage_regressions() = 
    WageRegressions(maxExperExponent = 4, maxExper = 14);

# Two school groups
wage_regressions_two() = 
    WageRegressions(experGroupV = [[:HSG, :CD], [:CG]], 
        maxExperExponent = 4);


# Suffix for a regression file, such as "_inc--same"
# "_inc" determines whether parental income is a regressor.
# "_same" or "_dif" refers to same or different experience profile by schooling.
function regr_file_suffix(wr :: WageRegressions)
    if use_parental_dummies(wr)
        incSuffix = "_inc";
    else
        incSuffix = "";
    end

    if length(exper_groups(wr)) == 1
        groupSuffix = "--same";
    elseif exper_groups(wr) == [[:HSG, :CD], [:CG]]
        groupSuffix = "--dif";
    else
        error("Invalid $wr");
    end

    return incSuffix * groupSuffix
end



# -------------