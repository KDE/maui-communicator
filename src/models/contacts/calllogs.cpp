#include "calllogs.h"

#include <QtConcurrent>
#include <QtConcurrent/QtConcurrentRun>
#include <QFuture>
#include <QFutureWatcher>

#ifdef STATIC_MAUIKIT
#include "mauiandroid.h"
#endif

CallLogs::CallLogs(QObject *parent) : MauiList(parent)
{
    this->getList();
}

const FMH::MODEL_LIST &CallLogs::items() const
{
    return this->list;
}

void CallLogs::setSortBy(const CallLogs::SORTBY &sort)
{
    if(this->sort == sort)
        return;

    this->sort = sort;

    this->preListChanged();
    this->sortList();
    this->postListChanged();
    emit this->sortByChanged();
}

CallLogs::SORTBY CallLogs::getSortBy() const
{
    return this->sort;
}

void CallLogs::setOrder(const CallLogs::ORDER &order)
{
    if(this->order == order)
        return;

    this->order = order;

    this->preListChanged();
    this->sortList();
    this->postListChanged();
    emit this->orderChanged();
}

CallLogs::ORDER CallLogs::getOrder() const
{
    return this->order;
}

void CallLogs::getList(const bool &cached)
{
    QFutureWatcher<FMH::MODEL_LIST> *watcher = new QFutureWatcher<FMH::MODEL_LIST>;
    connect(watcher, &QFutureWatcher<FMH::MODEL_LIST>::finished, [=]()
    {
        emit this->preListChanged();
        this->list = watcher->future().result();
        this->sortList();
        emit this->postListChanged();
        watcher->deleteLater();
    });

    const auto func = []() -> FMH::MODEL_LIST {
            FMH::MODEL_LIST list;

        #ifdef STATIC_MAUIKIT
            for(const auto &item : MAUIAndroid::getCallLogs())
    {
            auto map = item.toMap();
            map.insert(FMH::MODEL_NAME[FMH::MODEL_KEY::MODIFIED],
            QDate(QDateTime::fromString(map.value(FMH::MODEL_NAME[FMH::MODEL_KEY::DATE]).toString(), "dd-MM-yyyy HH:mm").date()).toString(Qt::TextDate));
    list << FMH::toModel(map);
}
#endif

return list;
};

QFuture<FMH::MODEL_LIST> t1 = QtConcurrent::run(func);
watcher->setFuture(t1);
}

template<typename T>
static bool OP(const T &t1, const T &t2, const CallLogs::ORDER &order)
{
    switch(order)
    {
        case CallLogs::ORDER::ASC:
            return t1 < t2;
        case CallLogs::ORDER::DESC:
            return t1 > t2;
    }

    return false;
};

void CallLogs::sortList()
{
    if(this->sort == CallLogs::SORTBY::NONE)
        return;

    const auto key = static_cast<FMH::MODEL_KEY>(this->sort);
    const auto order = this->order;
    std::sort(this->list.begin(), this->list.end(), [&key, &order](const FMH::MODEL &e1, const FMH::MODEL &e2) -> bool
    {

        switch(key)
        {
            case FMH::MODEL_KEY::DATE:
            {

                auto date1 = QDateTime::fromString(e1[key], "dd-MM-yyyy HH:mm").date();
                auto date2 = QDateTime::fromString(e2[key], "dd-MM-yyyy HH:mm").date();

                if (OP(date1.daysTo(QDate::currentDate()), date2.daysTo(QDate::currentDate()), order))
                    return true;

                break;
            }

            case FMH::MODEL_KEY::N:
            case FMH::MODEL_KEY::TYPE:
            case FMH::MODEL_KEY::TEL:
            {
                const auto str1 = QString(e1[key]).toLower();
                const auto str2 = QString(e2[key]).toLower();

                if(OP(str1, str2, order))
                    return true;
                break;
            }

            default:
                if(OP(e1[key], e2[key], order))
                    return true;
        }

        return false;
    });
}

QVariantMap CallLogs::get(const int &index) const
{
    if(index >= this->list.size() || index < 0)
        return QVariantMap();
    QVariantMap res;

    const auto item = this->list.at(index);

    res = FMH::toMap(item);
    return res;
}

void CallLogs::refresh()
{
    this->getList();
}
