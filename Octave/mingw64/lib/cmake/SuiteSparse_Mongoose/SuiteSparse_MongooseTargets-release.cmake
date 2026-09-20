#----------------------------------------------------------------
# Generated CMake target import file for configuration "Release".
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "SuiteSparse::Mongoose" for configuration "Release"
set_property(TARGET SuiteSparse::Mongoose APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(SuiteSparse::Mongoose PROPERTIES
  IMPORTED_IMPLIB_RELEASE "${_IMPORT_PREFIX}/lib/libsuitesparse_mongoose.dll.a"
  IMPORTED_LINK_DEPENDENT_LIBRARIES_RELEASE "SuiteSparse::SuiteSparseConfig"
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/bin/libsuitesparse_mongoose.dll"
  )

list(APPEND _cmake_import_check_targets SuiteSparse::Mongoose )
list(APPEND _cmake_import_check_files_for_SuiteSparse::Mongoose "${_IMPORT_PREFIX}/lib/libsuitesparse_mongoose.dll.a" "${_IMPORT_PREFIX}/bin/libsuitesparse_mongoose.dll" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
