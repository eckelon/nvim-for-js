FROM node:12-slim

ENV USER_NAME appuser
ENV USER_HOME /home/$USER_NAME
ENV PLUGDIR  $USER_HOME/.local/share/nvim/site/autoload/
ENV DEVDIR $USER_HOME/development
ENV NVIM $USER_HOME/squashfs-root/usr/bin/nvim


RUN useradd -ms /bin/bash $USER_NAME \
    && apt-get update \
    && apt-get install git ctags -y --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

USER $USER_NAME

WORKDIR $USER_HOME

RUN wget https://github.com/neovim/neovim/releases/download/nightly/nvim.appimage --no-check-certificate \
    && chmod a+x ./nvim.appimage \
    && ./nvim.appimage --appimage-extract \
    && mkdir -p $USER_HOME/.config/nvim \
    && mkdir -p $PLUGDIR \
    && wget -P $PLUGDIR https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim --no-check-certificate \
    && git config --global http.sslVerify false \
    && curl --compressed -o- -L https://yarnpkg.com/install.sh | bash

COPY nvim/ $USER_HOME/.config/nvim

VOLUME $DEVDIR

RUN ./squashfs-root/usr/bin/nvim +PlugInstall +qall

WORKDIR $DEVDIR
CMD $NVIM $DEVDIR
