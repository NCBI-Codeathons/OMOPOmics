#' genderConceptID
#'
#' Function to translate assorted male/female/NA inputs into gender concept IDs.
#'
#' @param gender_val Accepts male/female/NA, M/F/NA, 8507/8532/8551.
#'
#' genderConceptID()
#'
#' @export

genderConceptID   <- function(gender_val){
  sapply(tolower(as.character(gender_val)), function(x)
    case_when(x=="male" ~ "8507",
              x=="m" ~ "8507",
              x=="8507" ~ "8507",
              x=="female" ~ "8532",
              x=="f" ~ "8532",
              x=="8532" ~ "8532",
              TRUE ~ "8551"))
}
