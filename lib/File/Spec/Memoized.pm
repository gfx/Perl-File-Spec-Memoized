package File::Spec::Memoized;

use 5.010_000; # for dor operator (//)
use strict;

our $VERSION = '0.001';

use File::Spec;

# Class hierarchy:
# File::Spec -> File::Spec::Memoized -> File::Spec::$OS
#               ^^^^^^^^^^^^^^^^^^^^
our @ISA = @File::Spec::ISA;
@File::Spec::ISA = (__PACKAGE__);

# constants:
#   curdir, updir, rootdir, devnull

# already memoized:
#   tmpdir

my %cache;

foreach my $feature(qw(
    canonpath
    catdir
    catfile
    no_upwards
    file_name_is_absolute
    path
    splitpath
    splitdir
    catpath
    abs2rel
    rel2abs
    case_tolerant
)) {
    my $orig = "SUPER::$feature";

    my $fl   = '@' . $feature;
    my $fs   = '$' . $feature;

    my $memoized = sub :method {
        my $self = shift;
        if(wantarray){
            return @{
                $cache{$fl, @_} //= [$self->$orig(@_)]
            };
        }
        else {
            return $cache{$fs, @_} //= $self->$orig(@_);
        }
    };
    no strict 'refs';
    *{__PACKAGE__ . '::' . $feature} = $memoized;
}

sub flush_cache {
    undef %cache;
    return;
}

sub __cache { \%cache }

1;
__END__

=head1 NAME

File::Spec::Memoized - Makes File::Spec faster

=head1 VERSION

This document describes File::Spec::Memoized version 0.001.

=head1 SYNOPSIS

    # All you have to do is load this module.
    use File::Spec::Memoized;

    # Once this module is loaded, File::Spec features
    # will become faster.
    my $path = File::Spec->catfile('path', 'to', 'file.txt');

=head1 DESCRIPTION

File::Spec::Memoized makes File::Spec faster using memoization
(data caching). Once you load this module, File::Spec features
will become significantly faster.

=head1 INTERFACE

=head2 File::Spec features

=over 4

=item canonpath

=item catdir

=item catfile

=item curdir

=item rootdir

=item updir

=item no_upwards

=item file_name_is_absolute

=item path

=item devnull

=item tmpdir

=item splitpath

=item splitdir

=item catpath

=item abs2rel

=item rel2abs

=item case_tolerant

=back

=head2 Cache control methods

=over 4

=item flush_cache

Clears the cache and frees the memory used by the cache.

=back

=head1 DEPENDENCIES

Perl 5.10.0 or later.

=head1 BUGS

No bugs have been reported.

Please report any bugs or feature requests to the author.

=head1 SEE ALSO

L<File::Spec>

=head1 AUTHOR

Goro Fuji (gfx) E<lt>gfuji(at)cpan.orgE<gt>

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2010, Goro Fuji (gfx). Some rights reserved.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
