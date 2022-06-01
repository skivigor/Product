#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QtQml>
#include <QQuickStyle>
#include <QHostInfo>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
//#include <QSerialPortInfo>

#include "log/avlog.h"
#include "util/fileloader.h"
#include "util/utiltool.h"

#include "trans/l2flags.h"
#include "trans/serialclient.h"

#include "stand/waterstand.h"
#include "cam/avcamera.h"


int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QCoreApplication::setOrganizationName("TeleTec");
    QGuiApplication app(argc, argv);

    // App path
    QString appPath = QGuiApplication::applicationDirPath();

    // Host name
    QString host = QHostInfo::localHostName();
    host = host.left(10);

    // AvLog
    qInstallMessageHandler(avlog::AvLog::messageHandler);
    avlog::AvLogConfig cfg("Log_" + host + "-", true, false, false);
    avlog::AvLog &log = avlog::AvLog::instance(cfg);

    // Load conf.json
    QList<int> vendorList;
    QString appConfPath = appPath + "/conf/conf.json";
    QJsonDocument doc = util::FileLoader::instance().getFileAsJsonDoc(appConfPath);
    if (!doc.isEmpty())
    {
        QJsonObject cfg = doc.object();
        if (cfg["comVendor"].isArray())
        {
            QJsonArray arr = cfg["comVendor"].toArray();
            for (int i = 0; i < arr.size(); ++i) vendorList.append(arr.at(i).toInt());
        }
    }

    QQmlApplicationEngine engine;
    QQuickStyle::setStyle("Fusion");

    trans::L2Flags lvl(0xFF);
    trans::SerialClient serial(lvl);
    stand::WaterStand stand(serial, 57600);
    stand.setVendorList(vendorList);
    engine.rootContext()->setContextProperty("stand", &stand);

    cam::AvCamera camera;
    engine.rootContext()->setContextProperty("camera", &camera);

    util::FileLoader &file = util::FileLoader::instance();
    engine.rootContext()->setContextProperty("file", &file);

    util::UtilTool util;
    engine.rootContext()->setContextProperty("util", &util);

    engine.rootContext()->setContextProperty("avlog", &log);
    engine.rootContext()->setContextProperty("AppPath", appPath);

    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
