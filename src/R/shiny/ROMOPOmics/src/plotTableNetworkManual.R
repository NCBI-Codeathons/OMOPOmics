#!/bin/Rscript
#Demo the table dependencies and selections via plot.
#This manual version requires that all table identities be known ahead of time.

plotTableNetworkManual  <- function(table_list = tabs,inc_tables){
  tibble(table_names = names(table_list)) %>%
    mutate(include=table_names %in% inc_tables) %>%
    mutate(xmin=case_when(table_names %in% c("condition_occurrence","person","provider") ~ 0,
                          table_names %in% c("assay_parameters","specimen","perturbation") ~ 2,
                          TRUE ~ 3.2),
           xmax=xmin + 1,
           ymin=case_when(table_names %in% c("condition_occurrence","assay_parameters","assay_occurrence") ~ 2.25,
                          table_names %in% c("person","specimen") ~ 1,
                          TRUE ~ 0),
           ymax=case_when(table_names %in% c("person","specimen") ~ ymin + 1,
                          TRUE ~ ymin + 0.75),
           medical_tab = table_names %in% c("specimen","person","provider","condition_occurrence"),
           x = (xmin+xmax) / 2,
           y = (ymin+ymax) / 2,
           label = paste0(toupper(substr(table_names,1,1)),
                          substr(table_names,2,nchar(table_names))) %>%
                    gsub("_","\n",.)) %>% 
    ggplot(aes(xmin=xmin,xmax=xmax,ymin=ymin,ymax=ymax,x=x,y=y,
                  alpha=include,fill=medical_tab,label=label)) +
    annotate(geom="segment",x=0.5,xend=0.5,y=0.75, yend=2.25, color="darkgray",size=2,lineend="round") +
    annotate(geom="segment",x=2.5,xend=2.5,y=0.75, yend=2.25, color="darkgray",size=2,lineend="round") +
    annotate(geom="segment",x=0.5,xend=2.5,y=1.5, yend=1.5, color="darkgray",size=2,lineend="round") +
    annotate(geom="segment",x=2.5,xend=3.7,y=1.75,yend=1.75,color="darkgray",size=2,lineend="round") +
    annotate(geom="segment",x=2.5,xend=3.7,y=1.25,yend=1.25,color="darkgray",size=2,lineend="round") +
    annotate(geom="segment",x=3.7,xend=3.7,y=1.75,yend=2.25, color="darkgray",size=2,lineend="round") +
    annotate(geom="segment",x=3.7,xend=3.7,y=1.25,yend=0.75, color="darkgray",size=2,lineend="round") +
    geom_rect(size=1,color="black",show.legend = FALSE) +
    geom_text(show.legend = FALSE,size=7) +
    scale_alpha_manual(values=c(`TRUE`=1,`FALSE`=0.3)) +
    theme(panel.background = element_blank(),
          axis.text=element_blank(),
          axis.ticks= element_blank(),
          axis.title = element_blank(),
          plot.background = element_rect(size=1,fill=NA,color="black")) %>%
    return
}
