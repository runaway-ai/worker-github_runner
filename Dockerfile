# Base image
FROM nvidia/cuda:12.9.1-cudnn-devel-ubuntu24.04

# Use bash shell with pipefail option
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Set the working directory
WORKDIR /

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV RUNNER_ALLOW_RUNASROOT=1

# GitHub runner version argument
ARG RUNNER_VERSION=2.327.1

# Update and upgrade the system packages (Worker Template)
RUN apt-get update && apt-get install -y \
    curl libssl-dev libffi-dev libicu-dev libunwind8 libcurl4 \
    zlib1g libkrb5-3 liblttng-ust-dev libgssapi-krb5-2 \
    openssh-server python3 python3-dev python3-pip sudo && \
    apt-get clean && rm -rf /var/lib/apt/lists/*


# Install Python dependencies (Worker Template)
COPY builder/requirements.txt /requirements.txt
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install --upgrade -r /requirements.txt --no-cache-dir --break-system-packages && \
    rm /requirements.txt

# cd into the user directory, download and unzip the github actions runner
RUN mkdir actions-runner && cd actions-runner \
    && curl -O -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz && \
    rm -rf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

# install some additional dependencies
RUN /actions-runner/bin/installdependencies.sh

# Add src files (Worker Template)
ADD src .

CMD python3 -u /handler.py
