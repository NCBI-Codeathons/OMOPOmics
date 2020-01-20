prettifyColnames      <- function(in_text="specimen_id"){
  paste0(
    toupper(substr(in_text,start = 1,stop = 1)),
    gsub("_"," ",substr(in_text,start=2,stop=nchar(in_text))))
}
parseDayTime          <- function(dt_input = "224-00:00:00"){
  if(str_detect(dt_input,pattern="[:digit:]+-[:digit:]{1,2}:[:digit:]{2}:[:digit:]{2}")){
    mtch      <- as.integer(str_match(dt_input,pattern="([:digit:]+)-([:digit:]{1,2}):([:digit:]{2}):([:digit:]{2})")[,-1])
  }else if(str_detect(dt_input,pattern="[:digit:]{1,2}:[:digit:]{2}:[:digit:]{2}")){
    mtch      <- c(0,as.integer(str_match(dt_input,pattern="(^[:digit:]{1,2}):([:digit:]{2}):([:digit:]{2})")[,-1]))
  }else{
    mtch      <- c(NA,NA,NA,NA)
  }
  names(mtch)  <- c("days","hours","minutes","seconds")
  return(mtch)
}
add_conditional_panel <- function(tab_name = "assay_occurrence",table_set = tabs){
  tb_title<- prettifyColnames(tab_name)
  tb      <- table_set[[tab_name]]
  opt_nms <- colnames(tb)
  tog_name<- paste(tab_name,"toggle",sep="_")
  col_name<- paste(tab_name,"colSelect",sep="_")
  pan_cond<- paste0("input.",tog_name," == true")
  pan     <- 
    list(
      prettyToggle(inputId = tog_name,
                   label_on = tb_title,
                   label_off = tb_title,
                   value = FALSE),
      conditionalPanel(
        condition=pan_cond,
        lapply(opt_nms,add_conditional_filter,tab_name=tab_name,table_set=table_set)
      ))
  return(pan)
}
add_conditional_filter<- function(filt_name = "gender_source_value",tab_name = "person_table",table_set=tabs,default_true_cols=def_cols){
  input_pfx   <- paste(tab_name,filt_name,sep=".")
  tog_name    <- paste(input_pfx,"return",sep=".")
  tog_val     <- filt_name %in% default_true_cols
  flt_name    <- paste(input_pfx,"filter",sep=".")
  opts        <- table_set[[tab_name]] %>%
    as_tibble() %>%
    select(filt_name) %>% 
    arrange() %>%
    unlist(use.names=FALSE)
  
  fluidRow(
    column(1),
    column(1,checkboxInput(inputId = tog_name,label = NULL,value = tog_val)),
    column(10,selectInput(inputId = flt_name,label= prettifyColnames(filt_name),selected = NULL,choices = unique(opts),multiple = TRUE))
  ) %>% 
  return()
}
stacked_filters       <- function(table_in  = x,filter_list =filts,exclude=FALSE){
  #This probably recreates functionality available in dbplyr, but I can't find it...
  # Submit a table and a list of named filters: name should correspond to a table column,
  # values are a list of values to allow for. If <exclude>==TRUE, invert and only take 
  # columns WITHOUT these values.
  table_out     <- table_in
  if(exclude){
    for(flt_nm in names(filter_list)){
      flts      <- filter_list[[flt_nm]]
      table_out <- filter(table_out,!(!!as.name(flt_nm) %in% flts))
    }
  }else{
    for(flt_nm in names(filter_list)){
      flts      <- filter_list[[flt_nm]]
      table_out <- table_out %>% filter(!!as.name(flt_nm) %in% flts)
    }
  }
  return(table_out)
}
vectify               <- function(table_in, value_col, name_col){
  #Takes in two columns of a table, one for values and one for names, and returns
  # a named vector.
  select      <- dplyr::select
  nms         <- unlist(select(table_in, !!as.name(name_col)), use.names = FALSE)
  vals        <- as.list(select(table_in, !!as.name(value_col)))[[1]]
  names(vals) <- nms
  return(vals)
}
