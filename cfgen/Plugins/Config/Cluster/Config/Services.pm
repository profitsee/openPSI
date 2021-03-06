package Plugins::Config::Cluster::Config::Services;

use ModernStyle;
use Exporter qw(import);
use Data::Dumper;

our @EXPORT_OK = qw(service_definitions);

##########################################
# on first sight it seems odd to have the service config definition within the cluster plugin.
# however, services are just an abstraction, and in their very essence, just a collection of templates and scripts,
# they only make sense in the context of a cluster or a machine
##########################################

my $archive = {
    HOST       => [qr/(.+)/x],
    USER       => [qr/(.+)/x],
    PORT       => [qr/(\d{2,5})/x],
    PRIV       => [qr/^\s*(SECRETS:.+)/x],
    REMOTE_PUB => [qr/^\s*(SECRETS:.+)/x],
    KEYFILE    => [qr/^(\/.*)/x]
};

my $backup = {

    # backup has to be setup on node creation, see docs
    TARGET          => [qr/(.+)/x],
    TARGET_USER     => [qr/(.+)/x],
    TARGET_PASSWORD => [qr/^(SECRETS:.+)/x],
    TARGET_PRIV     => [qr/^(SECRETS:.+)/x],
    TARGET_PUB      => [qr/^(SECRETS:.+)/x],
    BORG_REPO       => [qr/^(SECRETS:.+)/x],
    BORG_KEY        => [qr/^(SECRETS:.+)/x],
};

my $csync = {
    KEY => [qr/^(\/.*)/x],
    CA  => [qr/(.+)/x],
};

my $dhcp = {

    # the interface name to serve (not the actual interface name, but the section name from NETWORK. this gets translated in cfgen)
    INTERFACE => [qr/(.+)/x],

    # dhcp range start
    START => [qr/(\d{1,3})/x],

    # dhcp range end
    END => [qr/(\d{1,3})/x],

    # lease time
    LEASE => [qr/(.+)/x],

    # list of static hosts
    HOSTS => {
        '*' => {
            MAC => => [qr/^((?:[0-9A-Fa-f]{2}[:]){5}[0-9A-Fa-f]{2})$/x],
            IP  => [qr/(\d{1,3})/x],
            NAT => {
                '*' => {
                    SOURCE           => [qr/(.+)/x],
                    SOURCE_INTERFACE => [qr/(.+)/x],
                    PROTO            => [qr/(.+)/x],
                    PORT             => [qr/(\d+)/x],
                    NAT_PORT         => [qr/(\d+)/x],
                }
            },
        },
    }
};

my $ssmtp = {
    MAILLOG => [qr/(.+@.+)/x],
    RELAY   => [qr/(.+:.+)/x],
    USER    => [qr/(.+)/x],
    AUTH    => [qr/(.+)/x],
    PW      => [qr/(.+)/x],
};
my $ssh = {
    SSHPORT     => [qr/^(\d+)/x],
    AUTHMETHODS => [qr/(.+)/x],

    # additional MACs, for legacy clients on dev machines
    ADDMACS  => [qr/(.+)/x],
    HOSTKEYS => {
        '*' => {
            PRIVPATH => [qr/^(\/.*)/x],
            PUBPATH  => [qr/^(\/.*)/x],
            PRIV     => [qr/^\s*(SECRETS:.+)/x],
            PUB      => [qr/^\s*(SECRETS:.+)/x],
        },
    },

    # used for deployment, when the PUBLIC interface is not facing the internet
    NAT => {
        ADDRESS        => [qr/(.+)/x],
        NORMAL_PORT    => [qr/(.+)/x],
        BOOTSTRAP_PORT => [qr/(.+)/x]
    },
};

my $strongswan = {

    # for a mass key change, do something like (this is for racoon)
    # for i in $(ls *ipsec*.priv*); do rm $i; plainrsa-gen -f $i ; e=$(echo $i | sed -e 's/priv/pub/'); cat $i  | head -n 1 | sed -e 's/^#//'  > $e; done
    PRIV => [qr/(.+)/x],
    CERT => [qr/(.+)/x],
    CA   => [qr/(.+)/x],

    # this is the interface IPSEC connections for roadwarriors should be terminated on.
    # for normal servers with a single physical NIC, only INTERN (docker0) is an option.
    # machines with multiple interfaces may use those. (like PRIVATE)
    # for dhcp services to work, this must be the same interface the dhcpd listens on
    INTERFACE => [qr/^(.+)/x],
};

my $syslog = {
    MONITOR    => [qr/^(.+)/x],
    SYSLOGPORT => [qr/^(\d+)/x],

    # the certificate of the CA used to sign the server/client certs
    CACERT => [qr/^\s*(SECRETS:.+)/x],

    # the cert of the machine
    SERVERCERT => [qr/^\s*(SECRETS:.+)/x],

    # and its private key
    SERVERKEY => [qr/^\s*(SECRETS:.+)/x],

};

my $check = {

    archive    => { $archive->%* },
    backup     => { $backup->%* },
    csync      => { $csync->%* },
    dhcp       => { $dhcp->%* },
    dio        => {},
    dnsmasq    => {},
    grub       => {},
    network    => {},
    prometheus => {},
    smartd     => {},
    ssh        => { $ssh->%* },
    ssmtp      => { $ssmtp->%* },
    strongswan => { $strongswan->%* },
    syslog     => { $syslog->%* },
};

# every service should have an enable switch
foreach my $k ( keys $check->%* ) {
    $check->{$k}->{ENABLE} = [qr/^\s*(yes|no)/x];
}

sub service_definitions () {

    return $check;
}
1;
