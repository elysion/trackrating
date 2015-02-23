#ifndef WAVEFORMIMAGEPROVIDER_H
#define WAVEFORMIMAGEPROVIDER_H

#include <QQuickImageProvider>

class WaveformImageProvider : public QQuickImageProvider
{
public:
    WaveformImageProvider();
    ~WaveformImageProvider();

public:
    QImage requestImage(const QString &id, QSize *size, const QSize &requestedSize);
};

#endif // WAVEFORMIMAGEPROVIDER_H
