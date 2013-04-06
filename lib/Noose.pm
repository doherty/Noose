package Noose;
use strict;
use warnings;
# ABSTRACT: just enough object orientation to hang yourself
# VERSION

use Sub::Name;
use Scalar::Util qw(blessed);

=head1 DESCRIPTION

L<Moose> led to L<Mouse> led to L<Moo> led to L<Mo> led finally to L<M>, which gives
you the least object-orientation possible, which is none at all. Noose continues
this L<illustrious trend|https://twitter.com/_doherty/statuses/115258513390960640>.

B<< Noose gives you I<just> enough object orientation to hang yourself. >>

=cut

=head1 METHODS

=head2 import

Imports the L</new> constructor into your class.

=cut

sub import {
    my $class = caller;

    my $sub_name = $class . '::new';
    my $sub_code = \&new;
    subname $sub_name => $sub_code;
    {
        no strict 'refs'; ## no critic (TestingAndDebugging::ProhibitNoStrict)
        *{$sub_name} = $sub_code;
    }
}

=head2 new

You can use L</import> to bring B<new> into your class, and it will become a
constructor that blesses any key-value pairs provided into an object of the
specified class. This is probably not very useful if you are trying not to
hang yourself, I<hint hint>.

Simply C<use Noose> to give your class a C<new> method. When the method is
called with some key-value pairs, a new object of the specified class is
created with the given attributes. Methods are created for each attribute,
in the familiar accessor form: calling the method with no arguments just
returns the current value for that attribute; calling the method with an
argument sets the attribute to that value. No checking of any kind is
performed.

=head2 Controlling object construction

If you need to have attributes that shouldn't be given in the contructor,
or if you want to have any amount of control over object construction at all
(which is proably a good idea), then give the empty list when loading Noose,
and write a constructor that provides the attributes.

You can use the same technique to override parameters the caller gives you,
add new ones, provide defaults, filter or alter values, die if invalid data
is provided etc.

    package Fancy;
    use Noose ();

    sub new {
        my $class = shift;
        my %args  = @_;

        die 'RTFM' unless $args{make_it_go};
        $args{fancy}  = 1;
        $args{useful} = 0;

        return Noose::new($class, %args);
    }

    # class body
    sub method { ... }

See F<examples/2.pl> for another example of this technique.

=head2 Using the constructor to clone an object

If you call C<new> as an object method, then you will get a clone of the object,
unless you used some parameters, in which case those parameters will be used
to create accessors just like with normal object creation. If there already were
accessors by those names, then the new values will prevail.

See F<examples/3.pl> for example usage.

=cut

sub new {
    my $class = shift;
    my %args = do {
        if ( blessed $class ) { # If it was called as an object method,
            require Storable;
            Storable->import(qw/dclone/);   # We're going to clone the object it was called on
            if (@_) {                   # Add in some args if there were any
                require Acme::Damn;     # HINT HINT
                Acme::Damn->import(qw/damn/);
                ( %{ damn( dclone($class) ) }, @_ ); # These args will be used to construct the returned object
            }
            else {                      # Otherwise, just return the clone
                return dclone($class);
            }
        }
        else {  # Called as a normal constructor, nothing exciting here
            @_;
        }
    };
    $class = blessed $class if blessed $class; # Can't bless into a reference, we need the package name

    foreach my $attr (keys %args) {
        my $sub_code = sub {
            @_ > 1
                ? $_[0]->{$attr} = $_[1]
                : $_[0]->{$attr};
        };

        my $sub_name = $class . '::' . $attr;
        subname $sub_name => $sub_code;

        {
            no warnings qw(redefine);
            no strict qw(refs); ## no critic (TestingAndDebugging::ProhibitNoStrict)
            *{$sub_name} = $sub_code;
        }
    }

    return bless { %args }, $class;
}

=head1 EXAMPLES

See the C<examples> subdirectory.

=head1 CAVEATS

In case it isn't obvious, B<you should not actually use Noose>. It has an C<Acme::>
module in the dependency tree, for crying out loud!

=cut

1;
