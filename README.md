# NAME

Test2::Plugin::SourceDiag - Output the lines of code that resulted in a
failure.

# DESCRIPTION

This plugin injects diagnostics messages that include the lines of source that
executed to produce the test failure. This is a less magical answer to Damian
Conway's [Test::Expr](https://metacpan.org/pod/Test::Expr) module, that has the benefit of working on any Test2
based test.

# SYNOPSIS

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

# SOURCE

The source code repository for Test2-Plugin-SourceDiag can be found at
`http://github.com/Test-More/Test2-Plugin-SourceDiag/`.

# MAINTAINERS

- Chad Granum <exodist@cpan.org>

# AUTHORS

- Chad Granum <exodist@cpan.org>

# COPYRIGHT

Copyright 2017 Chad Granum <exodist@cpan.org>.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

See `http://dev.perl.org/licenses/`