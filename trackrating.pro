TEMPLATE = app

QT += qml quick widgets sql multimedia svg

# For file-dialog
QT += core-private
QT += gui-private
QT += widgets

LIBS += -ltag

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

unix: LIBS += -L/usr/local/Cellar/taglib/1.11/lib/ -ltag -L/usr/local/Cellar/mpg123/1.23.4/lib/ -lmpg123

INCLUDEPATH += /usr/local/Cellar/taglib/1.11/include/
INCLUDEPATH += /usr/local/Cellar/mpg123/1.23.4/include/

DISTFILES +=
