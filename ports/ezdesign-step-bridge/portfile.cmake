set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO yordaa/ezdesign-step-bridge
    REF "v${VERSION}"
    SHA512 f182cc0875c04004b80350c26cbcf5fbba71a7e7244dec304d14404c4fee9a900f974a5effeb27e5fb91c2f0fc2457a2a11f179607234ee46916835cdba383fa
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
)
vcpkg_cmake_install()
vcpkg_copy_tools(TOOL_NAMES ezd2step AUTO_CLEAN)
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
