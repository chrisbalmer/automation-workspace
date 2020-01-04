FROM centos:7.6.1810 AS builder
WORKDIR /root/

RUN yum -y install epel-release
RUN yum -y install unzip golang

RUN mkdir /root/go \
    && export GO111MODULE=on \
    && go get github.com/gruntwork-io/terragrunt@v0.21.10 \
    && go get github.com/hashicorp/terraform@v0.12.18

RUN cd /root/ \
    && curl -O https://cache.agilebits.com/dist/1P/op/pkg/v0.8.0/op_linux_amd64_v0.8.0.zip \
    && unzip op_linux_amd64_v0.8.0.zip

RUN cd /root/ \
    && mkdir providers \
    && cd providers \
    && curl -LO https://github.com/anasinnyk/terraform-provider-1password/releases/download/0.5.0/terraform-provider-onepassword-linux-amd64.tar.gz \
    && tar xvf terraform-provider-onepassword-linux-amd64.tar.gz \
    && rm terraform-provider-onepassword-linux-amd64.tar.gz \
    && curl -LO https://github.com/rancher/terraform-provider-rke/releases/download/0.14.1/terraform-provider-rke_0.14.1_linux-amd64.zip \
    && unzip terraform-provider-rke_0.14.1_linux-amd64.zip \
    && rm terraform-provider-rke_0.14.1_linux-amd64.zip

FROM centos:7.6.1810
ENV LC_ALL=en_US.UTF-8
RUN yum -y install epel-release
RUN yum -y update \
    && yum -y install zsh \
               openssh \
               git \
               gcc \
               less \
               python3-devel \
               krb5-devel \
               krb5-workstation \
               openssl-devel \
               unzip \
               iputils \
               golang \
               jq \
               bind-dnssec-utils \
               bind-utils \
               vim \
    && yum clean all

RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

RUN mkdir -p /go/bin /workspace /root/.ssh/ /root/.terraform.d/plugins/linux_amd64
COPY --from=builder /root/go/bin/* /root/go/bin/
COPY --from=builder /root/op /usr/local/bin/
COPY --from=builder /root/providers/* /root/.terraform.d/plugins/linux_amd64/

WORKDIR /workspace

COPY requirements.txt /workspace/

RUN pip3 install -r requirements.txt && rm requirements.txt

COPY workspace.zsh-theme /root/.oh-my-zsh/themes/
COPY zshrc /root/.zshrc

RUN localedef -i en_US -f UTF-8 en_US.UTF-8

ENV SHELL /bin/zsh

