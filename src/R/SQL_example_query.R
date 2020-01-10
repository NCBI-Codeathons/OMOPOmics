setwd("~/Downloads")
library(DBI)
library (tidyverse)

con <- dbConnect(RSQLite::SQLite(), dbname = ":memory:")

dbListTables(con)

res <- dbSendQuery(con, "SELECT * FROM condition_occurance WHERE 
                   condition_source_value == T-cell activation")

dbFetch(res) 


dbDisconnect(con)




# details <- read.table("GSE60682_details.tsv", header = T, sep = "\t")