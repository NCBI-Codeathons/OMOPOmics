# OMOPOmics

clone repository with `git clone https://github.com/NCBI-Codeathons/OMOPOmics.git` 

There exists limited infrastructure for matching patient electronic health records (EHR) to patient molecular samples. A standardized infrastructure, i.e. following the [OHDSI common data model](https://ohdsi.github.io/TheBookOfOhdsi/), allows for population and patient-level analyses to improve medical practice and understand disease. 

We propose extending an EHR common data model for characterizing associated patient data, with a specific application towards T-cell data to better treat auto-inflammatory diseases.

![](docs/imgs/chroma-t-cell_scheme.png)

We have created an extension to the [OHDSI common data model](https://ohdsi.github.io/TheBookOfOhdsi/) towards patient T-cell 'omics profiling. We have evaluated our infrastructure with example queries and analyses (Qu et.al., 2015 [DOI](https://doi.org/10.1016/j.cels.2015.06.003.)).

# Using Example OMOPOmics Dataset

Run `SQL_build.R`  to initialize a SQL data base of example paitient ATAC-seq data sets from individuals with cutaneous T-cell lymphoma, healthy individuals with T-cell activation, or control patients. 

Perform queries **YASH**


# Using OMOPOmics Framework

![](docs/imgs/OMOPOmics_use_flowchart.png)

1. Collect/Extract Data 
        Collect detailed information regarding patient demographic, NGS assay parameters, 

2. Enter Data into Relevant Tables

3. Initialize SQL database with `SQL_build.R` command 

4. Perform directed search query for specific terms 
        e.g. **select** file_source_value **where** file_type_source_value == "BED" 
        **and** assay_source_value == ATAC **and** condition_source_value == "CTCL"

5. Export search results in .txt/.csv/.tsv
        
6. Use file paths/relevant parameters in automated analysis pipelines
            







