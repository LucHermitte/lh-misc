#!/usr/bin/perl
# Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
#           <URL:http://code.google.com/p/lh-vim/>
# Purpose:	Easily search files matching a regex
# Created:	Wed Sep 07 15:20:31 2005
#
# @todo
# - option: --pattern becomes optional => only find
# - pattern may add (OR)
# - option: --prune <name>
# - option: --path : adds path to the list of paths to use
#
# Examples:
# searchfile.pl -e h,cpp,idl '$Id\$'  # NB: same regex that the one expected by grep


### Code {{{1
## Includes {{{2
use strict                ;
# Damn! Pod::Usage is not installed
use Pod::Usage            ; # pod2usage()
use Getopt::Long          ; # Getoptions()
# use File::Spec            ; # catfile


## Globals {{{2

## Options {{{2
# The options {{{3
my $verbose         = 0  ;
my $opt_noexec      = 0  ; # no execution mode
my $opt_help        = 0  ;
my $opt_man         = 0  ;
my $opt_filename    = 1  ;
my $opt_lines       = 1  ;
my $opt_lineno      = 0  ;
my $opt_path        = ".";
my @opt_extensions  = () ;
my @opt_pattern     = "" ;
my $opt_colorize    = 0  ;
my $opt_insensitive = 0  ;
my @opt_exclude_pat = () ;

# very-light substitute for pod2usage {{{3
# sub pod2usage {
    # my (%params) = @_ ;
    # printf STDERR "Error: $params{-message}\n" if exists( $params{-message} );
    # exec ("perldoc    searchfile.pl") if ($params{-verbose} == 1 );
    # exec ("perldoc -v searchfile.pl") if ($params{-verbose} > 1 );
    # die , $params{-exitstatus};
# }

# merge lists like extensions-list {{{3
sub flatten_list
{
    my (@elements) = @_ ;
    printf "Flattening {@elements}" if ($verbose >= 4);
    @elements = split /[,;]/, join(',',@elements);
    printf " into {@elements}\n" if ($verbose >= 4);
    return @elements ;
}

# check_options {{{3
sub check_options
{
    # Check the options {{{4
    Getopt::Long::Configure("no_auto_abbrev");
    GetOptions ( 
        "v|verbose:i"           => sub { $verbose = $_[1]; }
        ,"q|quiet"              => sub { $verbose = -1; }
        ,"h|help"               => \$opt_help
        ,"man"                  => \$opt_man
        ,"noexecution"          => \$opt_noexec
        ,"p|path:s"             => \$opt_path
        ,"e|extension=s"        => \@opt_extensions
        ,"x|exclude=s"          => \@opt_exclude_pat
        ,"f|filename!"          => \$opt_filename
        ,"lines!"               => \$opt_lines
        ,"lineno|n!"            => \$opt_lineno
        ,"c|colorize!"          => \$opt_colorize
        ,"i|insensitive!"       => \$opt_insensitive
    ) or pod2usage(-exitstatus => 2, -verbose => 1) ;

    # help required ? {{{4
    pod2usage(-verbose => 1)                   if ($opt_help);
    pod2usage(-exitstatus => 0, -verbose => 2) if ($opt_man);

    # Checks required arguments {{{4
    @opt_pattern = @ARGV;
    pod2usage(
        -verbose => 1,
        -exitstatus => 2,
        -message => "Pattern to search expected")
    unless @opt_pattern;

    pod2usage(
        -verbose => 1,
        -exitstatus => 2,
        -message => "Specify a root directory")
    if ($opt_path =~ /^$/) ;

    @opt_extensions  = flatten_list(@opt_extensions) ;
    @opt_exclude_pat = flatten_list(@opt_exclude_pat) ;

    # Verbose ? {{{4
    printf "root search directory : $opt_path\n"        if ($verbose >= 1) ;
    printf "extensions searched   : @opt_extensions\n"  if ($verbose >= 1) ;
    printf "pattern searched      : @opt_pattern\n"     if ($verbose >= 1) ;
    printf "excluded pattern      : @opt_exclude_pat\n" if ($verbose >= 1) ;
    printf "Case insensitive      : $opt_insensitive\n" if ($verbose >= 1) ;
    printf "Display matching files: $opt_filename\n"    if ($verbose >= 1) ;
    printf "Display matched lines : $opt_lines\n"       if ($verbose >= 1) ;
    printf "Display line numbers  : $opt_lineno\n"      if ($verbose >= 1) ;
    printf "Colorize              : $opt_colorize\n"    if ($verbose >= 1) ;
    printf "noexecution mode      : $opt_noexec\n"      if ($verbose >= 1) ;
}

## Helper Functions {{{2

# escape backslashes {{{3
sub escape {
    my ($pattern) = @_;
    $pattern =~ s#\\#$&$&#g ;
    return $pattern;
}

# execute(@commands) {{{3
sub execute {
    my (@command) = @_;
    printf "    $#command - @command\n" if ($verbose >= 3);
    # this particular use of system => quoted-list-arg is required with find.
    system("@command") unless ($opt_noexec);
}

# Extensions -> find parameters {{{3
sub ext2find
{
    my (@extensions) = @_;
    printf "Transforming {@extensions}" if ($verbose >= 4);

    my (@find_params) ;
    # add «-o -name» before every extension
    map( {push(@find_params, "-o", "-name", "'*.$_'") } @extensions ) ;
    # strip leading "-o"
    shift(@find_params) ;
    # surround expression with parenthesis
    @find_params = ( '\(', @find_params, '\)' ) ;

    printf " into {@find_params}\n" if ($verbose >= 4);
    return @find_params ;
}

# what to display {{{3
sub what_to_display
{
    my ($disp_filenames, $disp_matches, $disp_lineno) = @_ ;
    my $opt1 = ($disp_filenames && ! $disp_matches)
    ? '-l'
    : ( ($disp_lineno) ? '-n' : '' ) ;
    my $opt2 = ($disp_filenames && $disp_matches) ? '-print' : '' ;
    printf "grep+find parameters: {$opt1 -- =$opt2}\n" if ($verbose >= 4);
    return ($opt1, $opt2) ;
}

## The search       {{{2
# constants {{{3
my $color_normal = "\\\033[00m";
my $color_blue   = "\\\033[00;34;34m";
my $color_red    = "\\\033[00;31;31m";

# search() {{{3
sub search
{
    my (@find_params)   = ext2find(@opt_extensions) ;
    my ($opt1, $opt2)   = what_to_display($opt_filename, $opt_lines, $opt_lineno) ;

    # my $opt_pattern     = escape("@opt_pattern") ;
    my $opt_pattern     = "@opt_pattern" ;
    my $opt_exclude_pat = escape("@opt_exclude_pat") ;

    # The trick with printf is required to surround each line with single
    # quotes in order to support file having spaces in their name
    my (@grep_cmd)    = ( '|', 'sed', '-e', "s/.*/`printf \"'&'\"`/",  '|', 'xargs', 'grep' ) ;
    push(@grep_cmd, $opt1) if ($opt1);
    push(@grep_cmd, '-i')  if ($opt_insensitive);
    # push(@grep_cmd, '"'.$opt_pattern.'"');
    push(@grep_cmd, "'".$opt_pattern."'");
    # push(@grep_cmd, $opt_pattern);
    my (@cmd) = ('find', $opt_path,
        '\(', 
        '-name', 'CVS', '-o',
        '-name', '.svn', '-o',
        '-name', '.git', '-o',
        '-name', 'Generated', '-o',
        # '-name', 'tu', '-o',
        # '-name', 'tv', '-o',
        '-name', 'SunWS_cache', '-o',
        '-name', 'obj', # '-o',
        # '-name', 'bin', '-o',
        # '-name', 'lib',
        '\)', '-prune', '-o',
        @find_params, '-print', @grep_cmd);

    # excluded pattern
    map( { push(@cmd, '|', 'egrep -v', "\"$_\"") } @opt_exclude_pat ) ;

    # colorization
    if ($opt_colorize) {
        if ($opt_insensitive) {
            $opt_pattern =~ s/[A-Za-z]/[\u$&\l$&]/g ;
        }
        push(@cmd, '|', 'sed' );

        # As sed(solaris) only supports Basic Regular Expression, we must loop
        # over the different extensions searched, hence map()
        map( { push(@cmd, '-e', 
            "s²\\^[-a-zA-Z0-9_/.]*\\.$_\\\:²`printf \"$color_red&$color_normal\"`²")
            #"s²\\^[a-zA-Z0-9_/-.]*\\.$_\\\:²`echo \"$color_red&$color_normal\"`²")
        } @opt_extensions ) ;
        push(@cmd, '-e',
            "s²\"$opt_pattern\"²`printf \"$color_blue&$color_normal\"`²g" );
            #"s²\"$opt_pattern\"²`echo \"$color_blue&$color_normal\"`²g" );
    }

    # And finally execute the search
    execute(@cmd);
}

## Main {{{2
check_options() ;
search() ;

#}}}1
# ======================================================================
### Help {{{1
__END__

=head1 NAME

I<searchfile.pl> - Search files matching a regex.

=head1 SYNOPSIS

=over 8

=item searchfile.pl B<--help>|B<--man>

=item searchfile.pl [OPTIONS] PARAMETERS PATTERN

=back

=head1 DESCRIPTION

Search files matching a regex.

This is mainly a user-friendly wrapper around find + grep.

=head1 OPTIONS

=head2 Required parameters:

=over 8

=item B<--extension> F<ext>

Comma separated list of filename extensions used to tell in which files the
PATTERN will be searched.

If this parameter is specified several times, the new extensions are appended
to the list of filename extensions.

=item F<PATTERN>

Basic Regular Expression used to define the pattern to search in the files.
See regex(5).

=back 

=head2 Optional parameters:

=over 8

=item B<--path|-p> F<search-path>

(String) A path name of a starting point in the directory hierarchy. Default:
current directory.

=item B<--exclude|-x> F<exclude-pattern>

(Regex) Pattern used to exclude lines matching the search PATTERN. This option can be used several
times.

=item B<--filename|--nofilename|-f>

(Boolean) Display the filename matching the regex. Default: true

=item B<--insensitive|--noinsensitive|-i>

(Boolean) Do a case insensitive search. Default: false

=item B<--lines|--nolines>

(Boolean) Display the lines matching the regex. Default: true

=item B<--lineno|--nolineno|-n>

(Boolean) Display the line numbers matching the regex. Default: false

=item B<--colorize|--nocolorize|-c>

(Boolean) Colorize the filesnames in which the pattern has been matched, and
the characters matching the pattern. Default: false

NB: it can be piped with F<less -isrR> (r|R being what matters to preserve the
colors)

=item B<--noexecution>

No execution mode. Prints system calls, but does not execute them.

=item B<--verbose|-v> F<verbose-level>

=item B<--quiet|-q>

=over 8

=item B<0> Quiet mode

=item B<1> Display the options recongnized.

=item B<2> Display the actions done (high-level info).

=item B<3> Display the actions done (low-level info: external commands
executed).

=item B<4> Display the traces of various transformations

=back

=back

=head1 EXAMPLES

=over 8

searchfile.pl B<--path> F<.> B<--ext> F<h,cpp> B<-verbose> B<--ext> F<inc> F<Pattern> B<-c>

searchfile.pl B<--ext> F<h,cpp,fcf,inc,c> "due date" B<--noli> B<--noc> | xargs gvim

=back

=head1 NOTES

CVS directories are implicitly excluded for the searched sub-directories.

=head1 SEE ALSO

find(1), grep(1), regex(5)

=head1 MAINTAINER

Luc Hermitte <luc.hermitte {at} free.fr>

=head1 VERSION

0.1.8

=cut


#}}}1
# ======================================================================
# vim600: set foldmethod=marker:expandtab:
# vim:et:ts=4:tw=79:
