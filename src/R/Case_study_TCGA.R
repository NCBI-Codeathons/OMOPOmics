
# PURPOSE --------

#' To load, reformat, and structure TCGA data for use by ROMOPOmics


# load libraries ----------------------------------------------------------

library(tidyverse)
library(data.table)
library(RTCGA.clinical)
library(RTCGA.mutations)


# cleaning and reformatting BRCA clinical data --------------------------------------------------------------

brca_clinical_dt_wide <- 
  RTCGA.clinical::BRCA.clinical %>% 
  data.table()

# the above is in wide format and I'd like to make it long 
# so we can revise the column names to remove the periods

brca_clinical_dt_wide[,.(admin.file_uuid,
                         patient.biospecimen.cqcf.normal.controls.normal.control.bcr_sample_uuid,
                         patient.bcr_patient_barcode,
                         patient.bcr_patient_uuid)]

brca_clinical_dt_long <- 
  brca_clinical_dt_wide %>% 
  melt(id.vars=c("patient.bcr_patient_barcode")) %>% 
  na.omit()

# With the above I'd now like to make it snake case and get rid of those periods
brca_clinical_dt_long_snake_case <- 
  brca_clinical_dt_long[,
                      .(snake_case_variable = str_to_lower(variable) %>% str_replace_all("\\.","_")),
                      .(patient.bcr_patient_barcode,value)
                      ]

# Now I'm going to make this wide again but now the column names are much nicer

brca_clinical_dt_long_snake_case[order(snake_case_variable)]$snake_case_variable %>% unique() %>% head(100)

brca_clinical_dt_long_snake_case[grepl("patient_anatomic_neoplasm_subdivisions_anatomic_neoplasm_subdivision",
                                       snake_case_variable)
                                 ] %>% dcast(patient.bcr_patient_barcode ~ snake_case_variable)
  
brca_clinical_dt_long_snack_case_wide <- 
  brca_clinical_dt_long_snake_case[
    snake_case_variable %in% c("admin_bcr",
                               "admin_file_uuid",
                               "patient_bcr_patient_uuid",
                               "patient_days_to_birth",
                               "patient_days_to_death",
                               "patient_age_at_initial_pathologic_diagnosis","admin_project_code",
                               "patient_ethnicity",
                               "patient_biospecimen_cqcf_tumor_samples_tumor_sample_tumor_necrosis_percent",
                               "patient_number_of_lymphnodes_positive_by_he",
                               "patient_number_of_lymphnodes_positive_by_ihc",
                               "patient_lymph_node_examined_count",
                               "patient_anatomic_neoplasm_subdivisions_anatomic_neoplasm_subdivision"
                               )
  ] %>% 
  dcast(patient.bcr_patient_barcode ~ snake_case_variable,value.var="value")

brca_clinical_dt_long_snack_case_wide_transpose <- 
  brca_clinical_dt_long_snack_case_wide %>% 
  t() %>% 
  data.table()

x <- "column_name"
brca_clinical_dt_long_snack_case_wide_transpose$column_name <- 
  colnames(brca_clinical_dt_long_snack_case_wide)

brca_clinical_dt_long_snack_case_wide_transpose_reorder <- 
  brca_clinical_dt_long_snack_case_wide_transpose[,
                                                  c(x,paste0("V",
                                                             1:(ncol(brca_clinical_dt_long_snack_case_wide_transpose)-1))
                                                  ),
                                                  with=F]

dim(brca_clinical_dt_long_snack_case_wide_transpose_reorder)
brca_clinical_dt_long_snack_case_wide_transpose_reorder[1:50,1:5]

brca_clinical_dt_long_snack_case_wide_transpose_reorder$column_name <- 
  lapply(brca_clinical_dt_long_snack_case_wide_transpose_reorder[,column_name],
       function(x){splt <- str_split(x,"_"); paste0(splt[[1]][2:length(splt[[1]])],collapse="_")})

brca_clinical_dt_long_snack_case_wide_transpose_reorder$column_name[[1]] <- 
  paste0("bcr_",brca_clinical_dt_long_snack_case_wide_transpose_reorder$column_name[[1]])

brca_clinical_dt_long_snack_case_wide_transpose_reorder %>% 
  fwrite("RTCGA_data/brca_clinical.csv")

barcodes <- 
  brca_clinical_dt_long_snack_case_wide_transpose_reorder[
    column_name=="patient.bcr_patient_barcode"
    ] %>% 
  unlist %>% 
  unname

# cleaning and reformatting BRCA mutation data --------------------------------------------------------------

brca_mutation_dt_wide <- 
  RTCGA.mutations::BRCA.mutations %>% 
  data.table()

brca_mutation_dt_long <- 
  brca_mutation_dt_wide %>% 
  melt(id.vars=c("bcr_patient_barcode")) %>% 
  na.omit()

bcr_map <- 
  unique(brca_mutation_dt_long[,
                             .(bcr_patient_barcode)
                             ]
       )[,
         .(bcr_patient_barcode,split = str_split(bcr_patient_barcode,"-")
           )
         ]

bcr_map$split_join <- sapply(bcr_map$split,function(x){paste0(str_to_lower(x[1:3]),collapse="-")})

tmp <- merge( 
  bcr_map[,
          .(bcr_patient_barcode,split_join)
          ],
  brca_mutation_dt_long,
  by="bcr_patient_barcode"
  )[
    ,c("bcr_patient_barcode") := list(NULL)
  ]

setnames(tmp,c("split_join"),c("bcr_patient_barcode"))

brca_mutation_dt_long_snake_case <- 
  tmp[,
      .(snake_case_variable = str_to_lower(variable)),
      .(bcr_patient_barcode,value)
      ]

brca_mutation_dt_long_snake_case$snake_case_variable %>% unique()

brca_mutation_dt_long_snack_case_wide <- 
  brca_mutation_dt_long_snake_case[
    snake_case_variable %in%
      c("tumor_sample_uuid","ncbi_build","sequencer",
        "bam_file","matched_norm_sample_barcode","tumor_sample_barcode",
        "validation_method","sequence_source")
  ] %>% 
  dcast(bcr_patient_barcode ~ snake_case_variable,value.var="value",fun.aggregate=function(x){x[1]})

brca_mutation_dt_long_snack_case_wide_transpose <- 
  brca_mutation_dt_long_snack_case_wide %>% 
  t() %>% 
  data.table()

x <- "column_name"
brca_mutation_dt_long_snack_case_wide_transpose$column_name <- 
  colnames(brca_mutation_dt_long_snack_case_wide)

brca_mutation_dt_long_snack_case_wide_transpose_reorder <- 
  brca_mutation_dt_long_snack_case_wide_transpose[,
                                                c(x,paste0("V",
                                                           1:(ncol(brca_mutation_dt_long_snack_case_wide_transpose)-1))
                                                  ),
                                                with=F] 

dim(brca_mutation_dt_long_snack_case_wide_transpose_reorder)
brca_mutation_dt_long_snack_case_wide_transpose_reorder[1:10,1:5]

brca_mutation_dt_long_snack_case_wide_transpose_reorder %>% 
  fwrite("RTCGA_data/brca_mutation.csv")
