package AnyEvent::Impl::NSRunLoop;
use strict;
use warnings;
use Carp;
use XSLoader;

our $VERSION = '0.01';

BEGIN {
    $ENV{PERL_ANYEVENT_MODEL} = 'NSRunLoop';
};

XSLoader::load __PACKAGE__, $VERSION;

sub timer {
    my ($class, %arg) = @_;

    my $cb    = $arg{cb};
    my $ival  = $arg{interval} || 0;
    my $after = $arg{after} || 0;

    my $timer = __add_timer(bless({}), $after, $ival, $cb);
    bless \\$timer, 'AnyEvent::Impl::NSRunLoop::timer';
}

sub AnyEvent::Impl::NSRunLoop::timer::DESTROY {
    __remove_timer($${$_[0]});
}

sub DESTROY {
    __stop_loop();
}

1;

__END__

=head1 NAME

AnyEvent::Impl::NSRunLoop - Module abstract (<= 44 characters) goes here

=head1 SYNOPSIS

  use AnyEvent::Impl::NSRunLoop;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for this module was created by ExtUtils::ModuleMaker.
It looks like the author of the extension was negligent enough
to leave the stub unedited.

Blah blah blah.

=head1 AUTHOR

Daisuke Murase <typester@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2009 by KAYAC Inc.

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.

=cut
