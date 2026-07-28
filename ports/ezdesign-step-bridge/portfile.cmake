set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO yordaa/ezdesign-step-bridge
    REF "v${VERSION}"
    SHA512 5b2faf2d2867bb9f406d80a31be9cd5b8457874d62887ae01a6696a1864e674d901360ec3ac4f2cf89236e26afca87af5ad575c3ad02741708ac3d3d93ae4ef3
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
)
vcpkg_cmake_install()
vcpkg_copy_tools(TOOL_NAMES ezd2step AUTO_CLEAN)
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
