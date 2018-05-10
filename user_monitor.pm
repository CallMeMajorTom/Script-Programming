################## METADATA ##################
# NAME: Xiaotong Jiang
# USERNAME: a17xiaji
# COURSE: IT334g-Script Programming
# ASSIGNMENT: Monitor user activities
# DATE OF LAST CHANGE: 2018-05-03
##############################################

package user_monitor;

sub user_login {
    my @login = `last|grep -P '\\S'|cut -d' ' -f1|sort|uniq -c`;

#last: The command displays a list of all users logged in
#cut -d' ' -f1: Cut the line with space as the field separator and output the first field
#grep -P '\\S': Remove the empty line
#sort: Sort the contents of text file
#uniq -c: Count how many times they occurred
    my %login_list = ();
    foreach my $item (@login) {
        my @tmp = split( /\s+/, $item );
        $login_list{ $tmp[2] } = $tmp[1];
    }
    delete $login_list{"wtmp"};
    return %login_list;
}

sub user_passwd {
     my $n;
     if(scalar(@_) >= 1){
        $n = shift @_ ;
    }
    else {
        die "Miss the first parameters";
    } 
    my @pass_time_original = `sudo cat /etc/shadow|cut -d: -f1,2,3`;

#/etc/shadow: A password file
#cut -d: -f1,3: Cut the line with colon as the field separator and output the first and the third fields which is the name of user and days since epoch of last password change
    my %pass_time    = ();
    my %warning_list = ();
    my $temp;
    my $current;
    foreach my $item (@pass_time_original) {
        my @tmp = split( /:/, $item );

        #split user name and days with colon
        chomp $tmp[1];
        if    ( $tmp[1] eq '!!' ) { }
        elsif ( $tmp[1] eq '*' )  { }
        else {
            chomp $tmp[2];    #remove invisible \n
            $current = time() / 60 / 60 / 24;    #transfer second into day
            $tmp[2] =
              $current -
              $tmp[2];    #caculate the time interval from the current time
            $tmp[2] = int( $tmp[2] );
            $pass_time{ $tmp[0] } = $tmp[2];    #push into hash table
            if ( $pass_time{ $tmp[0] } >= $n ) {
                $warning_list{ $tmp[0] } = $pass_time{ $tmp[0] };

   #Determine whether the value exceeds the threshold and push into warning list
            }
        }
    }
    return %warning_list;
}

sub user_disk_usage {
    my $n;
    if(scalar(@_) >= 1){
        $n = shift @_ ;
    }
    else {
        die "Miss the first parameters";
    } 
    my @disk_usage = `sudo du -smc /home/*`;

#du -smc: Display disk usage of /home directory with total disk usage at the last line in MB units
    my %warning_list = ();
    foreach my $item (@disk_usage) {
        my @tmp = split( /\s+/, $item );
        if ( $tmp[0] >= $n ) {
            $warning_list{ $tmp[1] } = $tmp[0]
              ; #Determine whether the value exceeds the threshold and push into warning list
        }
    }

    if(exists($warning_list{"total"})) {
	delete $warning_list{"total"};
    }
	
    return %warning_list;
}

1;

