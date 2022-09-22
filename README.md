
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

|    UKPRN | Name                                                  | Country  | Ofs_Tariff_1920       | TEF_1819 | Student numbers | Total Expenditure |
|---------:|:------------------------------------------------------|:---------|:----------------------|:---------|----------------:|:------------------|
| 10007814 | Cardiff University                                    | Wales    | NA                    | Silver   |           33510 | 573,201           |
| 10007790 | The University of Edinburgh                           | Scotland | NA                    | No TEF   |           37830 | 1,060,066         |
| 10007794 | The University of Glasgow                             | Scotland | NA                    | No TEF   |           37145 | 695,820           |
| 10000291 | Anglia Ruskin University Higher Education Corporation | England  | HEIs with low scores  | Silver   |           32180 | 270,231           |
| 10008640 | Falmouth University                                   | England  | Specialist HEI        | Gold     |            6170 | 64,303            |
| 10007760 | Birkbeck College                                      | England  | Specialist HEI        | Silver   |           12070 | 106,783           |
| 10007792 | University of Exeter                                  | England  | HEIs with high scores | Gold     |           30250 | 512,915           |
| 10007799 | University of Newcastle upon Tyne                     | England  | HEIs with high scores | Gold     |           27775 | 530,603           |
| 10007154 | University of Nottingham, the                         | England  | HEIs with high scores | Gold     |           35785 | 683,714           |
