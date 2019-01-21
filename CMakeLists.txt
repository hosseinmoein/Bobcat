cmake_minimum_required (VERSION 3.5)
project (Q
         VERSION 1.0.0)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON) # Produce compile_commands.json
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

# We use
# - InstallBasicPackageFiles (http://robotology.github.io/ycm/gh-pages/v0.8/module/InstallBasicPackageFiles.html)
# - AddUninstallTarget (http://robotology.github.io/ycm/gh-pages/v0.8/module/AddUninstallTarget.html)
# - AddInstallRPATHSupport (http://robotology.github.io/ycm/gh-pages/v0.8/module/AddInstallRPATHSupport.html)
# See https://github.com/robotology/ycm/
list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)

# Control where libraries and executables are placed during the build.
# With the following settings executables are placed in <the top level of the
# build tree>/bin and libraries/archives in <top level of the build tree>/lib.
# This is particularly useful to run ctests on libraries built on Windows
# machines: tests, which are executables, are placed in the same folders of
# dlls, which are treated as executables as well, so that they can properly
# find the libraries to run. This is a because of missing RPATH on Windows.
include(GNUInstallDirs)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_BINDIR}")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_LIBDIR}")
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_LIBDIR}")

# Disable C and C++ compiler extensions.
# C/CXX_EXTENSIONS are ON by default to allow the compilers to use extended
# variants of the C/CXX language.
# However, this could expose cross-platform bugs in user code or in the headers
# of third-party dependencies and thus it is strongly suggested to turn
# extensions off.
set(CMAKE_C_EXTENSIONS OFF)
set(CMAKE_CXX_EXTENSIONS OFF)

# Encourage user to specify a build type (e.g. Release, Debug, etc.), otherwise set it to Release.
if(NOT CMAKE_CONFIGURATION_TYPES)
    if(NOT CMAKE_BUILD_TYPE)
        message(STATUS "Setting build type to 'Release' as none was specified.")
        set_property(CACHE CMAKE_BUILD_TYPE PROPERTY VALUE "Release")
    endif()
endif()

set(LIBRARY_TARGET_NAME ${PROJECT_NAME})
add_library(${LIBRARY_TARGET_NAME} INTERFACE)
add_definitions(-D DMS_INCLUDE_SOURCE) # Need this for some of the .tcc files to be compiled
# List of header files.
set(${LIBRARY_TARGET_NAME}_HDR
   $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include/FixedSizeQueue.h>
   $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include/FixedSizeQueue.tcc>
   $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include/LockFreeQueue.h>
   $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include/LockFreeQueue.tcc>
   $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include/SharedQueue.h>
   $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include/SharedQueue.tcc>
)

target_include_directories(${LIBRARY_TARGET_NAME} INTERFACE "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>"
                                                            "$<INSTALL_INTERFACE:$<INSTALL_PREFIX>/${CMAKE_INSTALL_INCLUDEDIR}>"
							    )

# Specify installation targets, typology and destination folders.
# First install cmake exported files 
install(TARGETS ${LIBRARY_TARGET_NAME}
        EXPORT  ${PROJECT_NAME}
        LIBRARY       DESTINATION "${CMAKE_INSTALL_LIBDIR}"                            COMPONENT shlib
        ARCHIVE       DESTINATION "${CMAKE_INSTALL_LIBDIR}"                            COMPONENT lib
        RUNTIME       DESTINATION "${CMAKE_INSTALL_BINDIR}"                            COMPONENT bin
	)
# Second install the actual header files
install(FILES "${${LIBRARY_TARGET_NAME}_HDR}"
        DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/${LIBRARY_TARGET_NAME}"
	)

# Create and install CMake configuration files for your project that are
# necessary to for other projects to call find_package().
#
# Note that it is extremely important to use exactly the project name while installing configuration
# files (you can use PROJECT_NAME variable to avoid any possible error). This is required to allow
# find_package() to properly look for the installed library in system path, in particular in Windows
# when the installation is performed in the default path.
#
# install_basic_package_files() comes with many input parameters to customize the configuration
# files. The parameters used in the following call provide basic versions of CMake configuration
# files.  See install_basic_package_files() documentation found in ./cmake folder.
#
# Note that if your library depends from other libraries, you are probably
# required to used the install_basic_package_files() DEPENDENCIES option.
include(InstallBasicPackageFiles)
install_basic_package_files(${PROJECT_NAME}
                            VERSION ${${PROJECT_NAME}_VERSION}
                            COMPATIBILITY AnyNewerVersion
                            EXPORT ${PROJECT_NAME}
                            VARS_PREFIX ${PROJECT_NAME}
                            NO_CHECK_REQUIRED_COMPONENTS_MACRO)

# Add the uninstall target
include(AddUninstallTarget)

# Build the test binary
add_executable(fixedsizeq_tester src/fixedsizeq_tester.cc)
add_executable(lockfreeq_tester src/lockfreeq_tester.cc)
add_executable(sharedq_tester src/sharedq_tester.cc)
target_include_directories(fixedsizeq_tester PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/include)
target_include_directories(lockfreeq_tester PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/include)
target_include_directories(sharedq_tester PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/include)
if (UNIX)
  # Find pthreads library
  set(THREADS_PREFER_PTHREAD_FLAG ON)
  find_package(Threads REQUIRED)
  target_link_libraries(fixedsizeq_tester Threads::Threads)
  target_link_libraries(lockfreeq_tester Threads::Threads)
  target_link_libraries(sharedq_tester Threads::Threads)
endif (UNIX)


# Enable ctest, testing so we can see if unit tests pass or fail in CI
enable_testing()
add_test(NAME fixedsizeq_tester
         COMMAND fixedsizeq_tester
         WORKING_DIRECTORY $<TARGET_FILE_DIR:fixedsizeq_tester>)
add_test(NAME lockfreeq_tester
         COMMAND lockfreeq_tester
         WORKING_DIRECTORY $<TARGET_FILE_DIR:lockfreeq_tester>)
add_test(NAME sharedq_tester
         COMMAND sharedq_tester
         WORKING_DIRECTORY $<TARGET_FILE_DIR:sharedq_tester>)
