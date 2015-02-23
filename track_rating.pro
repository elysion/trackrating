TEMPLATE = app

QT += qml quick widgets sql multimedia

LIBS += -ltag

SOURCES += main.cpp \
    coverimageprovider.cpp \
    waveformimageprovider.cpp \
    trackinfoprovider.cpp

RESOURCES += qml.qrc \
    images.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
include(deployment.pri)

HEADERS += \
    coverimageprovider.h \
    waveformimageprovider.h \
    trackinfoprovider.h

unix: LIBS += -L/usr/local/Cellar/taglib/1.9.1/lib/ -ltag -L/usr/local/Cellar/mpg123/1.20.1/lib/ -lmpg123

INCLUDEPATH += /usr/local/Cellar/taglib/1.9.1/include/
INCLUDEPATH += /usr/local/Cellar/mpg123/1.20.1/include/

DISTFILES +=
