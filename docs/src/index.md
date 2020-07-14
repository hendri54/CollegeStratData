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

When the data files are updated: Push a new version number to github and `Pkg.update` in `CollegeStratData`.

For each data file, a function makes a [`RawDataFile`](@ref) object. It contains information where the file is to be found in the directory structure. 

A mapping from data moments to raw data files is constructed in `raw_file_map`. This makes it easy to locate the data file that belongs to a given moment by simply calling [`raw_file_path`](@ref).

```@docs
RawDataFile
raw_file_path
```

------------------
