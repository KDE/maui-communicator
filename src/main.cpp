#include <QCommandLineParser>
#include <QIcon>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QDate>

#ifdef Q_OS_ANDROID
#include <QGuiApplication>
#include <MauiKit3/Core/mauiandroid.h>
#else
#include <QApplication>
#endif

#include <MauiKit3/Core/mauiapp.h>
#include <KI18n/KLocalizedString>

#include "contactimage.h"
#include "contacts/contactsmodel.h"
#include "communicator.h"

#include "../communicator_version.h"

#define COMMUNICATOR_URI "org.maui.communicator"

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QCoreApplication::setAttribute(Qt::AA_UseHighDpiPixmaps, true);

#if defined Q_OS_ANDROID
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

    qDebug() << "APP LOADING SPEED TESTS" << 1;

    app.setOrganizationName(QStringLiteral("Maui"));
    app.setWindowIcon(QIcon("://communicator.svg"));

    KLocalizedString::setApplicationDomain("communicator");
    KAboutData about(
        QStringLiteral("communicator"), i18n("Communicator"), COMMUNICATOR_VERSION_STRING, i18n("Organize and sync your contacts."), KAboutLicense::LGPL_V3, i18n("© 2019-%1 Nitrux Development Team", QString::number(QDate::currentDate().year())), QString(GIT_BRANCH) + "/" + QString(GIT_COMMIT_HASH));
    about.addAuthor(i18n("Camilo Higuita"), i18n("Developer"), QStringLiteral("milo.h@aol.com"));
    about.setHomepage("https://mauikit.org");
    about.setProductName("maui/communicator");
    about.setBugAddress("https://invent.kde.org/maui/communicator/-/issues");
    about.setOrganizationDomain(COMMUNICATOR_URI);
    about.setProgramLogo(app.windowIcon());

    KAboutData::setApplicationData(about);
    MauiApp::instance()->setIconName("qrc:/communicator.svg");

    QCommandLineParser parser;
    parser.process(app);

    about.setupCommandLine(&parser);
    about.processCommandLine(&parser);

    QQmlApplicationEngine engine;

    engine.rootContext()->setContextObject(new KLocalizedContext(&engine));

    engine.addImageProvider("contact", new ContactImage(QQuickImageProvider::ImageType::Image));
    qmlRegisterType<ContactsModel>(COMMUNICATOR_URI, 1, 0, "ContactsList");
    qmlRegisterType<Communicator>(COMMUNICATOR_URI, 1, 0, "Communicator");

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
