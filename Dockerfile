# syntax=docker/dockerfile:experimental
# FROM ubuntu:16.04
FROM nvidia/cuda:10.2-devel-ubuntu18.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TERM=xterm-256color

RUN echo "dash dash/sh boolean false" | debconf-set-selections && \
  dpkg-reconfigure dash

RUN sed -i 's/archive.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list

# RUN --mount=type=cache,sharing=locked,id=aptlib,target=/var/lib/apt \
#     --mount=type=cache,sharing=locked,id=aptcache,target=/var/cache/apt \
RUN apt update && apt install -y --no-install-recommends \
    autoconf \
    automake \
    autotools-dev \
    bison \
    build-essential \
    ctags \
    curl \
    docker.io \
    flex \
    ffmpeg \
    gdb \
    global \
    git \
    htop \
    iputils-ping \
    less \
    libboost-dev \
    libcurl4-openssl-dev \
    libeigen3-dev \
    libevent-dev \
    libgl1-mesa-glx \
    liblua5.2-dev \
    libncurses5 \
    libncurses5-dev \
    libopencv-dev \
    libperl-dev \
    libreadline-dev \
    libssl1.0.0 \
    libx11-dev libxtst-dev libxt-dev libsm-dev libxpm-dev \
    locales \
    lsb-release \
    lua5.2 \
    m4 \
    man \
    mpich \
    nasm \
    net-tools \
    openssh-server \
    openssl \
    pkg-config \
    psutils \
    rsync \
    silversearcher-ag \
    software-properties-common \
    sudo \
    tree \
    wget \
    zip unzip \
    zsh
    # apt clean && rm -rf /var/lib/apt/lists/*

# python3.7
RUN add-apt-repository -y ppa:deadsnakes/nightly && \
  apt update && \
  apt install -y python3.7 python3.7-dev python3.7-venv python3.7-distutils && \
  update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.7 37

# pip
RUN curl https://bootstrap.pypa.io/get-pip.py | python3

# vim & tmux
# RUN --mount=type=tmpfs,target=/tmp \
RUN \
  # aws \
  pushd /tmp && \
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip && \
  unzip awscliv2.zip && ./aws/install && \
  # vim 8.2 \
  git clone --depth 1 --branch v8.2.1862 https://github.com/vim/vim.git && \
  pushd vim && \
  ./configure \
    --prefix=/usr/local \
    --enable-gui=auto \
    --with-x \
    --with-features=huge \
    --enable-multibyte \
    --enable-python3interp=yes \
    --with-python3-config-dir='/usr/lib/python3.7/config-3.7m-x86_64-linux-gnu' \
    --enable-perlinterp=yes \
    --enable-luainterp=yes \
    --enable-cscope && make -j$(nproc) install && \
  popd && \
  # tmux \
  git clone https://github.com/tmux/tmux.git && \
  pushd tmux && git checkout 3.2 && \
  bash ./autogen.sh && ./configure --prefix=/usr/local && make -j$(nproc) install &&  \
  popd
  # # su-exec \
  # git clone https://github.com/ncopa/su-exec.git && \
  # pushd su-exec && \
  # make && cp su-exec /sbin && \
  # popd

# locales
ENV LANGUAGE=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
RUN locale-gen en_US.UTF-8 && dpkg-reconfigure locales

RUN curl -sL https://deb.nodesource.com/setup_15.x | sudo -E bash - && \
  sudo apt-get install -y nodejs

# RUN --mount=type=cache,id=custom-pip,target=/root/.cache/pip \
RUN pip3 install \
    cmake \
    ipdb \
    ipympl \
    jupyterlab==2.2.9 \
    matplotlib \
    numpy \
    opencv-python \
    pandas \
    scipy \
    six \
    tqdm

RUN pip3 install \
  plotly==4.14.3 \
  qgrid && \
  jupyter nbextension enable --py --sys-prefix widgetsnbextension && \
  jupyter nbextension enable --py --sys-prefix qgrid && \
  jupyter labextension install @jupyter-widgets/jupyterlab-manager@2.0 && \
  jupyter labextension install jupyter-matplotlib && \
  jupyter labextension install qgrid2 && \
  jupyter labextension install jupyterlab-plotly@4.14.3 && \
  jupyter labextension install plotlywidget@4.14.3

RUN npm install --global http-server
