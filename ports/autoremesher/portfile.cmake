set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
if(VCPKG_TARGET_IS_OSX)
    set(VCPKG_FIXUP_MACHO_RPATH OFF)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO yordaa/autoremesher
    REF d70bffcd9756a4c07674f1bedb2c0541044c7d81
    SHA512 877c2d4e3590a4772160be3e187cd1705d473fd9412f42b033d906fa2ee0e6dddd9e97ca369f11ec2dd64c327d113b892561ebf9564201182461defdb999da45
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
