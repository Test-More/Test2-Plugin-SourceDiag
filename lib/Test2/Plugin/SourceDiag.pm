package Test2::Plugin::SourceDiag;
use strict;
use warnings;

our $VERSION = '0.000002';

use Test2::Event::Diag;

use Test2::API qw{
    test2_add_callback_post_load
    test2_stack
};

my %SEEN;
sub import {
    test2_add_callback_post_load(sub {
        my $hub = test2_stack()->top;
        $hub->listen(\&listener, inherit => 1);
    });
}

sub listener {
    my ($hub, $event) = @_;

    return unless $event->causes_fail;

    my $trace = $event->trace or return;
    my $code  = get_assert_code($trace) or return;

    chomp($code);

    $hub->send(Test2::Event::Diag->new(
        trace => $trace,
        message => "Failure source code:\n------------\n$code\n------------\n",
    ));
}

my %CACHE;
sub get_assert_code {
    my ($trace) = @_;

    my $file = $trace->file or return;
    my $line = $trace->line or return;
    my $sub  = $trace->subname or return;
    my $short_sub = $sub;
    $short_sub =~ s/^.*:://;
    return if $short_sub eq '__ANON__';

    my %subs = ($sub => 1, $short_sub => 1);

    require PPI::Document;
    my $pd = $CACHE{$file} ||= PPI::Document->new($file);
    $pd->index_locations;

    my $it = $pd->find(sub {!$_[1]->isa('PPI::Token::Whitespace') && $_[1]->logical_line_number == $line }) or return;

    my $found = $it->[0] or return;

    my $thing = $found;
    while ($thing) {
        if (($thing->can('children') && $subs{($thing->children)[0]->content}) || $subs{$thing->content}) {
            $found = $thing;
            last;
        }

        $thing = $thing->parent;
    }

    my @source;

    push @source => split /\r?\n/, $found->content;

    # Add in any indentation we may have cut off.
    my $prefix = $thing->previous_sibling;
    if ($prefix && $prefix->isa('PPI::Token::Whitespace') && $prefix->content ne "\n") {
        my $space = $prefix->content;
        $space =~ s/^.*\n//s;
        $source[0] = $space . $source[0] if length($space);
    }

    my $start = $found->logical_line_number;
    my $end = $start + $#source;
    my $len = length("$end");
    return join "\n" => map {sprintf("% ${len}s: %s", $start++, $_)} @source;
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Test2::Plugin::SourceDiag - Output the lines of code that resulted in a
failure.

=head1 DESCRIPTION

This plugin injects diagnostics messages that include the lines of source that
executed to produce the test failure. This is a less magical answer to Damian
Conway's L<Test::Expr> module, that has the benefit of working on any Test2
based test.

=head1 SYNOPSIS

This test:

    use Test2::V0;
    use Test2::Plugin::SourceDiag;

    ok(0, "fail");

    done_testing;

Produces the output:

    not ok 1 - fail
    Failure source code:
    # ------------
    # 4: ok(0, "fail");
    # ------------
    # Failed test 'fail'
    # at test.pl line 4.

=head1 SOURCE

The source code repository for Test2-Plugin-SourceDiag can be found at
F<http://github.com/Test-More/Test2-Plugin-SourceDiag/>.

=head1 MAINTAINERS

=over 4

=item Chad Granum E<lt>exodist@cpan.orgE<gt>

=back

=head1 AUTHORS

=over 4

=item Chad Granum E<lt>exodist@cpan.orgE<gt>

=back

=head1 COPYRIGHT

Copyright 2017 Chad Granum E<lt>exodist@cpan.orgE<gt>.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

See F<http://dev.perl.org/licenses/>

=cut
