#!perl -w
; use strict
; use Test::More tests => 4


; use IO::Util
; use Sys::Hostname
; use Time::HiRes

; ok(  ! defined &Tid
    && ! defined &Lid
    && ! defined &Uid
    )

; my $u1 = IO::Util::Tid()
; my $u2 = IO::Util::Lid()
; my $u3 = IO::Util::Uid()
; ok (  $u1 && $u2 && $u3
     && length($u1)<length($u2)
     && length($u2)<length($u3)
     )

; my $u4 = IO::Util::Tid(chars=>'base62')
; my $u5 = IO::Util::Lid(chars=>'base62')
; my $u6 = IO::Util::Uid(chars=>'base62')
; ok (  $u3 && $u4 && $u5
     && length($u4)<length($u5)
     && length($u5)<length($u6)
     )

; my $u7 = IO::Util::Tid(chars=>[0..9, 'A'..'F'])
; my $u8 = IO::Util::Lid(chars=>[0..9, 'A'..'F'])
; my $u9 = IO::Util::Uid(chars=>[0..9, 'A'..'F'])
; ok (  $u7 && $u8 && $u9
     && length($u7)<length($u8)
     && length($u8)<length($u9)
     )
