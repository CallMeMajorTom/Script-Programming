################## METADATA ##################
# NAME: Xiaotong Jiang
# USERNAME: a17xiaji
# COURSE: IT334g-Script Programming
# ASSIGNMENT: Monitor user activities
# DATE OF LAST CHANGE: 2018-05-03
##############################################

#!/usr/bin/env perl

use warnings;
use strict;
use lib "~/Desktop/GPart2";
use user_monitor;

print
"(L)ogin_information (P)assword_information (D)isk_usage_information (Q)uit\n";

while (1) {
    print "Choose function:";
    my $cmd = <STDIN>;
    chomp $cmd;
    if ( $cmd eq "L" ) {
        print "The list of users who logged in sorted by the times of login:\n";
        my %login_list = user_monitor::user_login;
        foreach my $key ( sort { $login_list{$b} <=> $login_list{$a} }
            ( keys(%login_list) ) )
        {
            print "$key:$login_list{$key}\n";
        }
    }
    elsif ( $cmd eq "P" ) {
        print "Input the threshold of the duration of didn't change password:";
        my $threshold           = <STDIN>;
        my %passwd_warning_list = user_monitor::user_passwd($threshold);
        foreach my $key ( keys %passwd_warning_list ) {
            print "$key:$passwd_warning_list{$key}\n";
        }
    }
    elsif ( $cmd eq "D" ) {
        print "Input the threshold of disk usage of home directory:";
        my $threshold               = <STDIN>;
        my %disk_usage_warning_list = user_monitor::user_disk_usage($threshold);
        foreach my $key ( keys %disk_usage_warning_list ) {
            print "$key:$disk_usage_warning_list{$key}\n";
        }
    }
    elsif ( $cmd eq "Q" ) { last; }
    else                  { print "Unknown command\n" }
}
