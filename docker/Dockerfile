# Start with BioSim base image.
ARG BASE_IMAGE=latest
FROM ghcr.io/ccpbiosim/jupyterhub-base:$BASE_IMAGE

LABEL maintainer="James Gebbie-Rayet <james.gebbie@stfc.ac.uk>"

ARG AMBERTOOLS_DL=null

# Install workshop deps
RUN mamba install ipywidgets nglview pandas numpy matplotlib scipy -y

USER root
RUN mkdir /opt/amber22 && \
    chown 1000:100 -R /opt/amber22 
WORKDIR /tmp

RUN wget $AMBERTOOLS_DL/AmberTools22.tar.bz2

RUN tar xvjf AmberTools22.tar.bz2 && \
    rm AmberTools22.tar.bz2

WORKDIR /tmp/amber22_src
RUN ./update_amber --update
RUN mkdir /tmp/build
WORKDIR /tmp/build

RUN cmake /tmp/amber22_src -DCMAKE_INSTALL_PREFIX=/opt/amber22 -DBUILD_PYTHON=TRUE -DCMAKE_INSTALL_RPATH_USE_LINK_PATH=TRUE -DDOWNLOAD_MINICONDA=FALSE -DCOMPILER=MANUAL -DBUILD_GUI=FALSE -DCOMPILER=GNU -DOPENMP=TRUE -DCUDA=FALSE -DMPI=FALSE -DUSE_FFT=True -DBUILD_DEPRECATED=False -DBUILD_INDEV=False -DBUILD_PERL=True -DOPTIMIZE=True
RUN make -j8
RUN make install

# Cleanup.
RUN rm -r /tmp/amber22_src /tmp/build

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

# Export important paths.

# Add the exec to the path.
ENV AMBERHOME=/opt/amber22
ENV PATH="$PATH:/opt/amber22/bin"
ENV LD_LIBRARY_PATH="$AMBERHOME/lib"
ENV PERL5LIB="$AMBERHOME/lib/perl"
ENV WHAM_HOME=/opt/wham

# Add all of the workshop files to the home directory
COPY --chown=1000:100 . .
RUN rm -rf AUTHORS LICENSE _config.yml README.md docker .git .github

# Copy lab workspace
COPY --chown=1000:100 docker/default-37a8.jupyterlab-workspace /home/jovyan/.jupyter/lab/workspaces/default-37a8.jupyterlab-workspace

# Always finish with non-root user as a precaution.
USER $NB_USER
