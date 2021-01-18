#include <QCommandLineParser>
#include <QIcon>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#ifdef Q_OS_ANDROID
#include <QGuiApplication>
#include <QIcon>
#else
#include <QApplication>
#endif

#include <MauiKit/mauiapp.h>
#include <KI18n/KLocalizedString>

#include "contactimage.h"
#include "contacts/calllogs.h"
#include "contacts/contactsmodel.h"

#include "../communicator_version.h"

#define COMMUNICATOR_URI "org.maui.communicator"

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QCoreApplication::setAttribute(Qt::AA_DontCreateNativeWidgetSiblings);
    QCoreApplication::setAttribute(Qt::AA_UseHighDpiPixmaps, true);
    QCoreApplication::setAttribute(Qt::AA_DisableSessionManager, true);

#ifdef Q_OS_ANDROID
    QGuiApplication app(argc, argv);
    if (!MAUIAndroid::checkRunTimePermissions({"android.permission.WRITE_EXTERNAL_STORAGE",
                                               "android.permission.READ_CALL_LOG",
                                               "android.permission.SEND_SMS",
                                               "android.permission.CALL_PHONE",
                                               "android.permission.MANAGE_ACCOUNTS",
                                               "android.permission.GET_ACCOUNTS",
                                               "android.permission.READ_CONTACTS"}))
        return -1;
#else
    QApplication app(argc, argv);
#endif

    app.setOrganizationName(QStringLiteral("Maui"));
    app.setWindowIcon(QIcon("://communicator.svg"));
    MauiApp::instance()->setHandleAccounts(false); // for now index can not handle cloud accounts
    MauiApp::instance()->setIconName("qrc:/communicator.svg");

    KLocalizedString::setApplicationDomain("communicator");
    KAboutData about(
        QStringLiteral("communicator"), i18n("Communicator"), COMMUNICATOR_VERSION_STRING, i18n("Communicator keeps your contacts synced and organized across devices."), KAboutLicense::LGPL_V3, i18n("© 2019-%1 Nitrux Development Team", QString::number(QDate::currentDate().year())));
    about.addAuthor(i18n("Camilo Higuita"), i18n("Developer"), QStringLiteral("milo.h@aol.com"));
    about.setHomepage("https://mauikit.org");
    about.setProductName("maui/communicator");
    about.setBugAddress("https://invent.kde.org/maui/communicator/-/issues");
    about.setOrganizationDomain(COMMUNICATOR_URI);
    about.setProgramLogo(app.windowIcon());

    KAboutData::setApplicationData(about);

    QCommandLineParser parser;
    parser.process(app);

    about.setupCommandLine(&parser);
    about.processCommandLine(&parser);

    QQmlApplicationEngine engine;

    engine.addImageProvider("contact", new ContactImage(QQuickImageProvider::ImageType::Image));
    qmlRegisterType<ContactsModel>(COMMUNICATOR_URI, 1, 0, "ContactsList");
    qmlRegisterType<CallLogs>(COMMUNICATOR_URI, 1, 0, "CallLogs");

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
