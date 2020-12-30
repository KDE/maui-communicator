#ifndef CONTACTIMAGE_H
#define CONTACTIMAGE_H

#include <QObject>
#include <QQuickImageProvider>

class ContactImage : public QObject, public QQuickImageProvider
{
    Q_OBJECT
public:
    ContactImage(ImageType type, Flags flags = nullptr);
    QImage requestImage(const QString &id, QSize *size, const QSize &requestedSize) override;

public slots:
    void updateImage(const QImage &image);

signals:
    void imageChanged();

private:
    QImage image;
    QImage no_image;
};

#endif // CONTACTIMAGE_H
