#ifndef FILESINFOLDERPROVIDER_H
#define FILESINFOLDERPROVIDER_H

#include <QObject>
#include <QStringList>

class FilesInFolderProvider : public QObject
{
    Q_OBJECT
public:
    explicit FilesInFolderProvider(QObject *parent = 0);
    ~FilesInFolderProvider();

signals:

public slots:
    QStringList getFiles(QString folder);
};

#endif // FILESINFOLDERPROVIDER_H
