# Benchmarking

Speed is an important part of Luaup - a slow parser is next to useless.

## Running Benchmarks

To run benchmarks, run `lune run bench` from the root of the project. This will run all benchmarks which might take a while.

## Adding New Benchmarks

To add a new benchmark, simply add a file under the `cases` folder. Prefer files that are greater than 1 kilobyte in size.

## Methodology

Benchmarks are run with the Luau CLI at O2, with and without native codegen. Each benchmark measures the time taken to parse the file.

It is known that performance will vary wildly between runtimes; as an example at the time writing, Lune parses at ~3 MB/s and Luau CLI parses at ~6 MB/s.
