Vagrant.configure("2") do |config|

  # Função para configurar o RAID em uma máquina virtual
  def configurar_raid(machine)
    machine.vm.provision "shell", inline: <<-SHELL
      sudo apt-get update
      sudo apt-get install -y mdadm
      sudo systemctl stop mdadm
      sudo mdadm --create --verbose /dev/md0 --level=1 --raid-devices=2 /dev/sdc /dev/sdd <<EOF
yes
EOF
      sudo mdadm --wait /dev/md0
      sudo mkfs.ext4 /dev/md0
      sudo mkdir -p /raid1
      sudo mount /dev/md0 /raid1
      echo '/dev/md0 /raid1 ext4 defaults,nofail 0 0' | sudo tee -a /etc/fstab
      sudo mdadm --detail --scan | sudo tee -a /etc/mdadm/mdadm.conf
      sudo update-initramfs -u
    SHELL
  end

  # Configuração da máquina 'web1'
  config.vm.define "web1" do |web1|
    web1.vm.box = "ubuntu/bionic64"
    web1.vm.network "private_network", ip: "192.168.19.121"
    web1.vm.hostname = "web1"
    config.vm.synced_folder "partilha/", "/vagrant"  
    web1.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
      vb.cpus = 1
    end

    # Adicionar discos para RAID
    web1.vm.disk :disk, size: "3GB", name: "sdc"
    web1.vm.disk :disk, size: "3GB", name: "sdd"

    # Provisionamento para configurar RAID
    configurar_raid(web1)

    # Provisionamento com scripts organizados inline
    web1.vm.provision "shell", inline: <<-SHELL
      sudo hostnamectl set-hostname web1
      chmod +x /vagrant/*.sh
      bash /vagrant/setup-inicial.sh
      bash /vagrant/setup-nginx.sh
      bash /vagrant/setup-glusterfs.sh
      sudo reboot
    SHELL
  end

  # Configuração da máquina 'web2'
  config.vm.define "web2" do |web2|
    web2.vm.box = "ubuntu/bionic64"
    web2.vm.network "private_network", ip: "192.168.19.122"
    web2.vm.hostname = "web2"
    config.vm.synced_folder "partilha/", "/vagrant"
    web2.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
      vb.cpus = 1
    end

    # Adicionar discos para RAID
    web2.vm.disk :disk, size: "3GB", name: "sdc"
    web2.vm.disk :disk, size: "3GB", name: "sdd"

    # Provisionamento para configurar RAID
    configurar_raid(web2)

    # Provisionamento com scripts organizados inline
    web2.vm.provision "shell", inline: <<-SHELL
      sudo hostnamectl set-hostname web2
      chmod +x /vagrant/*.sh
      bash /vagrant/setup-inicial.sh
      bash /vagrant/setup-nginx.sh
      bash /vagrant/setup-glusterfs.sh
      sudo reboot
    SHELL
  end

  # Configuração do banco de dados 'sql1'
  config.vm.define "sql1" do |sql1|
    sql1.vm.box = "ubuntu/bionic64"
    sql1.vm.network "private_network", ip: "192.168.19.111"
    sql1.vm.hostname = "sql1"
    config.vm.synced_folder "partilha/", "/vagrant"
    sql1.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
      vb.cpus = 1
    end

    # Adicionar discos para RAID
    sql1.vm.disk :disk, size: "3GB", name: "sdc"
    sql1.vm.disk :disk, size: "3GB", name: "sdd"

    # Provisionamento para configurar RAID
    configurar_raid(sql1)

    # Provisionamento com scripts organizados inline
    sql1.vm.provision "shell", inline: <<-SHELL
      sudo hostnamectl set-hostname sql1
      chmod +x /vagrant/*.sh
      bash /vagrant/setup-inicial.sh
      bash /vagrant/setup-mariadb.sh
      bash /vagrant/setup-glusterfs.sh
      sudo reboot
    SHELL
  end

  # Configuração do banco de dados 'sql2'
  config.vm.define "sql2" do |sql2|
    sql2.vm.box = "ubuntu/bionic64"
    sql2.vm.network "private_network", ip: "192.168.19.112"
    sql2.vm.hostname = "sql2"
    config.vm.synced_folder "partilha/", "/vagrant"
    sql2.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
      vb.cpus = 1
    end

    # Adicionar discos para RAID
    sql2.vm.disk :disk, size: "3GB", name: "sdc"
    sql2.vm.disk :disk, size: "3GB", name: "sdd"

    # Provisionamento para configurar RAID
    configurar_raid(sql2)

    # Provisionamento com scripts organizados inline
    sql2.vm.provision "shell", inline: <<-SHELL
      sudo hostnamectl set-hostname sql2
      chmod +x /vagrant/*.sh
      bash /vagrant/setup-inicial.sh
      bash /vagrant/setup-mariadb.sh
      bash /vagrant/setup-glusterfs.sh
      sudo reboot
    SHELL
  end

  # Configuração do proxy 'proxy1'
  config.vm.define "proxy1" do |proxy1|
    proxy1.vm.box = "ubuntu/bionic64"
    proxy1.vm.network "private_network", ip: "192.168.19.100"
    proxy1.vm.network "private_network", ip: "172.20.19.200" 
    proxy1.vm.hostname = "proxy1"
    config.vm.synced_folder "partilha/", "/vagrant"
    proxy1.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
      vb.cpus = 1
    end

    # Provisionamento com scripts organizados inline
    proxy1.vm.provision "shell", inline: <<-SHELL
      sudo hostnamectl set-hostname proxy1
      chmod +x /vagrant/*.sh
      bash /vagrant/setup-inicial.sh
      bash /vagrant/setup-haproxy.sh
      sudo reboot
    SHELL
  end

  # Configuração do proxy 'proxy2'
  config.vm.define "proxy2" do |proxy2|
    proxy2.vm.box = "ubuntu/bionic64"
    proxy2.vm.network "private_network", ip: "192.168.19.101"
    proxy2.vm.network "private_network", ip: "172.20.19.201" 
    proxy2.vm.hostname = "proxy2"
    config.vm.synced_folder "partilha/", "/vagrant"
    proxy2.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
      vb.cpus = 1
    end

    # Provisionamento com scripts organizados inline
    proxy2.vm.provision "shell", inline: <<-SHELL
      sudo hostnamectl set-hostname proxy2
      chmod +x /vagrant/*.sh
      bash /vagrant/setup-inicial.sh
      bash /vagrant/setup-haproxy.sh
      sudo reboot
    SHELL
  end

end
