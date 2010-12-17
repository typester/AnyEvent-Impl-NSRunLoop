package AnyEvent::Impl::NSRunLoop;
use strict;
use warnings;
use XSLoader;

use AnyEvent;

our $VERSION = '0.03';

BEGIN {
    push @AnyEvent::REGISTRY, [AnyEvent::Impl::NSRunLoop:: => AnyEvent::Impl::NSRunLoop::];
    XSLoader::load __PACKAGE__, $VERSION;
};

sub io {
    my ($class, %arg) = @_;

    my $fd = fileno($arg{fh});
    defined $fd or $fd = $arg{fh};

    my $mode = $arg{poll} eq 'r' ? 0 : 1;
    my $io = __add_io(bless({}), $fd, $mode, $arg{cb});

    bless \\$io, 'AnyEvent::Impl::NSRunLoop::io';
}

sub AnyEvent::Impl::NSRunLoop::io::DESTROY {
    __remove_io($${$_[0]});
}

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

=for stopwords API AnyEvent NSRunLoop github

=head1 NAME

AnyEvent::Impl::NSRunLoop - AnyEvent adaptor for Cocoa NSRunLoop

=head1 SYNOPSIS

    use AnyEvent;
    use AnyEvent::Impl::NSRunLoop;
    
    # do something

=head1 DESCRIPTION

This module provides NSRunLoop support to AnyEvent.

NSRunLoop is an event loop for Cocoa application. 
By using this module, you can use Cocoa based API in your AnyEvent application.

For example, using this module with L<Cocoa::Growl>, you can handle growl click event.

    my $cv = AnyEvent->condvar;
    
    # show growl notification
    growl_notify(
        name        => 'Notification Test',
        title       => 'Hello!',
        description => 'Growl world!',
        on_click    => sub {
            warn 'clicked!';
            $cv->send;
        },
    );
    
    $cv->recv;

Please look at L<Cocoa::Growl> documentation for more detail.

=head1 NOTICE

This module is in early development phase.
The implementation is not completed and alpha quality. See also skipped test cases in test directory.

Patches and suggestions are always welcome, let me know by email or on github :)

=head1 AUTHOR

Daisuke Murase <typester@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2009 by KAYAC Inc.

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.

=cut
