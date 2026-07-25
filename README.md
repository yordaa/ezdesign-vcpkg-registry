# ezdesign-vcpkg-registry

Private vcpkg Git registry for the prebuilt `ezd2step` tool. This repository
contains only registry metadata, ports, CI, and a consumer example—no product
source or release binaries.

The public
[`yordaa/ezdesign-step-bridge`](https://github.com/yordaa/ezdesign-step-bridge)
repository owns ezd2step source versions, release tags, and release assets.

## Consume ezd2step

Copy [`examples/consumer/vcpkg.json`](examples/consumer/vcpkg.json) and
[`examples/consumer/vcpkg-configuration.json`](examples/consumer/vcpkg-configuration.json)
into a project. Because this registry is private, authenticate Git first:

```sh
gh auth setup-git
vcpkg install --triplet arm64-osx
```

Use `x64-windows` on Windows. The installed executable and its runtime
libraries are under `vcpkg_installed/<triplet>/tools/ezd2step`.

## Update

Publish and verify the immutable source release assets first. Then update the
port, commit it, run `vcpkg x-add-version`, verify the generated git-tree, and
commit the versions database. The source release tag is the product version
authority.
