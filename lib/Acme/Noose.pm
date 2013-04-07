package Acme::Noose;
use strict;
use warnings;
# ABSTRACT: just enough object orientation to hang yourself
# VERSION

use Noose ();
BEGIN {
    *Acme::Noose:: = \%Noose::;
}

=head1 DESCRIPTION

This is simply a (more accurately named) alias of L<Noose>.

=for Pod::Coverage new

=cut

1;
