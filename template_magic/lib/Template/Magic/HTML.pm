package Template::Magic::HTML ;
$VERSION = 1.12 ;

; use 5.006_001
; use strict
; use base 'Template::Magic'

; BEGIN
   { *NEXT_HANDLER           = *Template::Magic::NEXT_HANDLER
   ; *LAST_HANDLER           = *Template::Magic::LAST_HANDLER
   ; *EXPORT_OK              = *Template::Magic::EXPORT_OK
   ; *DEFAULT_VALUE_HANDLERS = *Template::Magic::HTML_VALUE_HANDLERS
   ; *DEFAULT_MARKERS        = *Template::Magic::HTML_MARKERS
   }
   
; 1

__END__
      
=head1 NAME

Template::Magic::HTML - HTML handlers for Template::Magic used in a HTML environment

=head1 VERSION 1.12

Included in Template-Magic 1.12 distribution.

The latest versions changes are reported in the F<Changes> file in this distribution.

=head1 SYNOPSIS

    $tm = new Template::Magic::HTML ;
    
    # that means
    $tm = new Template::Magic
              markers        => 'HTML' ,
              value_handlers => 'HTML' ;
              
    # that explicitly means
    $tm = new Template::Magic
              markers        => [ qw( <!--{ / }--> ) ],
              value_handlers => [ qw( SCALAR
                                      REF
                                      CODE
                                      TableTiler
                                      ARRAY
                                      HASH
                                      FillInForm ) ] ;

=head1 DESCRIPTION

Template::Magic::HTML is a collection of handlers for Template::Magic useful when used in a HTML environment. It adds a couple of magic HTML specific value handlers to Template::Magic default value handlers. Just create and use the object as usual, to have a trasparent interface to HTML::TableTiler and HTML::FillInForm too.

Other interesting readings about how to use this collection are in:

=over

=item *

L<Template::Magic> (general documentation about the I<Template-Magic> system)

=item *

L<Template::Magic::Zone>

=back

=head1 HTML VALUE HANDLERS

=over

=item HTML

This is the shortcut for the complete HTML collection of handlers that defines the following value handlers:

    SCALAR
    REF
    CODE
    TableTiler
    ARRAY
    HASH
    FillInForm

See L<Template::Magic/"standard value handlers"> for details about I<SCALAR> I<REF> I<CODE> I<ARRAY> and I<HASH> handlers.

=item TableTiler

=over

=item Condition

a bidimensional array value

=item Action

magic generation of HTML table. No need to create and use a HTML::TableTiler object: this handler will manage it magically.

=item Description

The bidimensional array:

    $matrix_generating_a_table = [ [1..3], 
                                   [4..6], 
                                   [7..9] ];

The template could be as simple as a simple label with the same identifier of the bidimensional array:

    <p>paragraph text</p>
    <!--{matrix_generating_a_table}-->
    <p>other paragraph</p>

so the output will be a generic table including the array data:

    <p>paragraph text</p>
    <table>
    <tr>
        <td>1</td>
        <td>2</td>
        <td>3</td>
    </tr>
    <tr>
        <td>4</td>
        <td>5</td>
        <td>6</td>
    </tr>
    <tr>
        <td>7</td>
        <td>8</td>
        <td>9</td>
    </tr>
    </table>
    <p>paragraph text</p>


or the template could be a complete table I<Tile> included in a block with the same identifier of the bidimensional array, and with the optional ROW and COL TableTiler modes, passed as label attributes:

    <p>paragraph text</p>
    <!--{matrix_generating_a_table H_TILE V_TILE}-->
    <table border="1" cellspacing="2" cellpadding="2">
    <tr>
        <td><b><i>?</i></b></td>
        <td>?</td>
    </tr>
    <tr>
        <td>?</td>
        <td><b><i>?</i></b></td>
    </tr>
    </table>
    <!--{/matrix_generating_a_table}-->
    <p>other paragraph</p>

so the output will be a complete tiled table including the array data:

    <p>paragraph text</p>
    <table border="1" cellspacing="2" cellpadding="2">
    <tr>
        <td><b><i>1</i></b></td>
        <td>2</td>
        <td><b><i>3</i></b></td>
    </tr>
    <tr>
        <td>4</td>
        <td><b><i>5</i></b></td>
        <td>6</td>
    </tr>
    <tr>
        <td><b><i>7</i></b></td>
        <td>8</td>
        <td><b><i>9</i></b></td>
    </tr>
    </table>
    <p>paragraph text</p>

See L<HTML::TableTiler> for details about this module.

Note: if your template don't need this specific handler you can avoid its loading by explicitly omitting it:

    $tm = new Template::Magic::HTML
              value_handlers => [ qw( SCALAR
                                      REF
                                      CODE
                                      ARRAY
                                      HASH
                                      FillInForm ) ] ;

B<Warning>: since this handler checks for a bidimensional ARRAY, it must be checked BEFORE the ARRAY value handler in order to work.

=back

=item FillInForm

=over

=item Condition

a CGI query object value (or by a blessed object that has a param() method)

=item Action

magic fill in of a HTML form with the parameter in the CGI object

=item Description

The CGI object in your code:

    $my_query = new CGI;

If you want to fill a form with the param in the $my_query, just transform the form into a block giving it the same identifier.

    <!--{my_query}-->
    <form action="my.cgi">
    ...
    </form>
    <!--{/my_query}-->

One useful application of this handler is when a user submits an HTML form without filling out a required field. FillInForm handler will magically redisplay the form with all the form elements (input, textarea and select tags) filled with the submitted info ($my_query), without any other statement in your code. (No need to create and use a HTML::FillInForm object: this handler will manage it magically).

You can use this handler to fill the form with default values too, To do this, just create a new query object and fill it with the default param that you want in the form:

    $query = new CGI;
    $query->param( name    => 'John', 
                   surname => 'Smith', ...);

See L<HTML::FillInForm> for details about this module.

Note: if your template don't need this specific handler you can avoid its loading by explicitly omitting it:

    $tm = new Template::Magic::HTML
              value_handlers => [ qw( SCALAR
                                      REF
                                      CODE
                                      TableTiler
                                      ARRAY
                                      HASH ) ] ;

=back

=back

=head1 SEE ALSO

=over

=item * L<Template::Magic|Template::Magic>

=item * L<Template::Magic::Zone|Template::Magic::Zone>

=item * L<HTML::TableTiler|HTML::TableTiler>

=item * L<HTML::FillInForm|HTML::FillInForm>

=back

=head1 SUPPORT and FEEDBACK

You can join the CBF mailing list at this url:

    http://lists.sourceforge.net/lists/listinfo/template-magic-users

=head1 AUTHOR and COPYRIGHT

© 2004 by Domizio Demichelis (http://perl.4pro.net)

All Rights Reserved. This module is free software. It may be used, redistributed and/or modified under the same terms as perl itself.

