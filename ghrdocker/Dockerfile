FROM ubuntu:20.04

RUN apt-get update && apt-get -y install curl \
    iputils-ping \
    apt-transport-https \
    tar \
    jq \
    python && \
    apt-get clean && apt-get autoremove

ARG GH_RUNNER_VERSION="2.283.3"
WORKDIR /actions-runner
RUN curl -o actions.tar.gz --location "https://github.com/actions/runner/releases/download/v${GH_RUNNER_VERSION}/actions-runner-linux-x64-${GH_RUNNER_VERSION}.tar.gz" && \
    tar -zxf actions.tar.gz && \
    rm -f actions.tar.gz && \
    ./bin/installdependencies.sh

COPY entrypoint.sh .
RUN chmod +x entrypoint.sh
ENTRYPOINT ["/actions-runner/entrypoint.sh"]