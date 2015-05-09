#ifndef FILEIO_H
#define FILEIO_H

#include <QObject>
#include <QFile>
#include <QTextStream>
#include <QDebug>

class FileIO : public QObject
{
    Q_OBJECT

public slots:
    bool write(const QString& source, const QString& data)
    {
        QString fileLocation = QString(source).remove("file://");

        if (fileLocation.isEmpty()) {
            qDebug("Source not set");
            return false;
        }

        QFile file(fileLocation);
        if (!file.open(QFile::WriteOnly | QFile::Truncate)) {
            qDebug("Opening file for writing failed");
            return false;
        }

        QTextStream out(&file);
        out << data;
        file.close();
        return true;
    }

public:
    FileIO() {}
};

#endif // FILEIO_H
