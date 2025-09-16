# Start with BioSim base image.
ARG BASE_IMAGE=latest
FROM ghcr.io/ccpbiosim/jupyterhub-base:$BASE_IMAGE

LABEL maintainer="James Gebbie-Rayet <james.gebbie@stfc.ac.uk>"
LABEL org.opencontainers.image.source=https://github.com/jimboid/biosim-qmmm-workshop
LABEL org.opencontainers.image.description="A container environment for the ccpbiosim workshop on QM/MM."
LABEL org.opencontainers.image.licenses=MIT

ARG TARGETPLATFORM

# Root to install "rooty" things.
USER root

# Install Wham.
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

# Install workshop deps
RUN conda install ipywidgets nglview pandas numpy matplotlib compilers -y
RUN if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
      conda install conda-forge::ambertools -y; \
    elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
      mamba install conda-forge/osx-arm64::ambertools -y; \
    fi

# Export important paths.
ENV AMBERHOME=/opt/conda
ENV WHAM_HOME=/opt/wham

# Add all of the workshop files to the home directory
COPY --chown=1000:100 . .
RUN rm -r AUTHORS LICENSE _config.yml README.md docker .git .github

# Copy lab workspace
COPY --chown=1000:100 docker/default-37a8.jupyterlab-workspace /home/jovyan/.jupyter/lab/workspaces/default-37a8.jupyterlab-workspace

# UNCOMMENT THIS LINE FOR REMOTE DEPLOYMENT
COPY docker/jupyter_notebook_config.py /etc/jupyter/

# Always finish with non-root user as a precaution.
USER $NB_USER
