set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
if(VCPKG_TARGET_IS_OSX)
    set(VCPKG_FIXUP_MACHO_RPATH OFF)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO yordaa/autoremesher
    REF 839935676754d5a5074c1554f46ce3a3f42ac4e4
    SHA512 baadc94b39b512d595d9526a112b5b20e3bd403adf15cf2e774124f667d191a0dc4764fde895353f95c381b1bd7ae3dbe82f233199789241be8326c0544b6967
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DAUTOREMESHER_USE_BUNDLED_TBB=OFF
        -DBUILD_TESTING=OFF
)
vcpkg_cmake_install()
vcpkg_copy_tools(TOOL_NAMES autoremesher-cli AUTO_CLEAN)

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
