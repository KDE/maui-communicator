#include "contactsmodel.h"
#include "abstractinterface.h"

#include <QDebug>

#ifdef Q_OS_ANDROID
#include "androidinterface.h"
#else
#include "linuxinterface.h"
#endif

#include <MauiKit/Core/fmh.h>

#ifdef Q_OS_ANDROID
ContactsModel::ContactsModel(QObject *parent)
    : MauiList(parent)
    , syncer(AndroidInterface::getInstance())
#else
ContactsModel::ContactsModel(QObject *parent)
    : MauiList(parent)
    , syncer(new LinuxInterface(this))
#endif
{
    connect(syncer, &AbstractInterface::contactsReady, [this](FMH::MODEL_LIST contacts) {
        qDebug() << "CONATCTS READY AT MODEL 1" << contacts;
        emit this->preListChanged();
        this->list = contacts;
        this->filter();
        emit this->postListChanged();
        emit this->countChanged();
    });

    this->getList();
}

const FMH::MODEL_LIST &ContactsModel::items() const
{
    return this->list;
}

void ContactsModel::setQuery(const QString &query)
{
    if (this->m_query == query || query.isEmpty())
        return;

    this->m_query = query;

    emit this->preListChanged();
    this->filter();
    emit this->postListChanged();

    emit this->queryChanged();
}

QString ContactsModel::getQuery() const
{
    return this->m_query;
}

void ContactsModel::getList()
{
    qDebug() << "TRYING TO SET FULL LIST";
    this->syncer->getContacts();
}

bool ContactsModel::insert(const QVariantMap &map)
{
    qDebug() << "INSERTING NEW CONTACT" << map;

    if (map.isEmpty())
        return false;

    const auto model = FMH::toModel(map);
    if (!this->syncer->insertContact(model))
        return false;

    qDebug() << "inserting new contact count" << this->list.count();
    emit this->preItemAppended();
    this->list << model;
    emit this->postItemAppended();

    qDebug() << "inserting new contact count" << this->list.count();

    return true;
}

bool ContactsModel::update(const QVariantMap &map, const int &index)
{
    if (index >= this->list.size() || index < 0)
        return false;

    const auto newItem = FMH::toModel(map);
    const auto oldItem = this->list[index];

    auto updatedItem = FMH::MODEL();
    updatedItem[FMH::MODEL_KEY::ID] = oldItem[FMH::MODEL_KEY::ID];

    QVector<int> roles;
    for (const auto &key : newItem.keys()) {
        if (newItem[key] != oldItem[key]) {
            updatedItem.insert(key, newItem[key]);
            roles << key;
        }
    }

    qDebug() << "trying to update contact:" << oldItem << "\n\n" << newItem << "\n\n" << updatedItem;

    this->syncer->updateContact(oldItem[FMH::MODEL_KEY::ID], newItem);
    this->list[index] = newItem;
    emit this->updateModel(index, roles);

    return true;
}

bool ContactsModel::remove(const int &index)
{
    if (index >= this->list.size() || index < 0)
        return false;

    qDebug() << "trying to remove :" << this->list[index][FMH::MODEL_KEY::ID];
    if (this->syncer->removeContact(this->list[index][FMH::MODEL_KEY::ID])) {
        emit this->preItemRemoved(index);
        this->list.removeAt(index);
        emit this->postItemRemoved();
        return true;
    }

    return false;
}

void ContactsModel::filter()
{
    FMH::MODEL_LIST res;

    if (this->m_query.contains("=")) {
        auto q = this->m_query.split("=", Qt::SkipEmptyParts);
        if (q.size() == 2) {
            for (auto item : this->list) {
                if (item[FMH::MODEL_NAME_KEY[q.first().trimmed()]].replace(" ", "").contains(q.last().trimmed()))
                    res << item;
            }
        }

        this->list = res;
    }
}

void ContactsModel::append(const QVariantMap &item)
{
    if (item.isEmpty())
        return;

    emit this->preItemAppended();

    FMH::MODEL model;
    for (auto key : item.keys())
        model.insert(FMH::MODEL_NAME_KEY[key], item[key].toString());

    qDebug() << "Appending item to list" << item;
    this->list << model;

    qDebug() << this->list;

    emit this->postItemAppended();
}

void ContactsModel::append(const QVariantMap &item, const int &at)
{
    if (item.isEmpty())
        return;

    if (at > this->list.size() || at < 0)
        return;

    qDebug() << "trying to append at" << at << item["title"];

    emit this->preItemAppendedAt(at);
    this->list.insert(at, FMH::toModel(item));
    emit this->postItemAppended();
}

void ContactsModel::clear()
{
    emit this->preListChanged();
    this->list.clear();
    emit this->postListChanged();
}

void ContactsModel::reset()
{
    this->m_query.clear();
    this->getList();
}

void ContactsModel::refresh()
{
    this->getList();
}

QVariantList ContactsModel::getAccounts()
{
    return FMH::toMapList(syncer->getAccounts());
}
