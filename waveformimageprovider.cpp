#include "waveformimageprovider.h"

#include <QImage>
#include <QPainter>
#include <mpg123.h>
#include <math.h>
#include <climits>

const int IMAGE_WIDTH = 1000;
const int IMAGE_HEIGHT = 400;

WaveformImageProvider::WaveformImageProvider()
    : QQuickImageProvider(Image, QQuickImageProvider::ForceAsynchronousImageLoading)
{
}

WaveformImageProvider::~WaveformImageProvider()
{

}

void printNumber(int number) {
    qDebug(QString::number(number).toUtf8().constData());
}

QImage WaveformImageProvider::requestImage(const QString & id, QSize * size, const QSize & requestedSize)
{
    Q_UNUSED(requestedSize)
    Q_UNUSED(size)

    if (id.isEmpty()) {
        return QImage();
    }

    mpg123_handle *mh;
    unsigned char *buffer;
    size_t done;
    int err;
    int channels, encoding;
    long rate;

    /* initializations */
    mpg123_init();
    mh = mpg123_new(NULL, &err);

    /* open the file and get the decoding format */
    mpg123_open(mh, id.mid(QString("file://").length()).toUtf8().constData());
    mpg123_getformat(mh, &rate, &channels, &encoding);
    off_t length = mpg123_length(mh);

    QImage image(QSize(IMAGE_WIDTH, IMAGE_HEIGHT), QImage::Format_ARGB32);
    image.fill(Qt::transparent);

    QTransform transform;
    transform.translate(0, IMAGE_HEIGHT/2);
    transform.scale(1, float(IMAGE_HEIGHT) / SHRT_MAX / 2);

    QPainter p;
    p.begin(&image);
    p.setTransform(transform);
    p.setPen(QPen(QColor(Qt::black)));
    p.setBrush(QBrush(QColor(Qt::color0), Qt::NoBrush));

    int x = 0;
    int windowLength = length * 4 / IMAGE_WIDTH;
    buffer = (unsigned char*) malloc(windowLength * sizeof(unsigned char));

    int step = 1000 * channels;

    /* decode and play */
    while (mpg123_read(mh, buffer, windowLength, &done) == MPG123_OK) {
        short *values = (short*) buffer;

        float leftSquareSum = 0;
        float rightSquareSum = 0;

        for (unsigned long i = 0; i < done; i+=step) {
            short leftValue = values[i];
            short rightValue = values[i+1];
            leftSquareSum += powf(leftValue, 2);
            rightSquareSum += powf(rightValue, 2);
        }

        float leftRms = sqrt(leftSquareSum/done*step);
        float rightRms = sqrt(rightSquareSum/done*step);

        p.drawLine(x, 0, x, -leftRms);
        p.drawLine(x, 0, x, rightRms);
        ++x;
    }

    p.end();

    /* clean up */
    free(buffer);
    mpg123_close(mh);
    mpg123_delete(mh);

    return image;
}
