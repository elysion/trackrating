#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include "coverimageprovider.h"
#include "waveformimageprovider.h"
#include "trackinfoprovider.h"
#include "filesinfolderprovider.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    app.setOrganizationName("elysion");
    app.setOrganizationDomain("github.com/elysion");
    app.setApplicationName("Track Rating");

    QQmlApplicationEngine engine;
    engine.addImageProvider(QLatin1String("waveform"), new WaveformImageProvider);
    engine.addImageProvider(QLatin1String("cover"), new CoverImageProvider);
    qDebug(engine.offlineStoragePath().toUtf8().constData());
    TrackInfoProvider trackInfoProvider;
    engine.rootContext()->setContextProperty("trackInfoProvider", &trackInfoProvider);
    FilesInFolderProvider filesInFolderProvider;
    engine.rootContext()->setContextProperty("filesInFolderProvider", &filesInFolderProvider);
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    return app.exec();
}
