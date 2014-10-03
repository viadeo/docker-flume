VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "ubuntu/trusty64"
  config.vm.hostname = "docker-flume"

  config.vm.provision "docker"

  # Avro
  config.vm.network "forwarded_port", guest: 9999, host: 9999
end
