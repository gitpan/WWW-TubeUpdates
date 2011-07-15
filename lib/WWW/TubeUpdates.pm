package WWW::TubeUpdates;

use Moose;
use MooseX::Params::Validate;
use Moose::Util::TypeConstraints;
use namespace::clean;

use Carp;
use Data::Dumper;

use Readonly;
use HTTP::Request;
use LWP::UserAgent;

=head1 NAME

WWW::TubeUpdates - Interface to Tube Updates API.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';
Readonly my $BASE_URL   => 'http://api.tubeupdates.com/?method=get.status';
Readonly my $TUBE_LINES =>
{
    'all'             => 'Wildcard for all lines',
    'bakerloo'        => 'Bakerloo Line',
    'central'         => 'Central Line',
    'circle'          => 'Circle Line',
    'district'        => 'District Line',
    'docklands'       => 'Docklands',
    'hammersmithcity' => 'Hammersmith & City Line',
    'jubilee'         => 'Jubilee Line',
    'metropolitan'    => 'Metropolitan Line',
    'northern'        => 'Northern Line',
    'piccadilly'      => 'Piccadilly Line',
    'overground'      => 'London Overground system',
    'tube'            => 'Wildcard for all tube lines (excludes DLR and Overground)',
    'victoria'        => 'Victoria Line',
    'waterloocity'    => 'Waterloo & City Line'
};

=head1 DESCRIPTION

A very lightweight wrapper for the Tube Updates REST API provided by tubeupdates.com.

=cut

subtype 'TubeLine'
    => as 'Str'
    => where { _validateTubeLine($_) };
subtype 'ArrayRefOfTubeLine'
    => as 'ArrayRef[TubeLine]';
coerce 'ArrayRefOfTubeLine'
    => from 'TubeLine'
    => via { [ $_ ] }
    => from 'ArrayRef[Str]'
    => via { [ map { _coerceStrToTubeLine($_) } @$_ ] };

type 'Format'  => where { defined($_) && (/\bxml\b|\bjson\b/i) };
has  'format'  => (is => 'ro', isa => 'Format', default => 'json');
has  'browser' => (is => 'rw', isa => 'LWP::UserAgent', default => sub { return LWP::UserAgent->new(agent => 'Mozilla/5.0'); });

around BUILDARGS => sub
{
    my $orig  = shift;
    my $class = shift;

    if (@_ == 1 && ! ref $_[0])
    {
        return $class->$orig(format => $_[0]);
    }
    else
    {
        return $class->$orig(@_);
    }
};

=head1 CONSTRUCTOR

The constructor requires optionally format type. It can be either XML / JSON. The default type
is JSON.

    use strict; use warnings;
    use WWW::TubeUpdates;
    
    my ($tube);
    $tube = WWW::TubeUpdates->new('xml');
    # or
    $tube = WWW::TubeUpdates->new(format => 'xml');
    # or
    $tube = WWW::TubeUpdates->new({format => 'xml'});

=head1 METHODS

=head2 getStatus()

Returns the status of the given tube lines. Tube lines can be passed in as list or reference
to a list. Following is the list of valid tube lines:

    +-----------------+-----------------------------------------------------------+
    | Id              | Description                                               |
    +-----------------+-----------------------------------------------------------+
    | all             | Wildcard for all lines                                    |
    | bakerloo        | Bakerloo Line                                             |
    | central         | Central Line                                              |
    | circle          | Circle Line                                               | 
    | district        | District Line                                             |
    | docklands       | Docklands                                                 |
    | hammersmithcity | Hammersmith & City Line                                   | 
    | jubilee         | Jubilee Line                                              |
    | metropolitan    | Metropolitan Line                                         |
    | northern        | Northern Line                                             | 
    | piccadilly      | Piccadilly Line                                           |
    | overground      | London Overground system                                  |  
    | tube            | Wildcard for all tube lines (excludes DLR and Overground) |
    | victoria        | Victoria Line                                             |
    | waterloocity    | Waterloo & City Line                                      | 
    +-----------------+-----------------------------------------------------------+

    use strict; use warnings;
    use WWW::TubeUpdates;
    
    my $tube   = WWW::TubeUpdates->new('xml');
    print $tube->getStatus('circle') . "\n";
    # or
    print $tube->getStatus(['circle']) . "\n";
    # or
    print $tube->getStatus('circle', 'bakerloo') . "\n";
    # or
    print $tube->getStatus(['circle', 'bakerloo']) . "\n";

=cut

around 'getStatus' => sub
{
    my $orig  = shift;
    my $class = shift;

    if (@_ > 1 && !ref $_[0])
    {
        return $class->$orig([@_]);
    }
    else
    {
        return $class->$orig(@_);
    }
};
    
sub getStatus
{
    my $self    = shift;
    my ($lines) = pos_validated_list(\@_,
                  { isa => 'ArrayRefOfTubeLine', coerce => 1, required => 1 },
                    MX_PARAMS_VALIDATE_NO_CACHE => 1);
                  
    my ($browser, $url, $request, $response, $content);
    $browser = $self->browser;
    $browser->env_proxy;
    $url = sprintf("%s&lines=%s", $BASE_URL, join(",",@$lines));
    $url.= sprintf("&format=%s", $self->format);
    $request  = HTTP::Request->new(GET => $url);
    $response = $browser->request($request);
    croak("ERROR: Couldn't fetch data [$url]:[".$response->status_line."]\n")
        unless $response->is_success;
    $content  = $response->content;
    croak("ERROR: No data found.\n") unless defined $content;
    return $content;
}

sub _validateTubeLine 
{
    my $data = shift;
    return 1 if (defined($data) && exists($TUBE_LINES->{lc($data)}));
    return ();
}

sub _coerceStrToTubeLine
{
    my $str = shift;
    return $str if _validateTubeLine($str);
    warn("ERROR: Invalid tube line [$str].");
}

=head1 AUTHOR

Mohammad S Anwar, C<< <mohammad.anwar at yahoo.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-www-tubeupdates at rt.cpan.org> or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=WWW-TubeUpdates>. I will 
be notified & then you'll automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc WWW::TubeUpdates

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=WWW-TubeUpdates>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/WWW-TubeUpdates>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/WWW-TubeUpdates>

=item * Search CPAN

L<http://search.cpan.org/dist/WWW-TubeUpdates/>

=back

=head1 ACKNOWLEDGEMENT

Ben Dodson (author of TubeUpdates REST API).

=head1 LICENSE AND COPYRIGHT

Copyright 2011 Mohammad S Anwar.

This  program  is  free  software; you can redistribute it and/or modify it under the terms of
either:  the  GNU  General Public License as published by the Free Software Foundation; or the
Artistic License.

See http://dev.perl.org/licenses/ for more information.

=head1 DISCLAIMER

This  program  is  distributed in the hope that it will be useful,  but  WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

=cut

__PACKAGE__->meta->make_immutable;
no Moose; # Keywords are removed from the WWW::TubeUpdates package
no Moose::Util::TypeConstraints;

1; # End of WWW::TubeUpdates