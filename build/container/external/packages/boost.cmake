
#
# Config
#

# See http://www.boost.org/users/download/#history
set(Boost_VERSION 1.62.0)
set(Boost_VERSION_FILE 1_62_0)
set(Boost_URL https://sourceforge.net/projects/boost/files/boost/${Boost_VERSION}/boost_${Boost_VERSION_FILE}.tar.bz2)
set(Boost_URL_SHA256 36c96b0f6155c98404091d8ceb48319a28279ca0333fba1ad8611eb90afb2ca0)
set(Boost_COMPONENTS thread system regex random program_options date_time iostreams)

message(STATUS "External: Building Boost ${Boost_VERSION} COMPONENTS ${Boost_COMPONENTS}")

#
# Build
#

string(REPLACE ";" "," Boost_BUILD_COMPONENTS "${Boost_COMPONENTS}")

# set the toolchain
set(toolset "")
if("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
  set(toolset "gcc")
  file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/user-config.jam"
    "using gcc : : \"${CMAKE_CXX_COMPILER}\" ; \n")
else()
  message(FATAL_ERROR "Unknown compiler ${CMAKE_CXX_COMPILER_ID}.")
endif()

set(Boost_CFLAGS "-fPIC -O2")
set(Boost_VERBOSE_ARGS -d+2 --debug-configuration)

ExternalProject_Add(boost
  PREFIX ${EXTERNAL_ROOT}

  URL ${Boost_URL}
  URL_HASH SHA256=${Boost_URL_SHA256}

  DOWNLOAD_DIR ${EXTERNAL_DOWNLOAD_DIR}
  BUILD_IN_SOURCE 1

  PATCH_COMMAND ${CMAKE_COMMAND} -E copy "${CMAKE_CURRENT_BINARY_DIR}/user-config.jam" "<SOURCE_DIR>/tools/build/src/user-config.jam"
  CONFIGURE_COMMAND ./bootstrap.sh --prefix=<INSTALL_DIR> --libdir=<INSTALL_DIR>/lib/${EXTERNAL_CROSS_TRIPLE} --with-libraries=${Boost_BUILD_COMPONENTS}
  BUILD_COMMAND true
  INSTALL_COMMAND ./b2
    ${Boost_VERBOSE_ARGS}
    -j ${EXTERNAL_PARALLEL_LEVEL}
    toolset=${toolset}
    variant=release
    link=static
    threading=multi
    "include=<INSTALL_DIR>/include"
    "linkflags=-L<INSTALL_DIR>/lib/${EXTERNAL_CROSS_TRIPLE}"
    cxxflags=${Boost_CFLAGS}
    install

  LOG_DOWNLOAD ${EXTERNAL_LOGGING}
  LOG_PATCH ${EXTERNAL_LOGGING}
  LOG_CONFIGURE ${EXTERNAL_LOGGING}
  LOG_BUILD ${EXTERNAL_LOGGING}
  LOG_INSTALL ${EXTERNAL_LOGGING})
