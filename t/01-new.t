#!perl

use strict; use warnings;
use WWW::TubeUpdates;
use Test::More tests => 6;

my ($tube);

eval { $tube = WWW::TubeUpdates->new('xmml'); };
like($@, qr/Attribute \(format\) does not pass the type constraint/);

eval { $tube = WWW::TubeUpdates->new('jsson'); };
like($@, qr/Attribute \(format\) does not pass the type constraint/);

eval { $tube = WWW::TubeUpdates->new(format => 'xmml'); };
like($@, qr/Attribute \(format\) does not pass the type constraint/);

eval { $tube = WWW::TubeUpdates->new(format => 'jsson'); };
like($@, qr/Attribute \(format\) does not pass the type constraint/);

eval { $tube = WWW::TubeUpdates->new({format => 'xmml'}); };
like($@, qr/Attribute \(format\) does not pass the type constraint/);

eval { $tube = WWW::TubeUpdates->new({format => 'jsson'}); };
like($@, qr/Attribute \(format\) does not pass the type constraint/);