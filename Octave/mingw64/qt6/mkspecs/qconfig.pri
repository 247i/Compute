host_build {
    QT_ARCH = x86_64
    QT_BUILDABI = x86_64-little_endian-lp64
    QT_TARGET_ARCH = x86_64
    QT_TARGET_BUILDABI = x86_64-little_endian-lp64
} else {
    QT_ARCH = x86_64
    QT_BUILDABI = x86_64-little_endian-lp64
    QT_LIBCPP_ABI_TAG = 
}
QT.global.enabled_features = shared cross_compile pkg-config signaling_nan zstd thread future concurrent shared cross_compile shared reduce_exports
QT.global.disabled_features = static debug_and_release separate_debug_info appstore-compliant simulator_and_device rpath force_asserts framework c++20 c++2a c++2b reduce_relocations wasm-simd128 wasm-exceptions dbus openssl-linked opensslv11 opensslv30
QT.global.disabled_features += release build_all
QT_CONFIG += shared reduce_exports release
CONFIG += release  shared cross_compile plugin_manifest
QT_VERSION = 6.7.3
QT_MAJOR_VERSION = 6
QT_MINOR_VERSION = 7
QT_PATCH_VERSION = 3

QT_GCC_MAJOR_VERSION = 15
QT_GCC_MINOR_VERSION = 2
QT_GCC_PATCH_VERSION = 0
