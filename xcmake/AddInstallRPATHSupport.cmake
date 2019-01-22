#.rst:
# AddInstallRPATHSupport
# ----------------------
#

include(CMakeParseArguments)


function(ADD_INSTALL_RPATH_SUPPORT)

  set(_options USE_LINK_PATH)
  set(_oneValueArgs INSTALL_NAME_DIR)
  set(_multiValueArgs BIN_DIRS
                      LIB_DIRS
                      DEPENDS)

  cmake_parse_arguments(_ARS "${_options}"
                             "${_oneValueArgs}"
                             "${_multiValueArgs}"
                             "${ARGN}")

  # if either RPATH or INSTALL_RPATH is disabled
  # and the INSTALL_NAME_DIR variable is set, then hardcode the install name
  if(CMAKE_SKIP_RPATH OR CMAKE_SKIP_INSTALL_RPATH)
    if(DEFINED _ARS_INSTALL_NAME_DIR)
      set(CMAKE_INSTALL_NAME_DIR ${_ARS_INSTALL_NAME_DIR} PARENT_SCOPE)
    endif()
  endif()

  if (CMAKE_SKIP_RPATH OR (CMAKE_SKIP_INSTALL_RPATH AND CMAKE_SKIP_BUILD_RPATH))
    return()
  endif()


  set(_rpath_available 1)
  if(DEFINED _ARS_DEPENDS)
    foreach(_dep ${_ARS_DEPENDS})
      string(REGEX REPLACE " +" ";" _dep "${_dep}")
      if(NOT (${_dep}))
        set(_rpath_available 0)
      endif()
    endforeach()
  endif()

  if(_rpath_available)

    # Enable RPATH on OSX.
    set(CMAKE_MACOSX_RPATH TRUE PARENT_SCOPE)

    # Find system implicit lib directories
    set(_system_lib_dirs ${CMAKE_PLATFORM_IMPLICIT_LINK_DIRECTORIES})
    if(EXISTS "/etc/debian_version") # is this a debian system ?
        if(CMAKE_LIBRARY_ARCHITECTURE)
            list(APPEND _system_lib_dirs "/lib/${CMAKE_LIBRARY_ARCHITECTURE}"
                                         "/usr/lib/${CMAKE_LIBRARY_ARCHITECTURE}")
        endif()
    endif()
    # This is relative RPATH for libraries built in the same project
    foreach(lib_dir ${_ARS_LIB_DIRS})
      list(FIND _system_lib_dirs "${lib_dir}" isSystemDir)
      if("${isSystemDir}" STREQUAL "-1")
        foreach(bin_dir ${_ARS_LIB_DIRS} ${_ARS_BIN_DIRS})
          file(RELATIVE_PATH _rel_path ${bin_dir} ${lib_dir})
          if (${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
            list(APPEND CMAKE_INSTALL_RPATH "@loader_path/${_rel_path}")
          else()
            list(APPEND CMAKE_INSTALL_RPATH "\$ORIGIN/${_rel_path}")
          endif()
        endforeach()
      endif()
    endforeach()
    if(NOT "${CMAKE_INSTALL_RPATH}" STREQUAL "")
      list(REMOVE_DUPLICATES CMAKE_INSTALL_RPATH)
    endif()
    set(CMAKE_INSTALL_RPATH ${CMAKE_INSTALL_RPATH} PARENT_SCOPE)

    set(CMAKE_INSTALL_RPATH_USE_LINK_PATH ${_ARS_USE_LINK_PATH} PARENT_SCOPE)

  endif()

endfunction()
