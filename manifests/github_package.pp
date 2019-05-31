# github_package.pp

define r::github_package (
  $r_path       = '',
  $dependencies = false,
  $environment  = undef,
  $timeout      = 300,
  $organization = '',
) {
  if $name =~ /.*\/.*/ {
    $name_parts = split($name, '/')
  } else {
    $name_parts = nil
  }

  if $organization != '' {
    $org = $organization
  } elsif $name_parts != nil {
    $org = $name_parts[0]
  }

  if $name_parts == nil  {
    $package_name = $name
  } else {
    $package_name = $name_parts[1]
  }

  $deps = $dependencies ? {
    true    => 'TRUE',
    default => 'FALSE'
  }

  case $::osfamily {
    'Debian', 'RedHat': {

      if $r_path == '' {
        $binary = '/usr/bin/R'
      }
      else
      {
        $binary = $r_path
      }

      $command = "${binary} -e \"library(devtools); install_github('${org}/${package_name}', dependencies = ${deps})\""

        exec { "install_r_package_${name}":
          command     => $command,
          environment => $environment,
          timeout     => $timeout,
          unless      => "${binary} -q -e \"'${package_name}' %in% installed.packages()\" | grep 'TRUE'",
          require     => Class['r']
        }

    }
    default: { fail("Not supported on osfamily ${::osfamily}") }
  }
}
