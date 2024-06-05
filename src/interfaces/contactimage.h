#ifndef CONTACTIMAGE_H
#define CONTACTIMAGE_H

#include <QObject>
#include <QQuickImageProvider>

class ContactImage : public QQuickImageProvider
{
    Q_OBJECT
public:
    ContactImage(ImageType type);
    ContactImage(ImageType type, Flags flags);
    QImage requestImage(const QString &id, QSize *size, const QSize &requestedSize) override;

public Q_SLOTS:
    void updateImage(const QImage &image);

Q_SIGNALS:
    void imageChanged();

private:
    QImage image;
    QImage no_image;
};

#endif // CONTACTIMAGE_H
