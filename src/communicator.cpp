#include "communicator.h"

#include <KToolInvocation>

#include <QFileInfo>

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
}
