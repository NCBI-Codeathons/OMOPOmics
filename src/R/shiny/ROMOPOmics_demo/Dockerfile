# Base image https://hub.docker.com/u/rocker/
# Tutorials from https://www.statworx.com/blog/running-your-r-script-in-docker/
# and https://www.r-bloggers.com/how-to-dockerize-shinyapps/

# get latest version of rocker/shiny
FROM rocker/shiny:latest

# system libraries of general use
## install debian packages
RUN apt-get update -qq && apt-get -y --no-install-recommends install \
    libxml2-dev \
    libcairo2-dev \
    libsqlite3-dev \
    libmariadbd-dev \
    libpq-dev \
    libssh2-1-dev \
    unixodbc-dev \
    libcurl4-openssl-dev \
    libssl-dev

# Establish working directory.
WORKDIR ./

# Copy all files in the application's directory.
COPY . .

# install R-packages.
RUN Rscript -e 'install.packages("renv")'
RUN Rscript -e 'renv::restore()'
RUN Rscript -e 'devtools::install("./ROMOPOmics")'

# expose port.
EXPOSE 3838

# run application.
CMD ["R", "-e", "shiny::runApp('/app',host='0.0.0.0', port=3838)"]
