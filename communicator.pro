QT += qml
QT += quick
QT += sql
QT += concurrent

CONFIG += ordered
CONFIG += c++17

TARGET = contacts
TEMPLATE = app

VERSION_MAJOR = 1
VERSION_MINOR = 0
VERSION_BUILD = 0

VERSION = $${VERSION_MAJOR}.$${VERSION_MINOR}.$${VERSION_BUILD}

DEFINES += CONTACTS_VERSION_STRING=\\\"$$VERSION\\\"

linux:unix:!android {

    message(Building for Linux KDE)
    QT += KService KNotifications KNotifications KI18n KContacts
    QT += KIOCore KIOFileWidgets KIOWidgets KNTLM
    LIBS += -lMauiKit

#    SOURCES += src/interfaces/kcontactsinterface.cpp
#    HEADERS += src/interfaces/kcontactsinterface.h

} else:android {

    message(Building helpers for Android)
    QMAKE_LINK += -nostdlib++
    ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android_files

   DISTFILES += \
$$PWD/android_files/AndroidManifest.xml

    QT += androidextras

    DEFINES *= \
        COMPONENT_FM \
        COMPONENT_ACCOUNTS \
        COMPONENT_TAGGING \
        COMPONENT_EDITOR \
        MAUIKIT_STYLE \
        ANDROID_OPENSSL

    include($$PWD/3rdparty/kirigami/kirigami.pri)
    include($$PWD/3rdparty/mauikit/mauikit.pri)

    DEFINES += STATIC_KIRIGAMI

} else {
    message("Unknown configuration")
}

DEPENDPATH += \
    $$PWD/src/interfaces \
    $$PWD/src/models \
    $$PWD/src/models/contacts

INCLUDEPATH += \
    $$PWD/src/interfaces \
    $$PWD/src/models \
    $$PWD/src/models/contacts

SOURCES += \
    $$PWD/src/main.cpp \
    $$PWD/src/interfaces/androidinterface.cpp \
    $$PWD/src/interfaces/contactimage.cpp \
    $$PWD/src/models/contacts/calllogs.cpp \
    $$PWD/src/models/contacts/contactsmodel.cpp \

RESOURCES += \
    $$PWD/src/qml.qrc \
    $$PWD/assets/contacts_assets.qrc

HEADERS += \
     $$PWD/src/union.h \
    $$PWD/src/interfaces/androidinterface.h \
     $$PWD/src/models/contacts/contactsmodel.h \
     $$PWD/src/models/contacts/calllogs.h \
     $$PWD/src/interfaces/abstractinterface.h \
     $$PWD/src/interfaces/contactimage.h


qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target


