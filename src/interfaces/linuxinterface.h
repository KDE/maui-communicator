/*
 * Copyright 2019  Linus Jahn <lnj@kaidan.im>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License or (at your option) version 3 or any later version
 * accepted by the membership of KDE e.V. (or its successor approved
 * by the membership of KDE e.V.), which shall act as a proxy
 * defined in Section 14 of version 3 of the license.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef LINUXINTERFACE_H
#define LINUXINTERFACE_H

#include "abstractinterface.h"
#include <QObject>
#include <QStandardPaths>

class LinuxInterface : public AbstractInterface
{
    Q_OBJECT

private:
    FMH::MODEL_LIST m_contacts;

public:
    explicit LinuxInterface(QObject *parent = nullptr);

    FMH::MODEL getContact(const QString &id) override final;
    void getContacts() override final;
    bool insertContact(const FMH::MODEL &contact) override final;
    bool updateContact(const QString &id, const FMH::MODEL &contact) override final;
    bool removeContact(const QString &id) override final;

    /**
     * @brief contactPhoto is a static function to be used with the contactImage provider,
     * it takes the id of the contact and then looks for the photo url in the vcard
     * @param id of the vcard, it is the vcard filename for now
     * @return returns a QImage to be used with the contactImage provider
     */
    static QImage contactPhoto(const QString &id);

private:
    const QString path = QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation) + ("/kpeoplevcard");
};

#endif // LINUXINTERFACE_H
