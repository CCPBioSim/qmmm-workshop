# Start with BioSim base image.
ARG BASE_IMAGE=latest@sha256:5eb67b09e3fdf64b3128bd9501e08a0cbb007804b678f2096728d8c1260e6217
FROM ghcr.io/ccpbiosim/jupyterhub-base:$BASE_IMAGE

LABEL maintainer="James Gebbie-Rayet <james.gebbie@stfc.ac.uk>"

ARG TARGETPLATFORM
ARG AMBERTOOLS_VER=26

# Switch to jovyan user.
USER $NB_USER
WORKDIR $HOME

# Install workshop deps
RUN conda install -y -c conda-forge \
    conda-forge::nglview=4.0.1 \
    conda-forge::pandas=3.0.5 \
    conda-forge::numpy=2.5.3 \
    conda-forge::matplotlib=3.11.1 \
    conda-forge::scipy=1.18.1 \
    conda-forge::ambertools=$AMBERTOOLS_VER
WORKDIR /tmp

COPY docker/fix-nglview.sh /tmp/fix-nglview.sh
RUN bash /tmp/fix-nglview.sh

# Install Wham.
USER root
RUN cd /opt && \
    mkdir wham && \
    wget https://github.com/agrossfield/wham/archive/refs/tags/v2.1.1.tar.gz && \
    tar xvf v2.1.1.tar.gz -C wham --strip-components=1 && \
    rm v2.1.1.tar.gz && \
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
