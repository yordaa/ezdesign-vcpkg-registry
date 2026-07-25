set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
set(VCPKG_POLICY_MISMATCHED_NUMBER_OF_BINARIES enabled)

if(VCPKG_TARGET_IS_OSX AND VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
    set(platform macos-arm64)
    set(extension tar.gz)
    set(sha512 81c7ef4b38a90cae4e969b4be311fa0b1f22fedd42d98a79c50c01531f0980356ee53f25a8dfe8d93be67f447336a8c08bed4b1be47f130ce1845b9512b1b748)
elseif(VCPKG_TARGET_IS_WINDOWS AND VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(platform windows-x64)
    set(extension zip)
    set(sha512 65110277deb38d3bf2f47cfff4a41a017e5fdd2561e1776fda8d5f2dcd875f86024fd2a1cfcab2f8fe7a96eeb8d970d8b54d078764e088c35381eaaf4f1070fa)
else()
    message(FATAL_ERROR "ezd2step supports only macOS arm64 and Windows x64")
endif()

set(archive_name "ezd2step-${VERSION}-${platform}")
vcpkg_download_distfile(archive
    URLS "https://github.com/yordaa/ezdesign-step-bridge/releases/download/v${VERSION}/${archive_name}.${extension}"
    FILENAME "${archive_name}.${extension}"
    SHA512 "${sha512}"
)
vcpkg_extract_source_archive(source_path ARCHIVE "${archive}")

file(INSTALL "${source_path}/" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/ezd2step")
file(INSTALL "${CURRENT_PORT_DIR}/copyright"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
)
