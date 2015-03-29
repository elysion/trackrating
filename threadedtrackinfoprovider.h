#ifndef THREADEDTRACKINFOPROVIDER_H
#define THREADEDTRACKINFOPROVIDER_H

#include <QObject>
#include <QThread>
#include <QString>
#include <QList>
#include <QStringList>

class ThreadedTrackInfoProvider : public QObject
{
    Q_OBJECT
    QThread workerThread;

public:
    explicit ThreadedTrackInfoProvider(QObject *parent = 0);
    ~ThreadedTrackInfoProvider();

public slots:
    void getTrackInfo(QStringList urls);

signals:
    void resultReady(const QVariantMap &trackInfo);
    void process(QList<QString> urls);
};

#endif // THREADEDTRACKINFOPROVIDER_H
