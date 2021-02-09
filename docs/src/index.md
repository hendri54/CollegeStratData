# CollegeStratData

This package loads data targets for calibration of the CollegeStrat model.

The raw data files come as delimited text files. This package lets the user load a data moment using a simple call to [`load_moment`](@ref). For example, `load_moment(ds, :fracGrad_gV)` loads the graduation rate by `gpa` or `afqt` group as a `Vector{Float64}`.

The code admits multiple named sets of data files. Which ones are loaded is determined by the [`DataSettings`](@ref) object that is passed to `load_moment`. To define a new set of data moments, create an entry in [`make_data_settings`](@ref) that points at the correct directory in Dropbox.

For each data moment, standard errors are constructed. For choice fractions, such as the fraction of students who choose each college quality, the multinomial formula `sqrt(p * (1-p) / n)` is used. For sample means, such as average time to graduate, the standard error is `std(x) / sqrt(n)`.

Data moments follow a consistent naming convention. The base name (e.g. `fracGrad`) indicates which moment is to be loaded (the fraction of entrants who graduate). The suffix indicates for which groups the moment is to be loaded. E.g., `fracGrad_gpM` loads by `gpa` and `parental` group. The groups are:

* `g`: `gpa` or `afqt`
* `p`: parental background
* `q`: college quality
* `t`: year in college


```@docs
DataSettings
load_moment
make_data_settings
```

# DataSettings

A `DataSettings` object is constructed with [`make_data_settings`](@ref).

The following functions give access to properties of the data:

```@docs
n_school
n_colleges
n_2year
is_two_year
two_year_colleges
four_year_colleges
can_graduate
no_grad_idx
grad_idx
n_gpa
n_parental
hsgpa_ub
parental_ub
```

# Raw Data Files

The raw data files are created in delimited text format and stored in a nested directory structure in the `DataCollegeStrat` package. That package exports a single function, `data_dir`, which tells the other code where the data files live. When `DataCollegeStrat` is `add`ed, `Pkg` downloads the entire repo (including data files) into a hidden directory that `data_dir` points to.

For each data file, a function makes a [`RawDataFile`](@ref) object. It contains information where the file is to be found in the directory structure. 

A mapping from data moments to raw data files is constructed in `raw_file_map`. This makes it easy to locate the data file that belongs to a given moment by simply calling [`raw_file_path`](@ref).

## Updating data files

When the data files are updated: Simply copy the directory for a given set of moments, such as "uneven types", from `Dropbox` into the package directory. Bump the package version. Register. Upload to github.

The new data versions will be used only when `DataCollegeStrat` is `update`d in `CollegeStratData`. It is therefore easy to roll back to previous data versions (which correspond to package versions).

It is a good idea to first `dev DataCollegeStrat` and make sure all tests pass. Then commit the new data and update the version number.

Sometimes `DataCollegeStrat` gets stuck at an old version when `CollegeStratData` is updated in `CollegeStrat` (why?). The try the following:

```julia
add DataCollegeStrat
up DataCollegeStrat
rm DataCollegeStrat
```

Afterwards, make sure the version number was bumped.

*Before* copying the data files, run the following:

```julia
ds = make_data_settings(:default);
# Create a list with files that are present in new data compared with existing data.
file_name_differences(ds);
compare_dirs(ds);
```

* [`file_name_differences`](@ref) 
* [`compare_dirs`](@ref) checks that all delimited files in two directories have matching headers.

*After* copying the data files, run the following:

* [`missing_file_list`](@ref) makes sure that all files are present. 
* `zsh delete_unused_data_files.sh` in `DataCollegeStrat`


```@docs
RawDataFile
raw_file_path
missing_file_list
file_name_differences
compare_dirs
```

## Returned RegressionTable Objects

Regressions are returned as `RegressionTable` objects (from `EconometricsLH`).

Regressor names are independent of how things are named inside the raw files (which tends to change over time). They are looked up by [`regressor_name`](@ref).

Regression coefficients can be retrieved without directly referring to names using [`get_intercept`](@ref) and [`get_regr_coef`](@ref).

```@docs
regressor_name
get_intercept
get_regr_coef
```


## Constructing experience profiles

`exper_profile` constructs the experience profiles for all school groups. Efficiency is normalized to 1 for workers with no experience.

From NLSY, we have experience profiles as dummies up to about 12 years of experience. These are read with `read_exper_coefficients`. 

From Rupert and Zanella, we have PSID experience profiles for the 1942-46 birth cohort (wages and hours worked).

We combine the two profiles by appending the Rupert and Zanella profile for smoothed wages * hours worked to the end of the NLSY profile. We scale the Rupert and Zanella profiles to match those estimated from the NLSY in the last available year.

------------------
