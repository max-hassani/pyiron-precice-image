FROM pyiron/continuum:2021-10-05

LABEL maintainer="Muhammad Hassani <hassani@mpie.de>"

USER root

# Installing openfoam, precice, and the necessary apt packages
COPY apt.txt /tmp/
RUN apt update && \
    wget https://github.com/precice/precice/releases/download/v2.3.0/libprecice2_2.3.0_focal.deb && \
    apt-get install -y ./libprecice2_2.3.0_focal.deb && \
    wget -q -O - https://dl.openfoam.com/add-debian-repo.sh | bash && \
    apt update && \
    sudo apt-get install -y openfoam2106-dev && \
    xargs -a /tmp/apt.txt apt-get install -y && \
    apt-get clean && \
    rm /tmp/apt.txt && \
    rm libprecice2_2.3.0_focal.deb

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
RUN git clone --branch=master --depth 1 https://github.com/precice/openfoam-adapter && \
    cd openfoam-adapter && \
    sed -i 's/$(pkg-config --silence-errors --cflags libprecice)/ /g' Allwmake && \
    sed -i 's/$(pkg-config --silence-errors --libs libprecice)/ /g' Allwmake && \
    ./Allwmake 

USER root
RUN fix-permissions $CONDA_DIR && \
    fix-permissions /home/$DOCKER_USER
    
USER $DOCKER_UID
WORKDIR $HOME

