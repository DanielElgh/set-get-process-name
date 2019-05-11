#!/usr/bin/perl
# Daniel Elgh, 2019-05-12
#
# Perl functions to set and get the process name using syscall() and prctl
#
use warnings;
use strict;
use constant TASK_COMM_LEN => 16;
use constant PR_SET_NAME => 15;
use constant PR_GET_NAME => 16;
use constant PRCTL => 157;

exit main(@ARGV);

sub main {
    my @argument = @_;
    my $setNameTo = $argument[0] // 'A_very_long_name_for_a_process';
    print "Initial name: " . getProcessName() . "\n";
    setProcessName($setNameTo);
    print "New name....: " . getProcessName() . "\n";
    return 0;
}


sub setProcessName {
    my $newName = $_[0] // die("setProcessName: Argument missing\n");
    my $name = sprintf("%.*s\0", (TASK_COMM_LEN - 1), $newName);
    local $! = 0;
    if(syscall(PRCTL, PR_SET_NAME, $name, 0, 0, 0)) {
        die("setProcessName: syscall() failed with errno: $!\n");
    }
    return $name;
}

sub getProcessName {
    my $mem = "\0" x (TASK_COMM_LEN + 1);
    my $ptr = unpack('L', pack('P', $mem));
    local $! = 0;
    if(syscall(PRCTL, PR_GET_NAME, $ptr, 0, 0, 0)) {
        die("getProcessName: syscall() failed with errno: $!\n");
    }
    return unpack('Z*', $mem);
}
