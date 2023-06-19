#!/bin/bash
sudo apt-get update
sudo apt-get upgrade -y
wget https://www.emqx.com/en/downloads/enterprise/5.0.3/emqx-enterprise-5.0.3-ubuntu20.04-amd64.tar.gz -P ~/
mkdir -p ~/emqx && tar -zxvf ~/emqx-enterprise-5.0.3-ubuntu20.04-amd64.tar.gz -C ~/emqx
~/emqx/bin/emqx start