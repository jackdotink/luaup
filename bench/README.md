# Benchmarking

Speed is an important part of Luaup - a slow parser is next to useless.

## Running Benchmarks

To run benchmarks, run `lune run bench` from the root of the project. This will run all benchmarks, which will take some time.

## Adding New Benchmarks

To add a new benchmark, simply add a file under the `cases` folder. Prefer files that are greater than 10 kilobytes in size.

## Methodology

Benchmarks are run with Lune's `luau` library, at O2, and with and without native codegen.

Benchmarks are run twice, once to "warm up" and once after that to measure time.

It should be understood that performance can vary quite significantly between runtimes and each usecase should be benchmarked separately. These benchmarks exist primarily to help the development and optimization of Luaup.
