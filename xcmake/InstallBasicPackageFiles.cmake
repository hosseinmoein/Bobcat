#.rst:
# InstallBasicPackageFiles
# ------------------------
#

if(COMMAND install_basic_package_files)
  return()
endif()

include(GNUInstallDirs)
include(CMakePackageConfigHelpers)
include(CMakeParseArguments)

function(INSTALL_BASIC_PACKAGE_FILES _Name)
  set(_options NO_SET_AND_CHECK_MACRO
               NO_CHECK_REQUIRED_COMPONENTS_MACRO
               UPPERCASE_FILENAMES
               LOWERCASE_FILENAMES
               NO_COMPATIBILITY_VARS)
  set(_oneValueArgs VERSION
                    COMPATIBILITY
                    EXPORT
                    FIRST_TARGET
                    TARGETS_PROPERTY
                    VARS_PREFIX
                    EXPORT_DESTINATION
                    INSTALL_DESTINATION
                    DESTINATION
                    NAMESPACE
                    CONFIG_TEMPLATE
                    INCLUDE_FILE
                    COMPONENT)
  set(_multiValueArgs EXTRA_PATH_VARS_SUFFIX
                      TARGETS
                      TARGETS_PROPERTIES
                      DEPENDENCIES
                      PRIVATE_DEPENDENCIES)
  cmake_parse_arguments(_IBPF "${_options}" "${_oneValueArgs}" "${_multiValueArgs}" "${ARGN}")

  if(NOT DEFINED _IBPF_VARS_PREFIX)
    set(_IBPF_VARS_PREFIX ${_Name})
  endif()

  if(NOT DEFINED _IBPF_VERSION)
    message(FATAL_ERROR "VERSION argument is required")
  endif()

  if(NOT DEFINED _IBPF_COMPATIBILITY)
    message(FATAL_ERROR "COMPATIBILITY argument is required")
  endif()

  if(_IBPF_UPPERCASE_FILENAMES AND _IBPF_LOWERCASE_FILENAMES)
    message(FATAL_ERROR "UPPERCASE_FILENAMES and LOWERCASE_FILENAMES arguments cannot be used together")
  endif()

  # Prepare install and export commands
  set(_first_target ${_Name})
  set(_targets ${_Name})
  set(_install_cmd EXPORT ${_Name})
  set(_export_cmd EXPORT ${_Name})

  if(DEFINED _IBPF_FIRST_TARGET)
    if(DEFINED _IBPF_TARGETS OR DEFINED _IBPF_TARGETS_PROPERTIES OR DEFINED _IBPF_TARGETS_PROPERTIES)
      message(FATAL_ERROR "EXPORT cannot be used with TARGETS, TARGETS_PROPERTY or TARGETS_PROPERTIES")
    endif()

    set(_first_target ${_IBPF_FIRST_TARGET})
    set(_targets ${_IBPF_FIRST_TARGET})
  endif()

  if(DEFINED _IBPF_EXPORT)
    if(DEFINED _IBPF_TARGETS OR DEFINED _IBPF_TARGETS_PROPERTIES OR DEFINED _IBPF_TARGETS_PROPERTIES)
      message(FATAL_ERROR "EXPORT cannot be used with TARGETS, TARGETS_PROPERTY or TARGETS_PROPERTIES")
    endif()

    set(_export_cmd EXPORT ${_IBPF_EXPORT})
    set(_install_cmd EXPORT ${_IBPF_EXPORT})

  elseif(DEFINED _IBPF_TARGETS)
    if(DEFINED _IBPF_TARGETS_PROPERTY OR DEFINED _IBPF_TARGETS_PROPERTIES)
      message(FATAL_ERROR "TARGETS cannot be used with TARGETS_PROPERTY or TARGETS_PROPERTIES")
    endif()

    set(_targets ${_IBPF_TARGETS})
    set(_export_cmd TARGETS ${_IBPF_TARGETS})
    list(GET _targets 0 _first_target)

  elseif(DEFINED _IBPF_TARGETS_PROPERTY)
    if(DEFINED _IBPF_TARGETS_PROPERTIES)
      message(FATAL_ERROR "TARGETS_PROPERTIES cannot be used with TARGETS_PROPERTIES")
    endif()

    get_property(_targets GLOBAL PROPERTY ${_IBPF_TARGETS_PROPERTY})
    set(_export_cmd TARGETS ${_targets})
    list(GET _targets 0 _first_target)

  elseif(DEFINED _IBPF_TARGETS_PROPERTIES)

    unset(_targets)
    foreach(_prop ${_IBPF_TARGETS_PROPERTIES})
      get_property(_prop_val GLOBAL PROPERTY ${_prop})
      list(APPEND _targets ${_prop_val})
    endforeach()
    set(_export_cmd TARGETS ${_targets})
    list(GET _targets 0 _first_target)

  endif()

  # Path for installed cmake files
  if(DEFINED _IBPF_DESTINATION)
    message(DEPRECATION "DESTINATION is deprecated. Use INSTALL_DESTINATION instead")
    if(NOT DEFINED _IBPF_INSTALL_DESTINATION)
      set(_IBPF_INSTALL_DESTINATION ${_IBPF_DESTINATION})
    endif()
  endif()

  if(NOT DEFINED _IBPF_INSTALL_DESTINATION)
    if(WIN32 AND NOT CYGWIN)
      set(_IBPF_INSTALL_DESTINATION CMake)
    else()
      set(_IBPF_INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/xcmake/${_Name})
    endif()
  endif()

  if(NOT DEFINED _IBPF_EXPORT_DESTINATION)
    set(_IBPF_EXPORT_DESTINATION "${CMAKE_BINARY_DIR}")
  elseif(NOT IS_ABSOLUTE _IBPF_EXPORT_DESTINATION)
    set(_IBPF_EXPORT_DESTINATION "${CMAKE_BINARY_DIR}/${_IBPF_EXPORT_DESTINATION}")
  endif()

  if(NOT DEFINED _IBPF_NAMESPACE)
    set(_IBPF_NAMESPACE "${_Name}::")
  endif()

  if(NOT DEFINED _IBPF_COMPONENT)
    set(_IBPF_COMPONENT "${_Name}")
  endif()

  if(_IBPF_NO_SET_AND_CHECK_MACRO)
    list(APPEND configure_package_config_file_extra_args NO_SET_AND_CHECK_MACRO)
  endif()

  if(_IBPF_NO_CHECK_REQUIRED_COMPONENTS_MACRO)
    list(APPEND configure_package_config_file_extra_args NO_CHECK_REQUIRED_COMPONENTS_MACRO)
  endif()



  # Set input file for config, and ensure that _IBPF_UPPERCASE_FILENAMES
  # and _IBPF_LOWERCASE_FILENAMES are set correctly
  unset(_config_cmake_in)
  set(_generate_file 0)
  if(DEFINED _IBPF_CONFIG_TEMPLATE)
    if(NOT EXISTS "${_IBPF_CONFIG_TEMPLATE}")
      message(FATAL_ERROR "Config template file \"${_IBPF_CONFIG_TEMPLATE}\" not found")
    endif()
    set(_config_cmake_in "${_IBPF_CONFIG_TEMPLATE}")
    if(NOT _IBPF_UPPERCASE_FILENAMES AND NOT _IBPF_LOWERCASE_FILENAMES)
      if("${_IBPF_CONFIG_TEMPLATE}" MATCHES "${_Name}Config.cmake.in")
        set(_IBPF_UPPERCASE_FILENAMES 1)
      elseif("${_IBPF_CONFIG_TEMPLATE}" MATCHES "${_name}-config.cmake.in")
        set(_IBPF_LOWERCASE_FILENAMES 1)
      else()
        set(_IBPF_UPPERCASE_FILENAMES 1)
      endif()
    endif()
  else()
    string(TOLOWER "${_Name}" _name)
    if(EXISTS "${CMAKE_SOURCE_DIR}/${_Name}Config.cmake.in")
      set(_config_cmake_in "${CMAKE_SOURCE_DIR}/${_Name}Config.cmake.in")
      if(NOT _IBPF_UPPERCASE_FILENAMES AND NOT _IBPF_LOWERCASE_FILENAMES)
        set(_IBPF_UPPERCASE_FILENAMES 1)
      endif()
    elseif(EXISTS "${CMAKE_SOURCE_DIR}/${_name}-config.cmake.in")
      set(_config_cmake_in "${CMAKE_SOURCE_DIR}/${_name}-config.cmake.in")
      if(NOT _IBPF_UPPERCASE_FILENAMES AND NOT _IBPF_LOWERCASE_FILENAMES)
        set(_IBPF_LOWERCASE_FILENAMES 1)
      endif()
    elseif(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${_Name}Config.cmake.in")
      set(_config_cmake_in "${CMAKE_CURRENT_SOURCE_DIR}/${_Name}Config.cmake.in")
      if(NOT _IBPF_UPPERCASE_FILENAMES AND NOT _IBPF_LOWERCASE_FILENAMES)
        set(_IBPF_UPPERCASE_FILENAMES 1)
      endif()
    elseif(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${_name}-config.cmake.in")
      set(_config_cmake_in "${CMAKE_CURRENT_SOURCE_DIR}/${_name}-config.cmake.in")
      if(NOT _IBPF_UPPERCASE_FILENAMES AND NOT _IBPF_LOWERCASE_FILENAMES)
        set(_IBPF_LOWERCASE_FILENAMES 1)
      endif()
    else()
      set(_generate_file 1)
      if(_IBPF_LOWERCASE_FILENAMES)
        set(_config_cmake_in "${CMAKE_CURRENT_BINARY_DIR}/${_name}-config.cmake")
      else()
        set(_config_cmake_in "${CMAKE_CURRENT_BINARY_DIR}/${_Name}Config.cmake.in")
        set(_IBPF_UPPERCASE_FILENAMES 1)
      endif()
    endif()
  endif()

  # Set input file containing user variables
  if(DEFINED _IBPF_INCLUDE_FILE)
    if(NOT IS_ABSOLUTE "${_IBPF_INCLUDE_FILE}")
      if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${_IBPF_INCLUDE_FILE}")
        set(_IBPF_INCLUDE_FILE "${CMAKE_CURRENT_SOURCE_DIR}/${_IBPF_INCLUDE_FILE}")
      endif()
    endif()
    if(NOT EXISTS "${_IBPF_INCLUDE_FILE}")
        message(FATAL_ERROR "File \"${_IBPF_INCLUDE_FILE}\" not found")
    endif()
    file(READ ${_IBPF_INCLUDE_FILE} _includedfile_user_content_in)
    string(CONFIGURE ${_includedfile_user_content_in} _includedfile_user_content)
    set(INCLUDED_FILE_CONTENT
"#### Expanded from INCLUDE_FILE by install_basic_package_files() ####")
    set(INCLUDED_FILE_CONTENT "${INCLUDED_FILE_CONTENT}\n\n${_includedfile_user_content}")
    set(INCLUDED_FILE_CONTENT
"${INCLUDED_FILE_CONTENT}
#####################################################################")
  endif()

  # Select output file names
  if(_IBPF_UPPERCASE_FILENAMES)
    set(_config_filename ${_Name}Config.cmake)
    set(_version_filename ${_Name}ConfigVersion.cmake)
    set(_targets_filename ${_Name}Targets.cmake)
  elseif(_IBPF_LOWERCASE_FILENAMES)
    set(_config_filename ${_name}-config.cmake)
    set(_version_filename ${_name}-config-version.cmake)
    set(_targets_filename ${_name}-targets.cmake)
  endif()


  # If the template config file does not exist, write a basic one
  if(_generate_file)
    # Generate the compatibility code
    unset(_compatibility_vars)
    if(NOT _IBPF_NO_COMPATIBILITY_VARS)
      unset(_get_include_dir_code)
      unset(_set_include_dir_code)
      unset(_target_list)
      foreach(_target ${_targets})
        list(APPEND _target_list ${_IBPF_NAMESPACE}${_target})
      endforeach()
      if(DEFINED ${_IBPF_VARS_PREFIX}_BUILD_INCLUDEDIR OR
         DEFINED BUILD_${_IBPF_VARS_PREFIX}_INCLUDEDIR OR
         DEFINED ${_IBPF_VARS_PREFIX}_INSTALL_INCLUDEDIR OR
         DEFINED INSTALL_${_IBPF_VARS_PREFIX}_INCLUDEDIR)
        set(_get_include_dir "set(${_IBPF_VARS_PREFIX}_INCLUDEDIR \"\@PACKAGE_${_IBPF_VARS_PREFIX}_INCLUDEDIR\@\")\n")
        set(_set_include_dir "set(${_Name}_INCLUDE_DIRS \"\${${_IBPF_VARS_PREFIX}_INCLUDEDIR}\")")
      elseif(DEFINED ${_IBPF_VARS_PREFIX}_BUILD_INCLUDE_DIR OR
             DEFINED BUILD_${_IBPF_VARS_PREFIX}_INCLUDE_DIR OR
             DEFINED ${_IBPF_VARS_PREFIX}_INSTALL_INCLUDE_DIR OR
             DEFINED INSTALL_${_IBPF_VARS_PREFIX}_INCLUDE_DIR)
        set(_get_include_dir "set(${_IBPF_VARS_PREFIX}_INCLUDE_DIR \"\@PACKAGE_${_IBPF_VARS_PREFIX}_INCLUDE_DIR\@\")\n")
        set(_set_include_dir "set(${_Name}_INCLUDE_DIRS \"\${${_IBPF_VARS_PREFIX}_INCLUDE_DIR}\")")
      else()
        unset(_include_dir_list)
        foreach(_target ${_targets})
          set(_get_include_dir "${_get_include_dir}get_property(${_IBPF_VARS_PREFIX}_${_target}_INCLUDE_DIR TARGET ${_IBPF_NAMESPACE}${_target} PROPERTY INTERFACE_INCLUDE_DIRECTORIES)\n")
          list(APPEND _include_dir_list "\"\${${_IBPF_VARS_PREFIX}_${_target}_INCLUDE_DIR}\"")
        endforeach()
        string(REPLACE ";" " " _include_dir_list "${_include_dir_list}")
        string(REPLACE ";" " " _target_list "${_target_list}")
        set(_set_include_dir "set(${_Name}_INCLUDE_DIRS ${_include_dir_list})\nlist(REMOVE_DUPLICATES ${_Name}_INCLUDE_DIRS)")
      endif()
      set(_compatibility_vars "# Compatibility\n${_get_include_dir}\nset(${_Name}_LIBRARIES ${_target_list})\n${_set_include_dir}")
    endif()

    # Write the file
    file(WRITE "${_config_cmake_in}"
"set(${_IBPF_VARS_PREFIX}_VERSION \@PACKAGE_VERSION\@)

\@PACKAGE_INIT\@

\@PACKAGE_DEPENDENCIES\@

if(NOT TARGET ${_IBPF_NAMESPACE}${_first_target})
  include(\"\${CMAKE_CURRENT_LIST_DIR}/${_targets_filename}\")
endif()

${_compatibility_vars}

\@INCLUDED_FILE_CONTENT\@
")
  endif()

  # Make relative paths absolute (needed later on) and append the
  # defined variables to _(build|install)_path_vars_suffix
  foreach(p BINDIR          BIN_DIR
            SBINDIR         SBIN_DIR
            LIBEXECDIR      LIBEXEC_DIR
            SYSCONFDIR      SYSCONF_DIR
            SHAREDSTATEDIR  SHAREDSTATE_DIR
            LOCALSTATEDIR   LOCALSTATE_DIR
            LIBDIR          LIB_DIR
            INCLUDEDIR      INCLUDE_DIR
            OLDINCLUDEDIR   OLDINCLUDE_DIR
            DATAROOTDIR     DATAROOT_DIR
            DATADIR         DATA_DIR
            INFODIR         INFO_DIR
            LOCALEDIR       LOCALE_DIR
            MANDIR          MAN_DIR
            DOCDIR          DOC_DIR
            ${_IBPF_EXTRA_PATH_VARS_SUFFIX})
    if(DEFINED ${_IBPF_VARS_PREFIX}_BUILD_${p})
      list(APPEND _build_path_vars_suffix ${p})
      list(APPEND _build_path_vars "${_IBPF_VARS_PREFIX}_${p}")
    endif()
    if(DEFINED BUILD_${_IBPF_VARS_PREFIX}_${p})
      list(APPEND _build_path_vars_suffix ${p})
      list(APPEND _build_path_vars "${_IBPF_VARS_PREFIX}_${p}")
    endif()
    if(DEFINED ${_IBPF_VARS_PREFIX}_INSTALL_${p})
      list(APPEND _install_path_vars_suffix ${p})
      list(APPEND _install_path_vars "${_IBPF_VARS_PREFIX}_${p}")
    endif()
    if(DEFINED INSTALL_${_IBPF_VARS_PREFIX}_${p})
      list(APPEND _install_path_vars_suffix ${p})
      list(APPEND _install_path_vars "${_IBPF_VARS_PREFIX}_${p}")
    endif()
  endforeach()


  # <Name>ConfigVersion.cmake file (same for build tree and intall)
  write_basic_package_version_file("${_IBPF_EXPORT_DESTINATION}/${_version_filename}"
                                   VERSION ${_IBPF_VERSION}
                                   COMPATIBILITY ${_IBPF_COMPATIBILITY})
  install(FILES "${_IBPF_EXPORT_DESTINATION}/${_version_filename}"
          DESTINATION ${_IBPF_INSTALL_DESTINATION}
          COMPONENT ${_IBPF_COMPONENT})


  # Prepare PACKAGE_DEPENDENCIES variable
  set(_need_private_deps 0)
  if(NOT BUILD_SHARED_LIBS)
    set(_need_private_deps 1)
  else()
    foreach(_target ${_targets})
      get_property(_type TARGET ${_target} PROPERTY TYPE)
      if("${_type}" STREQUAL "STATIC_LIBRARY")
        set(_need_private_deps 1)
        break()
      endif()
    endforeach()
  endif()

  unset(PACKAGE_DEPENDENCIES)
  if(DEFINED _IBPF_DEPENDENCIES)
    set(PACKAGE_DEPENDENCIES "#### Expanded from @PACKAGE_DEPENDENCIES@ by install_basic_package_files() ####\n\ninclude(CMakeFindDependencyMacro)\n")

    # FIXME When CMake 3.9 or greater is required, remove this madness and just
    #       use find_dependency
    if (CMAKE_VERSION VERSION_LESS 3.9)
      string(APPEND PACKAGE_DEPENDENCIES "
set(_${_Name}_FIND_PARTS_REQUIRED)
if (${_Name}_FIND_REQUIRED)
  set(_${_Name}_FIND_PARTS_REQUIRED REQUIRED)
endif()
set(_${_Name}_FIND_PARTS_QUIET)
if (${_Name}_FIND_QUIETLY)
  set(_${_Name}_FIND_PARTS_QUIET QUIET)
endif()
")

      foreach(_dep ${_IBPF_DEPENDENCIES})
        if("${_dep}" MATCHES ".+ .+")
            string(REPLACE " " ";" _dep_list "${_dep}")
            list(INSERT _dep_list 1 \${_${_Name}_FIND_PARTS_QUIET} \${_${_Name}_FIND_PARTS_REQUIRED})
            string(REPLACE ";" " " _depx "${_dep_list}")
            string(APPEND PACKAGE_DEPENDENCIES "find_package(${_depx})\n")
        else()
          string(APPEND PACKAGE_DEPENDENCIES "find_dependency(${_dep})\n")
        endif()
      endforeach()
      if(_need_private_deps)
        foreach(_dep ${_IBPF_PRIVATE_DEPENDENCIES})
          if("${_dep}" MATCHES ".+ .+")
            string(REPLACE " " ";" _dep_list "${_dep}")
            list(INSERT _dep_list 1 \${_${_Name}_FIND_PARTS_QUIET} \${_${_Name}_FIND_PARTS_REQUIRED})
            string(REPLACE ";" "\n       " _depx "${_dep_list}")
            string(APPEND PACKAGE_DEPENDENCIES "find_package(${_depx})\n")
          else()
            string(APPEND PACKAGE_DEPENDENCIES "find_dependency(${_dep})\n")
          endif()
          endforeach()
      endif()

    else()

      foreach(_dep ${_IBPF_DEPENDENCIES})
        string(APPEND PACKAGE_DEPENDENCIES "find_dependency(${_dep})\n")
      endforeach()
      if(_need_private_deps)
        foreach(_dep ${_IBPF_PRIVATE_DEPENDENCIES})
          string(APPEND PACKAGE_DEPENDENCIES "find_dependency(${_dep})\n")
        endforeach()
      endif()

    endif()

    set(PACKAGE_DEPENDENCIES "${PACKAGE_DEPENDENCIES}\n###############################################################################\n")
  endif()

  # Prepare PACKAGE_VERSION variable
  set(PACKAGE_VERSION ${_IBPF_VERSION})

  # <Name>Config.cmake (build tree)
  foreach(p ${_build_path_vars_suffix})
    if(DEFINED ${_IBPF_VARS_PREFIX}_BUILD_${p})
      set(${_IBPF_VARS_PREFIX}_${p} "${${_IBPF_VARS_PREFIX}_BUILD_${p}}")
    elseif(DEFINED BUILD_${_IBPF_VARS_PREFIX}_${p})
      set(${_IBPF_VARS_PREFIX}_${p} "${BUILD_${_IBPF_VARS_PREFIX}_${p}}")
    endif()
  endforeach()
  configure_package_config_file("${_config_cmake_in}"
                                "${_IBPF_EXPORT_DESTINATION}/${_config_filename}"
                                INSTALL_DESTINATION ${_IBPF_EXPORT_DESTINATION}
                                PATH_VARS ${_build_path_vars}
                                ${configure_package_config_file_extra_args}
                                INSTALL_PREFIX ${CMAKE_BINARY_DIR})

  # <Name>Config.cmake (installed)
  foreach(p ${_install_path_vars_suffix})
    if(DEFINED ${_IBPF_VARS_PREFIX}_INSTALL_${p})
      set(${_IBPF_VARS_PREFIX}_${p} "${${_IBPF_VARS_PREFIX}_INSTALL_${p}}")
    elseif(DEFINED INSTALL_${_IBPF_VARS_PREFIX}_${p})
      set(${_IBPF_VARS_PREFIX}_${p} "${INSTALL_${_IBPF_VARS_PREFIX}_${p}}")
    endif()
  endforeach()
  configure_package_config_file("${_config_cmake_in}"
                                "${CMAKE_CURRENT_BINARY_DIR}/${_config_filename}.install"
                                INSTALL_DESTINATION ${_IBPF_INSTALL_DESTINATION}
                                PATH_VARS ${_install_path_vars}
                                ${configure_package_config_file_extra_args})
  install(FILES "${CMAKE_CURRENT_BINARY_DIR}/${_config_filename}.install"
          DESTINATION ${_IBPF_INSTALL_DESTINATION}
          RENAME ${_config_filename}
          COMPONENT ${_IBPF_COMPONENT})


  # <Name>Targets.cmake (build tree)
  export(${_export_cmd}
         NAMESPACE ${_IBPF_NAMESPACE}
         FILE "${_IBPF_EXPORT_DESTINATION}/${_targets_filename}")

  # <Name>Targets.cmake (installed)
  install(${_install_cmd}
          NAMESPACE ${_IBPF_NAMESPACE}
          DESTINATION ${_IBPF_INSTALL_DESTINATION}
          FILE "${_targets_filename}"
          COMPONENT ${_IBPF_COMPONENT})
endfunction()
