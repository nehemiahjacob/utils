package GPST;

#=======================================================================
# $Id$
#
# Character set: UTF-8
# ©opyleft 2002– Øyvind A. Holm <sunny@sunbase.org>
# License: GNU General Public License, see end of file for legal stuff.
#=======================================================================

use strict;
use warnings;

use GPSTdebug;

BEGIN {
    use Exporter ();
    our ($VERSION, @ISA, @EXPORT, @EXPORT_OK, %EXPORT_TAGS);

    my $rcs_id = '$Id$';
    push(@main::version_array, $rcs_id);
    $VERSION = ($rcs_id =~ / (\d+) /, $1);

    @ISA = qw(Exporter);
    @EXPORT = qw(&trackpoint);
    %EXPORT_TAGS = ();
}
our @EXPORT_OK;

sub trackpoint {
    my %Dat = @_;

    D("trackpoint(" . join('|', %Dat) . ")");

    defined($Dat{'type'}) || return(undef);
    defined($Dat{'error'}) || return(undef);

    defined($Dat{'year'}) || ($Dat{'year'} = 0);
    defined($Dat{'month'}) || ($Dat{'month'} = 0);
    defined($Dat{'day'}) || ($Dat{'day'} = 0);
    defined($Dat{'hour'}) || ($Dat{'hour'} = "");
    defined($Dat{'min'}) || ($Dat{'min'} = "");
    defined($Dat{'sec'}) || ($Dat{'sec'} = "");
    my $print_time = (
        !$Dat{'year'} ||
        !$Dat{'month'} ||
        !$Dat{'day'} ||
        !length($Dat{'hour'}) ||
        !length($Dat{'min'}) ||
        !length($Dat{'sec'})
    ) ? 0 : 1;

    # defined($Dat{'year'}) || ($Dat{'year'} = "");
    # defined($Dat{'month'}) || ($Dat{'month'} = "");
    # defined($Dat{'day'}) || ($Dat{'day'} = "");
    # defined($Dat{'hour'}) || ($Dat{'hour'} = "");
    # defined($Dat{'min'}) || ($Dat{'min'} = "");
    # defined($Dat{'sec'}) || ($Dat{'sec'} = "");
    defined($Dat{'lat'}) || ($Dat{'lat'} = "");
    defined($Dat{'lon'}) || ($Dat{'lon'} = "");
    defined($Dat{'ele'}) || ($Dat{'ele'} = "");
    defined($Dat{'desc'}) || ($Dat{'desc'} = "");

    my $Retval = "";

    if ($Dat{'type'} eq "tp") {
        if ($Dat{'format'} eq "gpsml") {
            my $Elem = $Dat{'error'} ? "etp" : "tp";
            $Retval .= join("",
                    $print_time
                        ? "<time>$Dat{'year'}-$Dat{'month'}-$Dat{'day'}T" .
                          "$Dat{'hour'}:$Dat{'min'}:$Dat{'sec'}Z</time> "
                        : "",
                    (length($Dat{'lat'}))
                        ? "<lat>" . $Dat{'lat'}*1.0 . "</lat> "
                        : "",
                    (length($Dat{'lon'}))
                        ? "<lon>" . $Dat{'lon'}*1.0 . "</lon> "
                        : "",
                    (length($Dat{'ele'}))
                        ? "<ele>" . $Dat{'ele'}*1.0 . "</ele> "
                        : "",
                    (length($Dat{'desc'}))
                        ? sprintf("<desc>%s</desc> ",
                                  $Dat{'desc'})
                        : ""
            );
            length($Retval) && ($Retval = "<$Elem> $Retval</$Elem>\n");
        }
    }
    return $Retval;
}

1;
