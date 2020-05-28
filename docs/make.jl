using Documenter, CollegeStratData

makedocs(
    modules = [CollegeStratData],
    format = Documenter.HTML(; prettyurls = get(ENV, "CI", nothing) == "true"),
    authors = "hendri54",
    sitename = "CollegeStratData.jl",
    pages = Any["index.md"]
    # strict = true,
    # clean = true,
    # checkdocs = :exports,
)

# deploydocs(
#     repo = "github.com/hendri54/CollegeStratData.jl.git",
#     push_preview = true
# )
