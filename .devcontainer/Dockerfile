FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

## Setup
RUN <<EOF
wget -O - https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list
apt-get update
EOF

## Kamal environment
RUN <<EOF
apt-get install -y --no-install-recommends \
    ruby-full \
    build-essential \
    terraform
gem install kamal --version=2.4.0
EOF

ADD https://vault.bitwarden.com/download/?app=cli&platform=linux /tmp/bw.zip
RUN <<EOF
unzip /tmp/bw.zip -d /usr/local/bin
EOF

## Cleanup
RUN rm -rf /var/lib/apt/lists/*

USER vscode
