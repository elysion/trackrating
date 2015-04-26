TEMPLATE = app

QT += qml quick widgets sql multimedia svg

CONFIG += console
LIBS += -ltag -lmpg123-0

SOURCES += main.cpp \
    coverimageprovider.cpp \
    waveformimageprovider.cpp \
    trackinfoprovider.cpp \
    filesinfolderprovider.cpp \
    threadedtrackinfoprovider.cpp

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
    threadedtrackinfoprovider.h

LIBS += -LC:\Users\elysion\Documents\Projects\trackrating\mpg123-1.22.0-x86 -LC:\Users\elysion\Documents\Projects\trackrating\taglib-1.9.1\taglib

INCLUDEPATH += ./taglib-1.9.1/
INCLUDEPATH += ./taglib-1.9.1/taglib/
INCLUDEPATH += ./taglib-1.9.1/taglib/toolkit/
INCLUDEPATH += ./taglib-1.9.1/taglib/mpeg/id3v2/
INCLUDEPATH += ./taglib-1.9.1/taglib/mpeg/id3v2/frames/
INCLUDEPATH += ./taglib-1.9.1/taglib/mpeg/
INCLUDEPATH += ./mpg123-1.22.0-x86/

DISTFILES +=
