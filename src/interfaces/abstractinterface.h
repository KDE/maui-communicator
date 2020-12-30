#ifndef ABSTRACTINTERFACE_H
#define ABSTRACTINTERFACE_H

#include <QObject>
#ifdef STATIC_MAUIKIT
#include "fmh.h"
#else
#include <MauiKit/fmh.h>
#endif

/**
 * This is an abstract class for handling the contacts,
 * it describes tha basic methods needed for Maui Dialer
 * to fetch, edit and remove contacts.
 * This abstraction is meant to be implemented on
 * the android and linux specific interfaces... and any other future platform
 */

class AbstractInterface : public QObject
{
    Q_OBJECT
private:
    //    /*
    //     *  m_contacts might work as a cached list of the contacts
    //     *  when fetching contacts all over again might be expensive
    //     */

    //    FMH::MODEL_LIST m_contacts;

public:
    explicit AbstractInterface(QObject *parent = nullptr)
        : QObject(parent)
    {
    }
    virtual ~AbstractInterface()
    {
    }

    /**
     * getContacts must be done async and
     * emit a signal with FMH::MODEL_LIST representing the contacts
     */

    virtual void getContacts() const
    {
    }
    virtual void getContacts()
    {
    }

    /**
     * getAccounts returns a FMH::MODEL_LIST
     * representing the avalible accounts handling the contacts
     */

    virtual FMH::MODEL_LIST getAccounts(...) const
    {
        return FMH::MODEL_LIST();
    }
    virtual FMH::MODEL_LIST getAccounts(...)
    {
        return FMH::MODEL_LIST();
    }

    /**
     * getContact returns a contact represented by a FMH::MODEL,
     * to do so, it needs a valid id
     */

    virtual FMH::MODEL getContact(const QString &id) const
    {
        Q_UNUSED(id)
        return FMH::MODEL();
    }
    virtual FMH::MODEL getContact(const QString &id)
    {
        Q_UNUSED(id)
        return FMH::MODEL();
    }

    /**
     * insertContact takes a contact represented by a FMH::MODEL,
     * and returns whether the contact was sucessfully inserted or not.
     * To insert a contact to a specific account, use the fields:
     *  FMH::MODEL_KEY::ACCOUNT = name of the account
     *  FMH::MODEL_KEY::ACCOUNT_TYPE = type of the account
     */

    virtual bool insertContact(const FMH::MODEL &contact) const
    {
        Q_UNUSED(contact)
        return false;
    }
    virtual bool insertContact(const FMH::MODEL &contact)
    {
        Q_UNUSED(contact)
        return false;
    }

    /**
     * updateContact takes the id of the contact to be updated,
     * and the up-to-date values represented as a FMH::MODEL,
     * and returns whether the contact was sucessfulyl updated or not
     */

    virtual bool updateContact(const QString &id, const FMH::MODEL &contact) const
    {
        Q_UNUSED(id)
        Q_UNUSED(contact)
        return false;
    }
    virtual bool updateContact(const QString &id, const FMH::MODEL &contact)
    {
        Q_UNUSED(id)
        Q_UNUSED(contact)
        return false;
    }

    /**
     * removeContact takes the id of the contact to be removed and return
     * whether the contact was sucesfully removed or not
     */

    virtual bool removeContact(const QString &id) const
    {
        Q_UNUSED(id)
        return false;
    }
    virtual bool removeContact(const QString &id)
    {
        Q_UNUSED(id)
        return false;
    }

signals:

    /**
     * contactsReady is emitted when all the contacts are ready,
     * this signal is expected to be emitted by the getContacts method,
     * which is supossed to work async.
     * The contacts data is represented by FMH::MODEL_LIST
     */
    void contactsReady(FMH::MODEL_LIST contacts);
};

#endif // ABSTRACTINTERFACE_H
