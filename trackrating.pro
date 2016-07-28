TEMPLATE = app

QT += qml quick widgets sql multimedia svg

# For file-dialog which is needed in order to set the filename for the export playlist dialog
QT += core-private
QT += gui-private
QT += widgets

QMAKE_CFLAGS += -gdwarf-2
QMAKE_CXXFLAGS += -gdwarf-2

LIBS += -ltag -lmpg123

SOURCES += main.cpp \
    coverimageprovider.cpp \
    waveformimageprovider.cpp \
    trackinfoprovider.cpp \
    filesinfolderprovider.cpp \
    threadedtrackinfoprovider.cpp \
    file-dialog/fileopendialog.cpp \
    file-dialog/filesavedialog.cpp

RESOURCES += qml.qrc \
    images.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
include(deployment.pri)

HEADERS += \
    coverimageprovider.h \
    waveformimageprovider.h \
    trackinfoprovider.h \
    filesinfolderprovider.h \
    threadedtrackinfoprovider.h \
    file-dialog/fileopendialog.h \
    file-dialog/filesavedialog.h \
    fileio.h

macx {
    QMAKE_INFO_PLIST = TrackRatingInfo.plist
    ICON = TrackRating.icns
    DISTFILES += \
        TrackRatingInfo.plist
    LIBS += -L/usr/local/Cellar/taglib/1.11/lib/ -L/usr/local/Cellar/mpg123/1.23.6/lib/

    INCLUDEPATH += /usr/local/Cellar/taglib/1.11/include/
    INCLUDEPATH += /usr/local/Cellar/mpg123/1.23.6/include/
}
