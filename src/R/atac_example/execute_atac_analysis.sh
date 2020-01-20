#!/bin/bash
#Run SQL query and execute ATAC-seq analysis on output.

CD=$(pwd)
cd ./src/R/atac_example
Rscript ./atac_example_query.R > ./tcell_timecourse.csv
R -e "rmarkdown::render('./20JAN20-atacseq_analysis_parameters.Rmd',params=list(input_file='./tcell_timecourse.csv'),output_format='html_document')"
cd $CD
