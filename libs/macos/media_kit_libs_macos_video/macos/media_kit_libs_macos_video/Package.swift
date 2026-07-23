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

let libmpvArtifactBase = "https://github.com/mom0ka27/libmpv-darwin-build/releases/download/v0.8.1/libmpv-xcframeworks_v0.8.1_macos-universal-video-full"
let libmpvChecksums = [
    "Ass": "1a4dde8f884afe3a0b952c986e90f0639f90dabb08fb262076ae5ad70ff3e0c1",
    "Avcodec": "88635af0d9b2423ff29e0ed69a944f9611a207100d6c39d0bc9f67854774ded8",
    "Avfilter": "4346580750929c28b06f76e9468fa2038e90dcdfadd2adb60f566910abb15910",
    "Avformat": "59f8cff80d20f49a37d6da53157dcb89dac901001e40b5d08882edc1ca4ab659",
    "Avutil": "0206768cc0767612bc42250078fe6af49229b372d0620a3a5f8e47fa38e3766b",
    "Dav1d": "a26e6a8344f35ae367883312355a898785bce4155a09b93bc7ca72487d694a60",
    "Freetype": "8c0057d5c273c9ec81d805492da8d20bb7211ea63e2dc991e7c2956587ba4d2c",
    "Fribidi": "f19b8c0073fe0fe48dea41b45bca7eb3c1b45ddfb48af7dd916a803600f04629",
    "Harfbuzz": "86d599d3530bebda2307874b2a363bdd139011d93186b5ada94cfa88bf1b9f9f",
    "Mpv": "6fa8efaa276a5938ef542457fe1a4316de41c91fa2ff5654c56ffa3d67b38779",
    "Png16": "88d43e69f292aabc1fc1f0a88fa13e6bfec7224f1611139af8c50734cd850dbd",
    "Swresample": "826b0b9e388160d826161623efc99fdca248c7b397461641e3913ad5b8fdd20e",
    "Swscale": "eed9df851f258120a4f1f6566c4942b2deef64e8dc18a8e8fbf935fb7dac041b",
    "Uchardet": "b0b4def7b8c9670d5f740c37b529c5b27828aa4082181e69c65f1a60ca0ca2e1",
    "Xml2": "9a731cdd1a345ea19dbb1299d2adb0b940dc629c87f8d95861263d5044320493"
]
let libmpvProductTargets: [String] = ["media_kit_libs_macos_video"] + libmpvTargets

let package = Package(
    name: "media_kit_libs_macos_video",
    platforms: [
        .macOS("10.9")
    ],
    products: [
        .library(name: "media-kit-libs-macos-video", targets: libmpvProductTargets),
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
            name: "media_kit_libs_macos_video",
            dependencies: libmpvTargets.map { framework in .target(name: framework) },
            resources: [
                .process("PrivacyInfo.xcprivacy")
            ]
        )
    ]
)
