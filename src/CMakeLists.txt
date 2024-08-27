# Copyright 2018-2020 Camilo Higuita <milo.h@aol.com>
# Copyright 2018-2020 Nitrux Latinoamericana S.C.
#
# SPDX-License-Identifier: GPL-3.0-or-later

remove_definitions(-DQT_NO_CAST_FROM_ASCII -DQT_STRICT_ITERATORS -DQT_NO_CAST_FROM_BYTEARRAY -DQT_NO_URL_CAST_FROM_STRING)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}/interfaces
    ${CMAKE_CURRENT_BINARY_DIR}/interfaces

    ${CMAKE_CURRENT_SOURCE_DIR}/models
    ${CMAKE_CURRENT_BINARY_DIR}/models

    ${CMAKE_CURRENT_BINARY_DIR}/models/contacts
    ${CMAKE_CURRENT_BINARY_DIR}/models/contacts)

set(communicator_SRCS
    main.cpp
    models/contacts/contactsmodel.cpp
    interfaces/contactimage.cpp
    communicator.cpp)

set(communicator_HDRS
    models/contacts/contactsmodel.h
    interfaces/abstractinterface.h
    interfaces/contactimage.h
    communicator.h)

if(ANDROID)
    set(communicator_android_SRCS
        interfaces/androidinterface.cpp)

    set(communicator_android_HDRS
        interfaces/androidinterface.h)
else()
    set(communicator_linux_SRCS
        interfaces/linuxinterface.cpp)

    set(communicator_linux_HDRS
        interfaces/linuxinterface.h)
endif()

qt_add_resources(communicator_ASSETS
    assets/communicator_assets.qrc)

if(ANDROID)
    qt_add_executable(${PROJECT_NAME}
        MANUAL_FINALIZATION
        ${communicator_SRCS}
        ${communicator_android_SRCS}
        ${communicator_HDRS}
        ${communicator_ASSETS})

    set_property(TARGET ${PROJECT_NAME} APPEND PROPERTY QT_ANDROID_PACKAGE_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/android_files)
    configure_file(${CMAKE_CURRENT_SOURCE_DIR}/android_files/version.gradle.in ${CMAKE_BINARY_DIR}/src/version.gradle)
else()
    qt_add_executable(${PROJECT_NAME}
        ${communicator_SRCS}
        ${communicator_linux_SRCS}
        ${communicator_HDRS}
        ${communicator_ASSETS})
endif()

qt_add_qml_module(${PROJECT_NAME} URI app.maui.communicator
    NO_PLUGIN
    QML_FILES
    main.qml
    views/contacts/ContactsView.qml
    views/contacts/ContactDelegate.qml
    views/contacts/ContactPage.qml
    widgets/MessageComposer.qml
    views/contacts/GridContactDelegate.qml
    views/contacts/ContactField.qml)

target_compile_definitions(${PROJECT_NAME}
    PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>)

target_link_libraries(${PROJECT_NAME}
    PRIVATE
    MauiKit4
    MauiKit4::FileBrowsing
    Qt6::QuickControls2
    Qt6::Qml
    Qt6::Concurrent
    KF6::I18n
    KF6::Service
    KF6::KIOCore
    # KF6::KIOFileWidgets
    #[[KF6::KIOWidgets]])

if(ANDROID)
    target_link_libraries(${PROJECT_NAME}
        PRIVATE
        Qt6::Multimedia
        Qt6::Sql
        Qt6::Xml)
    kde_source_files_enable_exceptions(${PROJECT_NAME} interfaces/androidinterface.cpp)
else()
    target_link_libraries(${PROJECT_NAME}
        PRIVATE
        KF6::Contacts
        KF6::People
        Qt6::Widgets)
endif()

if(UNIX AND NOT APPLE AND NOT ANDROID)
    install(FILES assets/communicator.svg DESTINATION ${KDE_INSTALL_ICONDIR}/hicolor/scalable/apps)
endif()

qt_finalize_target(${PROJECT_NAME})
