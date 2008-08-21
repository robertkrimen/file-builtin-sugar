use inc::Module::Install;

name 'File-Builtin-Sugar';
all_from 'lib/File/Builtin/Sugar.pm';

build_requires 'Test::More';

auto_install;

WriteAll;

