# ezdesign-vcpkg-registry

Public vcpkg Git registry for the source-built `ezdesign-step-bridge` package.
It installs the `ezd2step` command-line tool and its minimal dynamic OCCT
runtime closure.

The custom `opencascade` port starts from `TKDESTEP` and lets OCCT compute its
23-toolkit transitive closure. It supports only release-only dynamic builds for
macOS arm64 and Windows x64.

The
[`yordaa/ezdesign-step-bridge`](https://github.com/yordaa/ezdesign-step-bridge)
repository owns the proprietary bridge source, versions, and immutable tags.

## Consume ezdesign-step-bridge

Copy [`examples/consumer/vcpkg.json`](examples/consumer/vcpkg.json) and
[`examples/consumer/vcpkg-configuration.json`](examples/consumer/vcpkg-configuration.json)
into a project. Copy the matching file from [`triplets`](triplets), then install:

```sh
vcpkg install \
  --triplet arm64-osx-release \
  --overlay-triplets /path/to/triplets
```

Use `x64-windows-release` on Windows. The executable is installed under
`vcpkg_installed/<triplet>/tools/ezdesign-step-bridge`.

## Update

Publish and verify the immutable bridge source tag first. Then update the port,
commit it, run `vcpkg x-add-version`, verify the generated git tree, and commit
the versions database. The source tag is the product version authority.
