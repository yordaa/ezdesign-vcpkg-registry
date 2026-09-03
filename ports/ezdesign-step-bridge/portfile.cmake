set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO yordaa/ezdesign-step-bridge
    REF "v${VERSION}"
    SHA512 98e3bd447d18a420b2684a01519b95340deab84c3e9b34454272c94dcc23bcb3d33dc013eeb262785cc94858f75e045c0db0a5fff7fc4b54bc2d6d12bcdd8e69
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
)
vcpkg_cmake_install()
vcpkg_copy_tools(TOOL_NAMES ezd2step AUTO_CLEAN)
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
