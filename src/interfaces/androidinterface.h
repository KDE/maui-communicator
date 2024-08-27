#pragma once

#include "abstractinterface.h"
#include <QObject>

class AndroidInterface : public AbstractInterface
{
    Q_OBJECT
public:
    enum GET_TYPE : uint_fast8_t { CACHED, FETCH };

    static AndroidInterface *getInstance();

    QVariantList getCallLogs();

    FMH::MODEL_LIST getAccounts(const GET_TYPE &type = GET_TYPE::CACHED);
    FMH::MODEL getContact(const QString &id) override final;
    void getContacts(const GET_TYPE &type = GET_TYPE::CACHED);
    void getContacts() override final;
    bool insertContact(const FMH::MODEL &contact) override final;
    bool updateContact(const QString &id, const FMH::MODEL &contact) override final;
    bool removeContact(const QString &id) override final;

    static QImage contactPhoto(const QString &id);
    static void addContact(const QString &name, const QString &tel, const QString &tel2, const QString &tel3, const QString &email, const QString &title, const QString &org, const QString &photo, const QString &account, const QString &accountType);
    static void updateContact(const QString &id, const QString &field, const QString &value);

    static void call(const QString &tel);
    static void sendSMS(const QString &tel, const QString &subject, const QString &message);
    static void shareContact(const QString &id);


private:
    inline static AndroidInterface *instance = nullptr;
    FMH::MODEL_LIST m_contacts;
    FMH::MODEL_LIST m_accounts;

    void fetchContacts();
    FMH::MODEL_LIST fetchAccounts();

};
