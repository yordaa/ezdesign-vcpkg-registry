set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
if(VCPKG_TARGET_IS_OSX)
    set(VCPKG_FIXUP_MACHO_RPATH OFF)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO yordaa/autoremesher
    REF a91a191f16e4c25c36acd5285d0861c18067190c
    SHA512 9cb56534a2248e46c37823d1070a661ff95fc970cfccd22d3b8dec2892e07d29c3df3d9dea431b6950e56bcc8372dcd4526cf533ae273173ac2fa4f56fa48c81
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
