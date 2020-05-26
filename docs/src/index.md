# CollegeStratData

Construct data targets for calibration.

Settings are determined by [`DataSettings`](@ref)

Each data moment is loaded with [`load_moment`](@ref).


```@docs
DataSettings
load_moment
```


Read data from CSV files. Make them into named `Deviations` (using `ModelParams`).

Everything is converted into model units.

Each deviation shows up in several places:
1. `MomentTable` defines locations of data files
2. each deviation has a function that constructs it (e.g. `entry_by_gpa_yp`)
3. each deviation that is used in any of the model versions is listed in `make_deviation`

Adding a deviation
1. Locate the moments in a green table in the excel files
2. Locate the corresponding `dat` file
3. Add an entry in 'MomentTable'
4. Write a function that reads the `dat` file and converts it into a `Deviation`

------------------
