FROM golang:1.14.0 AS golang
RUN mkdir /root/go

##############################################################################
#### terragrunt
##############################################################################
RUN export GO111MODULE=on && \
    go get github.com/gruntwork-io/terragrunt@v0.22.5

##############################################################################
#### terraform
##############################################################################
RUN export GO111MODULE=on && \
    go get github.com/hashicorp/terraform@v0.12.24

RUN mkdir /go/src/panos-commit
COPY go/panos-commit.go /go/src/panos-commit/
RUN go get github.com/PaloAltoNetworks/pango && \
    cd /go/src/panos-commit && \
    go build panos-commit.go && \
    mv /go/src/panos-commit/panos-commit /go/bin/



FROM centos:7.7.1908 AS builder
WORKDIR /root/

RUN yum -y install epel-release
RUN yum -y install unzip

##############################################################################
#### 1Password CLI
##############################################################################
RUN cd /root/ && \
    curl -O https://cache.agilebits.com/dist/1P/op/pkg/v0.8.0/op_linux_amd64_v0.8.0.zip && \
    unzip op_linux_amd64_v0.8.0.zip

##############################################################################
#### k2tf
##############################################################################
RUN cd /root/ && \
    curl -LO https://github.com/sl1pm4t/k2tf/releases/download/v0.3.0/k2tf_0.3.0_Linux_x86_64.tar.gz && \
    tar xvf k2tf_0.3.0_Linux_x86_64.tar.gz

##############################################################################
#### helm
##############################################################################
RUN cd /root/ && \
    mkdir helm && \
    cd helm && \
    curl -LO https://get.helm.sh/helm-v3.1.1-linux-amd64.tar.gz && \
    tar xvf helm-v3.1.1-linux-amd64.tar.gz

##############################################################################
#### kubectl
##############################################################################
RUN cd /root/ && \
    curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.17.0/bin/linux/amd64/kubectl && \
    chmod +x ./kubectl

RUN cd /root/ && \
    mkdir providers

##############################################################################
#### terraform provider
#### 1Password
##############################################################################
RUN cd providers && \
    curl -LO https://github.com/anasinnyk/terraform-provider-1password/releases/download/0.5.0/terraform-provider-onepassword-linux-amd64.tar.gz && \
    tar xvf terraform-provider-onepassword-linux-amd64.tar.gz && \
    rm terraform-provider-onepassword-linux-amd64.tar.gz

##############################################################################
#### terraform provider
#### Ansible
##############################################################################
RUN cd providers && \
    curl -LO https://github.com/nbering/terraform-provider-ansible/releases/download/v1.0.3/terraform-provider-ansible-linux_amd64.zip && \
    unzip terraform-provider-ansible-linux_amd64.zip && \
    rm terraform-provider-ansible-linux_amd64.zip

##############################################################################
#### terraform provider
#### RKE
##############################################################################
RUN cd providers && \
    curl -LO https://github.com/rancher/terraform-provider-rke/releases/download/0.14.1/terraform-provider-rke_0.14.1_linux-amd64.zip && \
    unzip terraform-provider-rke_0.14.1_linux-amd64.zip && \
    rm terraform-provider-rke_0.14.1_linux-amd64.zip

##############################################################################
#### END BUILDER STAGE
#### START IMAGE
##############################################################################

FROM centos:7.7.1908
ENV LC_ALL=en_US.UTF-8
RUN yum -y install epel-release
RUN yum -y update && \
    yum -y install zsh \
           openssh \
           git \
           gcc \
           less \
           python3-devel \
           krb5-devel \
           krb5-workstation \
           make \
           openssl-devel \
           unzip \
           iputils \
           golang \
           jq \
           bind-dnssec-utils \
           bind-utils \
           vim && \
    yum clean all

RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

RUN mkdir -p /go/bin /workspaces /root/.ssh/ /root/.terraform.d/plugins/linux_amd64
COPY --from=golang /go/bin/* /usr/local/bin/
COPY --from=builder /root/op /usr/local/bin/
COPY --from=builder /root/k2tf /usr/local/bin/
COPY --from=builder /root/helm/linux-amd64/helm /usr/local/bin/
COPY --from=builder /root/kubectl /usr/local/bin/
COPY --from=builder /root/providers/* /root/.terraform.d/plugins/linux_amd64/

WORKDIR /workspaces

COPY requirements.txt /workspaces/

RUN pip3 install -r requirements.txt && rm requirements.txt

COPY workspace.zsh-theme /root/.oh-my-zsh/themes/
COPY zshrc /root/.zshrc
COPY vimrc /root/.vimrc

RUN localedef -i en_US -f UTF-8 en_US.UTF-8

ENV SHELL /bin/zsh

