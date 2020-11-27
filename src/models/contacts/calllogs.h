#ifndef CALLLOGS_H
#define CALLLOGS_H

#include <QObject>
#ifdef STATIC_MAUIKIT
#include "fm.h"
#include "mauilist.h"
#else
#include <MauiKit/fm.h>
#include <MauiKit/mauilist.h>
#endif

class CallLogs : public MauiList
{
    Q_OBJECT
    Q_PROPERTY(CallLogs::SORTBY sortBy READ getSortBy WRITE setSortBy NOTIFY sortByChanged)
    Q_PROPERTY(CallLogs::ORDER order READ getOrder WRITE setOrder NOTIFY orderChanged)

public:
    enum SORTBY : uint_fast8_t
    {
        DATE = FMH::MODEL_KEY::DATE, //when the contact was last contacted
        N = FMH::MODEL_KEY::N, //contact name
        TEL = FMH::MODEL_KEY::TEL, //contact phone
        DURATION = FMH::MODEL_KEY::DURATION, //how many times contacts has been messaged or called
        TYPE = FMH::MODEL_KEY::TYPE,
        NONE

    }; Q_ENUM(SORTBY)

    enum ORDER : uint_fast8_t
    {
        ASC,
        DESC

    }; Q_ENUM(ORDER)

    explicit CallLogs(QObject *parent = nullptr);
    const FMH::MODEL_LIST &items() const override final;

    void setSortBy(const CallLogs::SORTBY &sort);
    CallLogs::SORTBY getSortBy() const;

    void setOrder(const CallLogs::ORDER &order);
    CallLogs::ORDER getOrder() const;

private:
    FMH::MODEL_LIST list;
    void getList(const bool &cached = false);
    void sortList();

    CallLogs::SORTBY sort = CallLogs::SORTBY::DATE;
    CallLogs::ORDER order = CallLogs::ORDER::ASC;

signals:
    void sortByChanged();
    void orderChanged();

public slots:
    QVariantMap get(const int &index) const;
    void refresh();

};

#endif // CALLLOGS_H
