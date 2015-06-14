TEMPLATE = app

QT += qml quick widgets multimedia
QT += serialport
QT += gui

SOURCES += main.cpp \
    serialportreader.cpp \
    serialport.cpp

RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
include(deployment.pri)

HEADERS += \
    serialportreader.h \
    serialport.h
