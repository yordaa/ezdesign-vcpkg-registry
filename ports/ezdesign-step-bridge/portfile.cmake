set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO yordaa/ezdesign-step-bridge
    REF "v${VERSION}"
    SHA512 8d45c06418c69bbfc4e989a2182608a720c1d6785774dcce917feb04f9fe72bc7baa068cc30ceb0749f0809ecc1f7410f72ea30ecaf6ae2f984d2210f54fa927
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
)
vcpkg_cmake_install()
vcpkg_copy_tools(TOOL_NAMES ezd2step AUTO_CLEAN)
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
