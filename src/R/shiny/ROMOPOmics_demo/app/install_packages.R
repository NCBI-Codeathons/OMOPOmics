#Install packages.
install.packages("tidyverse")
install.packages("data.table")
install.packages("RSQLite")
install.packages("DBI")
install.packages("shiny")

#Install ROMOPomics from local directory.
library("devtools")
install("./ROMOPOmics")