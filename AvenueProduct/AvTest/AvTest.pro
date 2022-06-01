QT += quick
CONFIG += c++11

VKIT = $$(KIT)

contains( VKIT, Desktop ) {
     install_it.path = $$OUT_PWD
}
contains( VKIT, Rpi ) {
     INSTALLS        = target
     target.path     = /home/pi/app
     install_it.path = /home/pi/app
}

#install_it.path = /home/pi/app #$$OUT_PWD
install_it.files += $$PWD/../app_data
INSTALLS += install_it

# The following define makes your compiler emit warnings if you use
# any Qt feature that has been marked deprecated (the exact warnings
# depend on your compiler). Refer to the documentation for the
# deprecated API to know how to port your code away from it.
DEFINES += QT_DEPRECATED_WARNINGS

# You can also make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
# You can also select to disable deprecated APIs only up to a certain version of Qt.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += \
        main.cpp \
    avtestclass.cpp

RESOURCES +=

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

INCLUDEPATH += "../src/cpp"

include(../src/cpp/log/log.pri)
#include(../src/cpp/trans/trans.pri)
#include(../src/cpp/stand/stand.pri)
include(../src/cpp/db/db.pri)
include(../src/cpp/util/util.pri)
include(../src/cpp/power/power.pri)

# Default rules for deployment.
#qnx: target.path = /tmp/$${TARGET}/bin
#else: unix:!android: target.path = /opt/$${TARGET}/bin
#!isEmpty(target.path): INSTALLS += target

HEADERS += \
    avtestclass.h

unix:!macx:CONFIG(debug, debug|release) : LIBS += -L$$PWD/../src/lib/AvUtilsLib/debug/ -lAvUtilsLib
else:unix:!macx:CONFIG(release, debug|release) : LIBS += -L$$PWD/../src/lib/AvUtilsLib/release/ -lAvUtilsLib

INCLUDEPATH += $$PWD/../src/lib/AvUtilsLib/include
DEPENDPATH += $$PWD/../src/lib/AvUtilsLib/include

unix:!macx:CONFIG(debug, debug|release) : PRE_TARGETDEPS += $$PWD/../src/lib/AvUtilsLib/debug/libAvUtilsLib.a
else:unix:!macx:CONFIG(release, debug|release) : PRE_TARGETDEPS += $$PWD/../src/lib/AvUtilsLib/release/libAvUtilsLib.a


