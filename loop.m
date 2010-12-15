#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"

#import <Foundation/Foundation.h>

@interface Timer : NSObject {
@public
    NSTimer* timer;
    SV* cb;
}
-(void)callback;
@end

@implementation Timer

-(void)callback {
    dSP;

    ENTER;
    SAVETMPS;

    PUSHMARK(SP);
    PUTBACK;

    call_sv(cb, G_SCALAR);

    SPAGAIN;

    PUTBACK;
    FREETMPS;
    LEAVE;
}

-(void)dealloc {
    [super dealloc];
}

@end

XS(one_event) {
    dXSARGS;

    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                             beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    [pool drain];

    XSRETURN(0);
}

XS(loop) {
    dXSARGS;

    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    [[NSRunLoop currentRunLoop] run];
    [pool drain];

    XSRETURN(0);
}

XS(stop_loop) {
    dXSARGS;

    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    CFRunLoopStop([[NSRunLoop currentRunLoop] getCFRunLoop]);
    [pool drain];

    XSRETURN(0);
}

XS(add_timer) {
    dXSARGS;

    if (items < 3) {
        Perl_croak(aTHX_ "Usage: add_timer($obj, $after, $interval, $cb)");
    }

    SV* sv_obj      = ST(0);
    SV* sv_after    = ST(1);
    SV* sv_interval = ST(2);
    SV* sv_cb       = ST(3);

    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];

    double after    = SvNV(sv_after);
    double interval = SvNV(sv_interval);

    Timer* t = [[Timer alloc] init];

    t->cb = SvREFCNT_inc(sv_cb);
    t->timer = [[NSTimer alloc]
                   initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:after]
                           interval:interval
                             target:t
                           selector:@selector(callback)
                           userInfo:nil
                            repeats:interval ? YES : NO];

    sv_magic(SvRV(sv_obj), NULL, PERL_MAGIC_ext, NULL, 0);
    mg_find(SvRV(sv_obj), PERL_MAGIC_ext)->mg_obj = (void*)t;

    [[NSRunLoop currentRunLoop] addTimer:t->timer
                                 forMode:NSDefaultRunLoopMode];

    [pool drain];

    ST(0) = sv_obj;
    XSRETURN(1);
}

XS(remove_timer) {
    dXSARGS;

    if (items < 1) {
        Perl_croak(aTHX_ "Usage: remove_timer($timer)");
    }

    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];

    SV* sv_timer = ST(0);

    MAGIC* m = mg_find(SvRV(sv_timer), PERL_MAGIC_ext);
    Timer* t = (Timer*)m->mg_obj;

    [t->timer invalidate];
    SvREFCNT_dec(t->cb);
    [t release];

    [pool drain];

    XSRETURN(0);
}

XS(boot_AnyEvent__Impl__NSRunLoop) {
    newXS("AnyEvent::Impl::NSRunLoop::one_event", one_event, __FILE__);
    newXS("AnyEvent::Impl::NSRunLoop::loop", loop, __FILE__);
    newXS("AnyEvent::Impl::NSRunLoop::__stop_loop", stop_loop, __FILE__);
    newXS("AnyEvent::Impl::NSRunLoop::__add_timer", add_timer, __FILE__);
    newXS("AnyEvent::Impl::NSRunLoop::__remove_timer", remove_timer, __FILE__);
}
