#!perl

use strict; use warnings;
use WWW::TubeUpdates;
use Test::Warn;
use Test::More tests => 4;

my $tube = WWW::TubeUpdates->new('xml');

eval { $tube->getStatus(); };
like($@, qr/0 parameters were passed/);

eval { $tube->getStatus('xyz'); };
like($@, qr/did not pass the \'checking type constraint for ArrayRefOfTubeLine\'/);

warning_is { eval { $tube->getStatus(['xyz']) }; } "ERROR: Invalid tube line [xyz].";
warning_is { eval { $tube->getStatus(['circle', 'xyz']) }; } "ERROR: Invalid tube line [xyz].";