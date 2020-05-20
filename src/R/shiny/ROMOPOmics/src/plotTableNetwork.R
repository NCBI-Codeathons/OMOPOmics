#!/bin/Rscript
#Demo the table dependencies and selections via plot.
library(GGally) #https://briatte.github.io/ggnet/
library(network)
library(sna)

plotTableNetwork  <- function(dependency_matrix){
  net <- network(dependency_matrix,directed = TRUE)
  network.vertex.names(net)   <- gsub("_","\n",colnames(mtx))
  ggnet2(net,node.size = 40,shape = 15,label = TRUE,
         edge.color = "black",edge.size = 5,arrow.size = 25,arrow.gap = 0.08,
         color = ifelse(colnames(mtx) %in% inc_tables,"lightgreen","gray"),
         label.size = ifelse(colnames(mtx) %in% key_tables,9,5)) %>%
  return
}


