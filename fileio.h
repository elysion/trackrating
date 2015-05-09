#ifndef FILEIO_H
#define FILEIO_H

#include <QObject>
#include <QFile>
#include <QTextStream>
#include <QChar>
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

    QStringList read(const QString& location)
    {
        QString fileLocation = QString(location).remove("file://");
        QString contents;

        QFile file( fileLocation );
        if ( file.open(QFile::ReadOnly ) ) {
            QTextStream inStream(&file);
            contents = inStream.readAll();
        }
        file.close();

        if (contents.indexOf("\r\n") != -1) {
            return contents.split("\r\n");
        } else {
            return contents.split(contents.indexOf('\r') != -1 ? '\r' : '\n');
        }
    }

public:
    FileIO() {}
};

#endif // FILEIO_H
