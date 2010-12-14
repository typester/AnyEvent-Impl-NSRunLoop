use inc::Module::Install;
name 'AnyEvent-Impl-NSRunLoop';
all_from 'lib/AnyEvent/Impl/NSRunLoop.pm';

test_requires 'Test::More';
use_test_base;
author_tests('xt');

auto_include;
auto_set_repository;

WriteAll;
