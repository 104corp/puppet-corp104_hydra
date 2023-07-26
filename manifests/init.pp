class corp104_hydra (
  Optional[String] $http_proxy,
  String $version,
  String $tmp_path,
  String $install_path,
  String $environment_file = '/opt/hydra/.env',
  String $bin_path = '/opt/hydra/hydra',
  String $extra_options = 'serve all --dangerous-force-http',
){

  contain corp104_hydra::install
  contain corp104_hydra::service

  Class['::corp104_hydra::install']
  -> Class['::corp104_hydra::service']
}
