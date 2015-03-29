#include "filesinfolderprovider.h"

#include <QDir>
#include <QDirIterator>

FilesInFolderProvider::FilesInFolderProvider(QObject *parent) : QObject(parent)
{

}

FilesInFolderProvider::~FilesInFolderProvider()
{

}

QStringList FilesInFolderProvider::getFiles(QString folder)
{
    QStringList files;
    QDirIterator it(folder.remove("file://"), QStringList() << "*.mp3", QDir::Files, QDirIterator::Subdirectories);
    while (it.hasNext()) {
        files << it.next();
    }

    return files;
}

