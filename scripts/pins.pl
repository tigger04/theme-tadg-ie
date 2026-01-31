#!/usr/bin/env perl
# ABOUTME: Finds Hugo content files with non-empty pin: values in frontmatter.
# ABOUTME: Displays them sorted numerically for review and reordering.

use strict;
use warnings;
use Cwd qw(getcwd);
use File::Find;

sub show_help {
    print <<'HELP';
pins.pl - List pinned Hugo content files

USAGE:
    perl pins.pl
    perl pins.pl -h|--help

DESCRIPTION:
    Scans Hugo content files for 'pin:' values in frontmatter and displays
    them in a sorted table. Useful for reviewing and managing pinned content
    order on your site.

    Must be run from either:
    - The root of a Hugo project (where hugo.yaml/config.yaml exists)
    - Inside the content/ directory

OUTPUT:
    Displays a table with pin values and file paths, sorted numerically by
    pin value (lower numbers = higher priority).

EXAMPLES:
    cd /path/to/hugo/project
    perl pins.pl

    Pin  File
    ---  ----
    100  blog/important-post.md
    200  pages/featured.md
    500  plays/quadriplegia/index.org

HELP
    exit 0;
}

# Check for help flag
if (@ARGV && $ARGV[0] =~ /^(-h|--help)$/) {
    show_help();
}

my $content_dir = find_content_dir();

my @pinned;

find(sub {
    return unless /\.(md|org)$/;
    return unless -f $_;

    open my $fh, '<', $_ or return;
    my $in_frontmatter = 0;

    while (my $line = <$fh>) {
        if ($. == 1 && $line =~ /^---\s*$/) {
            $in_frontmatter = 1;
            next;
        }
        last if $in_frontmatter && $line =~ /^---\s*$/;
        last unless $in_frontmatter;

        if ($line =~ /^pin:\s+(\d+)\s*$/) {
            my $pin = $1;
            (my $rel = $File::Find::name) =~ s{^\Q$content_dir\E/}{};
            push @pinned, { pin => $pin, file => $rel };
            last;
        }
    }
    close $fh;
}, $content_dir);

unless (@pinned) {
    print "No pinned content found.\n";
    exit 0;
}

@pinned = sort { $a->{pin} <=> $b->{pin} } @pinned;

my $max_pin  = length 'Pin';
my $max_file = length 'File';
for my $p (@pinned) {
    my $pl = length $p->{pin};
    my $fl = length $p->{file};
    $max_pin  = $pl if $pl > $max_pin;
    $max_file = $fl if $fl > $max_file;
}

printf "%${max_pin}s  %s\n", 'Pin', 'File';
printf "%${max_pin}s  %s\n", '-' x $max_pin, '-' x $max_file;

for my $p (@pinned) {
    printf "%${max_pin}d  %s\n", $p->{pin}, $p->{file};
}

printf "\n%d pinned item(s)\n", scalar @pinned;

# --- Subroutines ---

sub find_content_dir {
    my $cwd = getcwd();

    # If we're at a Hugo project root, use ./content
    if (is_hugo_root($cwd)) {
        my $dir = "$cwd/content";
        die "Hugo project found but no content/ directory exists.\n"
            unless -d $dir;
        return $dir;
    }

    # If we're inside a content/ directory already
    if ($cwd =~ m{/content(?:/|$)}) {
        (my $root = $cwd) =~ s{/content(?:/.*)?$}{};
        if (is_hugo_root($root)) {
            return "$root/content";
        }
    }

    die "This must be run from the root of a Hugo project or its content directory.\n";
}

sub is_hugo_root {
    my ($dir) = @_;
    return -f "$dir/hugo.yaml"
        || -f "$dir/hugo.toml"
        || -f "$dir/hugo.json"
        || -f "$dir/config.yaml"
        || -f "$dir/config.toml"
        || -f "$dir/config.json";
}
