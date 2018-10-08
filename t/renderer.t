use Mojo::Base -strict;

use Test::More;
use Mojolicious;
use Path::Tiny;
use FindBin qw($Bin);

# Partial rendering
my $app = Mojolicious->new(secrets => ['works']);
$app->plugin('TemplateToolkit');
my $c = $app->build_controller;
$c->app->log->level('fatal');
is $c->render_to_string(inline => 'works', handler => 'tt2'), 'works', 'renderer is working';

$app->renderer->default_handler('tt2');

# Stash variable
is $c->render_to_string(inline => '[% foo %]', foo => 'bar'), 'bar', 'stash variable is passed';

# Helper
is $c->render_to_string(inline => '[% stash("foo") %]', foo => 'bar'), 'bar', 'helper works';
like $c->render_to_string(inline => "[% link_to('some link', 'http://www.example.com') %]"),
	qr(href.+http://www\.example\.com.+some link), 'helper works';

# Controller
is $c->render_to_string(inline => '[% c.stash.foo %]', foo => 'bar'), 'bar', 'controller is accessible';

# Encoding
is $c->render_to_string(inline => '☃'), '☃', 'encoding works';
is $c->render_to_string(inline => '[% foo %]', foo => '☃'), '☃', 'encoding works';

# Set configuration
$app = Mojolicious->new(secrets => ['works']);
my $tt_config = { INTERPOLATE => 1, START_TAG => '<%', END_TAG => '%>' };
$app->plugin(TemplateToolkit => { name => 'foo', template => $tt_config });
$c = $app->build_controller;
$c->app->log->level('fatal');

is $c->render_to_string(inline => 'foo', handler => 'foo'), 'foo', 'name works';
is $c->render_to_string(inline => '$foo', handler => 'foo', foo => 'bar'), 'bar', 'interpolate works';
is $c->render_to_string(inline => '<% foo %>', handler => 'foo', foo => 'bar'), 'bar', 'tags work';

$app = Mojolicious->new(secrets => ['works']);
$tt_config = { INTERPOLATE => 1, INCLUDE_PATH => $Bin . '/share/templates', DELIMITER => '/' };
$app->plugin(TemplateToolkit => { name => 'tt2', template => $tt_config });
$c = $app->build_controller;
$c->app->log->level('fatal');
#$c->app->log->handle(\*STDERR);
like($c->render_to_string(template => 'test', handler => 'tt2', format => 'html', foo => 'bar'),
    qr{<body>[\n\s]+bar[\n\s]+</body>},
    'rendering from TT included path works'
);

done_testing();
