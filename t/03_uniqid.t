#!perl -w
; use strict
; use Test::More tests => 4


; use IO::Util qw(Tid Lid Uid)

; ok(  defined &Tid
    && defined &Lid
    && defined &Uid
    )

; SKIP:
   { skip("Time::HiRes is not installed", 3)
     unless eval{require Time::HiRes}

; my $u1 = Tid
; my $u2 = Lid
; my $u3 = Uid
; ok (  $u1 && $u2 && $u3
     && length($u1)<length($u2)
     && length($u2)<length($u3)
     )

; my $u4 = Tid chars=>'base62'
; my $u5 = Lid chars=>'base62'
; my $u6 = Uid chars=>'base62'
; ok (  $u3 && $u4 && $u5
     && length($u4)<length($u5)
     && length($u5)<length($u6)
     )

; my $u7 = Tid chars=>[0..9, 'A'..'F']
; my $u8 = Lid chars=>[0..9, 'A'..'F']
; my $u9 = Uid chars=>[0..9, 'A'..'F']
; ok (  $u7 && $u8 && $u9
     && length($u7)<length($u8)
     && length($u8)<length($u9)
     )
     
   }
