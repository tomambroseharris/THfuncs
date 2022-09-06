#' @title <Function for Proportions>
#' @description <full descrip>
#' @param input_df an input data frame
#' @param value_col values
#' @param breakdowns_vector descrip
#' @param group_by_col desc
#' @export
#' @return NULL


prop_in_group <- function(input_df,
                          value_col,
                          breakdowns_vector,
                          group_by_col = NULL){
  
  if (!require("pacman")) install.packages("pacman")
  #This loads the packages within the p_load function
  pacman::p_load(dplyr,
                 data.table,
                 tidyverse,
                 janitor)
  
  
  if(missing(group_by_col)){
    
    input_df <- input_df %>%
      mutate(All = "All")
    
    group_by_col <- as.name("All")
  }
  
  
  
  
  
  unique_in_group <- input_df %>%
    dplyr::select({{group_by_col}}) %>%
    unique() %>%
    pull()
  
  
  
  
  
  # create an empty data frame: this is a df with all the headings needed in the output table, but with no rows
  # this allows the subsequently created tables to be bound onto the bottom of it
  # to understand for QA purposes, you could run: unique_in_group %>% purrr::map_dfc(~tibble::tibble(!!.x := logical())) with unique_in_group as any vector
  empty_df <- unique_in_group %>% purrr::map_dfc(~tibble::tibble(!!.x := logical())) %>%
    # there are additional columns included in the final table that do not come from the grouping column.
    # These are Grouping, Characteristic, `Known in Group` and Unknowns.
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
    
    # extract a single number for the total KNOWN FPE
    Char_Total <- input_df %>% filter(!!as.name(i) != "Unknown") %>% # !!as.name() calls the object associated with the character string, i, this will be a column
      summarise(Total_value = sum({{value_col}})) %>%
      pull()
    
    # extract a single number for the total UNKNOWN FPE
    Char_Unknown <- input_df %>% filter(is.na(!!as.name(i))) %>%
      summarise(Total_value = sum({{value_col}})) %>%
      pull()
    
    
    
    
    # extract the column that will be used to pivot_wider below. This cannot be nested in the pivotwider function itself
    pivot_col <- deparse(substitute(group_by_col))
    
    # create a summary table for the characteristic i
    Char_Summary <- input_df %>%
      filter(!is.na(!!as.name(i))) %>% # remove unknowns
      group_by(!!as.name(i), {{group_by_col}}) %>% # group by the characteristic (i) and the grouping column defined in the function
      summarise(Total = sum({{value_col}}), .groups = "drop") %>% # summarise the total FPE in those characteristics
      pivot_wider(names_from = all_of(pivot_col), values_from = "Total") %>% #pivot wider, leaving the characteristics as a column and creating new columns out of all the unique variables in the group_col
      adorn_totals("row") # add a total row to the bottom of the df
    
    # count the number of rows in Char_Summary
    row_total <- nrow(Char_Summary)
    
    Char_Summary <- Char_Summary %>%
      # this creates percentages out of the numeric columns. It divides each row by the data in the nth row.
      # because we have counted the number of rows above, this will always be the total row
      mutate_if(is.numeric, ~round(./.[[row_total]], 2)) %>%
      filter(!!as.name(i) != "Total") %>% # remove the total row from the bottom of the df (this will have the value 1 in it, because it's just been divided by itself)
      mutate(`Known in Group` = Char_Total, # add a known total row. Assign all rows the value extracted above: the total FPE when filtering out unknowns
             Unknowns = Char_Unknown, # do as above for unknowns
             Grouping = i)  # create a grouping column filled with whatever characteristic (i) is being grouped by in this loop
    
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
      bind_rows(Char_Summary)
    
    
    
  }
  
  return(binding_df)
  
}