#!/usr/bin/env perl

use strict;
use warnings;

use File::Spec;

my $orig_system_ui_path = $ARGV[0] || '';
my $new_system_ui_path = $ARGV[1] || '';
my $out_system_ui_name = $ARGV[2] || '';

die "Usage: $0 <orig system apk> <new system apk> <output name>" unless ($orig_system_ui_path || $new_system_ui_path || $out_system_ui_name);

my $tmp_dir_path = "/tmp/build_system_ui_temp";

mkdir $tmp_dir_path unless (-d $tmp_dir_path);

system("rm -rf $tmp_dir_path/*");

my $orig_apk_path = File::Spec->catfile($tmp_dir_path, "SystemUI_orig.apk");
my $orig_apk_dir = File::Spec->catfile($tmp_dir_path, "SystemUI_orig");

system("cp $orig_system_ui_path $orig_apk_path");


my $new_apk_path = File::Spec->catfile($tmp_dir_path, "SystemUI_new.apk");
my $new_apk_dir = File::Spec->catfile($tmp_dir_path, "SystemUI_new");

system("cp $new_system_ui_path $new_apk_path");

system("apktool d $orig_apk_path $orig_apk_dir");
system("apktool d $new_apk_path $new_apk_dir");

system("rm -rf $orig_apk_dir/res");
system("rm -rf $orig_apk_dir/smali");
system("cp -r $new_apk_dir/res $orig_apk_dir");
system("cp -r $new_apk_dir/smali $orig_apk_dir");

my $compile_temp_dir = File::Spec->catfile($tmp_dir_path, "compile_temp");
mkdir $compile_temp_dir;

system("apktool b $orig_apk_dir $tmp_dir_path/temp.apk");

system("7za x -o${compile_temp_dir} $orig_system_ui_path");

system("rm -rf $compile_temp_dir/assets");
system("rm -rf $compile_temp_dir/res");
system("rm -rf $compile_temp_dir/classes.dex");
system("rm -rf $compile_temp_dir/resources.arsc");

system("7za a -tzip $tmp_dir_path/temp.apk $compile_temp_dir/* -mx9 -r");

system("mv $tmp_dir_path/temp.apk $out_system_ui_name");
system("rm -rf $tmp_dir_path");
