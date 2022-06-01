#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QtQml>
#include <QQuickStyle>
#include <QHostInfo>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QSerialPortInfo>

#include "log/avlog.h"
#include "util/fileloader.h"
#include "util/utiltool.h"

#include "trans/l2flags.h"
#include "trans/serialclient.h"

#include "stand/fwmodel.h"

#include <QDebug>


int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QCoreApplication::setOrganizationName("TeleTec");
    QGuiApplication app(argc, argv);
    qmlRegisterType<stand::FwLoaderState>("FwStateLib", 1, 0, "FwState");

    // App path
    QString appPath = QGuiApplication::applicationDirPath();

    // Host name
    QString host = QHostInfo::localHostName();
    host = host.left(10);

    // AvLog
    qInstallMessageHandler(avlog::AvLog::messageHandler);
    avlog::AvLogConfig cfg("FwLog_" + host + "-", true, false, false);
    avlog::AvLog &log = avlog::AvLog::instance(cfg);

    // Load conf.json
    QList<int> vendorList;
    QString appConfPath = appPath + "/conf/fwconf.json";
    QJsonDocument doc = util::FileLoader::instance().getFileAsJsonDoc(appConfPath);
    QJsonArray binarr;
    if (!doc.isEmpty() && doc.object()["firmware"].isArray()) binarr = doc.object()["firmware"].toArray();

    qDebug() << "ARR SIZE: " << binarr.size();

    QQmlApplicationEngine engine;
    QQuickStyle::setStyle("Fusion");

    // Serial port
    const auto infos = QSerialPortInfo::availablePorts();
    QStringList ports;
    for (const QSerialPortInfo &info : infos) ports << info.portName();
    engine.rootContext()->setContextProperty("ports", ports);

    trans::L2Flags lvl(0xFF);
    trans::SerialClient serial(lvl);
    engine.rootContext()->setContextProperty("serial", &serial);

    stand::FwModel fwmodel;
    engine.rootContext()->setContextProperty("fwmodel", &fwmodel);
    fwmodel.setLink(&serial);

    util::FileLoader &file = util::FileLoader::instance();
    engine.rootContext()->setContextProperty("file", &file);

    engine.rootContext()->setContextProperty("avlog", &log);
    engine.rootContext()->setContextProperty("AppPath", appPath);

    // Load firm model
    for (int i = 0; i < binarr.size(); ++i)
    {
        QJsonObject obj = binarr.at(i).toObject();
        qDebug() << "Obj: " << obj;

        QString name = obj["file"].toString();
        QString path = appPath + "/conf/" + name;
        QByteArray ba = file.getFileAsBin(path);
        qDebug() << "File: " << ba.size();

        fwmodel.addItem(obj, name, ba);
    }

    qDebug() << "Model: " << fwmodel.size();


    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
