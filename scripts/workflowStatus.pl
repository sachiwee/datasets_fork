#!/usr/bin/env perl
use strict;
use warnings;
use JSON;
use Data::Dumper;

my $repo = "datasets";

my @workflows =
    (
     {
	 file => "updateLocalGroupDB.yml",
	 name =>  "Update-Local-Group-DB"
     }
    );

foreach my $workflow ( @workflows ) {

    my $json;
    open(my $gh,"gh run list --workflow ".$workflow->{'file'}." --branch master --json conclusion |");
    while ( my $line = <$gh> ) {
	$json .= $line;
    }
    close($gh);
    my $data = decode_json($json);
    my $status = ":question:";
    foreach my $run ( @{$data} ) {
	if      ( $run->{'conclusion'} eq ""        ) {
	    $status = ":clock2:";
	} elsif ( $run->{'conclusion'} eq "failure" ) {
	    $status = ":x:";
	} elsif ( $run->{'conclusion'} eq "success" ) {
	    $status = ":white_check_mark:";
	}
	last
	    unless ( $status eq ":question:" );
    }
    system("curl -X POST -H 'Content-type: application/json' --data '{\"repo\":\"".$repo."\",\"workflow\":\"".$workflow->{'name'}."\",\"status\":\"".$status."\",\"url\":\"https://github.com/galacticusorg/".$repo."/actions/workflows/".$workflow->{'file'}."\"}' ".$ENV{'SLACK_WEBHOOK_STATUS_URL'});

}

exit;
