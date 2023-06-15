wget https://dl.grafana.com/oss/release/grafana-9.5.2.linux-amd64.tar.gz
tar -zxvf grafana-9.5.2.linux-amd64.tar.gz
cd grafana-9.5.2

mkdir grafana-plugins
cd grafana-plugins
git clone https://github.com/isarantidis/mqtt-datasource.git
cd mqtt-datasource
# install yarn
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt-get update && sudo apt-get install yarn

curl -sL https://deb.nodesource.com/setup_16.x -o /tmp/nodesource_setup.sh
sudo bash /tmp/nodesource_setup.sh
sudo apt install nodejs

#install go
wget https://go.dev/dl/go1.20.4.linux-amd64.tar.gz -P ~/
tar -xf ~/go1.20.4.linux-amd64.tar.gz -C ~/
export GOPATH=~/go
export PATH=$PATH:$GOPATH/bin

#install mage

git clone https://github.com/magefile/mage ~/mage
cd ~/mage
go run bootstrap.go


#build mqtt-datasource
yarn install
yarn build


# Add data source to grafana
# Edit vi /etc/grafana/grafana.ini.

# Add data source folder
# Look for # Directory where grafana will automatically scan and look for plugins and update as follows

# # Directory where grafana will automatically scan and look for plugins
# ;plugins = /var/lib/grafana/plugins
# plugins = /path/to/grafana-plugins
# Allow unsigned sources
# Look for [plugins] section and update as follows

# [plugins]
# ;enable_alpha = false
# ;app_tls_skip_verify_insecure = false
# # Enter a comma-separated list of plugin identifiers to identify plugins that are allowed to be loaded even if they lack a valid signature.
# allow_loading_unsigned_plugins = grafana-mqtt-datasource 


# ./grafana-9.5.2/bin/grafana-server start
#https://github.com/grafana/mqtt-datasource/issues/15#issuecomment-894477802