FROM pyiron/continuum:2021-11-08

LABEL maintainer="Muhammad Hassani <hassani@mpie.de>"

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Europe/Berlin

USER root

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone
# Installing openfoam, precice, and the necessary apt packages
COPY apt.txt /tmp/
RUN wget -q -O - https://dl.openfoam.com/add-debian-repo.sh | bash && \
    apt update && \
    DEBIAN_FRONTEND="noninteractive" TZ="Europe/Berlin" sudo apt-get install -y openfoam2106-dev && \
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

WORKDIR $HOME

USER root
RUN chmod +x ${HOME}/include_notebooks.sh && \
    /bin/bash include_notebooks.sh &&\
    fix-permissions /home/$DOCKER_USER && \
    fix-permissions $CONDA_DIR
    
USER $DOCKER_UID
WORKDIR $HOME

