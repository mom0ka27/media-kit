// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let libmpvTargets = [
    "Avcodec",
    "Avfilter",
    "Avformat",
    "Avutil",
    "Mbedcrypto",
    "Mbedtls",
    "Mbedx509",
    "Mpv",
    "Swresample",
    "Swscale"
]

let libmpvArtifactBase = "https://github.com/mom0ka27/libmpv-darwin-build/releases/download/v0.8.1/libmpv-xcframeworks_v0.8.1_ios-universal-audio-default"
let libmpvChecksums = [
    "Avcodec": "5a4f53a474d20268f4ef3e4eee3ae37bce881ed33d0a07cb1b3ef6308c0c090c",
    "Avfilter": "ef6dde47fa8e41eb5ad85419a5ef70b44716cd1182fedf752faff353da7eea15",
    "Avformat": "f7367140eff680b6678af9598513f8a4b1b368a17ea95c20e5de0c97e65d759f",
    "Avutil": "f508661ef1acaf3b6fc457e3297311444c975ab41962479e7807949eea59c7c2",
    "Mbedcrypto": "553856aa92dcaf36dd18465fb104840d078a6239330c5bfdf227ed372e95837b",
    "Mbedtls": "1454d2637ad631b376654ad16b698a5e79205052842b28e4bd525e003b75f3eb",
    "Mbedx509": "da78a7f46fd3ad573899ea319afe8139c90eeff93bd02374627899e2334e7d12",
    "Mpv": "c1c319ea84f88183ffce4893d69cf1e0c59fd829eec5574473c5acf63e846f1d",
    "Swresample": "ee040ffdcd3618aa57a1e33159832a774bf07dec12e478750328274e4148ee27",
    "Swscale": "05450e27368d99249a625288bebb046b960747740992891293fb1bdf122700c8"
]

let package = Package(
    name: "media_kit_libs_ios_audio",
    platforms: [
        .iOS("9.0")
    ],
    products: [
        .library(name: "media-kit-libs-ios-audio", targets: ["media_kit_libs_ios_audio"] + libmpvTargets),
        .library(name: "Mpv", targets: ["Mpv"])
    ],
    dependencies: [],
    targets: libmpvTargets.map { framework in
        .binaryTarget(
            name: framework,
            url: "\(libmpvArtifactBase)_\(framework).zip",
            checksum: libmpvChecksums[framework]!
        )
    } + [
        .target(
            name: "media_kit_libs_ios_audio",
            dependencies: libmpvTargets.map { framework in .target(name: framework) },
            resources: [
                .process("PrivacyInfo.xcprivacy")
            ]
        )
    ]
)
