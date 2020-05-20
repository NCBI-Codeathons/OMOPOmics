# Base image https://hub.docker.com/u/rocker/
# Tutorials from https://www.statworx.com/blog/running-your-r-script-in-docker/
# and https://www.r-bloggers.com/how-to-dockerize-shinyapps/

# get latest version of rocker/shiny
FROM rocker/shiny:latest

# Establish working directory.
WORKDIR ./

# Copy all files in the application's directory.
COPY . .

# install R-packages.
RUN Rscript -e 'install.packages("renv")'
RUN Rscript -e 'renv::restore()'

# expose port.
EXPOSE 3838

# run application.
CMD ["R", "-e", "shiny::runApp('/app',host='0.0.0.0', port=3838)"]
