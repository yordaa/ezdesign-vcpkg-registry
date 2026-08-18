# Static or Dynamic Linking for Cross-Platform macOS Desktop Apps?

Research date: 2026-08-18. The primary scope is 2021–2026, using only first-party material from Apple, Qt, Electron, Flutter, Microsoft/vcpkg, and OCCT. Older Apple Mach-O documentation is used only to explain underlying mechanisms that remain applicable.

## Conclusion

The macOS best practice is not “all static” or “all dynamic.” It is a layered, hybrid approach:

1. **Dynamically link Apple system libraries and frameworks.** This is not an optional optimization. Apple DTS states that third-party programs must use the system dynamic linker; a fully static executable that bypasses system libraries and depends directly on the system-call ABI is not supported on Apple platforms ([Apple Library Primer, Apple DTS, accessed 2026-08-18](https://developer.apple.com/forums/thread/715385)).
2. **Choose the boundary for private third-party dependencies.** A leaf library with no plugin ABI and only one final executable consumer can be linked statically. A library needed for plugins, shared by several executables or helpers, or subject to a user-replacement licensing requirement is normally shipped as a private dynamic library or framework inside the app.
3. **Do not install private dylibs into system locations.** Ship them in the self-contained `.app`, under `Contents/Frameworks`, and load them through relative `@rpath` paths. Sign every nested code object correctly. Apple assigns macOS frameworks and dynamic libraries to `Contents/Frameworks` ([Placing content in a bundle, accessed 2026-08-18](https://developer.apple.com/documentation/bundleresources/placing-content-in-a-bundle)); Qt likewise states that third-party libraries are normally bundled per application rather than installed system-wide ([Qt for macOS 6.11, accessed 2026-08-18](https://doc.qt.io/qt-6/macos.html)).
4. **Do not switch based on performance intuition alone.** Apple’s 2022 guidance is to find the static/dynamic “sweet spot”: too many static libraries slow iterative linking, while too many dynamic libraries slow launch ([WWDC22: Link fast](https://developer.apple.com/videos/play/wwdc2022/110362/)). Measure app size, cold launch, and memory before changing the boundary.

For the current EzDesign registry, **keeping OCCT release-only and dynamically linked is the safer minimal choice**. Do not switch OCCT to static merely to pursue a “single file”; that trades a deployment problem for licensing, relinking, and build complexity. AutoRemesher/TBB could theoretically be made static independently, but there is currently no evidence that justifies a mixed-linkage triplet.

## Three questions that are easy to conflate

| Layer | Actual choice | Conclusion |
|---|---|---|
| System runtime, libSystem, AppKit, and similar frameworks | Whether the app can be completely static | No; Apple system dynamic libraries and frameworks are loaded through `dyld` |
| Application modules and third-party C/C++ libraries | Merge a `.a` into an executable or ship a `.dylib`/framework | Project-specific; a hybrid is normal |
| Distribution artifact | One Mach-O or a self-contained `.app` | A macOS app is normally distributed as an `.app` bundle; multiple internal files still appear to the user as one application |

The vcpkg default is not an Apple platform recommendation. Microsoft documents that the default `x64-osx` triplet produces static libraries and that dynamic macOS/Linux builds require an overlay triplet, while Windows defaults to dynamic libraries ([Using Overlay Triplets, accessed 2026-08-18](https://learn.microsoft.com/en-us/vcpkg/users/examples/overlay-triplets-linux-dynamic)). These are vcpkg preset policies, not an industry verdict on the architecture of a final `.app`.

## The real tradeoffs

| Concern | Static third-party library | Private dynamic library/framework in the app |
|---|---|---|
| Deployment | Fewer final Mach-O files; the app cannot fail because this particular runtime library was omitted | The complete transitive dependency closure must be copied, with correct install names and `@rpath` values |
| User installation experience | A `.app` is already a single Finder entity, so the advantage is smaller than for a loose Windows executable | Still a single self-contained `.app`, with no system-wide installation required |
| Launch | Fewer images to load, which normally helps launch | `dyld` must discover, map, fix up, and initialize every image; too many dylibs can slow launch |
| Build iteration | Apple notes that rebuilding static archives increases I/O, and ordered archive processing limits linker parallelism | Final executable linking is faster and module boundaries are clearer; some cost moves to launch time |
| File size and memory | The linker can select only the needed archive objects, but the same code is duplicated if linked into several executables | Several processes can share read-only physical pages from the same dylib; every dylib also introduces its own data pages and loading cost |
| Plugins | Must be included explicitly at build time and cannot provide a genuinely replaceable runtime module | `dlopen` and frameworks are natural boundaries for plugins and optional modules |
| ABI | No runtime ABI mismatch between the application and that library; upgrades require relinking the application | ABI, architecture, and minimum OS version must be managed; a missing or incompatible library can cause `dyld` to terminate the app at launch |
| Updates | A library fix requires rebuilding and releasing the application | **An app-private dylib still cannot be casually replaced in place**: modifying a signed bundle breaks its signature, so the normal approach is still a new signed application release |
| Security | Reduces private dynamic-load paths but does not remove the dependency on the system dynamic linker | Hardened Runtime library validation restricts loadable code by default; third-party plugins may require a security exception |
| Licensing | Some LGPL cases require object files or relinking material; “static” must not be assumed to eliminate obligations | Often makes a user-replacement or relinking requirement easier to satisfy, but every license still needs individual review |

The performance details come from Apple’s [WWDC22: Link fast](https://developer.apple.com/videos/play/wwdc2022/110362/): dynamic libraries can shorten static link time and let processes share physical pages, but they add launch-time linking and dirty pages. Apple does not specify a universal threshold. In 2023 Apple introduced mergeable libraries, allowing Debug builds to retain dynamic-linking iteration speed while Release builds approach static-linking launch behavior ([WWDC23: Meet mergeable libraries](https://developer.apple.com/videos/play/wwdc2023/10268/) and [Xcode configuration documentation](https://developer.apple.com/documentation/xcode/configuring-your-project-to-use-mergeable-libraries)). This is an Apple/Xcode option and should not be assumed to apply automatically to ordinary vcpkg/CMake dylibs.

## Evidence from cross-platform frameworks during the last five years

### Qt 6

Qt 6.11 officially supports both static and shared/framework deployment, but its binary distribution provides shared libraries. Qt documents the tradeoffs as follows: static deployment has fewer files, but larger executables, requires redeployment for upgrades, and cannot deploy runtime plugins; shared libraries suit plugins and sharing among multiple programs ([Deploying Qt Applications 6.11](https://doc.qt.io/qt-6/deployment.html)). The macOS documentation describes the standard artifact as a self-contained `.app` containing dependencies, plugins, and resources. It provides `macdeployqt` to copy private frameworks, rewrite paths, sign code, and prepare for notarization ([Qt for macOS - Deployment 6.11](https://doc.qt.io/qt-6/macos-deployment.html)).

This shows that a mature cross-platform C++ framework does not require static linking on macOS. Its default distribution and full plugin model favor private dynamic dependencies inside the app; static linking is a supported alternative with explicit constraints.

### Electron

Electron’s official distribution flow produces an `.app` containing its runtime, frameworks/helpers, and application resources. Its directory example places helpers under `Contents/Frameworks` and recommends Electron Forge for packaging ([Electron Application Packaging, accessed 2026-08-18](https://www.electronjs.org/docs/latest/tutorial/application-distribution/)). Electron also requires production macOS releases to be signed and notarized ([Electron Code Signing](https://www.electronjs.org/docs/latest/tutorial/code-signing)).

Electron is not a direct analogy for a C++ leaf library, but it is strong evidence that a cross-platform desktop app containing several private dynamic components is a normal, well-supported macOS distribution shape. Everything does not need to be compressed into one Mach-O file.

### Flutter

Flutter’s current macOS documentation similarly treats an Xcode-produced `.app` as the standard artifact and requires Hardened Runtime, signing, and notarization for distribution outside the Mac App Store ([Building macOS apps with Flutter, last updated 2026-07-21](https://docs.flutter.dev/platform-integration/macos/building)). It does not publish static-versus-dynamic adoption data, so it supports the standard bundle and signing model but cannot establish that Flutter applications generally choose a particular C++ linkage.

## Signing, notarization, rpath, and plugins

Dynamic linking is maintainable on macOS only when the platform structure is respected:

- Apple assigns embedded dylibs and frameworks to `Contents/Frameworks`; third-party libraries should use rpath-relative install names. Apple’s current examples use `@executable_path` and `@rpath` to correct nonstandard runtime paths ([Embedding nonstandard code structures in a bundle](https://developer.apple.com/documentation/xcode/embedding-nonstandard-code-structures-in-a-bundle)).
- An application with an incorrectly embedded dynamic dependency fails during launch. Apple’s representative error is `dependent dylib '@rpath/…' not found` ([Addressing missing framework crashes](https://developer.apple.com/documentation/xcode/addressing-missing-framework-crashes)).
- Notarization requires valid signatures on distributed executables and Hardened Runtime ([Notarizing macOS software before distribution](https://developer.apple.com/documentation/security/notarizing-macos-software-before-distribution)). The signature covers nested libraries and frameworks, and modifying bundle contents breaks the seal ([Understanding the Code Signature, Apple archive](https://developer.apple.com/library/archive/documentation/Security/Conceptual/CodeSigningGuide/AboutCS/AboutCS.html)).
- Hardened Runtime enables library validation by default: a process can load only code signed by Apple or by the same Team ID as the main program. Consider `com.apple.security.cs.disable-library-validation` only when loading plugins from other developers is essential; Apple notes that disabling it triggers additional Gatekeeper checks ([Disable Library Validation Entitlement](https://developer.apple.com/documentation/BundleResources/Entitlements/com.apple.security.cs.disable-library-validation)).

The best practice for dynamic linking is therefore not “put dylibs next to the executable.” It is to embed the audited dependency closure in the bundle, load it with relative paths, sign nested code before signing and notarizing the final artifact, and keep library validation enabled where possible.

## Guidance for EzDesign

The registry builds `ezd2step`, AutoRemesher, and OCCT; the final product is responsible for packaging them into the macOS `.app`. Based on the current code and the evidence above:

1. **Keep OCCT dynamic.** `ezd2step` is a proprietary bridge, while OCCT uses LGPL-2.1 with an additional exception. OCCT’s guidance specifically requires a proprietary application to let users run it with a modified OCCT; static linking or a distribution channel that prevents replacement requires additional material and care ([OCCT official wiki: License](https://github.com/Open-Cascade-SAS/OCCT/wiki)). The header exception addresses material from headers; it is not a blanket waiver of static-linking obligations ([OCCT_LGPL_EXCEPTION.txt](https://github.com/Open-Cascade-SAS/OCCT/blob/master/OCCT_LGPL_EXCEPTION.txt)). Dynamic OCCT is the lower-risk engineering boundary, although final compliance should still be reviewed by qualified counsel.
2. **Do not make AutoRemesher/TBB static merely to achieve a theoretical single file.** It might remove a small number of runtime libraries, but it would introduce per-port mixed-linkage configuration. There is no measured launch, package-size, or missing-library problem to justify that complexity.
3. **Treat registry triplets as dependency-build policy, not final packaging policy.** The final EzDesign consumer should place CLIs/helpers and required dylibs in Apple’s prescribed locations, correct `@rpath`, and complete signing and notarization.
4. **The current CI proves installation, dynamic linkage, and functional execution, not release quality.** It runs tools directly from `vcpkg_installed`; it does not prove that the final `.app` passes Gatekeeper, signature validation, and notarization on a clean Mac. That release check belongs in the final consumer repository, not as a duplicate packaging system in this registry.

Reconsider this decision only if one of three conditions appears: measurements show that the dylib count causes a material cold-launch regression; signing or rpath failures become an ongoing maintenance cost; or the product explicitly requires a standalone CLI file and its licensing approach has been resolved. Without that evidence, the current dynamic approach is the smaller change and fits established macOS distribution practice.

## What the evidence can and cannot establish

**Supported conclusion:** Apple supports and specifies private dynamic frameworks and dylibs inside an app; a completely static macOS program is not the supported distribution model; Apple’s toolchain guidance during the last five years balances build speed, launch speed, plugins, and module sharing; and the official Qt and Electron deployment paths show that self-contained `.app` bundles with dynamic components are a first-class, common shape.

**Unsupported conclusion:** Apple and the major cross-platform frameworks do not publish first-party adoption statistics split by static or dynamic linkage. It is therefore not rigorous to claim that a particular percentage of macOS applications, or every C++ leaf dependency, uses one form. The defensible best practice is to choose at each boundary and verify the final distribution, rather than set one global switch.
