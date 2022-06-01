QT += serialport

HEADERS += \
    $$PWD/iprotocoll2.h  \
    $$PWD/iconnection.h \
    $$PWD/connection.h \
    $$PWD/ilevel2.h \
    $$PWD/l2stuffbytes.h \
    $$PWD/l2flags.h \
    $$PWD/l2flagsfa.h \
    $$PWD/serialclient.h \
    $$PWD/transfactory.h \
    $$PWD/l2empty.h

SOURCES += \
    $$PWD/connection.cpp \
    $$PWD/l2stuffbytes.cpp \
    $$PWD/l2flags.cpp \
    $$PWD/l2flagsfa.cpp \
    $$PWD/serialclient.cpp \
    $$PWD/transfactory.cpp \
    $$PWD/l2empty.cpp

