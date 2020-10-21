# syntax=docker/dockerfile:experimental
FROM ubuntu:16.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TERM=xterm-256color

RUN echo "dash dash/sh boolean false" | debconf-set-selections && \
  dpkg-reconfigure dash

RUN sed -i 's/archive.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list \
  && apt clean

RUN --mount=type=cache,sharing=locked,id=aptlib,target=/var/lib/apt \
    --mount=type=cache,sharing=locked,id=aptcache,target=/var/cache/apt \
  apt update && apt install -y --no-install-recommends \
    autoconf \
    automake \
    autotools-dev \
    bison \
    build-essential \
    ctags \
    curl \
    docker.io \
    flex \
    gdb \
    global \
    git \
    htop \
    libevent-dev \
    liblua5.2-dev \
    libncurses5 \
    libncurses5-dev \
    libperl-dev \
    libreadline-dev \
    libssl1.0.0 \
    locales \
    lsb-release \
    lua5.2 \
    m4 \
    man \
    nasm \
    openssh-server \
    openssl \
    pkg-config \
    psutils \
    silversearcher-ag \
    software-properties-common \
    sudo \
    wget \
    zsh && \
    apt clean && rm -rf /var/lib/apt/lists/*

# python3.7
RUN add-apt-repository -y ppa:deadsnakes/nightly && \
  apt update && \
  apt install -y python3.7 python3.7-dev python3.7-venv python3.7-distutils && \
  apt clean && rm -rf /var/lib/apt/lists/* && \
  update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.5 35 && \
  update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.7 37

# pip
RUN curl https://bootstrap.pypa.io/get-pip.py | python3

# vim & tmux
RUN --mount=type=tmpfs,target=/tmp \
  # vim 8.2 \
  pushd /tmp && \
  git clone --depth 1 --branch v8.2.1862 https://github.com/vim/vim.git && \
  pushd vim && \
  ./configure \
    --prefix=/usr/local \
    --with-features=huge \
    --enable-multibyte \
    --enable-python3interp=yes \
    --with-python3-config-dir='/usr/lib/python3.7/config-3.7m-x86_64-linux-gnu' \
    --enable-perlinterp=yes \
    --enable-luainterp=yes \
    --enable-cscope && make -j$(nproc) install && \
  popd && \
  # tmux 2.6 \
  git clone --depth 1 --branch 2.6 https://github.com/tmux/tmux.git && \
  pushd tmux && \
  bash ./autogen.sh && ./configure --prefix=/usr/local && make -j$(nproc) install &&  \
  popd && \
  # su-exec \
  git clone https://github.com/ncopa/su-exec.git && \
  pushd su-exec && \
  make && cp su-exec /sbin && \
  popd

# add user
RUN useradd -ms /bin/zsh guoqiang && \
  echo "guoqiang:a" | chpasswd && \
  echo 'guoqiang ALL=(ALL:ALL) ALL' >> /etc/sudoers
WORKDIR /home/guoqiang
ENV HOME /home/guoqiang

# oh-my-zsh
RUN bash -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" && \
  git clone https://github.com/zsh-users/zsh-autosuggestions $HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions && \
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting && \
  find $HOME/.oh-my-zsh -name .git | xargs rm -rf

# vim
COPY /dotfiles/vimrc .vimrc
RUN curl -fLo $HOME/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim && \
    vim +PlugInstall +qall && \
    find $HOME/.vim/plugged/YouCompleteMe -name 'libclang-*.tar.*' -delete
    # find $HOME/.vim/plugged -name .git | xargs rm -rf && 

COPY /ycm_extra_conf.py .ycm_extra_conf.py
COPY /dotfiles/tmux.conf .tmux.conf
COPY /dotfiles/zshrc .zshrc
COPY /dotfiles/UltiSnips .vim/UltiSnips

# locales
ENV LANGUAGE=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
RUN locale-gen en_US.UTF-8 && dpkg-reconfigure locales

# git config
RUN git config --global user.name "gq" && \
  git config --global user.email "gq"

RUN mkdir -p $HOME/.pip && \
  echo "[global]" > $HOME/.pip/pip.conf && \
  echo "http://mirrors.aliyun.com/pypi/simple/" >> $HOME/.pip/pip.conf && \
  pip3 install -U --no-cache-dir \
    cmake \
    ipdb \
    jupyter \
    matplotlib \
    numpy \
    opencv-python \
    six \
    tqdm

# entrypoint
COPY entrypoint.sh /bin/entrypoint.sh
ENTRYPOINT ["/bin/entrypoint.sh"]
