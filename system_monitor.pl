################## METADATA ##################
# NAME: Xiaotong Jiang
# USERNAME: a17xiaji
# COURSE: IT334g-Script Programming
# ASSIGNMENT: System monitor
# DATE OF LAST CHANGE: 2018-05-03
##############################################

#!/usr/bin/env perl

use strict;
use warnings;
use lib "~/Desktop/GPart2";
use system_monitor;

my @listen_port_list = system_monitor::system_port;

print "(P)ort_information (S)ervice_runing_information (Q)uit\n";
while (1) {
    print "Choose function:";
    my $cmd = <STDIN>;
    chomp $cmd;
    if ( $cmd eq "P" ) {
        print "(A)ll_listening_port (F)ilter\n";
        my $cmd_p = <STDIN>;
        chomp $cmd_p;
        if ( $cmd_p eq "A" ) {
            foreach my $item (@listen_port_list) {
                my %tmp = %{$item};
                foreach my $key ( keys %tmp ) {
                    print "$key:$tmp{$key}\n";
                }
                print "==========\n";
            }
        }
        elsif ( $cmd_p eq "F" ) {
            print "Input the key you want to apply:";
            my $key_f = <STDIN>;
            chomp $key_f;
            print "Input the value you want to apply:";
            my $value_f = <STDIN>;
            chomp $value_f;
            my @filter =
              system_monitor::filter( $key_f, $value_f, \@listen_port_list );
            foreach my $a (@filter) {
                my %tmp = %{$a};
                foreach my $key ( keys %tmp ) {
                    print "$key:$tmp{$key}\n";
                }
                print "==========\n";
            }
        }
        else { print "Unknown command\n"; }
    }
    elsif ( $cmd eq "S" ) {
        print "Input the service you want check:";
        my $service = <STDIN>;
        system_monitor::service($service)
          ? print "running\n"
          : print "Inactive\n";
    }
    elsif ( $cmd eq "Q" ) {
        last;
    }
    else { print "Unknown command\n"; }
}

