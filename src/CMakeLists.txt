# Copyright 2018-2020 Camilo Higuita <milo.h@aol.com>
# Copyright 2018-2020 Nitrux Latinoamericana S.C.
#
# SPDX-License-Identifier: GPL-3.0-or-later

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}/interfaces
    ${CMAKE_CURRENT_BINARY_DIR}/interfaces

    ${CMAKE_CURRENT_SOURCE_DIR}/models
    ${CMAKE_CURRENT_BINARY_DIR}/models

    ${CMAKE_CURRENT_BINARY_DIR}/models/contacts
    ${CMAKE_CURRENT_BINARY_DIR}/models/contacts
    )

set(communicator_SRCS
    main.cpp
    models/contacts/contactsmodel.cpp
    interfaces/contactimage.cpp
    communicator.cpp
    )

set(communicator_HDRS
    models/contacts/contactsmodel.h
    interfaces/abstractinterface.h
    interfaces/contactimage.h
    communicator.h
    )

if(ANDROID)
    set(communicator_android_SRCS
        interfaces/androidinterface.cpp
        )

    set(communicator_android_HDRS
        interfaces/androidinterface.h
        )
else()
    set(communicator_linux_SRCS
        interfaces/linuxinterface.cpp
        )

    set(communicator_linux_HDRS
        interfaces/linuxinterface.h
        )
endif()

set(communicator_ASSETS
    assets/communicator_assets.qrc
    )

if(QUICK_COMPILER)
    qtquick_compiler_add_resources(communicator_QML_QRC qml.qrc)
else()
    qt5_add_resources(communicator_QML_QRC qml.qrc)
endif()

if(ANDROID)
    add_library(${PROJECT_NAME} SHARED
        ${communicator_SRCS}
        ${communicator_android_SRCS}
        ${communicator_HDRS}
        ${communicator_ASSETS}
        ${communicator_QML_QRC}
        )
else()
    add_executable(${PROJECT_NAME}
        ${communicator_SRCS}
        ${communicator_linux_SRCS}
        ${communicator_HDRS}
        ${communicator_ASSETS}
        ${communicator_QML_QRC}
        )
endif()

target_compile_definitions(${PROJECT_NAME}
  PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>)

target_link_libraries(${PROJECT_NAME} MauiKit MauiKit::FileBrowsing Qt5::QuickControls2 Qt5::Qml Qt5::Concurrent KF5::I18n KF5::Service)

if(ANDROID)
    target_link_libraries(${PROJECT_NAME} Qt5::AndroidExtras Qt5::Xml)
    kde_source_files_enable_exceptions(${PROJECT_NAME} interfaces/androidinterface.cpp)
else()
    target_link_libraries(${PROJECT_NAME} KF5::Contacts KF5::People Qt5::Widgets)
endif()

if(UNIX AND NOT APPLE AND NOT ANDROID)
install(FILES assets/communicator.svg DESTINATION ${KDE_INSTALL_ICONDIR}/hicolor/scalable/apps)
endif()


