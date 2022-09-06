---
output: github_document
---

# THfuncs

THfuncs hols functions that I have created. These are intended to make data analysis, data manipulation and other analytical outputs easier to accomplish. 

The first function is a summary proportion function, produced originally for equalities analysis in the Higher Education Analysis team. The function summarises wide data by give groups and characteristics, taking account of unknown values (NAs) and different sample sets.
It can be generalised to summarise other data frames, as shown in the example below

## Installation

You can install the development version of THfuncs like so:


```{r, eval=FALSE}
# install.packages("devtools")
library(devtools)
devtools::install_github("tomambroseharris/THfuncs", force = TRUE)
library(THfuncs)
```

## See what the function does
```{r, eval=FALSE}
?prop_in_group()
```

# Use
```{r, eval=FALSE}
data("iris")
iris
iris <- iris %>% mutate(example_group = if_else(Petal.Length > 4, "long", "short"))

output <- prop_in_group(input_df = iris,
              value_col = Petal.Length,
              breakdowns_vector = c("Species"),
              group_by_col = example_group,
              knowns_treatment = "count")

```

This creates the output contained below
[test_prop.csv](https://github.com/tomambroseharris/THfuncs/files/9499011/test_prop.csv)
