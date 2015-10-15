#!/bin/bash

cd "$(dirname $0)"

title="Cordova-Plugin-$(basename "$(cd ../../; pwd)")"

echo "################################"
echo "#### Generate Xcodeproject"

echo "Project Name: $title"

cat <<EOF | ruby
require 'xcodeproj'

def build_settings(project, params)
    project.targets.each do |target|
        target.build_configurations.each do |conf|
            params.each do |key, value|
                conf.build_settings[key] = value
            end
        end
    end
end

project_name = "$title"
project = Xcodeproj::Project.new "#{project_name}.xcodeproj"

target = project.new_target(:framework, 'GeneratedProduct', :ios)
project.recreate_user_schemes

group = project.new_group "Sources"

sources = Dir.glob("src/*.swift").map { |path| group.new_file(path) }
header = Dir.glob("src/*.h").map { |path| group.new_file(path) }.first

target.add_file_references(sources)

build_settings(project,
  "ENABLE_BITCODE" => "NO",
  "SWIFT_OBJC_BRIDGING_HEADER" => header.path
)

project.save
EOF

echo "################################"
echo "#### pod install"

cat <<EOF > Podfile
platform :ios, "8.0"

pod "Cordova"
pod "Fabric"
pod "Crashlytics"
EOF

pod install