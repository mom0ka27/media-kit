// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let libmpvTargets = [
    "Avcodec",
    "Avfilter",
    "Avformat",
    "Avutil",
    "Mpv",
    "Swresample",
    "Swscale"
]

let libmpvArtifactBase = "https://github.com/mom0ka27/libmpv-darwin-build/releases/download/v0.8.1/libmpv-xcframeworks_v0.8.1_macos-universal-audio-full"
let libmpvChecksums = [
    "Avcodec": "f7590fb24fc8f57a952ad0a5987880d64aa14563174e35945291b1bfba802a71",
    "Avfilter": "5bf14d74f74f7ad47d9e27b23d2f6d46caf64824ebc4d02d7ddc3db4a6b35edd",
    "Avformat": "7a122c5a92f0b0b3a43ad73d5dd6eabfc157d3e5896ccc3909c9f5d2b66bb206",
    "Avutil": "69675decdf46ae88fb340d61e7a060ce6e2b12e1b2917086309bcd9a72206a68",
    "Mpv": "aa369d938e47fdddc2c5b74ef4cce36b2e90e51c517ba915724ff857f26e4476",
    "Swresample": "f747b33e68c3c5c9d74bb378b273cdbbdbc6093bfd241eac3312d09a473abed5",
    "Swscale": "1799ab33851e204eee4786bff79839c905d699d1eab40016e29645afc72ee381"
]

let package = Package(
    name: "media_kit_libs_macos_audio",
    platforms: [
        .macOS("10.9")
    ],
    products: [
        .library(name: "media-kit-libs-macos-audio", targets: ["media_kit_libs_macos_audio"] + libmpvTargets),
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
            name: "media_kit_libs_macos_audio",
            dependencies: libmpvTargets.map { framework in .target(name: framework) },
            resources: [
                .process("PrivacyInfo.xcprivacy")
            ]
        )
    ]
)
