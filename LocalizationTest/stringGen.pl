#!/usr/bin/perl

# Julien Perrenoud
# 27.02.2017
# Copyright (c) BuddyHopp, all rights reserved.

use strict;
use warnings;
use Data::Dumper;
use feature 'say';

# Get file as first argument

my $filename = $ARGV[0];
my $output = $ARGV[1];
my $projectname = "LocalizableTest";
my $author = "Julien Perrenoud";
my $team = "BuddyHopp";
my ($min, $hour, $day, $month, $year)=(localtime)[1, 2, 3, 4, 5];
$year = $year + 1900;
$month = $month + 1;

if (not defined $filename) {
	print "Error: no Localizable.string file provided\n";
	exit;
}

if (not defined $output) {
  print "Error: no output file name provided\n";
  exit;
}

# Read values from file

print "Parsing file...\n";

my %allValues; # [String: [String, parameters...]]

my @links;

open(my $fh, '<:encoding(UTF-8)', $filename) or die "Could not open file '$filename' $!";

while (my $row = <$fh>) {
  chomp $row;

  if ($row =~ /\/\// or $. < 8 or $row =~ /^$/) {
  	# It's a comment, ignore
  } elsif ($row =~ /^"(?<key>[A-Za-z0-9\-\_\.]+)" = "(?<value>[^"]*)";$/) {

    my $key = $+{key};
    my $string = $+{value};

    # Verify format of key

    if ($key =~ /^[a-z][A-Za-z]*(\.[a-z][A-Za-z]*)*$/) {
      # correct
    } else {
      print "$filename:$.: warning : Localization key \"$key\" does not follow camelCase format.\n";
    }
    
    # Extract parameters

    my @parameters = ($string =~ m/\{\{(.+?)\}\}/g);

    for my $parameter (@parameters) {
      if ($parameter =~ /^[a-z][A-Za-z]*$/) {
        # Camel case
      } else {
        print "$filename:$.: warning : parameter $parameter does not follow camelCase format\n";
      }
    }

    # Dump in hash 

    $allValues{ $key } = [ $string, @parameters ];

    # Extract Links

    my @matches = ($string =~ m/\[.+?\]\((.+?)\)/g);
    push(@links, @matches);

  } else {
    # Not parsable
    print "$filename:$.: error : Could not parse line: $row\n";
  	exit;
  }
}

# Build multi-level hash

my %allValuesMultiLevel;

for my $key (keys %allValues) {

  # Split key into multiple levels & build multi-level dictionary

  my @keyLevels = split /\./, $key;
  my $currentLevel = 0;

  my $dict = \%allValuesMultiLevel;

  for my $level (@keyLevels) {
    if ($currentLevel == scalar @keyLevels - 1) {
      if (defined $dict->{$level}) {
        print STDERR "$filename:$.: error : Localization key \"$key\" is already a folder and cannot be used.\n";
        exit 1;
      } else {
        $dict->{ $level } = $allValues { $key };
      }    
    } else {
      if (defined $dict->{$level}) {
        #It's a hash
      } else {
        $dict->{ $level } = {};
      }
      $dict = $dict->{ $level };
      $currentLevel = $currentLevel + 1;
    }
  }
}

# Print Swift file

print("Generating template...\n");

my $identationLevel = 1;
my $tab = "    ";

my $folderRef = \%allValues;
my $linksString = "";


sub printHashAsString {
  my $hashRef = shift;
  my $identationLevel = shift;
  my $result = "";
  my $indentation = $tab x $identationLevel;
  chop $indentation;

  my @nodeKeys = ();
  my @leafKeys = ();

  for my $key (keys $hashRef) {
    if (ref $hashRef->{ $key } eq ref {}) {
      push @nodeKeys, $key;
    } else {
      push @leafKeys, $key;
    }
  }

  @leafKeys = sort @leafKeys;
  @nodeKeys = sort @nodeKeys;

  for my $key (@leafKeys) {
    my @array = @{$hashRef->{ $key }};

    if (scalar @array == 1) {
      $result = "$result\n$indentation case $key";
    } else {
      shift(@array);
      my @parametersWithType = map { "$_: String" } @array;
      my $parametersString = join(", ", @parametersWithType);
        
      $result = "$result\n$indentation case $key($parametersString)";
    }
  }

  for my $key (@nodeKeys) {
    my $hashString = printHashAsString( $hashRef->{ $key }, $identationLevel + 1);
    $result = "$result\n\n";
    $result = "$result$indentation enum $key: LocalizationKey {\n";
    $result = "$result$indentation $hashString\n";
    $result = "$result$indentation }";
  }

  return $result;
}

my $keysString = printHashAsString(\%allValuesMultiLevel, $identationLevel);

my $indentation = $tab x 2;
chop $indentation;

for my $link (@links) {
  $linksString = "$linksString\n$indentation case $link";
}

my $rawValuesString = "";
my $parametersString = "";

for my $key (sort keys %allValues) {
  $rawValuesString = "$rawValuesString\n$indentation case Strings.$key: return \"$key\"";

  my @parameters = @{$allValues { $key }}; 
  shift(@parameters);

  if (scalar @parameters == 0) {
      $parametersString = "$parametersString\n$indentation case Strings.$key: return [:]";
    } else {

      
      my @parametersWithType = map { "let $_" } @parameters;
      my $parametersArgumentString = join(", ", @parametersWithType);

      my @parametersAsDict = map { "\"$_\": $_" } @parameters;
      my $parametersAsDictString = join(", ", @parametersAsDict);
        
      $parametersString = "$parametersString\n$indentation case Strings.$key($parametersArgumentString): return [$parametersAsDictString]";
    }
}



my $template = <<"END_TEMPLATE";
// 
//  $output
//  $projectname
//
//  Auto-generated by $author on $month/$day/$year at $hour:$min
//  Copyright (c) $year $team. All rights reserved. 
//

enum Strings: LocalizationKey {
  $keysString
}

// MARK: - Extensions
    
extension LocalizationKey {

    static func getRawValue(key: LocalizationKey) -> String {
        switch key {$rawValuesString
        default: return ""
        }
    }
    
    static func getParameters(key: LocalizationKey) -> [String: String] {
        switch key {$parametersString
        default: return [:]
        }
    }
}
END_TEMPLATE

open($fh, '>', $output) or die "Could not open file '$output' $!";
print $fh $template;
close $fh;

### Add to project target

print "Adding to project $projectname...\n";

my $result = `ls -la`;

print "Execution Successful.\n";


