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

if(ANDROID)
set(communicator_SRCS
    main.cpp
    models/contacts/contactsmodel.cpp
    models/contacts/calllogs.cpp
    interfaces/androidinterface.cpp
    interfaces/contactimage.cpp
    )

set(communicator_HDRS
    models/contacts/contactsmodel.h
    models/contacts/calllogs.h
    interfaces/abstractinterface.h
    interfaces/androidinterface.h
    interfaces/contactimage.h
    )

else()
    set(communicator_SRCS
        main.cpp
        models/contacts/contactsmodel.cpp
        models/contacts/calllogs.cpp
        interfaces/linuxinterface.cpp
        interfaces/contactimage.cpp
        )

    set(communicator_HDRS
        models/contacts/contactsmodel.h
        models/contacts/calllogs.h
        interfaces/abstractinterface.h
        interfaces/linuxinterface.h
        interfaces/contactimage.h
        )
endif()

set(communicator_ASSETS
    qml.qrc
    assets/communicator_assets.qrc
    )

if(ANDROID)
    add_library(${PROJECT_NAME} SHARED
        ${communicator_SRCS}
        ${communicator_HDRS}
        ${communicator_ASSETS}
        )
else()
    add_executable(${PROJECT_NAME}
        ${communicator_SRCS}
        ${communicator_HDRS}
        ${communicator_ASSETS}
        )
endif()

target_compile_definitions(${PROJECT_NAME}
  PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>)

target_link_libraries(${PROJECT_NAME} MauiKit Qt5::Sql Qt5::Qml Qt5::Svg Qt5::Xml Qt5::Concurrent Qt5::QuickControls2 Qt5::Positioning KF5::I18n)

if(ANDROID)
    target_link_libraries(${PROJECT_NAME} Qt5::AndroidExtras)
#    kde_source_files_enable_exceptions(pix pix.cpp)
else()
    target_link_libraries(${PROJECT_NAME} KF5::Contacts KF5::People)
endif()


if(UNIX AND NOT APPLE AND NOT ANDROID)
install(FILES assets/communicator.svg DESTINATION ${KDE_INSTALL_ICONDIR}/hicolor/scalable/apps)
endif()


