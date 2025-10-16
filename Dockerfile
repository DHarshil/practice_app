FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC

# Base toolchain + Python + Java + venv support
RUN apt-get update && apt-get install -y \
    git python3 python3-venv python3-dev \
    openjdk-11-jdk curl unzip zip build-essential \
    pkg-config libffi-dev libssl-dev \
 && rm -rf /var/lib/apt/lists/*

# Create an isolated Python environment
RUN python3 -m venv /opt/pyenv
ENV VIRTUAL_ENV=/opt/pyenv
ENV PATH="${VIRTUAL_ENV}/bin:${PATH}"
ENV PIP_NO_CACHE_DIR=1 PIP_DISABLE_PIP_VERSION_CHECK=1

# Bazelisk
RUN curl -L https://github.com/bazelbuild/bazelisk/releases/download/v1.20.0/bazelisk-linux-amd64 \
      -o /usr/local/bin/bazel && chmod +x /usr/local/bin/bazel

# TensorFlow source
RUN git clone --depth=1 https://github.com/tensorflow/tensorflow.git /src/tensorflow
WORKDIR /src/tensorflow

# Python deps inside the venv
RUN python -m pip install --upgrade pip \
 && python -m pip install numpy wheel packaging setuptools keras_preprocessing

# Non-interactive TF configure (CPU-only) — point to venv’s python
ENV TF_NEED_CUDA=0 \
    CC_OPT_FLAGS="-march=x86-64-v3" \
    PYTHON_BIN_PATH=/opt/pyenv/bin/python \
    TF_DOWNLOAD_CLANG=0 \
    TF_SET_ANDROID_WORKSPACE=0

RUN yes "" | ./configure

# Big build
RUN bazel build --jobs=$(nproc) //tensorflow/tools/pip_package:wheel

# (optional) see how big the Bazel cache got
# RUN du -sh /root/.cache/bazel || true
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC

# Base toolchain + Python + Java + venv support
RUN apt-get update && apt-get install -y \
    git python3 python3-venv python3-dev \
    openjdk-11-jdk curl unzip zip build-essential \
    pkg-config libffi-dev libssl-dev \
 && rm -rf /var/lib/apt/lists/*

# Create an isolated Python environment
RUN python3 -m venv /opt/pyenv
ENV VIRTUAL_ENV=/opt/pyenv
ENV PATH="${VIRTUAL_ENV}/bin:${PATH}"
ENV PIP_NO_CACHE_DIR=1 PIP_DISABLE_PIP_VERSION_CHECK=1

# Bazelisk
RUN curl -L https://github.com/bazelbuild/bazelisk/releases/download/v1.20.0/bazelisk-linux-amd64 \
      -o /usr/local/bin/bazel && chmod +x /usr/local/bin/bazel

# TensorFlow source
RUN git clone --depth=1 https://github.com/tensorflow/tensorflow.git /src/tensorflow
WORKDIR /src/tensorflow

# Python deps inside the venv
RUN python -m pip install --upgrade pip \
 && python -m pip install numpy wheel packaging setuptools keras_preprocessing

# Non-interactive TF configure (CPU-only) — point to venv’s python
ENV TF_NEED_CUDA=0 \
    CC_OPT_FLAGS="-march=x86-64-v3" \
    PYTHON_BIN_PATH=/opt/pyenv/bin/python \
    TF_DOWNLOAD_CLANG=0 \
    TF_SET_ANDROID_WORKSPACE=0

RUN yes "" | ./configure

# Big build
RUN bazel build --jobs=$(nproc) //tensorflow/tools/pip_package:wheel

# (optional) see how big the Bazel cache got
# RUN du -sh /root/.cache/bazel || true
