#!/usr/bin/perl

# Julien Perrenoud
# 27.02.2017
# Copyright (c) BuddyHopp, all rights reserved.

use strict;
use warnings;



## -- CONFIGURATION -- 


# Get file as first argument

if (scalar @ARGV != 2) {
  die "Should provide exactly 2 arguments, i.e. the path to the config file and the template";
}

my $config_file = $ARGV[0];
my $template_file = $ARGV[1];

# Parse configuration

my $author;
my $project;
my $team;
my $enum_name;
my $protocol_name;
my $output_file;
my $output_path;
my $input_file;

my %config_params = (
  "Author" => \$author,
  "Project" => \$project,
  "Team" => \$team,
  "Enum Name" => \$enum_name,
  "Protocol Name" => \$protocol_name,
  "Output File Name" => \$output_file,
  "Output File Directory" => \$output_path,
  "Localizable.strings" => \$input_file,
);

my $last_config_param_ref;

open(my $config_iterator, '<:encoding(UTF-8)', $config_file) or die "Could not open config file '$config_file' $!\n";

while (my $row = <$config_iterator>) {
  chomp $row;

  if ($row =~ /<key>(?<key>.+)<\/key>/) {

    my $key = $+{ key };

    if (not defined $config_params { $key }) {
      die "Unknown config parameter: $key\n";
    }

    $last_config_param_ref = $config_params { $key };

    print "GOT KEY $key\n";

  } elsif ($row =~ /<string>(?<value>.+)<\/string>/) {

    $$last_config_param_ref = $+{ value };

    print "GOT VALUE $$last_config_param_ref\n";
  }
}

#for my $key (keys %config_params) {

#  if (not defined ${ $config_params { $key } }) {
#    die "Missing config parameter: $key\n";
#  }
#}

# Calculate time

my ($min, $hour, $day, $month, $year)=(localtime)[1, 2, 3, 4, 5];
$year = $year + 1900;
$month = $month + 1;



## -- PARSING -- 


# Read values from file

print "Parsing file...\n";

my %allValues; # [String: [String, parameters...]]

my @links;

open(my $fh, '<:encoding(UTF-8)', $input_file) or die "Could not open file '$input_file' $!";

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
      print "$input_file:$.: warning : Localization key \"$key\" does not follow camelCase format.\n";
    }
    
    # Extract parameters

    my @parameters = ($string =~ m/\{\{(.+?)\}\}/g);

    for my $parameter (@parameters) {
      if ($parameter =~ /^[a-z][A-Za-z]*$/) {
        # Camel case
      } else {
        print "$input_file:$.: warning : parameter $parameter does not follow camelCase format\n";
      }
    }

    # Dump in hash 

    $allValues{ $key } = [ $string, @parameters ];

    # Extract Links

    my @matches = ($string =~ m/\[.+?\]\((.+?)\)/g);
    push(@links, @matches);

  } else {
    # Not parsable
    print "$input_file:$.: error : Could not parse line: $row\n";
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
        print STDERR "$input_file:$.: error : Localization key \"$key\" is already a folder and cannot be used.\n";
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


## --- PRINTING ---


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
    $result = "$result$indentation enum $key: $protocol_name {\n";
    $result = "$result$indentation $hashString\n";
    $result = "$result$indentation }";
  }

  return $result;
}

my $keysString = printHashAsString(\%allValuesMultiLevel, $identationLevel);

my $indentation = $tab;
chop $indentation;

for my $link (@links) {
  $linksString = "$linksString\n$indentation case $link";
}

my $rawValuesString = "";
my $parametersString = "";

for my $key (sort keys %allValues) {
  $rawValuesString = "$rawValuesString\n$indentation case $enum_name.$key: return \"$key\"";

  my @parameters = @{$allValues { $key }}; 
  shift(@parameters);

  if (scalar @parameters == 0) {
      $parametersString = "$parametersString\n$indentation case $enum_name.$key: return [:]";
    } else {

      
      my @parametersWithType = map { "let $_" } @parameters;
      my $parametersArgumentString = join(", ", @parametersWithType);

      my @parametersAsDict = map { "\"$_\": $_" } @parameters;
      my $parametersAsDictString = join(", ", @parametersAsDict);
        
      $parametersString = "$parametersString\n$indentation case $enum_name.$key($parametersArgumentString): return [$parametersAsDictString]";
    }
}

my $template = do {
    local $/ = undef;
    open my $fh, "<", $template_file
        or die "could not open $template_file: $!";
    <$fh>;
};

my %variables = (
  AUTHOR => $author,
  FILE_NAME => $output_file,
  PROJECT_NAME => $project,
  TEAM => $team,
  YEAR => $year,
  MONTH => $month,
  DAY => $day,
  HOUR => $hour,
  MINUTE => $min,
  PROTOCOL_NAME => $protocol_name,
  ENUM_NAME => $enum_name,
  KEYS_STRING => $keysString,
  RAW_VALUES_STRING => $rawValuesString,
  PARAMETERS_STRING => $parametersString
);

for my $key (keys %variables) {
  my $value = $variables { $key };
  $template =~ s/$key/$value/g;
}

open($fh, '>', "$output_path/$output_file") or die "Could not open file '$output_path/$output_file' $!";
print $fh $template;
close $fh;

print "Execution Successful.\n";


