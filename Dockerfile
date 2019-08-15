FROM alpine:3.10.1

RUN apk update \
    && apk upgrade \
    && apk add zsh \
               python3 \
               openssh \
               git \
               gcc \
               python3-dev \
               krb5-dev \
               krb5 \
               unzip \
               curl \
               musl-dev \
               libffi-dev \
               openssl-dev \
               procps \
               vim \
               util-linux

RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

RUN cd /tmp/ \
    && curl -O https://releases.hashicorp.com/terraform/0.12.1/terraform_0.12.1_linux_amd64.zip \
    && unzip terraform_0.12.1_linux_amd64.zip \
    && mv terraform /usr/local/bin/ \
    && rm terraform_0.12.1_linux_amd64.zip

RUN cd /tmp/ \
    && curl -O https://cache.agilebits.com/dist/1P/op/pkg/v0.5.6-003/op_linux_amd64_v0.5.6-003.zip \
    && unzip op_linux_amd64_v0.5.6-003.zip \
    && mv op /usr/local/bin/ \
    && rm ./op*

RUN mkdir /workspace /root/.ssh/
WORKDIR /workspace

COPY requirements.txt /workspace/

RUN pip3 install -r requirements.txt && rm requirements.txt

RUN apk del python3-dev \
            krb5-dev \
            musl-dev \
            libffi-dev \
            openssl-dev \
            gcc

COPY workspace.zsh-theme /root/.oh-my-zsh/themes/
COPY zshrc /root/.zshrc


ENV SHELL /bin/zsh

