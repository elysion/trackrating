#include "coverimageprovider.h"

#include <QMediaMetaData>
#include <QMediaPlayer>

#include <taglib/fileref.h>
#include <tstring.h>
#include <id3v2tag.h>
#include <mpegfile.h>
#include <attachedpictureframe.h>

CoverImageProvider::CoverImageProvider()
    : QQuickImageProvider(QQuickImageProvider::Image)
{
}

CoverImageProvider::~CoverImageProvider()
{

}

QImage CoverImageProvider::requestImage(const QString & id, QSize * size, const QSize & requestedSize)
{
    Q_UNUSED(requestedSize)
    Q_UNUSED(size)

    QImage image;

    if (!id.isEmpty()) {
        TagLib::MPEG::File file(QString(id).remove("file://").toUtf8().constData());
        TagLib::ID3v2::Tag *tag = file.ID3v2Tag();

        if (file.isValid() && tag) {
            TagLib::String artist = tag->artist();
            TagLib::String album = tag->album();
            TagLib::ID3v2::FrameList frames = tag->frameList("APIC");

            if (!frames.isEmpty()) {
                TagLib::ID3v2::AttachedPictureFrame *frame =
                        static_cast<TagLib::ID3v2::AttachedPictureFrame *>(frames.back());

                if (frame) {
                    image.loadFromData((const uchar*) frame->picture().data(), frame->picture().size());
                }
            }
        }
    }

    return image;
}
