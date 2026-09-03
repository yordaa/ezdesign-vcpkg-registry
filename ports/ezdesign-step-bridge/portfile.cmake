set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO yordaa/ezdesign-step-bridge
    REF "v${VERSION}"
    SHA512 739a66d6b3efd9044fb27f7a519dc066206d899d0a7e36f43723156f5fa8aa1dd754a28c968435542b633f64b7b89d6df74c4c7b4885e1ddeedfac311138a3d4
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
)
vcpkg_cmake_install()
vcpkg_copy_tools(TOOL_NAMES ezd2step AUTO_CLEAN)
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
