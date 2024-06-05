#include "contactimage.h"
#ifdef Q_OS_ANDROID
#include "androidinterface.h"
#else
#include "linuxinterface.h"
#endif
#include <QDebug>

ContactImage::ContactImage(ImageType type)
    : QQuickImageProvider(type, Flags())
    , no_image(QImage(":/portrait.jpg"))
{
    //    this->blockSignals(false);
}

ContactImage::ContactImage(ImageType type, Flags flags)
    : QQuickImageProvider(type, flags)
    , no_image(QImage(":/portrait.jpg"))
{
    //    this->blockSignals(false);
}

QImage ContactImage::requestImage(const QString &id, QSize *size, const QSize &requestedSize)
{
    qDebug() << "requesting contact image with id " << id;
    QImage result;
#ifdef Q_OS_ANDROID
    result = AndroidInterface::contactPhoto(id);
#else
    result = LinuxInterface::contactPhoto(id);
#endif

    if (result.isNull()) {
        result = this->no_image;
    }

    if (size) {
        *size = result.size();
    }

    if (requestedSize.width() > 0 && requestedSize.height() > 0) {
        result = result.scaled(requestedSize.width(), requestedSize.height(), Qt::KeepAspectRatio);
    }

    return result;
}

void ContactImage::updateImage(const QImage &image)
{
    if (this->image != image) {
        this->image = image;
        Q_EMIT imageChanged();
    }
}
