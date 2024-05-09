# Copyright (c) Meta Platforms, Inc. and affiliates.
#
# This source code is licensed under both the MIT license found in the
# LICENSE-MIT file in the root directory of this source tree and the Apache
# License, Version 2.0 found in the LICENSE-APACHE file in the root directory
# of this source tree.

load("@shim//build_defs:prebuilt_cpp_library.bzl", "prebuilt_cpp_library")

def homebrew_library(
        package_name,
        name = None,
        default_target_platform = "prelude//platforms:default",
        visibility = ["PUBLIC"],
        deps = None,
        header_path = None):
    brew_headers = package_name + "__brew_headers"

    # @lint-ignore BUCKLINT
    native.genrule(
        name = brew_headers,
        default_target_platform = default_target_platform,
        out = "out",
        cmd = "cp -r `brew --prefix {}`/{} $OUT || echo Looks like you need to run: brew install {}".format(package_name, header_path or "include", package_name),
        labels = ["homebrew-package:{}".format(package_name)],
    )

    prebuilt_cpp_library(
        name = name or package_name,
        default_target_platform = default_target_platform,
        visibility = visibility,
        header_dirs = [":{}".format(brew_headers)],
        header_only = True,
        exported_deps = deps,
    )

def third_party_library(name, visibility = ["PUBLIC"], deps = [], homebrew_package_name = None, homebrew_header_path = None):
    homebrew_library(name = name, package_name = homebrew_package_name or name, visibility = visibility, deps = deps, header_path = homebrew_header_path)
