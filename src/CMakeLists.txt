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

set(communicator_ASSETS
    assets/communicator_assets.qrc)

qt_add_resources(communicator_QML_QRC qml.qrc)

if(ANDROID)
    add_library(${PROJECT_NAME} SHARED
        ${communicator_SRCS}
        ${communicator_android_SRCS}
        ${communicator_HDRS}
        ${communicator_ASSETS}
        ${communicator_QML_QRC})
else()
    add_executable(${PROJECT_NAME}
        ${communicator_SRCS}
        ${communicator_linux_SRCS}
        ${communicator_HDRS}
        ${communicator_ASSETS}
        ${communicator_QML_QRC})
endif()

target_compile_definitions(${PROJECT_NAME}
    PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>)

target_link_libraries(${PROJECT_NAME}
    MauiKit4
    MauiKit4::FileBrowsing
    Qt6::QuickControls2
    Qt6::Qml
    Qt6::Concurrent
    KF6::I18n
    KF6::Service
    KF6::KIOCore KF6::KIOFileWidgets KF6::KIOWidgets)

if(ANDROID)
    target_link_libraries(${PROJECT_NAME}
    Qt6::AndroidExtras 
    Qt6::Xml)
    kde_source_files_enable_exceptions(${PROJECT_NAME} interfaces/androidinterface.cpp)
else()
    target_link_libraries(${PROJECT_NAME} 
    KF6::Contacts 
    KF6::People 
    Qt6::Widgets)
endif()

if(UNIX AND NOT APPLE AND NOT ANDROID)
    install(FILES assets/communicator.svg DESTINATION ${KDE_INSTALL_ICONDIR}/hicolor/scalable/apps)
endif()


