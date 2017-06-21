use Test2::V0;
use Test2::API qw/intercept/;
use Test2::Plugin::SourceDiag;

ok(0, "This will fail");

is(
    {a => 1},
    {a => 2},
    "foo",
);

# Oooh, tricky :-) logical line number is 21: "hash test", I am amazed PPI knows that!
is(
    {a => 1},
    hash {
        field a => 2;
        end;
    },
    "hash test",
);

done_testing;
