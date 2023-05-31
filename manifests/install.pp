class corp104_hydra::install inherits corp104_hydra {

  # Hydra change package realease name at 1.11.0
  if versioncmp ($corp104_hydra::version, '1.11') >= 0 {
    # For 1.11 ~ 2.x
    # hydra_1.11.0-linux_64bit.tar.gz
    $download_package  = "hydra_${corp104_hydra::version}-linux_64bit.tar.gz"
    $download_checksum = 'checksums.txt'
  } else {
    # For 1.0.x ~ 1.10.x:
    # hydra_1.9.0_linux_64bit.tar.gz
    # hydra_1.8.5_linux_64-bit.tar.gz
    # hydra_1.4.9_linux_64-bit.tar.gz
    # hydra_1.4.6_Linux_64-bit.tar.gz
    $download_package  = "hydra_${corp104_hydra::version}_Linux_64-bit.tar.gz"
    # 1.0.x ~ 1.10.x
    $download_checksum = "hydra_${corp104_hydra::version}_checksums.txt"
  }

  $hydra_download_url = "https://github.com/ory/hydra/releases/download/v${corp104_hydra::version}/${download_package}"
  $hydra_checksum_url = "https://github.com/ory/hydra/releases/download/v${corp104_hydra::version}/${download_checksum}"

  $hydra_download_path = "${corp104_hydra::tmp_path}/${download_package}"
  $hydra_checksum_path = "${corp104_hydra::tmp_path}/${download_checksum}"

  # Create group
  group { 'hydra':
    ensure => 'present',
    before => User['hydra']
  }

  # Create user
  user { 'hydra':
    ensure => 'present',
    system => true,
    home   => '/opt/hydra',
    gid    => 'hydra',
    before => Exec['download-hydra-checksum']
  }

  # Download hydra
  if $corp104_hydra::http_proxy{
    exec { 'download-hydra-checksum':
      provider => 'shell',
      command  => "curl -x ${corp104_hydra::http_proxy} -L ${hydra_checksum_url} >  ${hydra_checksum_path}",
      path     => '/bin:/usr/bin:/usr/local/bin:/usr/sbin',
      unless   => "test -e ${hydra_checksum_path}",
      before   => Exec['download-hydra']
    }
    exec { 'download-hydra':
      provider => 'shell',
      command  => "curl -x ${corp104_hydra::http_proxy} -o ${hydra_download_path} -O -L ${hydra_download_url}",
      path     => '/bin:/usr/bin:/usr/local/bin:/usr/sbin',
      unless   => "cd ${corp104_hydra::tmp_path} && grep Linux_64 ${download_checksum} > checksum.txt && sha256sum -c checksum.txt",
    }
  }
  else {
    exec { 'download-hydra-checksum':
      provider => 'shell',
      command  => "curl -L ${hydra_checksum_url} >  ${hydra_checksum_path}",
      path     => '/bin:/usr/bin:/usr/local/bin:/usr/sbin',
      unless   => "test -e ${hydra_checksum_path}",
      before   => Exec['download-hydra']
    }
    exec { 'download-hydra':
      provider => 'shell',
      command  => "curl -o ${hydra_download_path} -O -L ${hydra_download_url}",
      path     => '/bin:/usr/bin:/usr/local/bin:/usr/sbin',
      unless   => "cd ${corp104_hydra::tmp_path} && grep Linux_64 ${download_checksum} > checksum.txt && sha256sum -c checksum.txt",
    }
  }

  # Unpackage
  exec { 'unpackage hydra':
    provider    => 'shell',
    command     => "tar xvf ${hydra_download_path} -C ${corp104_hydra::tmp_path}",
    path        => '/bin:/usr/bin:/usr/local/bin:/usr/sbin',
    refreshonly => true,
    subscribe   => Exec['download-hydra'],
  }

  # create hydra directory
  file { '/opt/hydra':
    ensure  => 'directory',
    before  => File['hydra'],
    require => User['hydra'],
    owner   => 'hydra',
    group   => 'hydra'
  }

    # create hydra log directory
  file { '/var/log/hydra':
    ensure  => 'directory',
    before  => File['hydra'],
    require => User['hydra'],
    owner   => 'hydra',
    group   => 'hydra'
  }

  # Copy file
  file { 'hydra':
    ensure             => present,
    source             => "${corp104_hydra::tmp_path}/hydra",
    path               => "${corp104_hydra::install_path}/hydra",
    recurse            => true,
    replace            => false,
    source_permissions => use,
    owner              => 'hydra',
    group              => 'hydra',
    subscribe          => Exec['unpackage hydra'],
  }
}
