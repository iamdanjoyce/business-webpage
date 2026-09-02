#!/usr/bin/env ruby
# frozen_string_literal: true
#
# Bootstrap generator for MyApp.xcodeproj.
#
# This exists only so the project can be recreated without Xcode's "New Project"
# assistant. Once you open MyApp.xcodeproj in Xcode, Xcode owns the project file
# and you normally will not need this script again.
#
# Requires the `xcodeproj` gem:
#   gem install xcodeproj --user-install
#
# Usage (from the repo root):
#   ruby scripts/generate_xcodeproj.rb

require "fileutils"
require "xcodeproj"

ROOT = File.expand_path("..", __dir__)
PROJECT_PATH = File.join(ROOT, "MyApp.xcodeproj")
APP_NAME = "MyApp"
BUNDLE_ID = "com.example.MyApp"
DEPLOYMENT_TARGET = "17.0"
SWIFT_VERSION = "5.0"

FileUtils.rm_rf(PROJECT_PATH)
project = Xcodeproj::Project.new(PROJECT_PATH)

# Project-level build configurations.
%w[Debug Release].each do |name|
  project.add_build_configuration(name, name == "Debug" ? :debug : :release)
end

shared_settings = {
  "SWIFT_VERSION" => SWIFT_VERSION,
  "IPHONEOS_DEPLOYMENT_TARGET" => DEPLOYMENT_TARGET,
  "SDKROOT" => "iphoneos",
  "ALWAYS_SEARCH_USER_PATHS" => "NO",
  "CLANG_ENABLE_MODULES" => "YES",
  "CLANG_ENABLE_OBJC_ARC" => "YES",
  "ENABLE_STRICT_OBJC_MSGSEND" => "YES",
  "GCC_NO_COMMON_BLOCKS" => "YES",
}
project.build_configurations.each do |config|
  config.build_settings.merge!(shared_settings)
  config.build_settings["ONLY_ACTIVE_ARCH"] = "YES" if config.name == "Debug"
  config.build_settings["SWIFT_OPTIMIZATION_LEVEL"] = "-Onone" if config.name == "Debug"
end

# ---------------------------------------------------------------------------
# App target
# ---------------------------------------------------------------------------
app_target = project.new_target(:application, APP_NAME, :ios, DEPLOYMENT_TARGET)
# `new_target` auto-links a version-pinned Foundation.framework from the active
# SDK. SwiftUI/Foundation link implicitly, and the pinned path breaks on a
# different SDK, so start from an empty Frameworks phase.
app_target.frameworks_build_phase.clear

app_group = project.main_group.new_group(APP_NAME, APP_NAME)
%w[MyAppApp.swift ContentView.swift].each do |name|
  app_target.add_file_references([app_group.new_reference(name)])
end
app_target.add_resources([app_group.new_reference("Assets.xcassets")])
app_target.add_resources([app_group.new_reference("Preview Content/Preview Assets.xcassets")])

app_common = {
  "PRODUCT_NAME" => "$(TARGET_NAME)",
  "PRODUCT_BUNDLE_IDENTIFIER" => BUNDLE_ID,
  "MARKETING_VERSION" => "1.0",
  "CURRENT_PROJECT_VERSION" => "1",
  "GENERATE_INFOPLIST_FILE" => "YES",
  "INFOPLIST_KEY_UIApplicationSceneManifest_Generation" => "YES",
  "INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents" => "YES",
  "INFOPLIST_KEY_UILaunchScreen_Generation" => "YES",
  "INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad" =>
    "UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown " \
    "UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight",
  "INFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone" =>
    "UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft " \
    "UIInterfaceOrientationLandscapeRight",
  "SWIFT_EMIT_LOC_STRINGS" => "YES",
  "ENABLE_PREVIEWS" => "YES",
  "DEVELOPMENT_ASSET_PATHS" => "\"MyApp/Preview Content\"",
  "ASSETCATALOG_COMPILER_APPICON_NAME" => "AppIcon",
  "ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME" => "AccentColor",
  "TARGETED_DEVICE_FAMILY" => "1,2",
  "CODE_SIGN_STYLE" => "Automatic",
  "LD_RUNPATH_SEARCH_PATHS" => "$(inherited) @executable_path/Frameworks",
}
app_target.build_configurations.each do |config|
  config.build_settings.merge!(app_common)
end

# ---------------------------------------------------------------------------
# Unit test target
# ---------------------------------------------------------------------------
test_target = project.new_target(:unit_test_bundle, "#{APP_NAME}Tests", :ios, DEPLOYMENT_TARGET)
test_target.frameworks_build_phase.clear
test_group = project.main_group.new_group("#{APP_NAME}Tests", "#{APP_NAME}Tests")
test_target.add_file_references([test_group.new_reference("#{APP_NAME}Tests.swift")])
test_target.add_dependency(app_target)

test_common = {
  "PRODUCT_NAME" => "$(TARGET_NAME)",
  "PRODUCT_BUNDLE_IDENTIFIER" => "#{BUNDLE_ID}.Tests",
  "GENERATE_INFOPLIST_FILE" => "YES",
  "TEST_HOST" =>
    "$(BUILT_PRODUCTS_DIR)/#{APP_NAME}.app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/#{APP_NAME}",
  "BUNDLE_LOADER" => "$(TEST_HOST)",
  "SWIFT_EMIT_LOC_STRINGS" => "NO",
  "LD_RUNPATH_SEARCH_PATHS" =>
    "$(inherited) @executable_path/Frameworks @loader_path/Frameworks",
}
test_target.build_configurations.each do |config|
  config.build_settings.merge!(test_common)
end

# Drop the auto-added Foundation.framework file reference (and the now-empty
# "Frameworks" group) that `new_target` leaves behind after clearing the phase.
project.files.select { |f| f.path.to_s.end_with?("Foundation.framework") }.each(&:remove_from_project)
if (frameworks_group = project.main_group["Frameworks"]) && frameworks_group.children.empty?
  frameworks_group.remove_from_project
end

project.save

# ---------------------------------------------------------------------------
# Shared scheme so the app is runnable straight after opening the project.
# ---------------------------------------------------------------------------
scheme = Xcodeproj::XCScheme.new
scheme.add_build_target(app_target)
scheme.set_launch_target(app_target)
scheme.add_test_target(test_target)
scheme.save_as(PROJECT_PATH, APP_NAME, true)

puts "Generated #{PROJECT_PATH}"
