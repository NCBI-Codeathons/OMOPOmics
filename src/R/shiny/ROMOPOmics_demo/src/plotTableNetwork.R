#!/bin/Rscript
#Demo the table dependencies and selections via plot.
library(GGally) #https://briatte.github.io/ggnet/
library(network)
library(sna)

plotTableNetwork  <- function(dependency_matrix,mode_out="circle",selected="All",
                              def_cols = "lightgray",def_edge_cols="lightgray",
                              def_size = 4, def_edge_size = 0.3,
                              def_alpha=0){
  mtx <- dependency_matrix
  net <- network(mtx,directed = TRUE)
  vert_cols   <- rep(def_cols,length(net$val))
  vert_size   <- rep(def_size,length(net$val))
  vert_alph   <- rep(0,length(net$val))
  edge_cols   <- rep(def_edge_cols,length(net$mel))
  edge_size   <- rep(def_edge_size,length(net$mel))
  
  if(selected!="All"){
    sel   <- rownames(mtx) == selected
    dep   <- which(as.logical(mtx[,selected]))
    sup   <- which(as.logical(mtx[selected,]))
    vrt   <- which(rownames(mtx) == selected)
    
    sup_edges   <- unlist(net$oel[which(sel)])
    dep_edges   <- unlist(net$iel[which(sel)])
    
    vert_size[vrt]        <- 8
    vert_size[dep]        <- 6
    vert_cols[vrt]        <- "black"
    vert_cols[sup]        <- "black"
    vert_cols[dep]        <- "red"
    #vert_alph[vrt]        <- 1
    edge_cols[sup_edges]  <- "black"
    edge_cols[dep_edges]  <- "red"
    edge_size[c(dep_edges,sup_edges)] <- 0.6
  }
  #network.vertex.names(net)   <- toupper(network.vertex.names(net))
  ggnet2(net,
         shape = 19,
         label = TRUE,
         mode = mode_out, #"fruchtermanreingold"
         edge.size = edge_size,
         arrow.size = 5,
         arrow.gap = 0.07,
         node.size = 40,
         alpha = vert_alph,
         edge.color = edge_cols,
         label.color = vert_cols,
         label.size = vert_size) %>%
  return
}


