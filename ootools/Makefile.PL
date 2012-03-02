use ExtUtils::MakeMaker;

WriteMakefile
(
  NAME             => 'OOTools',
  VERSION_FROM     => 'lib/Class/props.pm',
  ($] ge '5.005')
     ? ('AUTHOR'   => 'Domizio Demichelis <dd\@4pro.net>',
        'ABSTRACT' => 'Pragmas to implement constructors and accessors' )
                      
     : (),
);

