
# THfuncs

# Purpose

The THfuncs R packages houses functions created to help with data
analysis, data manipulation and other functionality in R.

The first (and currently only function) contained in this package is
`prop_in_group()`. This function transforms tidy data into a grouped
proportion table, using columns in the data. It can be generalised to
summarise wide data frames, as shown in the example below.

## Installation

You can install the development version of THfuncs like so:

``` r
# install.packages("devtools")
library(devtools)
devtools::install_github("tomambroseharris/THfuncs", force = TRUE)
library(THfuncs)
```

## prop_in_group

### See what the function does

``` r
?prop_in_group()
```

# Example use

``` r
data("iris")
iris
iris <- iris %>% mutate(example_group = if_else(Petal.Length > 4, "long", "short"))
```

The output looks like this

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
```

``` r
kableExtra::kbl(output_table, format = "pipe")
```

| Grouping | Subgroup   | short | long | Known in Group | Unknowns |
|:---------|:-----------|------:|-----:|---------------:|---------:|
| Species  | setosa     |  0.55 |   NA |            150 |        0 |
| Species  | versicolor |  0.45 | 0.36 |            150 |        0 |
| Species  | virginica  |    NA | 0.64 |            150 |        0 |

The proportion of total petal length that is contained in each species
is split by the example group: short and long petal lengths, the
mutate() assignment for which can be seen above. The breakdowns vector
means that multiple different breakdowns can be included in a given
table. These will be stacked on top of each other. The text in
breakdowns_vector will be parsed to the grouping column, the unique
values in that column will become the subgroup. There need be no
group_by column. If there is none, the function will operate on the data
frame as a whole.
