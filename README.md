# CollegeStratData

Data routines for CollegeStrat and MismatchMM projects.

Order of categories: school (s), quality (q), gpa (g), parental (p)

## Change log 2025

April 10 (v3)
- v3 for submitted IBA paper

## Change log 2024

Feb-23 (2.13)
- changed financial moments to SelfReport for larger sample size.
Feb-21 (2.12)
- all moments from Transcript files, except college earnings and experience profiles, wage regressions, wage fixed effects
Feb-19
- Cumulative loans by [quality, parental, year]

## Change log 2023

Nov-21
- Fixed more inconsistencies in grad rates (same source as Nov 17). Drops overall grad rate 0.44 (from 0.48)
Nov-17
- Inconsistency in constructing grad rates by [quality, gpa]. Because 2y starters cannot graduate, the marginals do not match the joint fractions by [q, g]. Now constructing frac grad(g) from massGrad(g) and massEnter(g)
Oct-2
- correctly renamed quality regressors (last_type now becomes Qual).
Sep-12
- updated and clarified renaming of variables from raw data files; especially regressions.
Sep-5
- load wage fixed effects by [quality, afqt].
Sep-1
- now computed from fraction dropping out by [afqt, quality, t] data:
  - frac drop qual year, `frac_drop_4y_by_year`
  (because `statusByYear` does not work for my model)
Aug-8
- move to BaseMM
July-18 (v2.5)
- added DataCollegeStrat v2.3
July-8 (v2.4)
- check counts and convert to Int when loading.
July-7 (v2.2)
- load wage fixed effects
- Added classifications (e.g. ClassHsGpa)
- Added groups (e.g. GrpFinance)
July-6
- MomentTypes as types rather than symbols
Jun-26
- `frac_drop_qual_gpa`
Mar-15:
- added tuition moments by [q,g] and [q,p]
Feb-22:
NLSY79 data files no longer have `SelfReport` or `Transcript` sub-directories.

Feb-7
Added data moment "fraction gpa by quality"
Feb-1 (v2.2.1)
Added college earnings targets.

---------------