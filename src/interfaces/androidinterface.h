#ifndef ANDROIDINTERFACE_H
#define ANDROIDINTERFACE_H

#include "abstractinterface.h"
#include <QObject>

class AndroidInterface : public AbstractInterface
{
    Q_OBJECT
public:
    enum GET_TYPE : uint_fast8_t { CACHED, FETCH };

    static AndroidInterface *getInstance();
    void call(const QString &tel) const;

    void getCallLogs();

    FMH::MODEL_LIST getAccounts(const GET_TYPE &type = GET_TYPE::CACHED);
    FMH::MODEL getContact(const QString &id) override final;
    void getContacts(const GET_TYPE &type = GET_TYPE::CACHED);
    void getContacts() override final;
    bool insertContact(const FMH::MODEL &contact) override final;
    bool updateContact(const QString &id, const FMH::MODEL &contact) override final;
    bool removeContact(const QString &id) override final;

private:
    static AndroidInterface *instance;
    FMH::MODEL_LIST m_contacts;
    FMH::MODEL_LIST m_accounts;

    void fetchContacts();
    FMH::MODEL_LIST fetchAccounts();

public slots:
};

#endif // ANDROIDINTERFACE_H
