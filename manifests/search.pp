# Public: Manage search domain entries in /etc/resolv.conf.
#
# namevar  - The search domain name as a String.
# priority - The optional priority of the search domain as an Integer.  If a
#            value between 0 and 5 is provided, the entry will be the first
#            through sixth search domain respectively.
# ensure   - The desired state of the resource as a String.  Valid values are
#            'absent' and 'present' (default: 'present').
#
# Examples
#
#   resolvconf::search {
#     'foo.test.com':
#       priority => 1;
#     'test.com':
#       priority => 2;
#   }
define resolvconf::search ($priority = '999', $ensure = 'present') {
  Augeas {
    incl => '/etc/resolv.conf',
    lens => 'Resolv.lns',
  }

  if $priority == 0 {
    fail("Priority must nit be 0, start with 1 please.")
  }
  $match_priority = $priority ? {
    '999'   => '',
    default => "[${priority}]",
  }

  notice("set search/domain${match_priority} ${name}")

  case $ensure {
    'present' : {
      augeas { "Adding search domain '${name}' to /etc/resolv.conf":
        changes => "set search/domain${match_priority} ${name}",
        onlyif  => "match search/*${match_priority}[.='${name}'] size == 0",
      }
    }
    'absent'  : {
      augeas { "Removing search domain '${name}' from /etc/resolv.conf":
        changes => "rm search/*[.='${name}']",
        onlyif  => "match search/domain[.='${name}'] include '${name}'",
      }
    }
    default   : {
      fail("Invalid ensure value passed to Resolvconf::Search[${name}]")
    }
  }
}
