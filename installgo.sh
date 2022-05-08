yum install wget -y
wget https://dl.google.com/go/go1.18.1.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.18.1.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin
source ~/.bash_profile

yum install git -y
git clone https://github.com/Mirantis/cri-dockerd
cd cri-dockerd
mkdir bin
cd src && go get && go build -o ../bin/cri-dockerd

mkdir -p /usr/local/bin
cd ../
install -o root -g root -m 0755 bin/cri-dockerd /usr/local/bin/cri-dockerd
cp -a packaging/systemd/* /etc/systemd/system
sed -i -e 's,/usr/bin/cri-dockerd,/usr/local/bin1/cri-dockerd,' /etc/systemd/system/cri-docker.service
systemctl daemon-reload
systemctl enable cri-docker.service
systemctl enable --now cri-docker.socket

systemctl status cri-docker.service
journalctl -xe
systemctl start cri-docker.service
systemctl reset-failed cri-docker.service



