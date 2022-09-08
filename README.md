
# THfuncs

## Installation

You can install the development version of THfuncs like so:


```{r, eval=FALSE}
# install.packages("devtools")
library(devtools)
devtools::install_github("tomambroseharris/THfuncs", force = TRUE)
library(THfuncs)
```

# Purpose

THfuncs houses functions created to help with data analysis, data manipulation and other functionality in R.  

The first (and currently only function) contained in this package is `prop_in_group()`. This transforms tidy data into a grouped proportion table, using columns in the data. It can be generalised to summarise wide data frames, as shown in the example below.



## See what the function does
```{r, eval=FALSE}
?prop_in_group()
```

# Use
```{r, eval=FALSE}
data("iris")
iris
iris <- iris %>% mutate(example_group = if_else(Petal.Length > 4, "long", "short"))

```

The output looks like this
```{r, echo = FALSE, eval = TRUE}
library(magrittr)
iris_table <- tibble::tribble(~`Sepal.Length` ~`Sepal.Width` ~`Petal.Length` ~`Petal.Width`    ~`Species`,
"1", "2", "3", "4", "5")

```

```{r, eval=FALSE}
output <- prop_in_group(input_df = iris,
              value_col = Petal.Length,
              breakdowns_vector = c("Species"),
              group_by_col = example_group,
              knowns_treatment = "count")

```

This creates the output contained in this table:
[test_prop.csv](https://github.com/tomambroseharris/THfuncs/files/9499011/test_prop.csv)

The proportion of total petal length that is contained in each species is split by the example group: short and long petal lengths, the mutate() assignment for which can be seen above. 

