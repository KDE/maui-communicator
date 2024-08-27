#include "communicator.h"

#include <QDesktopServices>
#include <QFileInfo>
#include <QDebug>
#include <QUrl>

#ifdef Q_OS_ANDROID
#include "androidinterface.h"
#else
#include <KEMailClientLauncherJob>
#endif

Communicator::Communicator(QObject *parent) : QObject(parent)
{

}

void Communicator::attachEmail(const QStringList &urls)
{
#ifndef Q_OS_ANDROID

    if (urls.isEmpty())
        return;

    QFileInfo file(urls[0]);

    auto job = new KEMailClientLauncherJob();
    job->setAttachments(QUrl::fromStringList(urls));
    job->setSubject(file.baseName());
    job->start();

        
    // KToolInvocation::invokeMailer("", "", "", file.baseName(), "Files shared... ", "", urls);
    //    QDesktopServices::openUrl(QUrl("mailto:?subject=test&body=test&attachment;="
    //    + url));
#endif
}

void Communicator::email(const QString &to, const QString &cc, const QString &bcc, const QString &subject, const QString &body, const QString &messageFile, const QStringList &urls)
{
#ifdef Q_OS_ANDROID
    QDesktopServices::openUrl(QString("mailto:%1?cc=%2&bcc=%3&subject=%4&body=%5").arg(to, cc, bcc, subject, body));
#else
    // KToolInvocation::invokeMailer(to, cc, bcc, subject, body, messageFile, urls);
    
     auto job = new KEMailClientLauncherJob();
    job->setAttachments(QUrl::fromStringList(urls));
    job->setTo({to});
    job->setCc({cc});
    job->setBcc({bcc});
    job->setSubject(subject);
    job->setBody(body);
    job->setBody(body);
    job->start();

    //    QDesktopServices::openUrl(QUrl("mailto:?subject=test&body=test&attachment;="
    //    + url));

//    Qt.openUrlExternally("mailto:" + contact.email)
#endif

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
