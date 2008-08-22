#!/usr/bin/perl -w

use strict;
use warnings;

use Test::Most;
plan qw/no_plan/;

use File::Builtin::Sugar qw/:all/;

rename qw/a b/ or ok(1);
symlink qw/a b/ or ok(1);
