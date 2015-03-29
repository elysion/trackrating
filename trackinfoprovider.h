#ifndef TRACKINFOPROVIDER_H
#define TRACKINFOPROVIDER_H

#include <QVariantMap>
#include <QObject>
#include <QString>
#include <QStringList>

class TrackInfoProvider : public QObject
{
    Q_OBJECT

public:
    TrackInfoProvider();
    ~TrackInfoProvider();

public slots:
    QVariantMap getTrackInfo(QString url);
    void process(QList<QString> urls);

signals:
    void resultReady(QVariantMap result);
};

#endif // TRACKINFOPROVIDER_H
