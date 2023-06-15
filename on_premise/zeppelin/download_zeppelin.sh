wget https://dlcdn.apache.org/zeppelin/zeppelin-0.10.1/zeppelin-0.10.1-bin-all.tgz
tar -zxvf zeppelin-0.10.1-bin-all.tgz
rm zeppelin-0.10.1-bin-all.tgz
cp ./source/zeppelin-site.xml ./zeppelin-0.10.1-bin-all/conf
cp ./source/IoT_query_2J12NNXQ4.zpln ./zeppelin-0.10.1-bin-all/notebook
./zeppelin-0.10.1-bin-all/bin/zeppelin-daemon.sh start