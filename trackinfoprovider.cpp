#include "trackinfoprovider.h"
#include <taglib/fileref.h>
#include <taglib/tstring.h>
#include <taglib/id3v2tag.h>
#include <taglib/mpegfile.h>
#include <QDebug>

TrackInfoProvider::TrackInfoProvider()
{
}

TrackInfoProvider::~TrackInfoProvider()
{
}

QString toQString(TagLib::String string) {
    return QString::fromUtf8(string.toCString(true));
}

QVariantMap TrackInfoProvider::getTrackInfo(QString url)
{
    QVariantMap info;

    if (!url.isEmpty()) {
        TagLib::MPEG::File file(url.mid(QString("file://").length()).toUtf8().constData());
        TagLib::ID3v2::Tag *tag = file.ID3v2Tag();

        if (file.isValid() && tag) {
            info.insert("title", toQString(tag->title()));
            info.insert("artist", toQString(tag->artist()));
            info.insert("album", toQString(tag->album()));
        }
    }

    return info;
}

