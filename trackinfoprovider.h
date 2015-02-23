#ifndef TRACKINFOPROVIDER_H
#define TRACKINFOPROVIDER_H

#include <QVariantMap>
#include <QObject>
#include <QString>

class TrackInfoProvider : public QObject
{
    Q_OBJECT

public:
    TrackInfoProvider();
    ~TrackInfoProvider();

public slots:
    QVariantMap getTrackInfo(QString url);
};

#endif // TRACKINFOPROVIDER_H
