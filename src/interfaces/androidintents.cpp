#include "androidintents.h"
#include "./mauikit/src/android/mauiandroid.h"
#include <QDomDocument>

AndroidIntents::AndroidIntents(QObject *parent) : QObject(parent)
{
    this->mauia = new MAUIAndroid(this);
}

void AndroidIntents::call(const QString &tel)
{
    this->mauia->call(tel);
}

FMH::MODEL_LIST AndroidIntents::getContacts()
{
    FMH::MODEL_LIST data;

    const auto array = mauia->getContacts();
    QString xmlData(array);
    QDomDocument doc;

    if (!doc.setContent(xmlData)) return data;

    const QDomNodeList nodeList = doc.documentElement().childNodes();

    for (int i = 0; i < nodeList.count(); i++)
    {
        QDomNode n = nodeList.item(i);

        if(n.nodeName() == "item")
        {
            FMH::MODEL model;
            auto contact = n.toElement().childNodes();

            for(int i=0; i < contact.count(); i++)
            {
                const QDomNode m = contact.item(i);

                if(m.nodeName() == "n")
                {
                    const auto name = m.toElement().text();
                    model.insert(FMH::MODEL_KEY::N, name);

                }else if(m.nodeName() == "tel")
                {
                    const auto tel = m.toElement().text();
                    model.insert(FMH::MODEL_KEY::TEL, tel);

                }else if(m.nodeName() == "email")
                {
                    const auto email = m.toElement().text();
                    model.insert(FMH::MODEL_KEY::EMAIL, email);
                }
            }

            data << model;
        }
    }

    return data;
}
