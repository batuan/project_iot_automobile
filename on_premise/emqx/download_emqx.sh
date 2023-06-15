mkdir emqx_ee
wget https://www.emqx.com/en/downloads/enterprise/v5.0.3/emqx-enterprise-5.0.3-ubuntu18.04-amd64.tar.gz
mkdir -p emqx_ee && tar -zxvf emqx-enterprise-5.0.3-ubuntu18.04-amd64.tar.gz -C emqx_ee
./emqx_ee/bin/emqx start