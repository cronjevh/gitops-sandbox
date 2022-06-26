FROM ubuntu:18.04

ARG Powershell_Version=7.0.10\*
ARG Terraform_Version=1.1.3
ARG Azure_Powershell_Version=4.5.0
ARG Kubectl_Version=1.24.2-00
ARG Helm_Version=v3.9.0

# To make it easier for build and release pipelines to run apt-get,
# configure apt to not require confirmation (assume the -y argument by default)
ENV DEBIAN_FRONTEND=noninteractive
RUN echo "APT::Get::Assume-Yes \"true\";" > /etc/apt/apt.conf.d/90assumeyes

RUN apt-get update \
&& apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        jq \
        git \
        iputils-ping \
        libcurl4 \
        libicu60 \
        libunwind8 \
        netcat \
        libssl1.0 \
		zip \
		unzip \
&& rm -rf /var/lib/apt/lists/*

RUN curl -LsS https://aka.ms/InstallAzureCLIDeb | bash \
  && rm -rf /var/lib/apt/lists/*

# get `wget` & software-properties-common
# https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-linux?view=powershell-7#ubuntu-1804
RUN apt-get update && \
    apt-get install -y wget unzip apt-utils curl software-properties-common

# get powershell for 18.04 - Gotta have pwsh ...
RUN wget -q https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb && \
    dpkg -i packages-microsoft-prod.deb && \
    apt-get update && \
    add-apt-repository universe && \
    apt-get install -y powershell=${Powershell_Version}

# Get Kubectl
# https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-using-native-package-management
RUN wget --quiet -O - https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -  && \
    echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list && \
    apt-get update && apt-get install -y kubectl=${Kubectl_Version}

# Get Helm3
RUN wget --quiet -O - https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get | bash -s -- -v ${Helm_Version}

# Get AZ Powershell core modules
# https://docs.microsoft.com/en-us/powershell/azure/install-az-ps?view=azps-3.6.1
RUN pwsh -c 'Install-Module -Force -Name Az -AllowClobber -Scope AllUsers -MaximumVersion "'${Azure_Powershell_Version}'"'

# Install Flux CLI https://fluxcd.io/docs/installation/
RUN curl -s https://fluxcd.io/install.sh | bash

# Install tfctl CLI 
RUN wget --quiet https://github.com/weaveworks/tf-controller/releases/download/v0.10.0-rc.4/tfctl_Linux_amd64.tar.gz && \
    tar xf tfctl_Linux_amd64.tar.gz && \
    mv tfctl /usr/local/bin

# # Install SOPS CLI 
RUN wget --quiet https://github.com/mozilla/sops/releases/download/v3.7.3/sops-v3.7.3.linux.amd64 && \
    mv sops-v3.7.3.linux.amd64 /usr/local/bin/sops && chmod +x /usr/local/bin/sops

WORKDIR /azp

COPY ./start.sh .
RUN chmod +x start.sh

CMD ["./start.sh"]