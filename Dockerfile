FROM pyiron/continuum:2021-10-05

LABEL maintainer="Muhammad Hassani <hassani@mpie.de>"

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Europe/Berlin

USER root

# Installing openfoam, precice, and the necessary apt packages
COPY apt.txt /tmp/
RUN wget -q -O - https://dl.openfoam.com/add-debian-repo.sh | bash && \
    apt update && \
    sudo apt-get install -y openfoam2106-dev && \
    xargs -a /tmp/apt.txt apt-get install -y && \
    apt-get clean && \
    rm /tmp/apt.txt

# installing openfoam adapter
USER ${DOCKER_UID}


# installing fenics adapter
COPY . ${HOME}/
RUN mamba env update -n base -f ${HOME}/environment.yml --prune && \
    conda clean --all -f -y && \
    conda list



SHELL ["/bin/bash", "-c", "source /usr/lib/openfoam/openfoam2106/etc/bashrc"]

USER $DOCKER_UID
WORKDIR $HOME

USER root
RUN fix-permissions $CONDA_DIR && \
    fix-permissions /home/$DOCKER_USER
    
USER $DOCKER_UID
WORKDIR $HOME

