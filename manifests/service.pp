class corp104_hydra::service inherits corp104_hydra {
  file { '/lib/systemd/system/hydra.service':
    ensure  => file,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    content => template("${module_name}/hydra.service.erb"),
    require => Class['Corp104_hydra::install']
  }
}
