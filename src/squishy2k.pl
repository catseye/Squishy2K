#!/usr/bin/env perl
# squishy2k.pl - v2000.10.06 Chris Pressey
# Squishy2K to Perl 5 compiler in Perl 5
# This work is in the public domain.  See the file UNLICENSE for more
# information.

### SYNOPSIS

# squishy2k.pl - Squishy2K to Perl 5 compiler in Perl 5
# usage: [perl] squishy2k[.pl] <input.sq2k >output.pl

### GLOBALS

$token = '';
$line = '';
$curline = '';

### SCANNER

sub perr
{
  my $msg = shift;
  print "$msg\n";
  print "($curline:$token)\n";
}

sub scan
{
  restart_scan:
  while (not defined $line or $line eq '')
  {
    if (defined($line = <STDIN>))
    {
      chomp $line;
      $curline = $line;
    } else
    {
      $line = ''; $token = '&&&EOF'; return;
    }
  }
  if ($line =~ /^\/\//) { $line = ''; goto restart_scan; }
  if ($line =~ /^\s+/) { $line = $'; goto restart_scan; }
  if ($line =~ /^(\d+)/) { $line = $'; $token = $1; return; }
  if ($line =~ /^([a-zA-Z_]\w*)/) { $line = $'; $token = $1; return; }
  if ($line =~ /^(\".*?\")/) { $line = $'; $token = $1; return; }
  if ($line =~ /^(\".*?)\s*$/) # exp. del. inform quotes
  {
    $token = $1;
    $line = <INFILE>;
    chomp $line;
    while ($line !~ /^\s*(.*?\")/)
    {
      $token .= $line;
      $line = <INFILE>;
      chomp $line;
    }
    $line =~ /^\s*(.*?\")/;
    $line = $';
    $token .= " $1";
    return;
  }
  if ($line =~ /^(.)/) { $line = $'; $token = $1; return; }
}

sub tokeq
{
  return (uc($token) eq uc(shift));
}

sub tokne
{
  return (uc($token) ne uc(shift));
}

sub expect
{
  my $s = shift;
  my $t = shift || 'unidentified production';
  if(tokeq($s))
  {
    scan();
  } else
  {
    perr "Expected '$s' not '$token' in '$t'";
    # while (tokne($s)) { scan(); }
    exit(0) if <STDIN> =~ /^q/;
  }
}

### PARSER

# Program ::= {State}.
sub program
{
  scan();
  print "\$s = join('', <STDIN>); print \"\\n\";\n";
  print "\$s =~ s/\\n/ /gos;\n";

  while(tokeq('*')) { state(); }
  expect('&&&EOF');
  print "print main(\$s);\n";
}

# State   ::= "*" Name "{" {Rule} ["!" Name] "}".
sub state
{
  expect('*');
  my $n = defn_name();
  expect('{');
  print "sub $n {\n";
  print "  my \$s = shift;\n";
  # print "  print \"$n...\\n\";\n";
  while(tokne('}') and tokne('!')) { rule(); }
  if(tokeq('!'))
  {
    scan();
    my $q = apply_name();
    print "  \@_ = (\$s); goto \&$q;\n";
  }
  expect('}');
  print "  return \$s;\n";
  print "}\n";
}

# Rule    ::= String "?" String "!" [Name].
sub rule
{
  my $a = lstring();
  expect('?');
  my $b = rstring();
  expect('!');
  if ($token =~ /^[a-zA-Z]\w+$/)
  {
    my $n = apply_name();
    print "  if(\$s =~ s/$a/$b/e) { \@_ = (\$s); goto \&$n; }\n";
  } else
  {
    print "  if(\$s =~ s/$a/$b/e) { return \$s; }\n";
  }
}

sub defn_name
{
  my $n = $token;
  scan();
  return $n;
}

sub apply_name
{
  my $n = $token;
  scan();
  return $n;
}

# LString ::= {quoted | "few" | "many" | "start" | "finish"}.
sub lstring
{
  my $s = '';
  while ($token =~ /^\".*?\"$/ or
         $token eq 'start' or $token eq 'finish' or
         $token eq 'few' or $token eq 'many')
  {
    my $t = $token;
    if ($t eq 'few')
    {
      $s .= "(.*?)";
    } elsif ($t eq 'many')
    {
      $s .= "(.*)";
    } elsif ($t eq 'start')
    {
      $s .= "^";
    } elsif ($t eq 'finish')
    {
      $s .= "\$";
    } else
    {
      $t =~ s/^\"(.*?)\"$/$1/;
      $s .= quotemeta($t);
    }
    scan();
  }
  return $s;
}

# RString ::= {quoted | digit | Name "(" RString ")"}.
sub rstring
{
  my $s = '""';
  while ($token =~ /^\".*?\"$/ or
         $token =~ /^\d+$/ or
         $token =~ /^[a-zA-Z]\w*$/)
  {
    my $t = $token;
    if ($t =~ /^[a-zA-Z]\w*$/)
    {
      $s .= " . $t(";
      scan();
      expect("(");
      $s .= rstring();
      expect(")");
      $s .= ")";
    } elsif ($t =~ /^\d+$/)
    {
      $s .= " . \$$t";
      scan();
    } else
    {
      $t =~ s/^\"(.*?)\"$/$1/;
      $s .= " . \"" . quotemeta($t) . "\"";
      scan();
    }
  }
  return $s;
}

### MAIN

program();

### END
