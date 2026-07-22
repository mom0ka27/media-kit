// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let libmpvTargets = [
    "Ass",
    "Avcodec",
    "Avfilter",
    "Avformat",
    "Avutil",
    "Dav1d",
    "Freetype",
    "Fribidi",
    "Harfbuzz",
    "Mpv",
    "Png16",
    "Swresample",
    "Swscale",
    "Uchardet",
    "Xml2"
]

let libmpvArtifactBase = "https://github.com/mom0ka27/libmpv-darwin-build/releases/download/v0.8.1/libmpv-xcframeworks_v0.8.1_ios-universal-video-full"
let libmpvChecksums = [
    "Ass": "4588e8dee23b66164d05de0eafa0c0c8bfbcbd00a79347e9d9975bf86dcb0087",
    "Avcodec": "ec303b211724e86123ad666c77070cfb4f54f8a3b54200b1a17db59fd60f4611",
    "Avfilter": "fdc47b77af6bfc682fa1e88424ea59de6d8bcf782242a430a7598d284f520b6e",
    "Avformat": "85597343c8594f6843d3415f0f881d3228d2951ac55cd1f785dd60737ead1c10",
    "Avutil": "150f58d9fac7337d237e49ecda94aff1926a185ddd380f48e91acc2eb7fd4095",
    "Dav1d": "8eaf1abaefba8ef8d8d9b35ec219413f1aec2eabb21e98e770a036c1f9f1af7e",
    "Freetype": "d9df186a9c01cbd40a52988c29f81192050e16b6cb380702ad4266be17b5eab4",
    "Fribidi": "35850a749eddeee182b904fae51c1aeec9d421abbe331d8d179be672e39d4ab1",
    "Harfbuzz": "3c0f140c5aee1edb65608728dc31b016ba7091eca723e9047e9d299a6ae712b1",
    "Mpv": "89bbfd6ada650e91aefd4ded11e130fbc9e1239bb9cdbdbf5d7202da2fd865f3",
    "Png16": "fec3b652e327a577db2ed729308457b8a288fa9160ebe5a9c4317c4ddecefffd",
    "Swresample": "7a9b923408f47d5fce59f78aab0909d96d6d034c2db7cb8ab0f6d969b869818b",
    "Swscale": "f8458324708784ec1b168a8dd5e2c1c8b67b94f1776c8eff19daecddf1aeea76",
    "Uchardet": "f80a4f2c179226c52eacf4090fd3eec870e1acacb0a56459eb71ad72b945a738",
    "Xml2": "f0db06575fc7bf2cf6ca5f2d6f25c5cd690554f4f119c3ad34344afcfa0d58e1"
]
let libmpvProductTargets: [String] = ["media_kit_libs_ios_video"] + libmpvTargets

let package = Package(
    name: "media_kit_libs_ios_video",
    platforms: [
        .iOS("9.0")
    ],
    products: [
        .library(name: "media-kit-libs-ios-video", targets: libmpvProductTargets),
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
            name: "media_kit_libs_ios_video",
            dependencies: libmpvTargets.map { framework in .target(name: framework) },
            resources: [
                .process("PrivacyInfo.xcprivacy")
            ]
        )
    ]
)
