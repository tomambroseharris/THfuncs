#' Summarise the proportions of a df (population) which fall in each of n categories
#'
#' @description produce a summary table showing the proportion of a numeric column within groups and subgroups, which are assigned by the values in the corresponding row of other columns
#' @param input_df an input data frame
#' @param breakdowns_vector a vector containing the column names of each group to see the proportion for
#' @param value_col the population values to be summed. If the purpose is to count rows, leave this blank blank.
#' @param group_by_col an additional layer of grouping, if required, to see a broader subset
#' @param prop_dps how many decimal places to make the proportion. The default is 2, representing a percentage with no decimals
#' @param include_knowns whether to include a count or sum of NA values in the df. Default == "yes"
#' @param knowns_treatment inlcude "sum" or "count" to specify how to calculate the unknowns/known instances column
#' @param round_knowns_to_nearest the number to round the knowns/unknowns to e.g. 1,5,10
#' @return The output from the function - a data frame with 5+ columns: grouping (containing each element in the breakdowns vector); subgroup (containing each unique value within each grouping); a column per group_by_col unique value, if none, this will just be the prop_in_total_group; how many rows had known values; and how many unknowns there were
#' @seealso function documentation at: https://github.com/tomambroseharris/THfuncs
#' @export
#'
#'
prop_in_group <- function(input_df,
                          breakdowns_vector,
                          value_col = NULL,
                          group_by_col = NULL,
                          value_or_prop = "prop",
                          prop_dps = 2,
                          include_knowns = "yes",
                          knowns_treatment = "count",
                          round_knowns_to_nearest = 1){

  # load necessary complimentary packages
  if (!require("pacman")) install.packages("pacman")
  #This loads the packages within the p_load function
  pacman::p_load(dplyr,
                 data.table,
                 tidyverse,
                 janitor)

  `%notin%` <- Negate(`%in%`)

  # if there is not an additional group_by column, create a column for all rows
  if(missing(group_by_col) && value_or_prop == "prop"){

    input_df <- input_df %>%
      mutate(Proportion = "Proportion")

    # assign the group_by col
    group_by_col <- as.name("Proportion")
  } else if (missing(group_by_col) && value_or_prop == "value"){

    input_df <- input_df %>%
      mutate(Value = "Value")

    # assign the group_by col
    group_by_col <- as.name("Value")

  } else if (value_or_prop %notin% c("value", "prop")){

    stop("Acceptable inputs for value_or_prop are 'value' or 'prop'; the default is 'prop'.")
  }

  #if there is no value column, this implies that the function should count rows rather than summing values. Therefore, create a column equal to one
  if(missing(value_col)){

    input_df <- input_df %>%
      mutate(prop_group = 1)

    # assign the group_by col
    value_col <- as.name("prop_group")
  }

  # select the unique inputs in the group_by column
  # if this is automatically assigned as "All", then "All" will be the only thing extracted
  unique_in_group <- input_df %>%
    dplyr::select({{group_by_col}}) %>%
    unique() %>%
    pull()


  # create an empty data frame: this is a df with all the headings needed in the output table, but with no rows
  # this allows the subsequently created tables to be bound onto the bottom of it
  # to understand for QA purposes, you could run: unique_in_group %>% purrr::map_dfc(~tibble::tibble(!!.x := logical())) with unique_in_group as any vector
  empty_df <- unique_in_group %>% purrr::map_dfc(~tibble::tibble(!!.x := logical())) %>%
    # there are additional columns included in the final table that do not come from the grouping column.
    # These are Grouping, Subgroup, `Known in Group` and Unknowns.
    # The add_column() function makes columns with the correct data structure for what will eventually be bound to them
    add_column(Grouping = as.character(),
               Subgroup = as.character(),
               `Known in Group` = as.numeric(),
               Unknowns = as.numeric())

  # retrieve the number of columns in the data frame
  empty_df_ncols <- ncol(empty_df)

  # create a binding data frame from the empty data frame
  binding_df <- empty_df %>%
    # select the columns in the order that they are wanted for presentation purposes
    dplyr::select(Grouping, Subgroup, 1:all_of(empty_df_ncols))

  # run a loop around each of the elements in the breakdowns_vector to create summary tables

  for(i in breakdowns_vector){


    # run some if loops, depending on how we want to count (or sum) unknown / known values.
    # the input to knowns_treatment will affect this
    if(knowns_treatment == "sum"){

      # extract a single number for the total KNOWN values
      Char_Total <- input_df %>% filter(!!as.name(i) != "Unknown") %>% # !!as.name() calls the object associated with the character string, i, this will be a column
        summarise(Total_value = sum({{value_col}})) %>%
        pull()

      # extract a single number for the total UNKNOWN values
      Total_Value <- input_df %>%
        summarise(Total_value = sum({{value_col}})) %>%
        pull()

      Char_Unknown <- Total_Value - Char_Total

    } else if (knowns_treatment == "count"){

      # extract a single number for the total KNOWN values
      Char_Total <- input_df %>% filter(!!as.name(i) != "Unknown") %>% # !!as.name() calls the object associated with the character string, i, this will be a column
        summarise(Total_value = nrow(.)) %>%
        pull()

      # extract a single number for the total UNKNOWN values
      Total_Value <- input_df %>%
        summarise(Total_value = nrow(.)) %>%
        pull()

      Char_Unknown <- Total_Value - Char_Total

    } else {
      stop("Acceptable inputs for knowns_treatment are 'sum' or 'count'; the default is 'sum'.")
    }


    # extract the column that will be used to pivot_wider below. This cannot be nested in the pivotwider function itself
    pivot_col <- deparse(substitute(group_by_col))

    # create a summary table for the subgroup i
    Char_Summary <- input_df %>%
      filter(!is.na(!!as.name(i))) %>% # remove unknowns
      group_by(!!as.name(i), {{group_by_col}}) %>% # group by the subgroup (i) and the grouping column defined in the function
      summarise(Total = sum({{value_col}}), .groups = "drop") %>% # summarise the total FPE in those characteristics
      pivot_wider(names_from = all_of(pivot_col), values_from = "Total") %>% #pivot wider, leaving the characteristics as a column and creating new columns out of all the unique variables in the group_col
      adorn_totals("row") # add a total row to the bottom of the df

    # count the number of rows in Char_Summary
    row_total <- nrow(Char_Summary)


    if(value_or_prop == "prop"){

    Char_Summary <- Char_Summary %>%
      # this creates percentages out of the numeric columns. It divides each row by the data in the nth row.
      # because we have counted the number of rows above, this will always be the total row
      mutate_if(is.numeric, ~round(./.[[row_total]], prop_dps)) %>%
      filter(!!as.name(i) != "Total")

    } else if (value_or_prop == "value"){

      Char_Summary <- Char_Summary %>%
        mutate_if(is.numeric, ~.[[row_total]]) %>%
        filter(!!as.name(i) != "Total")

    }  else {
      stop("Acceptable inputs for include_knowns are 'yes' or 'no'; the default is 'yes'.")

}


    Char_Summary <- Char_Summary  %>% # remove the total row from the bottom of the df (this will have the value 1 in it, because it's just been divided by itself)
      mutate(`Known in Group` = Char_Total, # add a known total row. Assign all rows the value extracted above: the total FPE when filtering out unknowns
             Unknowns = Char_Unknown, # do as above for unknowns
             Grouping = i)  # create a grouping column filled with whatever subgroup (i) is being grouped by in this loop

    # count the number of columns in the summary table
    # this is identical to empty_df_ncols above, but do it again here because it's clearer
    col_numbers <- ncol(Char_Summary)



    # reorder the Char_Summary table
    Char_Summary <- Char_Summary %>%
      dplyr::select(Grouping,
                    # select the second column (i), but rename it as "Subgroup"
                    # this is required for all the data frames to have identical names for when they're bound together
                    # because we've put what the characteristic is in the grouping column above, we still have an identifier
                    "Subgroup" = !!as.name(i),
                    # select all of the rest of the columns in the df in the order they're in
                    2:all_of(col_numbers))

    # bind the rows of this Char summary to the binding df
    # for the first loop, binding_df will be empty at this stage
    # for each subsequent one, it will have the previous Char_Summary tables already bound above
    binding_df <- binding_df %>%
      bind_rows(Char_Summary) %>%
      mutate(across(c(`Known in Group`, `Unknowns`), ~ plyr::round_any(.x, round_knowns_to_nearest, f = round)))

      if(include_knowns == "yes"){
      NULL
    } else if (include_knowns == "no"){

      binding_df <- binding_df %>%
        select(-`Known in Group`, -`Unknowns`)

    }  else {
       stop("Acceptable inputs for include_knowns are 'yes' or 'no'; the default is 'yes'.")

    }

  }

  return(binding_df)

}
