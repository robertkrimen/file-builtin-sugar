package File::Builtin::Sugar;

use warnings;
use strict;

=head1 NAME

File::Builtin::Sugar -

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

#my %CORE = (
#    rename => sub { return CORE::rename $_[0], $_[1] },
#    symlink => sub { return CORE::symlink $_[0], $_[1] },
#    link => sub { return CORE::link $_[0], $_[1] },
#);

# TODO Checkout File::Utils

use vars qw/@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS/;

@ISA = qw/Exporter/;
#@EXPORT_OK = map { ($_, "${_}z") } keys %CORE;
@EXPORT_OK = qw/rename symlink link/;
$EXPORT_TAGS{all} = \@EXPORT_OK;

#use Carp::Clan qw/^(?:Carp::Clan::__ANON__()|File::Builtin::Sugar|Context::Preserve)/;
use Carp::Clan;
use Exporter;
use Context::Preserve;
use Path::Class;

sub _meld($$) {
    my $base = shift;
    my $default = shift;

    my %meld = %$base;
    for (keys %$default) {
        $meld{$_} = $default->{$_} unless exists $meld{$_};
    }

    return %meld;
}

sub _handle_make_path($$) {
    my ($want, $to) = @_;

    if ($want->{make_path}) {
        my $path = (file $to)->parent;
        $path->mkpath unless -d $path;
    }
}

sub symlink {
    my %want = _meld((ref $_[0] eq 'HASH' ? shift : {}), {
        core => 0,
        relative => 0,
        skip_existing => 1,
        overwrite_existing => 0,
        make_path => 1,
        verbose => 1,
    });

    my ($from, $to) = @_;
    
    if ($want{skip_existing}) {
        return if $want{skip_existing} eq 2 && -e $to;
        return if -l $to;
    }

    _handle_make_path \%want, $to;

    if ($want{relative}) {
        # TODO Check that from/to is absolute?
        my $to_parent = (file $to)->parent;
        $from = $from->relative($to_parent);
    }

    if ($want{verbose}) {
        local $! = undef;
        my $result = CORE::symlink $from, $to;
        carp "symlink($from, $to): $!" if $! or ! $result;
        return $result;
    }
    else {
        return CORE::symlink $from, $to;
    }
}

sub link {
    my %want = _meld((ref $_[0] eq 'HASH' ? shift : {}), {
        core => 0,
        skip_existing => 1,
        overwrite_existing => 0,
        make_path => 1,
        verbose => 1,
    });

    my ($from, $to) = @_;
    
    if ($want{skip_existing}) {
        return if -l $to;
    }

    _handle_make_path \%want, $to;

    if ($want{verbose}) {
        local $! = undef;
        my $result = CORE::link $from, $to;
        carp "link($from, $to): $!" if $! or ! $result;
        return $result;
    }
    else {
        return CORE::link $from, $to;
    }
}

sub rename {
    my %want = _meld((ref $_[0] eq 'HASH' ? shift : {}), {
        core => 0,
        skip_existing => 1,
        overwrite_existing => 0,
        make_path => 1,
        verbose => 1,
    });

    my ($from, $to) = @_;
    
    if ($want{skip_existing}) {
        return if -l $to;
    }

    _handle_make_path \%want, $to;

    if ($want{verbose}) {
        local $! = undef;
        my $result = CORE::rename $from, $to;
        carp "rename($from, $to): $!" if $! or ! $result;
        return $result;
    }
    else {
        return CORE::rename $from, $to;
    }
}

=head1 AUTHOR

Robert Krimen, C<< <rkrimen at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-file-builtin-sugar at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=File-Builtin-Sugar>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc File::Builtin::Sugar


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=File-Builtin-Sugar>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/File-Builtin-Sugar>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/File-Builtin-Sugar>

=item * Search CPAN

L<http://search.cpan.org/dist/File-Builtin-Sugar>

=back


=head1 ACKNOWLEDGEMENTS


=head1 COPYRIGHT & LICENSE

Copyright 2008 Robert Krimen, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

1; # End of File::Builtin::Sugar

__END__

for my $function (qw/rename link/) {
    no strict 'refs';
    my $CORE_function = $CORE{$function};
    *$function = sub {
        my ($from, $to) = @_;

        local $! = undef;
        return preserve_context {
            return $CORE_function->($from, $to);
        }
        after => sub { $_[0] or ! $! or carp "$function($from, $to): $!" }
        ;
    };

    my $functionz = "${function}z";
    *$functionz = sub {
        my ($from, $to) = @_;

        return if -e $to;

        my $dir = (file $to)->parent;
        $dir->mkpath unless -d $dir;


        *$function->($from, $to);
    };
}

