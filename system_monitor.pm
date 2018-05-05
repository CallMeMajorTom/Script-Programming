################## METADATA ##################
# NAME: Xiaotong Jiang
# USERNAME: a17xiaji
# COURSE: IT334g-Script Programming
# ASSIGNMENT: System monitor
# DATE OF LAST CHANGE: 2018-05-03
##############################################

package system_monitor;

sub system_tcp_4_port {
    my @listen_port_list;
    my @port_list = `sudo netstat -lt4np`;

    #List the listening port number
    #-l: listening
    #-t: TCP protocol
    #-4: IPV4
    #-n: numerical
    #-p: process
    shift(@port_list);
    shift(@port_list);    #remove pointless lines
    my @header = (
        'Proto',           'Recv-Q',
        'Send-Q',          'Local Address',
        'Foreign Address', 'State',
        'PID/Program name'
    );
    foreach my $item (@port_list) {
        my %listen_port;
        my @tmp = split( /\s+/, $item );
        for ( my $i = 0 ; $i < scalar(@header) ; $i++ ) {
            $listen_port{ $header[$i] } =
              $tmp[$i];    #push key-value pairs into hash table
        }
        push( @listen_port_list, \%listen_port )
          ;                #push the reference of hash table into array list
    }
    return @listen_port_list;
}

sub system_tcp_6_port {
    my @listen_port_list;
    my @port_list = `sudo netstat -lt6np`;

    #List the listening port number
    #-6: IPV6
    shift(@port_list);
    shift(@port_list);
    my @header = (
        'Proto',           'Recv-Q',
        'Send-Q',          'Local Address',
        'Foreign Address', 'State',
        'PID/Program name'
    );
    foreach my $item (@port_list) {
        my %listen_port;
        my @tmp = split( /\s+/, $item );
        for ( my $i = 0 ; $i < scalar(@header) ; $i++ ) {
            $listen_port{ $header[$i] } = $tmp[$i];
        }
        push( @listen_port_list, \%listen_port );
    }
    return @listen_port_list;
}

sub system_udp_4_port {
    my @listen_port_list;
    my @port_list = `sudo netstat -lu4np`;

    #List the listening port number
    #-u: TCP protocol
    #-4: IPV4
    shift(@port_list);
    shift(@port_list);
    my @header = (
        'Proto',           'Recv-Q',
        'Send-Q',          'Local Address',
        'Foreign Address', 'PID/Program name'
    );
    foreach my $item (@port_list) {
        my %listen_port;
        my @tmp = split( /\s+/, $item );
        if ( scalar(@tmp) > scalar(@header) ) {
            my $length = scalar(@header);
            while ( $length < scalar(@tmp) ) {
                $tmp[ scalar(@header) - 1 ] =
                  $tmp[ scalar(@header) - 1 ] . " " . $tmp[$length];
                $length++;
            }
        }
        for ( my $i = 0 ; $i < scalar(@header) ; $i++ ) {
            $listen_port{ $header[$i] } = $tmp[$i];
        }
        push( @listen_port_list, \%listen_port );
    }
    return @listen_port_list;
}

sub system_udp_6_port {
    my @listen_port_list;
    my @port_list = `sudo netstat -lu6np`;

    #List the listening port number
    #-u: UDP protocol
    #-6: IPV6
    shift(@port_list);
    shift(@port_list);
    my @header = (
        'Proto',           'Recv-Q',
        'Send-Q',          'Local Address',
        'Foreign Address', 'PID/Program name'
    );
    foreach my $item (@port_list) {
        my %listen_port;
        my @tmp = split( /\s+/, $item );
        ##Handle the problem that PID/Program name has some spaces inside
        if ( scalar(@tmp) > scalar(@header) ) {
            my $length = scalar(@header);
            while ( $length < scalar(@tmp) ) {
                $tmp[ scalar(@header) - 1 ] =
                  $tmp[ scalar(@header) - 1 ] . " " . $tmp[$length];
                $length++;
            }
        }
        for ( my $i = 0 ; $i < scalar(@header) ; $i++ ) {
            $listen_port{ $header[$i] } = $tmp[$i];
        }
        push( @listen_port_list, \%listen_port );
    }
    return @listen_port_list;
}

sub filter {
    my $header   = shift @_ or die "Miss the first parameters";
    my $value    = shift @_ or die "Miss the second parameters";
    my $list_ref = shift @_ or die "Miss the third parameters";
    my @filter   = ();
    my @listen_port_list = @{$list_ref};
    foreach my $item (@listen_port_list) {
        my %tmp = %{$item};
        if ( $tmp{$header} eq $value ) {
            push( @filter, \%tmp )
              ; #push the hash table whose value meet the requirement into array
        }
    }
    return @filter;
}

sub service {
    my $name = shift @_ or die "Miss the first parameters";
    my $cmd = "sudo systemctl status " . "$name";

    #systemctl status command to get the status of the given service
    my $status = `$cmd`;
    if ( $status =~ /running/ ) {
        return 1;
    }
    else {
        return 0;
    }
}

sub system_port {
    my @listen_port_tcp_4_list = system_monitor::system_tcp_4_port;
    my @listen_port_tcp_6_list = system_monitor::system_tcp_6_port;
    my @listen_port_udp_6_list = system_monitor::system_udp_6_port;
    my @listen_port_udp_4_list = system_monitor::system_udp_4_port;
    my @listen_port_list_pre   = (
        @listen_port_tcp_4_list, @listen_port_tcp_6_list,
        @listen_port_udp_6_list, @listen_port_udp_4_list
    );
    my @listen_port_list;

    foreach my $item (@listen_port_list_pre) {
        my %tmp = %{$item};

        #Handle the local address

        my @temp = split( /:/, $tmp{"Local Address"} );
        my $LocalAddress;
        for ( my $i = 0 ; $i < scalar(@temp) - 2 ; $i++ ) {
            $LocalAddress = $LocalAddress . $temp[$i] . ":";
        }
        $LocalAddress         = $LocalAddress . $temp[$i];
        $tmp{"Local Address"} = $LocalAddress;
        $tmp{"Port number"}   = @temp[ scalar(@temp) - 1 ];

        #Handle the PID/Program name
        my @temp1 = split( /\//, $tmp{"PID/Program name"} );
        my $ProgramName;
        for ( my $i = 1 ; $i < scalar(@temp1) ; $i++ ) {
            $ProgramName = $ProgramName . $temp1[$i];
        }
        $tmp{"PID"}          = $temp1[0];
        $tmp{"Program name"} = $ProgramName;

        delete $tmp{"PID/Program name"};
        delete $tmp{"Recv-Q"};
        delete $tmp{"Send-Q"};
        delete $tmp{"Foreign Address"};

        #Handle the Proto and ip version
        if ( $tmp{"Proto"} eq "tcp6" ) {
            $tmp{"Proto"}      = "tcp";
            $tmp{"IP version"} = "6";
        }
        elsif ( $tmp{"Proto"} eq "udp6" ) {
            $tmp{"Proto"}      = "udp";
            $tmp{"IP version"} = "6";
        }
        elsif ( $tmp{"Proto"} eq "tcp" ) {
            $tmp{"Proto"}      = "tcp";
            $tmp{"IP version"} = "4";
        }
        elsif ( $tmp{"Proto"} eq "udp" ) {
            $tmp{"Proto"}      = "udp";
            $tmp{"IP version"} = "4";
        }
        push( @listen_port_list, \%tmp );
    }
    return @listen_port_list;
}

1;
