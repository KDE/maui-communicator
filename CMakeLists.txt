# Copyright 2018-2020 Camilo Higuita <milo.h@aol.com>
# Copyright 2018-2020 Nitrux Latinoamericana S.C.
#
# SPDX-License-Identifier: GPL-3.0-or-latercmake_minimum_required(VERSION 3.14)

cmake_minimum_required(VERSION 3.16)

set(COMMUNICATOR_VERSION 4.0.0)
add_compile_definitions(APP_COPYRIGHT_NOTICE="© 2019-2024 Maui Development Team")

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

project(communicator VERSION ${COMMUNICATOR_VERSION})

set(QT_MAJOR_VERSION 6)

set(REQUIRED_QT_VERSION 6.5.2)
set(REQUIRED_KF_VERSION 5.240.0)

if(ANDROID)
    set(ANDROID_PACKAGE_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/android_files)
    set(ANDROID_ABIS "armeabi-v7a")
    configure_file(${CMAKE_CURRENT_SOURCE_DIR}/android_files/version.gradle.in ${CMAKE_BINARY_DIR}/version.gradle)
endif()

find_package(ECM ${REQUIRED_KF_VERSION} REQUIRED NO_MODULE)

set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake" ${ECM_MODULE_PATH})

find_package(Qt6 ${REQUIRED_QT_VERSION} REQUIRED NO_MODULE COMPONENTS Qml Quick QuickControls2 Concurrent)

find_package(KF6 ${REQUIRED_KF_VERSION} REQUIRED COMPONENTS I18n KIO CoreAddons Service)

find_package(MauiKit4 REQUIRED COMPONENTS FileBrowsing)

if(ANDROID)
    find_package(Qt6 ${REQUIRED_QT_VERSION} REQUIRED NO_MODULE COMPONENTS AndroidExtras Xml)
elseif(UNIX)
    find_package(KF6 ${REQUIRED_KF_VERSION} REQUIRED COMPONENTS Contacts People)
    find_package(Qt6 ${REQUIRED_QT_VERSION} REQUIRED NO_MODULE COMPONENTS Widgets)
endif()

if(UNIX AND NOT APPLE AND NOT ANDROID)
    include(KDEInstallDirs)
    include(KDECMakeSettings)
    include(ECMInstallIcons)
    include(ECMAddAppIcon)
endif()

include(KDECompilerSettings NO_POLICY_SCOPE)
include(KDEClangFormat)
include(ECMSetupVersion)
include(ECMSourceVersionControl)
include(FeatureSummary)

if(${ECM_SOURCE_UNDER_VERSION_CONTROL})
    execute_process(
        COMMAND git rev-parse --abbrev-ref HEAD
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        OUTPUT_VARIABLE GIT_BRANCH
        OUTPUT_STRIP_TRAILING_WHITESPACE)

    # Get the latest abbreviated commit hash of the working branch
    execute_process(
        COMMAND git log -1 --format=%h
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        OUTPUT_VARIABLE GIT_COMMIT_HASH
        OUTPUT_STRIP_TRAILING_WHITESPACE)

    add_definitions(-DGIT_COMMIT_HASH="${GIT_COMMIT_HASH}")
    add_definitions(-DGIT_BRANCH="${GIT_BRANCH}")

else()
    add_definitions(-DGIT_COMMIT_HASH="${COMMUNICATOR_VERSION}")
    add_definitions(-DGIT_BRANCH="Stable")
endif()

ecm_setup_version(${COMMUNICATOR_VERSION}
    VARIABLE_PREFIX COMMUNICATOR
    VERSION_HEADER "${CMAKE_CURRENT_BINARY_DIR}/communicator_version.h")

add_subdirectory(src)

ki18n_install(po)

if(UNIX AND NOT APPLE AND NOT ANDROID)
    install(TARGETS ${PROJECT_NAME} ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
    install(FILES org.kde.communicator.desktop DESTINATION ${KDE_INSTALL_APPDIR})
    install(FILES org.kde.communicator.json DESTINATION /usr/share/maui-accounts/manifests)
    install(FILES org.kde.communicator.appdata.xml DESTINATION ${KDE_INSTALL_METAINFODIR})
endif()

feature_summary(WHAT ALL FATAL_ON_MISSING_REQUIRED_PACKAGES)

file(GLOB_RECURSE ALL_CLANG_FORMAT_SOURCE_FILES *.cpp *.h)
kde_clang_format(${ALL_CLANG_FORMAT_SOURCE_FILES})
