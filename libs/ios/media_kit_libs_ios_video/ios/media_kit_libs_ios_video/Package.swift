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
    "Mbedcrypto",
    "Mbedtls",
    "Mbedx509",
    "Mpv",
    "Png16",
    "Swresample",
    "Swscale",
    "Uchardet",
    "Xml2"
]

let libmpvArtifactBase = "https://github.com/mom0ka27/libmpv-darwin-build/releases/download/v0.8.0/libmpv-xcframeworks_v0.8.0_ios-universal-video-full"
let libmpvChecksums = [
    "Ass": "65b41ae7a3329e9e3a2ad47c81c96cb9bd2dd954df6e2e4795383c7e5aa88903",
    "Avcodec": "2f1fd91fa2a326336609f2d716be7dd78da96af9aca829a8dbb680cf830ca2d7",
    "Avfilter": "c87280e889f7b963b429dfdb23ddf25692b911b3b84c4f65561071ea04d7bab0",
    "Avformat": "18663a6bbe6bbd45b6215d28fa23309cf241d039366d42b09a64c1ab1f6bbee1",
    "Avutil": "ad32decdd05a398efdb0eb3499240c4bd4ca40eb3df5ffa90f56d339629f6df0",
    "Dav1d": "573301668fe7da7e5eccaa2dacdeec16cec114d27d1989066d350f9a36c203a2",
    "Freetype": "dfadec574d8b1754d48ea17e0bb8887d66d63bd2cc3706e1129930c309dbde0f",
    "Fribidi": "80d8407e83208431b1cae7be27fa64c29a1b7cf5b730f47c32a7a8bb7a1fe9d4",
    "Harfbuzz": "399ab762aa5d0340cc9037ab51d0bef0e71f03428ef136208f2e6a6587204877",
    "Mbedcrypto": "d1fc5b2ea028950c8738223a8e7c8e442c2028c4f5d985eba8b6900de77a5d9c",
    "Mbedtls": "8421cc33e8c5a49c0a52ae4060be42294d316bb6f4eb24402b7baa9f99aa0899",
    "Mbedx509": "8bfb9e317baaed7cae9e1a5f2a99163547ff09461b92b67e0fdede785e9af792",
    "Mpv": "d86e98450211ca870fb1335c2bbe8f1dd4de5ba52ee1d62a4d210c134f33cdba",
    "Png16": "0d68602048f23253b4e1713929db91e1132da51526df9e638864b80e22d1c799",
    "Swresample": "3d84aea6ee2e21fe91000d6c66004b3139211055b57bc1f58739186415b28d24",
    "Swscale": "4bbdb2486f3b1c49c2c33273acde09ffd01a75aa053a8e99d2663fd1667383ed",
    "Uchardet": "2383bf059e2c5b3d3f4fa8920839827a709db58368cd7d472d8f7340ad5fc4ce",
    "Xml2": "7a674fcc76ed5dea7056c1c3d89a6669beb1c3d55f5beb29b014b33e33c1ad59"
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
