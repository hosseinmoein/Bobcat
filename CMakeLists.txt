cmake_minimum_required (VERSION 3.5)
project (Q
         VERSION 1.0.0)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON) # Produce compile_commands.json
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/xcmake)

include(GNUInstallDirs)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_BINDIR}")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_LIBDIR}")
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_LIBDIR}")

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
   $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include/Bobcat/FixedSizeQueue.h>
   $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include/Bobcat/FixedSizeQueue.tcc>
   $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include/Bobcat/LockFreeQueue.h>
   $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include/Bobcat/LockFreeQueue.tcc>
   $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include/Bobcat/SharedQueue.h>
   $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include/Bobcat/SharedQueue.tcc>
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
