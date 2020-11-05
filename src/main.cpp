#include <QQmlApplicationEngine>
#include <QIcon>
#include <QCommandLineParser>
#include <QQmlContext>

#ifdef Q_OS_ANDROID
#include <QGuiApplication>
#include <QIcon>
#else
#include <QApplication>
#endif

#ifdef STATIC_MAUIKIT
#include "3rdparty/mauikit/src/mauikit.h"
#include "mauiapp.h"
#else
#include <MauiKit/mauiapp.h>
#endif

#if defined Q_OS_MACOS || defined Q_OS_WIN
#include <KF5/KI18n/KLocalizedContext>
#include <KF5/KI18n/KLocalizedString>
#else
#include <KI18n/KLocalizedContext>
#include <KI18n/KLocalizedString>
#endif

#include "src/models/contacts/contactsmodel.h"
#include "src/models/contacts/calllogs.h"
#include "contactimage.h"

#ifdef STATIC_MAUIKIT
#include "./3rdparty/mauikit/src/mauikit.h"
#include <QStyleHints>
#endif

#ifndef STATIC_MAUIKIT
#include "communicator_version.h"
#endif

#define COMMUNICATOR_URI "org.maui.communicator"

int main(int argc, char *argv[])
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
	MauiApp::instance()->setHandleAccounts(false); //for now index can not handle cloud accounts
    MauiApp::instance()->setIconName("qrc:/communicator.svg");

	KLocalizedString::setApplicationDomain("communicator");
    KAboutData about(QStringLiteral("communicator"), i18n("Communicator"), COMMUNICATOR_VERSION_STRING, i18n("Communicator keeps your contacts synced and organized across devices."),
					 KAboutLicense::LGPL_V3, i18n("© 2019-2020 Nitrux Development Team"));
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

#ifdef STATIC_KIRIGAMI
	KirigamiPlugin::getInstance().registerTypes();
#endif

#ifdef STATIC_MAUIKIT
	MauiKit::getInstance().registerTypes();
#endif
	engine.rootContext()->setContextObject(new KLocalizedContext(&engine));

	engine.addImageProvider("contact", new ContactImage(QQuickImageProvider::ImageType::Image));
	qmlRegisterType<ContactsModel>(COMMUNICATOR_URI, 1, 0, "ContactsList");
	qmlRegisterType<CallLogs>(COMMUNICATOR_URI, 1, 0, "CallLogs");

	engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
	if (engine.rootObjects().isEmpty())
		return -1;

	return app.exec();
}
