#ifndef COVERIMAGEPROVICED_H
#define COVERIMAGEPROVICED_H

#include <QQuickImageProvider>

class CoverImageProvider : public QQuickImageProvider
{
public:
    CoverImageProvider();
    ~CoverImageProvider();

public:
    QImage requestImage(const QString &id, QSize *size, const QSize &requestedSize);
};

#endif // COVERIMAGEPROVICED_H
