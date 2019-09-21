FROM fedora:30 AS builder
WORKDIR /root/

RUN dnf -y install unzip golang

RUN mkdir /root/go \
    && export GO111MODULE=on \
    && go get github.com/gruntwork-io/terragrunt@v0.19.21 \
    && go get github.com/hashicorp/terraform@v0.12.7

RUN cd /root/ \
    && curl -O https://cache.agilebits.com/dist/1P/op/pkg/v0.5.6-003/op_linux_amd64_v0.5.6-003.zip \
    && unzip op_linux_amd64_v0.5.6-003.zip

FROM fedora:30
RUN dnf -y update \
    && dnf -y install zsh \
               openssh \
               git \
               gcc \
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
    && dnf clean all

RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

RUN mkdir /go /go/bin /workspace /root/.ssh/
COPY --from=builder /root/go/bin/* /root/go/bin/
COPY --from=builder /root/op /usr/local/bin/

WORKDIR /workspace

COPY requirements.txt /workspace/

RUN pip3 install -r requirements.txt && rm requirements.txt

COPY workspace.zsh-theme /root/.oh-my-zsh/themes/
COPY zshrc /root/.zshrc


ENV SHELL /bin/zsh

