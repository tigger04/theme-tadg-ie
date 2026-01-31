#!/usr/bin/env perl
use strict;
use warnings;
use utf8;

# Convert orgmode play format to Hugo shortcodes
# Usage: perl org-play-to-shortcodes.pl <file.org>
#
# Converts:
#   *** Stage direction  ->  {{< direction >}}Stage direction{{< /direction >}}
#   **** CHARACTER text  ->  {{< dialogue "CHARACTER" >}}text{{< /dialogue >}}
#   **** CHARACTER, direction  ->  {{< dialogue "CHARACTER" "direction" >}}text{{< /dialogue >}}
#
# Preserves all other content (frontmatter, * and ** headers, bullet points, etc)

sub show_help {
    print <<'HELP';
org-play-to-shortcodes.pl - Convert orgmode play format to Hugo shortcodes

USAGE:
    perl org-play-to-shortcodes.pl <file.org>
    perl org-play-to-shortcodes.pl -h|--help

DESCRIPTION:
    Converts orgmode play scripts to use Hugo shortcodes for dialogue and
    stage directions. Modifies the file in-place.

CONVERSIONS:
    *** Stage direction          ->  {{< direction >}}Stage direction{{< /direction >}}
    **** CHARACTER text          ->  {{< dialogue "CHARACTER" >}}text{{< /dialogue >}}
    **** CHARACTER, direction    ->  {{< dialogue "CHARACTER" "direction" >}}text{{< /dialogue >}}

    All other content is preserved unchanged (frontmatter, * and ** headers,
    bullet points, regular text, etc).

EXAMPLES:
    perl org-play-to-shortcodes.pl content/plays/myplay/index.org

HELP
    exit 0;
}

# Check for help flag
if (@ARGV == 0 || $ARGV[0] =~ /^(-h|--help)$/) {
    show_help();
}

# Read entire file
my $file = $ARGV[0] or die "Usage: $0 <file>\n";
open my $fh, '<:utf8', $file or die "Can't open $file: $!\n";
my @lines = <$fh>;
close $fh;

my @output;
my $in_frontmatter = 0;
my $frontmatter_count = 0;
my $in_dialogue = 0;
my @dialogue_lines;
my $dialogue_character = '';
my $dialogue_direction = '';

sub flush_dialogue {
    return unless $in_dialogue;
    
    my $text = join('', @dialogue_lines);
    $text =~ s/^\n+//;  # Remove leading newlines
    $text =~ s/\n+$//;  # Remove trailing newlines
    
    my $open_tag = '{{<';
    my $close_tag = '>}}';
    my $end_tag = '{{<';
    
    if ($dialogue_direction) {
        push @output, "$open_tag dialogue \"$dialogue_character\" \"$dialogue_direction\" $close_tag\n";
    } else {
        push @output, "$open_tag dialogue \"$dialogue_character\" $close_tag\n";
    }
    push @output, "$text\n";
    push @output, "$end_tag /dialogue $close_tag\n\n";
    
    $in_dialogue = 0;
    @dialogue_lines = ();
    $dialogue_character = '';
    $dialogue_direction = '';
}

for my $line (@lines) {
    # Track frontmatter (YAML between ---)
    if ($line =~ /^---$/) {
        flush_dialogue();
        $frontmatter_count++;
        $in_frontmatter = ($frontmatter_count == 1);
        push @output, $line;
        next;
    }
    
    # Skip processing in frontmatter
    if ($in_frontmatter) {
        push @output, $line;
        next;
    }
    
    # Don't touch * or ** headers (sections like CHARACTERS, Setting, Scene 1, etc)
    if ($line =~ /^(\*{1,2})\s+(.+)$/) {
        flush_dialogue();
        push @output, $line;
        next;
    }
    
    # Convert h3 headers (*** ) to {{< direction >}} shortcode
    if ($line =~ /^\*\*\* (.+)$/) {
        flush_dialogue();
        my $content = $1;
        my $open_tag = '{{<';
        my $close_tag = '>}}';
        push @output, "$open_tag direction $close_tag$content$open_tag /direction $close_tag\n\n";
        next;
    }
    
    # Convert h4 headers (**** CHARACTER optional direction) to start dialogue
    if ($line =~ /^\*\*\*\* (\w+)(.*)$/) {
        flush_dialogue();  # Flush any previous dialogue
        
        $dialogue_character = $1;
        my $rest = $2;
        $rest =~ s/^\s+//;  # trim leading space
        $rest =~ s/^,\s*//;  # remove leading comma if present
        $dialogue_direction = $rest;
        
        $in_dialogue = 1;
        @dialogue_lines = ();
        next;
    }
    
    # If we're in dialogue mode, collect the lines
    if ($in_dialogue) {
        # If we hit a blank line or another header, it might be end of dialogue
        if ($line =~ /^\s*$/ || $line =~ /^\*/) {
            # Check if next line continues dialogue or is new structure
            # For now, flush on any header
            if ($line =~ /^\*/) {
                flush_dialogue();
                # Process this line again
                redo;
            } else {
                # Just a blank line within dialogue, keep it
                push @dialogue_lines, $line;
            }
        } else {
            push @dialogue_lines, $line;
        }
        next;
    }
    
    # Keep everything else (bullet points, regular text, etc)
    push @output, $line;
}

# Flush any remaining dialogue at end of file
flush_dialogue();

# Write output
open my $out, '>:utf8', $file or die "Can't write $file: $!\n";
print $out @output;
close $out;

print "Converted to shortcodes: $file\n";
