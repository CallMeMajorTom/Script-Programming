################## METADATA ##################
# NAME: Xiaotong Jiang
# USERNAME: a17xiaji
# COURSE: IT334g-Script Programming
# ASSIGNMENT: Tying it together
# DATE OF LAST CHANGE: 2018-05-03
##############################################

#!/usr/bin/env perl

use warnings;
use strict;
use lib "~/Desktop/GPart2";
use system_monitor;
use user_monitor;

my @listen_port_list = system_monitor::system_port;

#Filter by proto and IP version
my @tcp_list = system_monitor::filter( "Proto", "tcp", \@listen_port_list );
my @udp_list = system_monitor::filter( "Proto", "udp", \@listen_port_list );
my @tcp_ipv4_list = system_monitor::filter( "IP version", "4", \@tcp_list );
my @udp_ipv4_list = system_monitor::filter( "IP version", "4", \@udp_list );
my @tcp_ipv6_list = system_monitor::filter( "IP version", "6", \@tcp_list );
my @udp_ipv6_list = system_monitor::filter( "IP version", "6", \@udp_list );

#Write the information of tcp and IPv4 port into file
my $file = "tcp_ipv4.csv";
open( OUTPUT, ">$file" ) or die("Fail to open $file $!");
foreach my $a (@tcp_ipv4_list) {
    my %tmp = %{$a};
    print OUTPUT
      "$tmp{'Port number'},$tmp{'Local Address'},$tmp{'Program name'}\
";
}
close(OUTPUT);

#Write the information of tcp and IPv6 port into file
$file = "tcp_ipv6.csv";
open( OUTPUT, ">$file" ) or die("Fail to open $file $!");
foreach my $a (@tcp_ipv6_list) {
    my %tmp = %{$a};
    print OUTPUT
      "$tmp{'Port number'},$tmp{'Local Address'},$tmp{'Program name'}\
";
}
close(OUTPUT);

#Write the information of udp and IPv4 port into file
$file = "udp_ipv4.csv";
open( OUTPUT, ">$file" ) or die("Fail to open $file $!");
foreach my $a (@udp_ipv4_list) {
    my %tmp = %{$a};
    print OUTPUT
      "$tmp{'Port number'},$tmp{'Local Address'},$tmp{'Program name'}\
";
}
close(OUTPUT);

#Write the information of udp and IPv6 port into file
$file = "udp_ipv6.csv";
open( OUTPUT, ">$file" ) or die("Fail to open $file $!");
foreach my $a (@udp_ipv6_list) {
    my %tmp = %{$a};
    print OUTPUT
      "$tmp{'Port number'},$tmp{'Local Address'},$tmp{'Program name'}\
";
}
close(OUTPUT);

$file = "service_status.csv";
open( OUTPUT, ">$file" ) or die("Fail to open $file $!");
my $status;
$status =
  system_monitor::service("sshd")
  ? "yes"
  : "no";    #Determine the status of specific service
print OUTPUT "sshd,$status\
";
$status = system_monitor::service("cups") ? "yes" : "no";
print OUTPUT "cups,$status\
";
$status = system_monitor::service("ntpd") ? "yes" : "no";
print OUTPUT "ntpd,$status\
";
$status = system_monitor::service("named") ? "yes" : "no";
print OUTPUT "bind,$status\
";
$status = system_monitor::service("httpd") ? "yes" : "no";
print OUTPUT "httpd,$status\
";
close(OUTPUT);

$file = "users.csv";
open( OUTPUT, ">$file" ) or die("Fail to open $file $!");
my @user_list = `sudo cat /etc/passwd|grep /home|cut -d: -f1`;

#Get the list of regular user

my %login_list = user_monitor::user_login;

#Get the list of login user

my %user_passwd_100 = user_monitor::user_passwd(100);

#Get the list of users that didn't change password over 100 days

my %disk_usage_list = user_monitor::user_disk_usage(0);

#Get the list of users whose disk usage over 0

foreach my $user (@user_list) {
    chomp $user;
    my $login_times = exists( $login_list{$user} ) ? $login_list{$user} : 0;

#If you can find the user in user login list, then read the times of login from it, otherwise it should be 0

    my $passwd = !exists( $user_passwd_100{$user} ) ? "yes" : "no";

#If you can find the user in the list of users that didn't change password over 100 days, then "yes"

    my $disk_usage =
      exists( $disk_usage_list{ "/home/" . $user } )
      ? $disk_usage_list{ "/home/" . $user }
      : 0;

#If you can find the list of users whose disk usage over 0, then read the disk usage from it, otherwise it should be 0
    print OUTPUT "$user,$login_times,$passwd,$disk_usage\
";    #Organized it and output it
}
close(OUTPUT);

my $message_body = "Please see the attached .csv files for details";
my $subject      = "System_monitor_result";
my $user         = "a17xiaji\@a17xiaji.nsa.his.se";

`echo $message_body | mailx -s $subject  -a tcp_ipv4.csv -a tcp_ipv6.csv -a udp_ipv4.csv -a udp_ipv6.csv -a service_status.csv -a users.csv $user`;

#Send the email

