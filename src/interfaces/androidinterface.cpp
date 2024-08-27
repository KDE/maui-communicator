#include "androidinterface.h"

#include <QDomDocument>
#include <QFuture>
#include <QFutureWatcher>
#include <QtConcurrent/QtConcurrentRun>
#include <QtConcurrent>
#include <QException>

#include <QImage>

#include <MauiKit4/Core/mauiandroid.h>
#include <MauiKit4/Core/fmh.h>

class InterfaceConnFailedException : public QException
{
public:
    void raise() const { throw *this; }
    InterfaceConnFailedException *clone() const { return new InterfaceConnFailedException(*this); }
};


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

bool AndroidInterface::insertContact(const FMH::MODEL &contact)
{
    qDebug() << "ADDING CONTACT TO ACCOUNT" << contact;
    AndroidInterface::addContact(contact[FMH::MODEL_KEY::N],
                                 contact[FMH::MODEL_KEY::TEL],
                                 contact[FMH::MODEL_KEY::TEL_2],
                                 contact[FMH::MODEL_KEY::TEL_3],
                                 contact[FMH::MODEL_KEY::EMAIL],
                                 contact[FMH::MODEL_KEY::TITLE],
                                 contact[FMH::MODEL_KEY::ORG],
                                 contact[FMH::MODEL_KEY::PHOTO],
                                 contact[FMH::MODEL_KEY::ACCOUNT],
                                 contact[FMH::MODEL_KEY::ACCOUNTTYPE]);

    return true;
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

    return FMH::MODEL_LIST();
}

void AndroidInterface::getContacts(const GET_TYPE &type)
{
    if (type == GET_TYPE::CACHED) {
        if (!this->m_contacts.isEmpty())
            Q_EMIT this->contactsReady(this->m_contacts);
        else
            this->fetchContacts();

    } else if (type == GET_TYPE::FETCH)
        this->fetchContacts();
}

void AndroidInterface::getContacts()
{
    this->getContacts(GET_TYPE::FETCH);
}

static QJniObject androidActivity()
{
    return QJniObject::callStaticObjectMethod("org/qtproject/qt/android/QtNative", "activity", "()Landroid/app/Activity;"); // activity is valid;
}

QVariantList AndroidInterface::getCallLogs()
{
    QJniObject logsObj = QJniObject::callStaticObjectMethod("com/kde/maui/tools/Union",
                                                            "callLogs",
                                                            "(Landroid/content/Context;)Ljava/util/List;",
                                                            androidActivity().object<jobject>());

    return MAUIAndroid::transform(logsObj);

}

FMH::MODEL AndroidInterface::getContact(const QString &id)
{
    QJniObject contactObj = QJniObject::callStaticObjectMethod("com/kde/maui/tools/Union",
                                                               "getContact",
                                                               "(Landroid/content/Context;Ljava/lang/String;)Ljava/util/HashMap;",
                                                               androidActivity().object<jobject>(),
                                                               QJniObject::fromString(id).object<jstring>());


    return FMH::toModel(MAUIAndroid::createVariantMap(contactObj.object<jobject>()));
}

bool AndroidInterface::updateContact(const QString &id, const FMH::MODEL &contact)
{
    for (const auto &key : contact.keys())
        updateContact(id, FMH::MODEL_NAME[key], contact[key]);

    return true;
}

bool AndroidInterface::removeContact(const QString &id)
{
    return false;
}

QImage AndroidInterface::contactPhoto(const QString &id)
{
    return QImage();
}

void AndroidInterface::addContact(const QString &name, const QString &tel, const QString &tel2, const QString &tel3, const QString &email, const QString &title, const QString &org, const QString &photo, const QString &account, const QString &accountType)
{
    qDebug()<< "Adding new contact to android";
    QJniObject::callStaticMethod<void>("com/kde/maui/tools/Union",
                                       "addContact",
                                       "(Landroid/content/Context;"
                                       "Ljava/lang/String;"
                                       "Ljava/lang/String;"
                                       "Ljava/lang/String;"
                                       "Ljava/lang/String;"
                                       "Ljava/lang/String;"
                                       "Ljava/lang/String;"
                                       "Ljava/lang/String;"
                                       "Ljava/lang/String;"
                                       "Ljava/lang/String;"
                                       "Ljava/lang/String;)V",
                                       androidActivity().object<jobject>(),
                                       QJniObject::fromString(name).object<jstring>(),
                                       QJniObject::fromString(tel).object<jstring>(),
                                       QJniObject::fromString(tel2).object<jstring>(),
                                       QJniObject::fromString(tel3).object<jstring>(),
                                       QJniObject::fromString(email).object<jstring>(),
                                       QJniObject::fromString(title).object<jstring>(),
                                       QJniObject::fromString(org).object<jstring>(),
                                       QJniObject::fromString(photo).object<jstring>(),
                                       QJniObject::fromString(account).object<jstring>(),
                                       QJniObject::fromString(accountType).object<jstring>() );

}

void AndroidInterface::updateContact(const QString &id, const QString &field, const QString &value)
{
    QJniObject::callStaticMethod<void>("com/kde/maui/tools/Union",
                                       "updateContact",
                                       "(Landroid/content/Context;"
                                       "Ljava/lang/String;"
                                       "Ljava/lang/String;"
                                       "Ljava/lang/String;)V",
                                       androidActivity().object<jobject>(),
                                       QJniObject::fromString(id).object<jstring>(),
                                       QJniObject::fromString(field).object<jstring>(),
                                       QJniObject::fromString(value).object<jstring>() );

}


static QVariantList getAllContacts()
{
    QJniObject contactsObj = QJniObject::callStaticObjectMethod("com/kde/maui/tools/Union",
                                                                "fetchContacts",
                                                                "(Landroid/content/Context;)Ljava/util/List;",
                                                                androidActivity().object<jobject>());

    return MAUIAndroid::transform(contactsObj);

}

void AndroidInterface::fetchContacts()
{
    QFutureWatcher<FMH::MODEL_LIST> *watcher = new QFutureWatcher<FMH::MODEL_LIST>;
    connect(watcher, &QFutureWatcher<FMH::MODEL_LIST>::finished, [=]() {
        this->m_contacts = watcher->future().result();
        Q_EMIT this->contactsReady(this->m_contacts);

        watcher->deleteLater();
    });

    const auto func = []() -> FMH::MODEL_LIST {
        FMH::MODEL_LIST data;

        auto list = getAllContacts();

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

    //    const auto array = MAUIAndroid::getAccounts();
    //    QString xmlData(array);
    //    QDomDocument doc;

    //    if (!doc.setContent(xmlData))
    //        return data;

    //    const QDomNodeList nodeList = doc.documentElement().childNodes();

    //    for (int i = 0; i < nodeList.count(); i++) {
    //        QDomNode n = nodeList.item(i);

    //        if (n.nodeName() == "account") {
    //            FMH::MODEL model;
    //            auto contact = n.toElement().childNodes();

    //            for (int i = 0; i < contact.count(); i++) {
    //                const QDomNode m = contact.item(i);

    //                if (m.nodeName() == "name") {
    //                    const auto account = m.toElement().text();
    //                    model.insert(FMH::MODEL_KEY::ACCOUNT, account);

    //                } else if (m.nodeName() == "type") {
    //                    const auto type = m.toElement().text();
    //                    model.insert(FMH::MODEL_KEY::ACCOUNTTYPE, type);
    //                }
    //            }

    //            data << model;
    //        }
    //    }
    return data;
}

void AndroidInterface::call(const QString &tel)
{
    QJniEnvironment _env;
    QJniObject activity = QJniObject::callStaticObjectMethod("org/qtproject/qt/android/QtNative", "activity", "()Landroid/app/Activity;");   //activity is valid
    if (_env->ExceptionCheck()) {
        _env->ExceptionClear();
        throw InterfaceConnFailedException();
    }
    if ( activity.isValid() )
    {
        qDebug()<< "trying to call from senitents" << tel;

        QJniObject::callStaticMethod<void>("com/kde/maui/tools/Union",
                                           "call",
                                           "(Landroid/app/Activity;Ljava/lang/String;)V",
                                           activity.object<jobject>(),
                                           QJniObject::fromString(tel).object<jstring>());


        if (_env->ExceptionCheck())
        {
            _env->ExceptionClear();
            throw InterfaceConnFailedException();
        }
    }else
        throw InterfaceConnFailedException();

}

void AndroidInterface::sendSMS(const QString &tel, const QString &subject, const QString &message)
{
    qDebug() << "trying to send sms text";
    QJniEnvironment _env;
    QJniObject activity = QJniObject::callStaticObjectMethod("org/qtproject/qt/android/QtNative", "activity", "()Landroid/app/Activity;"); // activity is valid
    if (_env->ExceptionCheck()) {
        _env->ExceptionClear();
        throw InterfaceConnFailedException();
    }
    if (activity.isValid()) {
        QJniObject::callStaticMethod<void>("com/kde/maui/tools/Union",
                                           "sendSMS",
                                           "(Landroid/app/Activity;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V",
                                           activity.object<jobject>(),
                                           QJniObject::fromString(tel).object<jstring>(),
                                           QJniObject::fromString(subject).object<jstring>(),
                                           QJniObject::fromString(message).object<jstring>());

        if (_env->ExceptionCheck()) {
            _env->ExceptionClear();
            throw InterfaceConnFailedException();
        }
    } else
        throw InterfaceConnFailedException();
}


void AndroidInterface::shareContact(const QString &id)
{
    QJniObject::callStaticMethod<void>("com/kde/maui/tools/Union",
                                       "shareContact",
                                       "(Landroid/content/Context;"
                                       "Ljava/lang/String;)V",
                                       androidActivity().object<jobject>(),
                                       QJniObject::fromString(id).object<jstring>());
}


