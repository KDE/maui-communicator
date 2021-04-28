#include "communicator.h"

#include <KToolInvocation>

#include <QFileInfo>
#include <QDebug>
#include <QUrl>

#ifdef Q_OS_ANDROID
#include "androidinterface.h"
#else
#include <QDesktopServices>
#endif

Communicator::Communicator(QObject *parent) : QObject(parent)
{

}

void Communicator::attachEmail(const QStringList &urls)
{
    if (urls.isEmpty())
        return;

    QFileInfo file(urls[0]);

    KToolInvocation::invokeMailer("", "", "", file.baseName(), "Files shared... ", "", urls);
    //    QDesktopServices::openUrl(QUrl("mailto:?subject=test&body=test&attachment;="
    //    + url));
}

void Communicator::email(const QString &to, const QString &cc, const QString &bcc, const QString &subject, const QString &body, const QString &messageFile, const QStringList &urls)
{
    KToolInvocation::invokeMailer(to, cc, bcc, subject, body, messageFile, urls);
    //    QDesktopServices::openUrl(QUrl("mailto:?subject=test&body=test&attachment;="
    //    + url));

//    Qt.openUrlExternally("mailto:" + contact.email)

}


void Communicator::call(const QString &tel)
{
#ifdef Q_OS_ANDROID
    AndroidInterface::call(tel);
#else
    QDesktopServices::openUrl(QUrl("call://"+tel));
#endif

}

void Communicator::sendSMS(const QString &tel, const QString &subject, const QString &body)
{
#ifdef Q_OS_ANDROID
    AndroidInterface::sendSMS(tel,subject, body);
#else
    QDesktopServices::openUrl(QUrl("smsto:" + tel +"&sms_body:" + subject+" " + body));
#endif
}
