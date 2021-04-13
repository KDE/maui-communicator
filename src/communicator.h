#ifndef COMMUNICATOR_H
#define COMMUNICATOR_H

#include <QObject>

class Communicator : public QObject
{
    Q_OBJECT
public:
    explicit Communicator(QObject *parent =nullptr);

public slots:
    void attachEmail(const QStringList &urls);
    void email(const QString &to, const QString &cc, const QString &bcc, const QString &subject, const QString &body, const QString &messageFile, const QStringList &urls);


signals:

};

#endif // COMMUNICATOR_H
