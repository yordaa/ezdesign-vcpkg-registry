set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
if(VCPKG_TARGET_IS_OSX)
    set(VCPKG_FIXUP_MACHO_RPATH OFF)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO yordaa/autoremesher
    REF 4e935e02eec2096fcb0bb6bcfd22dfa00a5b4620
    SHA512 ef172d4823fe7a3bd22f1b4f976023b63392b1b4cd63baf5666321b967f1b7e5791b1811d0ebe773f06f6492e2829e59845bd0a53e4ae4f697f02e21c3bedb18
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DAUTOREMESHER_USE_BUNDLED_TBB=OFF
        -DBUILD_TESTING=OFF
)
vcpkg_cmake_install()
vcpkg_copy_tools(TOOL_NAMES autoremesher-cli AUTO_CLEAN)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

if(VCPKG_TARGET_IS_OSX)
    file(GLOB TBB_RUNTIME "${CURRENT_INSTALLED_DIR}/lib/libtbb.*dylib")
    file(COPY ${TBB_RUNTIME}
        DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}"
        FOLLOW_SYMLINK_CHAIN)
endif()

vcpkg_install_copyright(FILE_LIST
    "${SOURCE_PATH}/LICENSE"
    "${SOURCE_PATH}/thirdparty/isotropicremesher/LICENSE"
    "${SOURCE_PATH}/thirdparty/tbb/LICENSE"
    "${SOURCE_PATH}/thirdparty/tinyobjloader/LICENSE"
    "${SOURCE_PATH}/thirdparty/eigen/COPYING.APACHE"
    "${SOURCE_PATH}/thirdparty/eigen/COPYING.BSD"
    "${SOURCE_PATH}/thirdparty/eigen/COPYING.MINPACK"
    "${SOURCE_PATH}/thirdparty/eigen/COPYING.MPL2"
    "${SOURCE_PATH}/thirdparty/eigen/COPYING.README"
)
