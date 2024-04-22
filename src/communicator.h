#ifndef COMMUNICATOR_H
#define COMMUNICATOR_H

#include <QObject>

class Communicator : public QObject
{
    Q_OBJECT
public:
    explicit Communicator(QObject *parent =nullptr);

public Q_SLOTS:
    static void attachEmail(const QStringList &urls);
    static void email(const QString &to, const QString &cc, const QString &bcc, const QString &subject, const QString &body, const QString &messageFile = "", const QStringList &urls = {});
    static void call(const QString &tel);
    static void sendSMS(const QString &tel, const QString &subject, const QString &body);

};

#endif // COMMUNICATOR_H
