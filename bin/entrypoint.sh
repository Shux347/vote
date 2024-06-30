#!/bin/bash

# Ensure the Dart SDK is in the PATH
export PATH=$PATH:/app/dart-sdk/bin

# Ensure PUBSPEC_PATH is set
export PUBSPEC_PATH=${PUBSPEC_PATH:-/app/pubspec.yaml}

# Run pub get using the specified pubspec.yaml
pub get --directory=${PUBSPEC_PATH%/*}

# Run your Dart application
dart main.dart
