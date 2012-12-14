#!/usr/bin/perl

#=======================================================================
# tests/suuid.t
# File ID: 7a006334-f988-11dd-8845-000475e441b9
# Test suite for suuid(1).
#
# Character set: UTF-8
# ©opyleft 2008– Øyvind A. Holm <sunny@sunbase.org>
# License: GNU General Public License version 3 or later, see end of 
# file for legal stuff.
#=======================================================================

use strict;
use warnings;

BEGIN {
    use Test::More qw{no_plan};
    use lib "$ENV{HOME}/bin/src/suuid";
    use_ok("suuid");
}

use bigint;
use Getopt::Long;

local $| = 1;

our $Debug = 0;
our $CMD = "../suuid";
our $cmdprogname = $CMD;
$cmdprogname =~ s/^.*\/(.*?)$/$1/;
$ENV{'SESS_UUID'} = "";

our %Opt = (

    'all' => 0,
    'debug' => 0,
    'help' => 0,
    'todo' => 0,
    'verbose' => 0,
    'version' => 0,

);

our $progname = $0;
$progname =~ s/^.*\/(.*?)$/$1/;
our $VERSION = '0.50';

Getopt::Long::Configure('bundling');
GetOptions(

    'all|a' => \$Opt{'all'},
    'debug' => \$Opt{'debug'},
    'help|h' => \$Opt{'help'},
    'todo|t' => \$Opt{'todo'},
    'verbose|v+' => \$Opt{'verbose'},
    'version' => \$Opt{'version'},

) || die("$progname: Option error. Use -h for help.\n");

$Opt{'debug'} && ($Debug = 1);
$Debug && print("\@INC = '" . join("', '", @INC) . "'\n");
$Opt{'help'} && usage(0);
if ($Opt{'version'}) {
    print_version();
    exit(0);
}

my $cdata = '[^<]+';
my $Lh = "[0-9a-fA-F]";
my $Templ = "$Lh\{8}-$Lh\{4}-$Lh\{4}-$Lh\{4}-$Lh\{12}";
my $v1_templ = "$Lh\{8}-$Lh\{4}-1$Lh\{3}-$Lh\{4}-$Lh\{12}";
my $v1rand_templ = "$Lh\{8}-$Lh\{4}-1$Lh\{3}-$Lh\{4}-$Lh\[37bf]$Lh\{10}";
my $date_templ = '20[0-9][0-9]-[0-1][0-9]-[0-3][0-9]T[0-2][0-9]:[0-5][0-9]:[0-6][0-9]\.\d+Z';
my $xml_header = join("",
    '<\?xml version="1\.0" encoding="UTF-8"\?>\n',
    '<!DOCTYPE suuids SYSTEM "dtd\/suuids\.dtd">\n',
    '<suuids>\n',
);

exit(main(%Opt));

sub main {
    # {{{
    my %Opt = @_;
    my $Retval = 0;

    diag(sprintf('========== Executing %s v%s ==========',
        $progname,
        $VERSION));

    if ($Opt{'todo'} && !$Opt{'all'}) {
        goto todo_section;
    }

=pod

    testcmd("$CMD command", # {{{
        <<'END',
[expected stdin]
END
        '',
        0,
        'description',
    );

    # }}}

=cut

    test_standard_options();
    test_test_functions();
    test_suuid_executable();

    todo_section:
    ;

    if ($Opt{'all'} || $Opt{'todo'}) {
        diag('Running TODO tests...'); # {{{

        TODO: {

    local $TODO = '';
    # Insert TODO tests here.

        }
        # TODO tests }}}
    }

    diag('Testing finished.');

    return($Retval);
    # }}}
} # main()

sub test_standard_options {
    diag('Testing -h (--help) option...');
    likecmd("$CMD -h", # {{{
        '/  Show this help\./',
        '/^$/',
        0,
        'Option -h prints help screen',
    );

    # }}}
    diag('Testing -v (--verbose) option...');
    likecmd("$CMD -hv", # {{{
        '/^\n\S+ v\d\.\d\d\n/s',
        '/^$/',
        0,
        'Option --version with -h returns version number and help screen',
    );

    # }}}
    diag('Testing --version option...');
    likecmd("$CMD --version", # {{{
        '/^\S+ v\d\.\d\d\n/',
        '/^$/',
        0,
        'Option --version returns version number',
    );

    # }}}
    return;
} # test_standard_options()

sub test_test_functions {
    diag("Testing uuid_time()..."); # {{{
    is(uuid_time("c7f54e5a-afae-11df-b4a3-dffbc1242a34"), "2010-08-24T18:38:25.8316890Z", "uuid_time() works");
    is(uuid_time("3cbf9480-16fb-409f-98cc-bdfb02bf0e30"), "", "uuid_time() returns \"\" if UUID version 4");
    is(uuid_time(""), "", "uuid_time() receives empty string, returns \"\"");
    is(uuid_time("rubbish"), "", "uuid_time() receives rubbish, returns \"\"");

    # }}}
    diag("Testing uuid_time2()..."); # {{{
    is(uuid_time2("2527c268-b024-11df-a05c-09f86a2af1d3"), "2010-08-25T08:38:33.3078120Z", "uuid_time2() works");
    is(uuid_time2("3cbf9480-16fb-409f-98cc-bdfb02bf0e30"), "", "uuid_time2() returns \"\" if UUID version 4");
    is(uuid_time2(""), "", "uuid_time2() receives empty string, returns \"\"");
    is(uuid_time2("rubbish"), "", "uuid_time2() receives rubbish, returns \"\"");

    # }}}
    diag("Testing suuid_xml()..."); # {{{
    is(suuid_xml(""), "", "suuid_xml() receives empty string");
    is(suuid_xml("<&>\\"), "&lt;&amp;&gt;\\\\", "suuid_xml(\"<&>\\\\\")");
    is(suuid_xml("<&>\\\n\t", 1), "<&>\\\n\t", "suuid_xml(\"<&>\\\\\\n\\t\", 1) i,e. don’t convert");
    is(suuid_xml("<&>\n\r\t"), "&lt;&amp;&gt;\\n\\r\\t", "suuid_xml(\"<&>\\n\\r\\t\")");
    is(suuid_xml("\x00\x01\xFF"), "\x00\x01\xFF", "suuid_xml(\"\\x00\\x01\\xFF\")"); # FIXME: Should it behave like this?

    # }}}
    diag("Testing bighex()..."); # {{{
    is(bighex(""), 0, "bighex() receives empty string");
    is(bighex("0000"), 0, "bighex(\"0000\")");
    is(bighex("00001"), 1, "bighex(\"00001\")");
    is(bighex("ff"), 255, "bighex(\"ff\")");
    is(bighex("DeadBeef"), 3735928559, "bighex(\"DeadBeef\")");
    is(bighex("EDC4E5813177A7457214F6B62C1CB1"), 1234567890987654321234567890987654321, "Big stuff to bighex()");
    is(bighex("!Amob=+[]CdE.-f0\n12\t345"), NaN(), "bighex() returns NaN()");
    is(bighex("AbCdEf012345\n"), "NaN", "bighex() also returns \"NaN\"");

    # }}}
    diag("Testing s_top()..."); # {{{
    like(
        (
            "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n" .
            "<!DOCTYPE suuids SYSTEM \"dtd/suuids.dtd\">\n" .
            "<suuids>\n" .
            "</suuids>\n"
        ),
        s_top(''),
        "s_top('') returns empty file"
    );

    # }}}
    diag("Testing s_suuid_tag()..."); # {{{
    is(s_suuid_tag(''), '', "s_suuid_tag('') returns ''");
    is(s_suuid_tag('test'), '<tag>test</tag> ', "s_suuid_tag('test')");
    is(s_suuid_tag('test,lixom'), '<tag>test</tag> <tag>lixom</tag> ', "s_suuid_tag('test,lixom')");
    is(s_suuid_tag('test,lixom,på en måte'), '<tag>test</tag> <tag>lixom</tag> <tag>på en måte</tag> ', "s_suuid_tag('test,lixom,på en måte')");
    is(s_suuid_tag('test,lixom, space '), '<tag>test</tag> <tag>lixom</tag> <tag> space </tag> ', "s_suuid_tag('test,lixom, space ')");

    # }}}
    diag("Testing s_suuid_sess()..."); # {{{
    is(s_suuid_sess(''), '', "s_suuid_sess('') returns ''");

    for my $l_desc ('deschere', '') {
        for my $l_slash ('/', '') {
            for my $l_uuid ('ff529c20-4522-11e2-8c4a-0016d364066c', '') {
                for my $l_comma (',', '') {
                    my $fail = 0;
                    my $str = "$l_desc$l_slash$l_uuid$l_comma";
                    my $humstr = sprintf(
                        "s_suuid_sess() %s desc, %s slash, %s uuid, %s comma",
                        length($l_desc)  ? "with" : "without",
                        length($l_slash) ? "with" : "without",
                        length($l_uuid)  ? "with" : "without",
                        length($l_comma) ? "with" : "without",
                    );
                    length($l_slash) || ($fail = 1);
                    length($l_comma) || ($fail = 1);
                    length($l_uuid)  || ($fail = 1);
                    if ($fail) {
                        if (length($str)) {
                            is(s_suuid_sess($str), undef, $humstr);
                        }
                    } else {
                        like(s_suuid_sess($str), '/^<sess( desc="deschere")?>ff529c20-4522-11e2-8c4a-0016d364066c<\/sess> $/', $humstr)
                    }
                }
            }
        }
    }

    is(
        s_suuid_sess('ff529c20-4522-11e2-8c4a-0016d364066c'),
        undef,
        "s_suuid_sess() without comma and slash returns undef",
    );
    is(
        s_suuid_sess('ff529c20-4522-11e2-8c4a-0016d364066c,'),
        undef,
        "s_suuid_sess() with comma but missing slash returns undef",
    );
    is(
        s_suuid_sess('xterm/ff529c20-4522-11e2-8c4a-0016d364066c'),
        undef,
        "s_suuid_sess() with desc, but missing comma returns undef",
    );
    is(
        s_suuid_sess('/ff529c20-4522-11e2-8c4a-0016d364066c,'),
        '<sess>ff529c20-4522-11e2-8c4a-0016d364066c</sess> ',
        "s_suuid_sess() without desc, but with slash and comma",
    );
    is(
        s_suuid_sess('xterm/ff529c20-4522-11e2-8c4a-0016d364066c,'),
        '<sess desc="xterm">ff529c20-4522-11e2-8c4a-0016d364066c</sess> ',
        "s_suuid_sess() with desc and comma",
    );
    is(
        s_suuid_sess(
            'xfce/bbd272a0-44e0-11e2-bcdb-0016d364066c,' .
            'xterm/c1986406-44e0-11e2-af23-0016d364066c,' .
            'screen/e7f897b0-44e0-11e2-b5a0-0016d364066c,'
        ),
        (
            '<sess desc="xfce">bbd272a0-44e0-11e2-bcdb-0016d364066c</sess> ' .
            '<sess desc="xterm">c1986406-44e0-11e2-af23-0016d364066c</sess> ' .
            '<sess desc="screen">e7f897b0-44e0-11e2-b5a0-0016d364066c</sess> ',
        ),
        's_suuid_sess() receives string with three with desc',
    );
    is(
        s_suuid_sess('/ee5db39a-43f7-11e2-a975-0016d364066c,/da700fd8-43eb-11e2-889a-0016d364066c,'),
        '<sess>ee5db39a-43f7-11e2-a975-0016d364066c</sess> <sess>da700fd8-43eb-11e2-889a-0016d364066c</sess> ',
        "s_suuid_sess() receives two without desc",
    );

    # }}}
} # test_test_functions()

sub test_suuid_executable {
    my $Outdir = "tmp-suuid-t-$$-" . substr(rand, 2, 8);
    if (-e $Outdir) {
        die("$progname: $Outdir: WTF?? Directory element already exists.");
    }
    unless (mkdir($Outdir)) {
        die("$progname: $Outdir: Cannot mkdir(): $!\n");
    }

    diag("No options (except --logfile)...");
    likecmd("$CMD -l $Outdir", # {{{
        "/^$v1_templ\n\$/s",
        '/^$/',
        0,
        "No options (except -l) sends UUID to stdout",
    );

    # }}}
    my $Outfile = glob("$Outdir/*");
    like($Outfile, "/^$Outdir\\/\\S+\.xml\$/", "Filename of logfile OK");
    like(file_data($Outfile), # {{{
        s_top(
            s_suuid(),
        ),
        "Log contents OK after exec with no options",
    );

    # }}}
    testcmd("$CMD -l $Outdir >/dev/null", # {{{
        '',
        '',
        0,
        "Redirect stdout to /dev/null",
    );

    # }}}
    like(file_data($Outfile), # {{{
        s_top(
             s_suuid() .
             s_suuid(),
        ),
        "Entries are added, not replacing",
    );

    # }}}
    ok(unlink($Outfile), "Delete $Outfile");
    testcmd("$CMD --rcfile rcfile-inv-uuidcmd -l $Outdir", # {{{
        '',
        "suuid: '': Generated UUID is not in the expected format\n",
        1,
        "uuidcmd does not generate valid UUID",
    );

    # }}}
    my $host_outfile = glob("$Outdir/*");
    like(file_data($host_outfile), # {{{
        s_top(''),
        "suuid file is empty",
    );

    # }}}
    diag("Read the SUUID_LOGDIR environment variable...");
    likecmd("SUUID_LOGDIR=$Outdir $CMD", # {{{
        "/^$v1_templ\n\$/s",
        '/^$/',
        0,
        "Read environment variable",
    );

    # }}}
    like(file_data($Outfile), # {{{
        s_top(
            s_suuid(),
        ),
        "The SUUID_LOGDIR environment variable was read",
    );

    # }}}
    ok(unlink($Outfile), "Delete $Outfile");
    diag("Read the SUUID_HOSTNAME environment variable...");
    likecmd("SUUID_HOSTNAME=urk13579kru $CMD -l $Outdir", # {{{
        "/^$v1_templ\n\$/s",
        '/^$/',
        0,
        "Read environment variable",
    );

    # }}}
    like(file_data("$Outdir/urk13579kru.xml"), # {{{
        s_top(
            s_suuid(
                'host' => 'urk13579kru',
            ),
        ),
        "The SUUID_HOSTNAME environment variable was read",
    );

    # }}}
    ok(unlink("$Outdir/urk13579kru.xml"), "Delete $Outdir/urk13579kru.xml");
    diag("Testing -m (--random-mac) option...");
    likecmd("$CMD -m -l $Outdir", # {{{
        "/^$v1rand_templ\\n\$/s",
        '/^$/s',
        0,
        "--random-mac option works",
    );

    # }}}
    like(file_data($Outfile), # {{{
        s_top(
            s_suuid(),
        ),
        "Log contents OK after --random-mac",
    );

    # }}}
    ok(unlink($Outfile), "Delete $Outfile");
    diag("Testing --raw option...");
    likecmd("$CMD --raw -c '<dingle><dangle>bær</dangle></dingle>' -l $Outdir", # {{{
        "/^$v1_templ\\n\$/s",
        '/^$/s',
        0,
        "--raw option works",
    );

    # }}}
    like(file_data($Outfile), # {{{
        s_top(
            s_suuid('txt' => ' <dingle><dangle>bær<\/dangle><\/dingle> '),
        ),
        "Log contents after --raw is OK",
    );
    # }}}
    ok(unlink($Outfile), "Delete $Outfile");
    diag("Testing --rcfile option...");
    likecmd("$CMD --rcfile rcfile1 -l $Outdir", # {{{
        "/^$v1_templ\\n\$/s",
        '/^$/s',
        0,
        "--rcfile option works",
    );

    # }}}
    like(file_data("$Outdir/altrc1.xml"), # {{{
        s_top(
            s_suuid('host' => 'altrc1'),
        ),
        "hostname from rcfile1 is stored in the file",
    );

    # }}}
    ok(unlink("$Outdir/altrc1.xml"), "Delete $Outdir/altrc1.xml");
    ok(!-e 'nosuchrc', "'nosuchrc' doesn't exist");
    likecmd("$CMD --rcfile nosuchrc -l $Outdir", # {{{
        "/^$v1_templ\\n\$/s",
        '/^$/s',
        0,
        "--rcfile with non-existing file",
    );

    # }}}
    ok(unlink($host_outfile), "Delete $host_outfile");
    diag("Testing -t (--tag) option...");
    likecmd("$CMD -t snaddertag -l $Outdir", # {{{
        "/^$v1_templ\n\$/s",
        '/^$/',
        0,
        "-t (--tag) option",
    );

    # }}}
    testcmd("$CMD -t schn\xfcffelhund -l $Outdir", # {{{
        "",
        "suuid: Tags have to be in UTF-8\n",
        1,
        "Refuse non-UTF-8 tags",
    );

    # }}}
    like(file_data($Outfile), # {{{
        s_top(
            s_suuid('tag' => 'snaddertag'),
        ),
        "Log contents OK after tag",
    );

    # }}}
    ok(unlink($Outfile), "Delete $Outfile");
    test_suuid_comment($Outdir, $Outfile);
    diag("Testing -n (--count) option...");
    likecmd("$CMD -n 5 -c \"Great test\" -t testeri -l $Outdir", # {{{
        "/^($v1_templ\n){5}\$/s",
        '/^$/',
        0,
        "-n (--count) option with comment and tag",
    );

    # }}}
    like(file_data($Outfile), # {{{
        s_top(
            s_suuid(
                'tag' => 'testeri',
                'txt' => 'Great test',
            ) x 5,
        ),
        "Log contents OK after count, comment and tag",
    );

    # }}}
    diag("Check for randomness in the MAC address field...");
    cmp_ok(unique_macs($Outfile), '==', 1, 'MAC adresses does not change');
    ok(unlink($Outfile), "Delete $Outfile");
    likecmd("$CMD -m -n 5 -l $Outdir", # {{{
        "/^($v1_templ\n){5}\$/s",
        '/^$/',
        0,
        "-n (--count) option with -m (--random-mac)",
    );

    # }}}
    cmp_ok(unique_macs($Outfile), '==', 5, 'MAC adresses are random');
    diag("Testing -w (--whereto) option...");
    likecmd("$CMD -w o -l $Outdir", # {{{
        "/^$v1_templ\\n\$/s",
        '/^$/s',
        0,
        "Output goes to stdout",
    );

    # }}}
    likecmd("$CMD -w e -l $Outdir", # {{{
        '/^$/s',
        "/^$v1_templ\\n\$/s",
        0,
        "Output goes to stderr",
    );

    # }}}
    likecmd("$CMD -w eo -l $Outdir", # {{{
        "/^$v1_templ\\n\$/s",
        "/^$v1_templ\\n\$/s",
        0,
        "Output goes to stdout and stderr",
    );

    # }}}
    likecmd("$CMD -w a -l $Outdir", # {{{
        "/^$v1_templ\\n\$/s",
        "/^$v1_templ\\n\$/s",
        0,
        "Option -wa sends output to stdout and stderr",
    );

    # }}}
    likecmd("$CMD -w n -l $Outdir", # {{{
        '/^$/s',
        '/^$/s',
        0,
        "Output goes nowhere",
    );

    # }}}
    ok(unlink($Outfile), "Delete $Outfile");
    diag("Testing -q (--quiet) option...");
    test_suuid_environment($Outdir, $Outfile);
    diag("Test behaviour when unable to write to the log file...");
    my @stat_array = stat($Outfile);
    ok(chmod(0444, $Outfile), "Make $Outfile read-only");
    likecmd("$CMD -l $Outdir", # {{{
        '/^$/s',
        "/^$cmdprogname: $Outfile: Cannot open file for append: .*\$/s",
        13,
        "Unable to write to the log file",
    );
    chmod($stat_array[2], $Outfile);

    # }}}
    ok(unlink($Outfile), "Delete $Outfile");
    ok(rmdir($Outdir), "rmdir $Outdir");
} # test_suuid_executable()

sub test_suuid_comment {
    my ($Outdir, $Outfile) = @_;
    diag("Testing -c (--comment) option...");
    likecmd("$CMD -c \"Great test\" -l $Outdir", # {{{
        "/^$v1_templ\n\$/s",
        '/^$/',
        0,
        "-c (--comment) option",
    );

    # }}}
    testcmd("$CMD -c \"F\xf8kka \xf8pp\" -l $Outdir", # {{{
        "",
        "suuid: Comment contains illegal characters or is not valid UTF-8\n",
        1,
        "Refuse non-UTF-8 text to --comment option",
    );

    # }}}
    testcmd("$CMD -c \"Ctrl-d: \x04\" -l $Outdir", # {{{
        "",
        "suuid: Comment contains illegal characters or is not valid UTF-8\n",
        1,
        "Reject Ctrl-d in comment",
    );

    # }}}
    likecmd("echo \"Great test\" | $CMD -c - -l $Outdir", # {{{
        "/^$v1_templ\n\$/s",
        '/^suuid: Enter uuid comment: $/',
        0,
        "Read comment from stdin",
    );

    # }}}
    testcmd("echo \"F\xf8kka \xf8pp\" | $CMD -c - -l $Outdir", # {{{
        "",
        "suuid: Enter uuid comment: suuid: Comment contains illegal characters or is not valid UTF-8\n",
        1,
        "Reject non-UTF-8 comment from stdin",
    );

    # }}}
    testcmd("echo \"Ctrl-d: \x04\" | $CMD -c - -l $Outdir", # {{{
        "",
        "suuid: Enter uuid comment: suuid: Comment contains illegal characters or is not valid UTF-8\n",
        1,
        "Reject Ctrl-d in comment from stdin",
    );

    # }}}
    like(file_data($Outfile), # {{{
        s_top(
            s_suuid('txt' => 'Great test') x 2,
        ),
        "Log contents OK after comment",
    );

    # }}}
    ok(unlink($Outfile), "Delete $Outfile");
} # test_suuid_comment()

sub test_suuid_environment {
    my ($Outdir, $Outfile) = @_;
    diag("Test logging of \$SESS_UUID environment variable...");
    likecmd("SESS_UUID=27538da4-fc68-11dd-996d-000475e441b9 $CMD -t yess -l $Outdir", # {{{
        "/^$v1_templ\n\$/s",
        '/^$/',
        0,
        "-t (--tag) option",
    );

    # }}}
    like(file_data($Outfile), # {{{
        s_top(
            s_suuid(
                'tag' => 'yess',
                'sess' => '/27538da4-fc68-11dd-996d-000475e441b9,',
            ),
        ),
        "\$SESS_UUID envariable is logged",
    );

    # }}}
    ok(unlink($Outfile), "Delete $Outfile");
    likecmd("SESS_UUID=ssh-agent/da700fd8-43eb-11e2-889a-0016d364066c, $CMD -l $Outdir", # {{{
        "/^$v1_templ\n\$/s",
        '/^$/',
        0,
        "SESS_UUID with 'ssh-agent/'-prefix and comma at the end",
    );

    # }}}
    like(file_data($Outfile), # {{{
        s_top(
            s_suuid(
                'sess' => 'ssh-agent/da700fd8-43eb-11e2-889a-0016d364066c,',
            ),
        ),
        "<sess> contains desc attribute",
    );

    # }}}
    likecmd("SESS_UUID=ssh-agent/da700fd8-43eb-11e2-889a-0016d364066c,dingle©/4c66b03a-43f4-11e2-b70d-0016d364066c, $CMD -l $Outdir", # {{{
        "/^$v1_templ\n\$/s",
        '/^$/',
        0,
        "SESS_UUID with 'ssh-agent' and 'dingle©'",
    );

    # }}}
    like(file_data($Outfile), # {{{
        s_top(
            s_suuid(
                'sess' => 'ssh-agent/da700fd8-43eb-11e2-889a-0016d364066c,',
            ) .
            s_suuid(
                'sess' => 'ssh-agent/da700fd8-43eb-11e2-889a-0016d364066c,' .
                          'dingle©/4c66b03a-43f4-11e2-b70d-0016d364066c,',
            ),
        ),
        "<sess> contains both desc attributes, one with ©",
    );

    # }}}
    ok(unlink($Outfile), "Delete $Outfile");
    likecmd("SESS_UUID=ssh-agent/da700fd8-43eb-11e2-889a-0016d364066c $CMD -l $Outdir", # {{{
        "/^$v1_templ\n\$/s",
        '/^$/',
        0,
        "SESS_UUID with 'ssh-agent', missing comma",
    );

    # }}}
    like(file_data($Outfile), # {{{
        s_top(
            s_suuid(
                'sess' => 'ssh-agent/da700fd8-43eb-11e2-889a-0016d364066c,',
            ),
        ),
        "<sess> is correct without comma",
    );

    # }}}
    ok(unlink($Outfile), "Delete $Outfile");
    likecmd("SESS_UUID=/da700fd8-43eb-11e2-889a-0016d364066c $CMD -l $Outdir", # {{{
        "/^$v1_templ\n\$/s",
        '/^$/',
        0,
        "SESS_UUID missing name and comma, but has slash",
    );

    # }}}
    like(file_data($Outfile), # {{{
        s_top(
            s_suuid(
                'sess' => '/da700fd8-43eb-11e2-889a-0016d364066c,',
            ),
        ),
        "<sess> is OK without name and comma",
    );

    # }}}
    ok(unlink($Outfile), "Delete $Outfile");
    likecmd("SESS_UUID=ee5db39a-43f7-11e2-a975-0016d364066c,/da700fd8-43eb-11e2-889a-0016d364066c $CMD -l $Outdir", # {{{
        "/^$v1_templ\n\$/s",
        '/^$/',
        0,
        "SESS_UUID with two UUIDs, latter missing name and comma, but has slash",
    );

    # }}}
    like(file_data($Outfile), # {{{
        s_top(
            s_suuid(
                'sess' => '/ee5db39a-43f7-11e2-a975-0016d364066c,/da700fd8-43eb-11e2-889a-0016d364066c,',
            ),
        ),
        "Second <sess> is correct without comma",
    );

    # }}}
    ok(unlink($Outfile), "Delete $Outfile");
    likecmd("SESS_UUID=ee5db39a-43f7-11e2-a975-0016d364066cda700fd8-43eb-11e2-889a-0016d364066c $CMD -l $Outdir", # {{{
        "/^$v1_templ\n\$/s",
        '/^$/',
        0,
        "SESS_UUID with two UUIDs smashed together",
    );

    # }}}
    like(file_data($Outfile), # {{{
        s_top(
            s_suuid(
                'sess' => '/ee5db39a-43f7-11e2-a975-0016d364066c,/da700fd8-43eb-11e2-889a-0016d364066c,',
            ),
        ),
        "Still separates them into two UUIDs",
    );

    # }}}
    ok(unlink($Outfile), "Delete $Outfile");
    likecmd("SESS_UUID=da700fd8-43eb-11e2-889a-0016d364066cabcee5db39a-43f7-11e2-a975-0016d364066c $CMD -l $Outdir", # {{{
        "/^$v1_templ\n\$/s",
        '/^$/',
        0,
        "SESS_UUID with two UUIDs, only separated by 'abc'",
    );

    # }}}
    like(file_data($Outfile), # {{{
        s_top(
            s_suuid(
                'sess' => '/da700fd8-43eb-11e2-889a-0016d364066c,/ee5db39a-43f7-11e2-a975-0016d364066c,',
            ),
        ),
        "Separated the two UUIDs, discards 'abc'",
    );

    # }}}
    ok(unlink($Outfile), "Delete $Outfile");
    likecmd("SESS_UUID=da700fd8-43eb-11e2-889a-0016d364066cabc/ee5db39a-43f7-11e2-a975-0016d364066c $CMD -l $Outdir", # {{{
        "/^$v1_templ\n\$/s",
        '/^$/',
        0,
        "SESS_UUID with two UUIDs, separated by 'abc/'",
    );

    # }}}
    like(file_data($Outfile), # {{{
        s_top(
            s_suuid(
                'sess' => '/da700fd8-43eb-11e2-889a-0016d364066c,/ee5db39a-43f7-11e2-a975-0016d364066c,',
            ),
        ),
        "The two UUIDs are separated, 'abc/' is discarded",
    );

    # }}}
    ok(unlink($Outfile), "Delete $Outfile");
    likecmd("SESS_UUID=5f650dac-4404-11e2-8e0e-0016d364066c5f660e28-4404-11e2-808e-0016d364066c5f66ef14-4404-11e2-8b45-0016d364066c5f67e266-4404-11e2-a6f8-0016d364066c $CMD -l $Outdir", # {{{
        "/^$v1_templ\n\$/s",
        '/^$/',
        0,
        "SESS_UUID contains four UUIDs, no separators",
    );

    # }}}
    like(file_data($Outfile), # {{{
        s_top(
            s_suuid(
                'sess' => '/5f650dac-4404-11e2-8e0e-0016d364066c,' .
                          '/5f660e28-4404-11e2-808e-0016d364066c,' .
                          '/5f66ef14-4404-11e2-8b45-0016d364066c,' .
                          '/5f67e266-4404-11e2-a6f8-0016d364066c,',
            ),
        ),
        "All four UUIDs are separated",
    );

    # }}}
    ok(unlink($Outfile), "Delete $Outfile");
    likecmd("SESS_UUID=5f650dac-4404-11e2-8e0e-0016d364066cabc5f660e28-4404-11e2-808e-0016d364066c5f66ef14-4404-11e2-8b45-0016d364066c,nmap/5f67e266-4404-11e2-a6f8-0016d364066c $CMD -l $Outdir", # {{{
        "/^$v1_templ\n\$/s",
        '/^$/',
        0,
        "SESS_UUID contains four UUIDs, 'abc' separates the first two, last one has desc",
    );

    # }}}
    like(file_data($Outfile), # {{{
        s_top(
            s_suuid(
                'sess' => '/5f650dac-4404-11e2-8e0e-0016d364066c,' .
                          '/5f660e28-4404-11e2-808e-0016d364066c,' .
                          '/5f66ef14-4404-11e2-8b45-0016d364066c,' .
                          'nmap/5f67e266-4404-11e2-a6f8-0016d364066c,',
            ),
        ),
        "All four UUIDs separated, 'abc' discarded, 'nmap' kept",
    );

    # }}}
    ok(unlink($Outfile), "Delete $Outfile");
    likecmd("SESS_UUID=ssh-agent/fea9315a-43d6-11e2-8294-0016d364066c,logging/febfd0f4-43d6-11e2-9117-0016d364066c,screen/0e144c10-43d7-11e2-9833-0016d364066c,ti/152d8f16-4409-11e2-be17-0016d364066c, $CMD -l $Outdir", # {{{
        "/^$v1_templ\n\$/s",
        '/^$/',
        0,
        "SESS_UUID is OK and contains four UUIDs, all with desc",
    );

    # }}}
    like(file_data($Outfile), # {{{
        s_top(
            s_suuid(
                'sess' => 'ssh-agent/fea9315a-43d6-11e2-8294-0016d364066c,' .
                          'logging/febfd0f4-43d6-11e2-9117-0016d364066c,' .
                          'screen/0e144c10-43d7-11e2-9833-0016d364066c,' .
                          'ti/152d8f16-4409-11e2-be17-0016d364066c,',
            ),
        ),
        "The four UUIDs are separated, all four descs kept",
    );

    # }}}
} # test_suuid_environment()

sub s_top {
    # {{{
    my $xml = shift;
    my @Ret = ();

    push(@Ret,
        '/^',
        $xml_header,
        $xml,
        '<\/suuids>\n',
        '$/s',
    );
    return(join('', @Ret));
    # }}}
} # s_top()

sub s_suuid {
    # {{{
    my %d = @_;
    my @Ret = ();

    defined($d{suuid_t}) || ($d{suuid_t} = $date_templ);
    defined($d{suuid_u}) || ($d{suuid_u} = $v1_templ);
    defined($d{tag}) || ($d{tag} = '');
    defined($d{txt}) || ($d{txt} = '');
    defined($d{host}) || ($d{host} = $cdata);
    defined($d{cwd}) || ($d{cwd} = $cdata);
    defined($d{user}) || ($d{user} = $cdata);
    defined($d{tty}) || ($d{tty} = $cdata);
    defined($d{sess}) || ($d{sess} = '');

    push(@Ret,
        "<suuid t=\"$d{suuid_t}\" u=\"$d{suuid_u}\">",
        ' ',
        length($d{tag})
            ? s_suuid_tag($d{tag})
            : '',
        length($d{txt})
            ? "<txt>$d{txt}</txt> "
            : '',
        "<host>$d{host}<\\/host>",
        ' ',
        "<cwd>$d{cwd}<\\/cwd>",
        ' ',
        "<user>$d{user}<\\/user>",
        ' ',
        "<tty>$d{tty}<\\/tty>",
        ' ' ,
        length($d{sess})
            ? s_suuid_sess($d{sess})
            : '',
        "<\\/suuid>\\n",
    );
    return(join('', @Ret));
    # }}}
} # s_suuid()

sub s_suuid_tag {
    # {{{
    my $txt = shift;
    $txt =~ s/,+$//;
    $txt .= ',';
    my @arr = split(/,/, $txt);
    my $retval = '';
    for (@arr) {
        $retval .= "<tag>$_</tag> ";
    }
    return($retval);
    # }}}
} # s_suuid_tag()

sub s_suuid_sess {
    # {{{
    my $txt = shift;
    my @arr = ();
    $txt =~ s{
        ([^/]+?)?
        /
        ($v1_templ)
        ,
    } {
        my ($desc, $uuid) = ($1, $2);
        defined($desc) || ($desc = '');
        push(@arr,
            join('',
                '<sess',
                length($desc)
                    ? " desc=\"$desc\""
                    : '',
                '>',
                $uuid,
                '</sess>',
            ),
        );
        '';
    }egx;
    length($txt) && return(undef);
    $txt =~ s/,+$//;
    $txt .= ',';
    my $retval = '';
    for (@arr) {
        $retval .= "$_ ";
    }
    return($retval);
    # }}}
} # s_suuid_sess()

sub unique_macs {
    # {{{
    my $file = shift;
    my %mac = ();
    open(my $fp, '<', $file) or die("$progname: $file: Cannot open file for read: $!\n");
    while (<$fp>) {
        /^<suuid t="[^"]+" u="$Lh{8}-$Lh{4}-1$Lh{3}-$Lh{4}-($Lh{12})".*/ && ($mac{$1} = 1);
    }
    close($fp);
    return(scalar(keys %mac));
    # }}}
} # unique_macs()

sub testcmd {
    # {{{
    my ($Cmd, $Exp_stdout, $Exp_stderr, $Exp_retval, $Desc) = @_;
    my $stderr_cmd = '';
    my $deb_str = $Opt{'debug'} ? ' --debug' : '';
    my $Txt = join('',
        "\"$Cmd\"",
        defined($Desc)
            ? " - $Desc"
            : ''
    );
    my $TMP_STDERR = 'suuid-stderr.tmp';

    if (defined($Exp_stderr) && !length($deb_str)) {
        $stderr_cmd = " 2>$TMP_STDERR";
    }
    is(`$Cmd$deb_str$stderr_cmd`, "$Exp_stdout", "$Txt (stdout)");
    my $ret_val = $?;
    if (defined($Exp_stderr)) {
        if (!length($deb_str)) {
            is(file_data($TMP_STDERR), $Exp_stderr, "$Txt (stderr)");
            unlink($TMP_STDERR);
        }
    } else {
        diag("Warning: stderr not defined for '$Txt'");
    }
    is($ret_val >> 8, $Exp_retval, "$Txt (retval)");
    return;
    # }}}
} # testcmd()

sub likecmd {
    # {{{
    my ($Cmd, $Exp_stdout, $Exp_stderr, $Exp_retval, $Desc) = @_;
    my $stderr_cmd = '';
    my $deb_str = $Opt{'debug'} ? ' --debug' : '';
    my $Txt = join('',
        "\"$Cmd\"",
        defined($Desc)
            ? " - $Desc"
            : ''
    );
    my $TMP_STDERR = 'suuid-stderr.tmp';

    if (defined($Exp_stderr) && !length($deb_str)) {
        $stderr_cmd = " 2>$TMP_STDERR";
    }
    like(`$Cmd$deb_str$stderr_cmd`, "$Exp_stdout", "$Txt (stdout)");
    my $ret_val = $?;
    if (defined($Exp_stderr)) {
        if (!length($deb_str)) {
            like(file_data($TMP_STDERR), "$Exp_stderr", "$Txt (stderr)");
            unlink($TMP_STDERR);
        }
    } else {
        diag("Warning: stderr not defined for '$Txt'");
    }
    is($ret_val >> 8, $Exp_retval, "$Txt (retval)");
    return;
    # }}}
} # likecmd()

sub file_data {
    # Return file content as a string {{{
    my $File = shift;
    my $Txt;
    if (open(my $fp, '<', $File)) {
        local $/ = undef;
        $Txt = <$fp>;
        close($fp);
        return($Txt);
    } else {
        return;
    }
    # }}}
} # file_data()

sub print_version {
    # Print program version {{{
    print("$progname v$VERSION\n");
    return;
    # }}}
} # print_version()

sub usage {
    # Send the help message to stdout {{{
    my $Retval = shift;

    if ($Opt{'verbose'}) {
        print("\n");
        print_version();
    }
    print(<<"END");

Usage: $progname [options] [file [files [...]]]

Contains tests for the suuid(1) program.

Options:

  -a, --all
    Run all tests, also TODOs.
  -h, --help
    Show this help.
  -t, --todo
    Run only the TODO tests.
  -v, --verbose
    Increase level of verbosity. Can be repeated.
  --version
    Print version information.
  --debug
    Print debugging messages.

END
    exit($Retval);
    # }}}
} # usage()

sub msg {
    # Print a status message to stderr based on verbosity level {{{
    my ($verbose_level, $Txt) = @_;

    if ($Opt{'verbose'} >= $verbose_level) {
        print(STDERR "$progname: $Txt\n");
    }
    return;
    # }}}
} # msg()

__END__

# Plain Old Documentation (POD) {{{

=pod

=head1 NAME

run-tests.pl

=head1 SYNOPSIS

suuid.t [options] [file [files [...]]]

=head1 DESCRIPTION

Contains tests for the suuid(1) program.

=head1 OPTIONS

=over 4

=item B<-a>, B<--all>

Run all tests, also TODOs.

=item B<-h>, B<--help>

Print a brief help summary.

=item B<-t>, B<--todo>

Run only the TODO tests.

=item B<-v>, B<--verbose>

Increase level of verbosity. Can be repeated.

=item B<--version>

Print version information.

=item B<--debug>

Print debugging messages.

=back

=head1 AUTHOR

Made by Øyvind A. Holm S<E<lt>sunny@sunbase.orgE<gt>>.

=head1 COPYRIGHT

Copyleft © Øyvind A. Holm E<lt>sunny@sunbase.orgE<gt>
This is free software; see the file F<COPYING> for legalese stuff.

=head1 LICENCE

This program is free software: you can redistribute it and/or modify it 
under the terms of the GNU General Public License as published by the 
Free Software Foundation, either version 3 of the License, or (at your 
option) any later version.

This program is distributed in the hope that it will be useful, but 
WITHOUT ANY WARRANTY; without even the implied warranty of 
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along 
with this program.
If not, see L<http://www.gnu.org/licenses/>.

=head1 SEE ALSO

=cut

# }}}

# vim: set fenc=UTF-8 ft=perl fdm=marker ts=4 sw=4 sts=4 et fo+=w :
