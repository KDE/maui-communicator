#include "androidinterface.h"
#include "mauiandroid.h"
#include <QDomDocument>

#include "fmh.h"
#include <QFuture>
#include <QFutureWatcher>
#include <QtConcurrent/QtConcurrentRun>
#include <QtConcurrent>

AndroidInterface *AndroidInterface::instance = nullptr;

AndroidInterface *AndroidInterface::getInstance()
{
    if (!instance) {
        instance = new AndroidInterface();
        qDebug() << "getInstance(AndroidInterface): First AndroidInterface instance\n";
        return instance;
    } else {
        qDebug() << "getInstance(AndroidInterface): previous AndroidInterface instance\n";
        return instance;
    }
}

void AndroidInterface::call(const QString &tel) const
{
    MAUIAndroid::call(tel);
}

bool AndroidInterface::insertContact(const FMH::MODEL &contact)
{
    qDebug() << "ADDING CONTACT TO ACCOUNT" << contact;
    MAUIAndroid::addContact(contact[FMH::MODEL_KEY::N],
                            contact[FMH::MODEL_KEY::TEL],
                            contact[FMH::MODEL_KEY::TEL_2],
                            contact[FMH::MODEL_KEY::TEL_3],
                            contact[FMH::MODEL_KEY::EMAIL],
                            contact[FMH::MODEL_KEY::TITLE],
                            contact[FMH::MODEL_KEY::ORG],
                            contact[FMH::MODEL_KEY::PHOTO],
                            contact[FMH::MODEL_KEY::ACCOUNT],
                            contact[FMH::MODEL_KEY::ACCOUNTTYPE]);
}

FMH::MODEL_LIST AndroidInterface::getAccounts(const GET_TYPE &type)
{
    if (type == GET_TYPE::CACHED) {
        if (!m_accounts.isEmpty())
            return this->m_accounts;
        else
            this->fetchAccounts();

    } else if (type == GET_TYPE::FETCH)
        return this->fetchAccounts();
}

void AndroidInterface::getContacts(const GET_TYPE &type)
{
    if (type == GET_TYPE::CACHED) {
        if (!this->m_contacts.isEmpty())
            emit this->contactsReady(this->m_contacts);
        else
            this->fetchContacts();

    } else if (type == GET_TYPE::FETCH)
        this->fetchContacts();
}

void AndroidInterface::getContacts()
{
    this->getContacts(GET_TYPE::FETCH);
}

void AndroidInterface::getCallLogs()
{
    const auto logs = MAUIAndroid::getCallLogs();
}

FMH::MODEL AndroidInterface::getContact(const QString &id) const
{
    return FMH::toModel(MAUIAndroid::getContact(id));
}

bool AndroidInterface::updateContact(const QString &id, const FMH::MODEL &contact)
{
    for (const auto &key : contact.keys())
        MAUIAndroid::updateContact(id, FMH::MODEL_NAME[key], contact[key]);

    return true;
}

bool AndroidInterface::removeContact(const QString &id)
{
    return false;
}

void AndroidInterface::fetchContacts()
{
    QFutureWatcher<FMH::MODEL_LIST> *watcher = new QFutureWatcher<FMH::MODEL_LIST>;
    connect(watcher, &QFutureWatcher<FMH::MODEL_LIST>::finished, [=]() {
        this->m_contacts = watcher->future().result();
        emit this->contactsReady(this->m_contacts);

        watcher->deleteLater();
    });

    const auto func = []() -> FMH::MODEL_LIST {
        FMH::MODEL_LIST data;

        auto list = MAUIAndroid::getContacts();

        for (auto item : list)
            data << FMH::toModel(item.toMap());

        return data;
    };

    QFuture<FMH::MODEL_LIST> t1 = QtConcurrent::run(func);
    watcher->setFuture(t1);
}

FMH::MODEL_LIST AndroidInterface::fetchAccounts()
{
    FMH::MODEL_LIST data;

    const auto array = MAUIAndroid::getAccounts();
    QString xmlData(array);
    QDomDocument doc;

    if (!doc.setContent(xmlData))
        return data;

    const QDomNodeList nodeList = doc.documentElement().childNodes();

    for (int i = 0; i < nodeList.count(); i++) {
        QDomNode n = nodeList.item(i);

        if (n.nodeName() == "account") {
            FMH::MODEL model;
            auto contact = n.toElement().childNodes();

            for (int i = 0; i < contact.count(); i++) {
                const QDomNode m = contact.item(i);

                if (m.nodeName() == "name") {
                    const auto account = m.toElement().text();
                    model.insert(FMH::MODEL_KEY::ACCOUNT, account);

                } else if (m.nodeName() == "type") {
                    const auto type = m.toElement().text();
                    model.insert(FMH::MODEL_KEY::ACCOUNTTYPE, type);
                }
            }

            data << model;
        }
    }
    return data;
}
