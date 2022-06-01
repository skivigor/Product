#-------------------------------------------------
#
# Project created by QtCreator 2016-06-29T08:55:50
#
#-------------------------------------------------

QT       += core

QT       -= gui

TARGET = TestConfig
CONFIG   += console
CONFIG   -= app_bundle

TEMPLATE = app

QMAKE_CXXFLAGS += -std=c++11

SOURCES += main.cpp \
    filemedialoader.cpp \
    jsonconfigloader.cpp \
    testconfigloader.cpp \
    testmedialoader.cpp

HEADERS += \
    filemedialoader.h \
    iconfigloader.h \
    imedialoader.h \
    jsonconfigloader.h \
    testconfigloader.h \
    testmedialoader.h \
    config.h

INCLUDEPATH += "../"

include(../utils/utils.pri)

DISTFILES += \
    config.pri
