
# THfuncs

## Installation

You can install the development version of THfuncs like so:

``` r
# install.packages("devtools")
library(devtools)
#> Loading required package: usethis
#> Warning: package 'usethis' was built under R version 4.2.1
devtools::install_github("tomambroseharris/THfuncs", force = TRUE)
#> Downloading GitHub repo tomambroseharris/THfuncs@HEAD
#> * checking for file 'C:\Users\THARRIS1\AppData\Local\Temp\Rtmpa8bTdv\remotes3db42a0e7916\tomambroseharris-THfuncs-672ee6b/DESCRIPTION' ... OK
#> * preparing 'THfuncs':
#> * checking DESCRIPTION meta-information ... OK
#> * checking for LF line-endings in source and make files and shell scripts
#> * checking for empty or unneeded directories
#> Omitted 'LazyData' from DESCRIPTION
#> * building 'THfuncs_0.1.0.tar.gz'
#> 
library(THfuncs)
```

# Purpose

THfuncs houses functions created to help with data analysis, data
manipulation and other functionality in R.

The first (and currently only function) contained in this package is
`prop_in_group()`. This transforms tidy data into a grouped proportion
table, using columns in the data. It can be generalised to summarise
wide data frames, as shown in the example below.

## See what the function does

``` r
?prop_in_group()
```

# Use

``` r
data("iris")
iris
iris <- iris %>% mutate(example_group = if_else(Petal.Length > 4, "long", "short"))
```

The output looks like this

    #> 
    #> Attaching package: 'dplyr'
    #> The following object is masked from 'package:kableExtra':
    #> 
    #>     group_rows
    #> The following objects are masked from 'package:stats':
    #> 
    #>     filter, lag
    #> The following objects are masked from 'package:base':
    #> 
    #>     intersect, setdiff, setequal, union

| Sepal.Length | Sepal.Width | Petal.Length | Petal.Width | Species | example_group |
|-------------:|------------:|-------------:|------------:|:--------|:--------------|
|          5.1 |         3.5 |          1.4 |         0.2 | setosa  | short         |
|          4.9 |         3.0 |          1.4 |         0.2 | setosa  | short         |
|          4.7 |         3.2 |          1.3 |         0.2 | setosa  | short         |
|          4.6 |         3.1 |          1.5 |         0.2 | setosa  | short         |
|          5.0 |         3.6 |          1.4 |         0.2 | setosa  | short         |

``` r
output_table <- prop_in_group(input_df = reformatted_iris,
              value_col = Petal.Length,
              breakdowns_vector = c("Species"),
              group_by_col = example_group,
              knowns_treatment = "count") 
#> Loading required package: pacman
```

``` r
kableExtra::kbl(output_table, format = "pipe")
```

| Grouping | Subgroup   | short | long | Known in Group | Unknowns |
|:---------|:-----------|------:|-----:|---------------:|---------:|
| Species  | setosa     |  0.55 |   NA |            150 |        0 |
| Species  | versicolor |  0.45 | 0.36 |            150 |        0 |
| Species  | virginica  |    NA | 0.64 |            150 |        0 |

This creates the output contained in this table:
[test_prop.csv](https://github.com/tomambroseharris/THfuncs/files/9499011/test_prop.csv)

The proportion of total petal length that is contained in each species
is split by the example group: short and long petal lengths, the
mutate() assignment for which can be seen above.
