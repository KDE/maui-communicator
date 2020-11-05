cmake_minimum_required(VERSION 3.1)
set(COMMUNICATOR_VERSION 1.2.0)
project(communicator LANGUAGES CXX VERSION ${COMMUNICATOR_VERSION})

set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(ECM 1.7.0 REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake" ${ECM_MODULE_PATH})

find_package(MauiKit REQUIRED)
find_package(Qt5 REQUIRED NO_MODULE COMPONENTS Qml Quick Sql Svg QuickControls2 Widgets Concurrent)
include(KDEInstallDirs)
include(KDECompilerSettings NO_POLICY_SCOPE)
include(KDECMakeSettings)
include(ECMInstallIcons)
include(ECMAddAppIcon)
include(ECMSetupVersion)
include(FeatureSummary)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}/src/interfaces
    ${CMAKE_CURRENT_BINARY_DIR}/src/interfaces

    ${CMAKE_CURRENT_SOURCE_DIR}/src/models
    ${CMAKE_CURRENT_BINARY_DIR}/src/models

    ${CMAKE_CURRENT_BINARY_DIR}/src/models/contacts
    ${CMAKE_CURRENT_BINARY_DIR}/src/models/contacts
    )

set(communicator_SRCS
    src/main.cpp
    src/models/contacts/contactsmodel.cpp
    src/models/contacts/calllogs.cpp
    src/interfaces/linuxinterface.cpp
    src/interfaces/contactimage.cpp
    )

set(communicator_HDRS
    src/models/contacts/contactsmodel.h
    src/models/contacts/calllogs.h
    src/interfaces/abstractinterface.h
    src/interfaces/linuxinterface.h
    src/interfaces/contactimage.h
    )

set(communicator_ASSETS
    src/qml.qrc
    assets/communicator_assets.qrc
    )

add_executable(${PROJECT_NAME}
    ${communicator_SRCS}
    ${communicator_HDRS}
    ${communicator_ASSETS}
    )

ecm_setup_version(${COMMUNICATOR_VERSION}
    VARIABLE_PREFIX COMMUNICATOR
    VERSION_HEADER "${CMAKE_CURRENT_BINARY_DIR}/communicator_version.h"
    )

if (ANDROID)
    find_package(Qt5 REQUIRED COMPONENTS AndroidExtras)

    target_link_libraries(${PROJECT_NAME} Qt5::AndroidExtras)
    #    kde_source_files_enable_exceptions(union src/pix.cpp)
elseif(${CMAKE_SYSTEM_PROCESSOR} MATCHES "arm")
add_subdirectory(src/communicator/linux)
else()
    find_package(KF5 ${KF5_VERSION} REQUIRED COMPONENTS I18n Notifications Config KIO Attica Contacts People SyntaxHighlighting)

    target_link_libraries(${PROJECT_NAME} KF5::ConfigCore KF5::Notifications KF5::KIOCore KF5::I18n KF5::Attica KF5::Contacts KF5::People)
endif()

if (TARGET create-apk-communicator)
    set_target_properties(create-apk-communicator PROPERTIES ANDROID_APK_DIR "${MAUIKIT_ANDROID_DIR}")
endif()

target_link_libraries(${PROJECT_NAME} MauiKit Qt5::Sql Qt5::Qml Qt5::Widgets Qt5::Svg Qt5::Concurrent Qt5::Quick)

install(TARGETS ${PROJECT_NAME} ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
install(FILES org.maui.communicator.desktop DESTINATION ${XDG_APPS_INSTALL_DIR})

#TODO: port to ecm_install_icons()
install(FILES assets/communicator.svg DESTINATION ${KDE_INSTALL_ICONDIR}/hicolor/scalable/apps)
install(FILES org.maui.communicator.json DESTINATION /usr/share/maui-accounts/manifests)
#install(FILES org.kde.pix.appdata.xml DESTINATION ${KDE_INSTALL_METAINFODIR})

feature_summary(WHAT ALL   FATAL_ON_MISSING_REQUIRED_PACKAGES)
