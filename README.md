
# THfuncs

# Purpose

The THfuncs R packages house functions created to help with data
analysis, data manipulation and other functionality in R.

The first (and currently only function) contained in this package is
`prop_in_group()`. This function transforms tidy data into a grouped
proportion table, using columns in the data. It can be generalised to
summarise wide data frames, as shown in the example below.

# Installation

You can install the development version of THfuncs like so:

``` r
# install.packages("devtools")
library(devtools)
devtools::install_github("tomambroseharris/THfuncs", force = TRUE)
library(THfuncs)
```

## prop_in_group

See what the function does by running: `?prop_in_group()` The inputs are
shown in `Usage`. There are defaults, which mean that the only arguments
necessary to specify are the `input_df` and `breakdowns_vector`.

<img src="Data/prop_in_group_screenshot.JPG" width="100%" />

# Example use

We will use some dummy data on universities, shown below.

|    UKPRN | Name                        | Country  | Ofs_Tariff_1920 | TEF_1819 | Student numbers | Total Expenditure |
|---------:|:----------------------------|:---------|:----------------|:---------|----------------:|------------------:|
| 10007814 | Cardiff University          | Wales    | NA              | Silver   |           33510 |            573201 |
| 10007790 | The University of Edinburgh | Scotland | NA              | No TEF   |           37830 |           1060066 |
| 10007794 | The University of Glasgow   | Scotland | NA              | No TEF   |           37145 |            695820 |
| 10000291 | Anglia Ruskin University    | England  | Low Tariff      | Silver   |           32180 |            270231 |
| 10008640 | Falmouth University         | England  | Specialist HEI  | Gold     |            6170 |             64303 |
| 10007760 | Birkbeck College            | England  | Specialist HEI  | Silver   |           12070 |            106783 |
| 10007792 | University of Exeter        | England  | High Tariff     | Gold     |           30250 |            512915 |
| 10007799 | University of Newcastle     | England  | High Tariff     | Gold     |           27775 |            530603 |
| 10007154 | University of Nottingham    | England  | High Tariff     | Gold     |           35785 |            683714 |

### Example 1. - Basic

Showing the proportion of observations (rows) that have each breakdown.

``` r

prop_in_group(input_df = universities,
              breakdowns_vector = c("Country", "Ofs_Tariff_1920", "TEF_1819"))
```

| Grouping        | Subgroup       | Proportion | Known in Group | Unknowns |
|:----------------|:---------------|-----------:|---------------:|---------:|
| Country         | England        |       0.67 |              9 |        0 |
| Country         | Scotland       |       0.22 |              9 |        0 |
| Country         | Wales          |       0.11 |              9 |        0 |
| Ofs_Tariff_1920 | High Tariff    |       0.50 |              6 |        3 |
| Ofs_Tariff_1920 | Low Tariff     |       0.17 |              6 |        3 |
| Ofs_Tariff_1920 | Specialist HEI |       0.33 |              6 |        3 |
| TEF_1819        | Gold           |       0.44 |              9 |        0 |
| TEF_1819        | No TEF         |       0.22 |              9 |        0 |
| TEF_1819        | Silver         |       0.33 |              9 |        0 |

**Notes:** *Only the rows for which the data points are known will be
included in the calculation, therefore ensuring that the proportion sums
to 1 within each grouping.*

### Example 2a. - Proportion of student numbers

Showing the proportion of observations (rows) that have each breakdown.
SUM how much of the total is known.

``` r

prop_in_group(input_df = universities,
              breakdowns_vector = c("Country", "Ofs_Tariff_1920", "TEF_1819"),
              value_col = `Student numbers`,
              knowns_treatment = "sum")
```

| Grouping        | Subgroup       | Proportion | Known in Group | Unknowns |
|:----------------|:---------------|-----------:|---------------:|---------:|
| Country         | England        |       0.57 |         252715 |        0 |
| Country         | Scotland       |       0.30 |         252715 |        0 |
| Country         | Wales          |       0.13 |         252715 |        0 |
| Ofs_Tariff_1920 | High Tariff    |       0.65 |         144230 |   108485 |
| Ofs_Tariff_1920 | Low Tariff     |       0.22 |         144230 |   108485 |
| Ofs_Tariff_1920 | Specialist HEI |       0.13 |         144230 |   108485 |
| TEF_1819        | Gold           |       0.40 |         252715 |        0 |
| TEF_1819        | No TEF         |       0.30 |         252715 |        0 |
| TEF_1819        | Silver         |       0.31 |         252715 |        0 |

### Example 2b. - Proportion of student numbers

Showing the proportion of observations (rows) that have each breakdown.
COUNT how many rows have known values. (This is the default, as shown in
example 1).

``` r

prop_in_group(input_df = universities,
              breakdowns_vector = c("Country", "Ofs_Tariff_1920", "TEF_1819"),
              value_col = `Student numbers`,
              knowns_treatment = "count")
```

| Grouping        | Subgroup       | Proportion | Known in Group | Unknowns |
|:----------------|:---------------|-----------:|---------------:|---------:|
| Country         | England        |       0.57 |              9 |        0 |
| Country         | Scotland       |       0.30 |              9 |        0 |
| Country         | Wales          |       0.13 |              9 |        0 |
| Ofs_Tariff_1920 | High Tariff    |       0.65 |              6 |        3 |
| Ofs_Tariff_1920 | Low Tariff     |       0.22 |              6 |        3 |
| Ofs_Tariff_1920 | Specialist HEI |       0.13 |              6 |        3 |
| TEF_1819        | Gold           |       0.40 |              9 |        0 |
| TEF_1819        | No TEF         |       0.30 |              9 |        0 |
| TEF_1819        | Silver         |       0.31 |              9 |        0 |

### Example 3. - Dual breakdowns

Now we will derive the proportion in each group split by the unique
variables in the `Country` column.

``` r

prop_in_group(input_df = universities,
              breakdowns_vector = c("TEF_1819"),
              value_col = `Student numbers`,
              group_by_col = Country,
              knowns_treatment = "count")
```

| Grouping | Subgroup | Wales | Scotland | England | Known in Group | Unknowns |
|:---------|:---------|------:|---------:|--------:|---------------:|---------:|
| TEF_1819 | Gold     |    NA |       NA |    0.69 |              9 |        0 |
| TEF_1819 | No TEF   |    NA |        1 |      NA |              9 |        0 |
| TEF_1819 | Silver   |     1 |       NA |    0.31 |              9 |        0 |

**Notes** *Where there are no corresponding data in the original data
frame (e.g., No Welsh universities in the df were TEF_1819 = Gold), NA
will be returned*
