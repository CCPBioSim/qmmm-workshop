# Start with BioSim base image.
ARG BASE_IMAGE=latest
FROM ghcr.io/ccpbiosim/jupyterhub-base:$BASE_IMAGE

LABEL maintainer="James Gebbie-Rayet <james.gebbie@stfc.ac.uk>"

ARG TARGETPLATFORM
ARG AMBERTOOLS_VER=26

# Switch to jovyan user.
USER $NB_USER
WORKDIR $HOME

# Install workshop deps
RUN mamba install nglview pandas numpy matplotlib scipy ambertools=$AMBERTOOLS_VER -y 
WORKDIR /tmp

# Install Wham.
USER root
RUN cd /opt && \
    mkdir wham && \
    wget http://membrane.urmc.rochester.edu/sites/default/files/wham/wham-release-2.0.11.tgz && \
    tar xvf wham-release-2.0.11.tgz -C wham --strip-components=1 && \
    rm wham-release-2.0.11.tgz && \
    cd wham/wham && \
    make clean && \
    make &&\
    chown -R $NB_USER:$NB_GID /opt/wham

# Switch to jovyan user.
USER $NB_USER
WORKDIR $HOME

# Add the exec to the path.
ENV WHAM_HOME=/opt/wham

# Add all of the workshop files to the home directory
COPY --chown=1000:100 . .
RUN rm -rf AUTHORS LICENSE _config.yml README.md docker .git .github

RUN if [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
      sed -i 's%trajin rc0.00/md1ps.nc%trajin rc-0.00/md1ps.nc%' /home/jovyan/data/make_us_trj.in; \
    fi

# Copy lab workspace
COPY --chown=1000:100 docker/default-37a8.jupyterlab-workspace /home/jovyan/.jupyter/lab/workspaces/default-37a8.jupyterlab-workspace

# Always finish with non-root user as a precaution.
USER $NB_USER
