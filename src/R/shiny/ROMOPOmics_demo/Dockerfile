#https://www.bioconductor.org/packages/release/bioc/vignettes/sevenbridges/inst/doc/rstudio.html
# Base image https://hub.docker.com/u/rocker/
# Tutorials from https://www.statworx.com/blog/running-your-r-script-in-docker/
# and https://www.r-bloggers.com/how-to-dockerize-shinyapps/

# get latest version of rocker/shiny
FROM andrewc160/base_shiny:latest

# Establish working directory.
WORKDIR ./

# Copy all files in the application's directory.
COPY . .

# install ROMOPOmics
RUN Rscript -e 'devtools::install("./ROMOPOmics")'

# expose port.
EXPOSE 3838

# run application.
CMD ["R", "-e", "shiny::runApp('/app',host='0.0.0.0', port=3838)"]
