FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Etc/UTC

# Base toolchain + Python + Java (for Bazel)
RUN apt-get update && apt-get install -y \
    git python3 python3-pip python3-dev \
    openjdk-11-jdk curl unzip zip build-essential \
    pkg-config libffi-dev libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Bazelisk (auto-manages Bazel versions)
RUN curl -L https://github.com/bazelbuild/bazelisk/releases/download/v1.20.0/bazelisk-linux-amd64 \
      -o /usr/local/bin/bazel && chmod +x /usr/local/bin/bazel

# Grab TensorFlow (shallow clone is fine; build will still be huge)
RUN git clone --depth=1 https://github.com/tensorflow/tensorflow.git /src/tensorflow
WORKDIR /src/tensorflow

# Preinstall Python deps commonly needed by TF’s configure
RUN python3 -m pip install --no-cache-dir numpy wheel packaging setuptools keras_preprocessing \
    && python3 -m pip install --no-cache-dir --upgrade pip

# Non-interactive configure (CPU-only, opt build).
# Adjust as needed; this keeps it big but avoids CUDA prompts.
ENV TF_NEED_CUDA=0 \
    CC_OPT_FLAGS="-march=x86-64-v3" \
    PYTHON_BIN_PATH=/usr/bin/python3 \
    TF_DOWNLOAD_CLANG=0 \
    TF_SET_ANDROID_WORKSPACE=0

RUN yes "" | ./configure

# BIG BUILD: pip wheel target (very heavy).
# The bazel cache (~ /root/.cache/bazel) will balloon.
RUN bazel build --jobs=$(nproc) \
  //tensorflow/tools/pip_package:wheel

# (Optional) Keep more artifacts to grow final image:
# RUN bazel build --jobs=$(nproc) //tensorflow/... :all
