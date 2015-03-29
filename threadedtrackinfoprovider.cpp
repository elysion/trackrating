#include "threadedtrackinfoprovider.h"
#include "trackinfoprovider.h"

#include <QDebug>

ThreadedTrackInfoProvider::ThreadedTrackInfoProvider(QObject *parent) : QObject(parent)
{
    TrackInfoProvider *worker = new TrackInfoProvider;
    worker->moveToThread(&workerThread);
    connect(&workerThread, &QThread::finished, worker, &QObject::deleteLater);
    connect(this, &ThreadedTrackInfoProvider::process, worker, &TrackInfoProvider::process);
    connect(worker, &TrackInfoProvider::resultReady, this, &ThreadedTrackInfoProvider::resultReady);
    workerThread.start();
}

ThreadedTrackInfoProvider::~ThreadedTrackInfoProvider()
{
    workerThread.quit();
    workerThread.wait();
}

void ThreadedTrackInfoProvider::getTrackInfo(QStringList urls)
{
    emit process(urls);
}

