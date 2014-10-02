#!/bin/bash

increase_nofile() {
  cat <<EOF > /etc/security/limits.d/riak.conf
*                soft    nofile          65536
*                hard    nofile          65536
EOF
}

update_sysctl() {
  cat <<EOF >> /etc/sysctl.conf
vm.swappiness = 0
vm.dirty_bytes = 209715200
vm.dirty_background_bytes = 104857600
net.ipv4.tcp_max_syn_backlog = 40000
net.core.somaxconn = 40000
net.ipv4.tcp_sack = 1
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_fin_timeout = 15
net.ipv4.tcp_keepalive_intvl = 30
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_moderate_rcvbuf = 1
net.core.rmem_max = 134217728
net.core.wmem_max = 134217728
net.ipv4.tcp_mem  = 134217728 134217728 134217728
net.ipv4.tcp_rmem = 4096 277750 134217728
net.ipv4.tcp_wmem = 4096 277750 134217728
net.core.netdev_max_backlog = 300000
EOF

  sysctl -p
}

tuning_system() {
  find /sys/block/sd* -type l -exec sh -c 'echo deadline > {}/queue/scheduler' \;
  find /sys/block/sd* -type l -exec sh -c 'echo 1024 > {}/queue/nr_requests' \;

  [ ! -f /etc/security/limits.d/riak.conf ] && increase_nofile
  grep vm.swappiness /etc/sysctl.conf > /dev/null
  [ $? -eq 1 ] && update_sysctl
}

update_repo() {
  echo deb http://jp.archive.ubuntu.com/ubuntu/ precise main universe | tee /etc/apt/sources.list
  echo deb http://jp.archive.ubuntu.com/ubuntu/ precise-security main universe | tee -a /etc/apt/sources.list
  echo deb http://jp.archive.ubuntu.com/ubuntu/ precise-updates main universe | tee -a /etc/apt/sources.list
  apt-get update
}

install_packages() {
  apt-get install --no-install-recommends -y build-essential libncurses5-dev openssl libssl-dev fop xsltproc unixodbc-dev libpam0g-dev
  apt-get install --no-install-recommends -y curl lsb-release git wget
}

install_erlang() {
  if [ -d otp_src_R16B02-basho5 ]; then
    return
  fi
  wget http://s3.amazonaws.com/downloads.basho.com/erlang/otp_src_R16B02-basho5.tar.gz
  tar zxvf otp_src_R16B02-basho5.tar.gz
  cd otp_src_R16B02-basho5
  ./configure && make -j 8 && sudo make install
  cd ../
}

install_jdk() {
  echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
  apt-get install --no-install-recommends -y python-software-properties
  add-apt-repository ppa:webupd8team/java
  apt-get update
  apt-get install --no-install-recommends -y oracle-java7-installer
}

build_riak() {
  VERSION=2.0.1
  curl -O http://s3.amazonaws.com/downloads.basho.com/riak/2.0/${VERSION}/riak-${VERSION}.tar.gz
  tar zxvf riak-${VERSION}.tar.gz
  mv riak-${VERSION} riak
  cd riak
  DEVNODES=5 make devrel
  cd ../
  chown -R vagrant:vagrant riak
}

tuning_system
update_repo
install_packages
install_erlang
install_jdk
build_riak
