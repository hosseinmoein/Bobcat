[![Build status](https://ci.appveyor.com/api/projects/status/hjw01qui3bvxs8yi?svg=true)](https://ci.appveyor.com/project/hosseinmoein/Q)
[![C++17](https://img.shields.io/badge/C%2B%2B-17-blue.svg)](https://isocpp.org/std/the-standard )
[![Build Status](https://travis-ci.org/hosseinmoein/Q.svg?branch=master)](https://travis-ci.org/hosseinmoein/Q)

# Queue
This repository includes 3 different multi-threaded queues:<BR>
This is a header-only library
1. A lock-free queue for one producer and one consumer
2. A fixed size, circular, multi-threaded queue
3. A generic multi-threaded queue

[Lock-free Q Test File](src/lockfreeq_tester.cc)<BR>
[Circular fixed-size Q Test File](src/fixedsizeq_tester.cc)<BR>
[Generic Q Test File](src/fixedsizeq_tester.cc)<BR>

## [License](License)

### Installing using CMake
```
mkdir build
cd build
cmake ..
make install
```

### Uninstalling

```
cd build
make uninstall
```
