#ifndef CONTACTSMODEL_H
#define CONTACTSMODEL_H

#include <QObject>

#ifdef STATIC_MAUIKIT
#include "mauilist.h"
#else
#include <MauiKit/mauilist.h>
#endif

class AbstractInterface;
class ContactsModel : public MauiList
{
    Q_OBJECT
    Q_PROPERTY(QString query READ getQuery WRITE setQuery NOTIFY queryChanged)

public:
    explicit ContactsModel(QObject *parent = nullptr);

    const FMH::MODEL_LIST &items() const override final;

    QString getQuery() const;
    void setQuery(const QString &query);

private:
    /*
     * *syncer (abstract interface) shouyld work with whatever interface derived from
     * AbstractInterface, for now we have Android and Linux interfaces
     */

    AbstractInterface *syncer;

    /**
     * There is the list that holds the conatcts data,
     * and the list-bk which holds a cached version of the list,
     * this helps to not have to fecth contents all over again
     * when filtering the list
     */
    FMH::MODEL_LIST list;


    void filter();
    void getList();

    /**
     * query is a property to start filtering the list, the filtering is
     * done over the list-bk cached list instead of the main list
     */
    QString m_query;

signals:
    void queryChanged();

public slots:
    bool insert(const QVariantMap &map);
    bool update(const QVariantMap &map, const int &index);
    bool remove(const int &index);

    void append(const QVariantMap &item, const int &at);
    void append(const QVariantMap &item);

    void clear();
    void reset();
    void refresh();
    QVariantList getAccounts();
};

#endif // CONTACTSMODEL_H
