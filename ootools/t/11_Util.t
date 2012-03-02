#!perl -w
; use strict
; use warnings
; use Test::More tests => 5
#; use Data::Dumper

; BEGIN
   { use_ok 'Class::Util'
   }

; my $c1 = 'c1'
; eval{ Class::Util::load $c1 }
; like $@, qr/^Can't locate/

; package c2
; sub new { bless \$_[1], $_[0] }

; package main
; my $c2 = 'c2'
; Class::Util::load $c2
; ok $@
; my $o2 = $c2->new()
; isa_ok $o2, 'c2'

; my $c3 = 'CGI'
; Class::Util::load $c3  
; my $o3 = $c3->new()
; isa_ok $o3, 'CGI'


