max_exper(wr :: WageRegressions) = wr.maxExper
exper_groups(wr :: WageRegressions) = wr.experGroupV;
max_exper_exponent(wr :: WageRegressions) = wr.maxExperExponent;
# School groups that are recognized
s_groups(wr :: WageRegressions) = vcat(exper_groups(wr)...);
n_school(wr :: WageRegressions) = length(s_groups(wr));
use_parental_dummies(wr :: WageRegressions) = wr.useParentalDummies;

default_wage_regressions() = 
    WageRegressions(maxExperExponent = 4, maxExper = 14);

wage_regressions_two() = 
    WageRegressions(experGroupV = [[:HSG, :CD], [:CG]], 
        maxExperExponent = 4);

# -------------