#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QtQml>
#include <QQuickStyle>
#include <QFont>
#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QHostInfo>
#include <QSerialPortInfo>

#include "log/avlog.h"

#include "trans/transfactory.h"
#include "stand/standfactory.h"
#include "stand/fwloader.h"
#include "db/dbfactory.h"

#include "util/fileloader.h"
#include "util/scripttool.h"

#include "power/powerfactory.h"
//#include "power/pwprotocol.h"

#include "label/labelprinterclient.h"
#include "scan/avscannerclient.h"

#include <QDebug>

#include "trans/l2flags.h"

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QCoreApplication::setOrganizationName("TeleTec");
    QGuiApplication app(argc, argv);
    qmlRegisterType<stand::FwLoaderState>("FwStateLib", 1, 0, "FwState");

    // Host name
    QString host = QHostInfo::localHostName();
    host = host.left(10);

    // AvLog
    qInstallMessageHandler(avlog::AvLog::messageHandler);
    avlog::AvLogConfig cfg("Log_" + host + "-", true, false, false);
    avlog::AvLog &log = avlog::AvLog::instance(cfg);

    // Load conf.json & search main QML file
    QString appPath(QCoreApplication::applicationDirPath() + "/");
    QString appConfPath = appPath + "/app_data/conf/";
    QJsonDocument doc = util::FileLoader::instance().getFileAsJsonDoc(appPath + "/app_data/conf/conf.json");
    assert(!doc.isEmpty());
    QJsonObject jObj = doc.object();
    assert(jObj["qml"].isObject());
    QString qmlPath = appPath + "/" + jObj["qml"].toObject().value("mainFile").toString();
    QString style = appPath + "/" + jObj["qml"].toObject().value("style").toString();

    QQmlApplicationEngine engine;
    QQuickStyle::setStyle(style);  // Default Fusion Imagine Material Universal
    using namespace power;
//    qRegisterMetaType<PwProtocol::PwCmdMode>("PwProtocol::PwCmdMode");
//    qRegisterMetaType<PwProtocol::PwCmdType>("PwProtocol::PwCmdType");

    power::PowerFactory pwFact;
    QJSValue pwObj = engine.newQObject(&pwFact);
    engine.globalObject().setProperty("pwfact", pwObj);
    engine.evaluate(
                "function PowerSupplyWithTcp(uri, port) {"
                "    return pwfact.createPowerSupplyWithTcp(uri, port)"
                "}");

    db::DbFactory dbFact;
    QJSValue dbObj = engine.newQObject(&dbFact);
    engine.globalObject().setProperty("dbfact", dbObj);
    engine.evaluate(
        "function DbServiceClient() {"
        "    return dbfact.createDbClient()"
        "}");

    trans::TransFactory trFact;
    QJSValue trObj = engine.newQObject(&trFact);
    engine.globalObject().setProperty("trfact", trObj);
    engine.evaluate(
        "function SerialClient(mode) {"
        "    return trfact.createSerialClient(mode)"
        "}");

    stand::StandFactory stndFact;
    QJSValue stndObj = engine.newQObject(&stndFact);
    engine.globalObject().setProperty("stndfact", stndObj);
    engine.evaluate(
        "function Scanner() {"
        "    return stndfact.createScanner()"
        "}");
    engine.evaluate(
        "function Stand() {"
        "    return stndfact.createStand()"
        "}");

    util::ScriptTool scr;
    engine.rootContext()->setContextProperty("util", &scr);
    QJSValue scrObj = engine.newQObject(&scr);
    engine.globalObject().setProperty("scr", scrObj);
    engine.evaluate(
        "function wait(ms) {"
        "    scr.wait(ms)"
        "}");

    // Available Serial ports
    const auto infos = QSerialPortInfo::availablePorts();
    QStringList ports;
    for (const QSerialPortInfo &info : infos) if (info.portName().contains("USB") || info.portName().contains("COM")) ports << info.portName();
    engine.rootContext()->setContextProperty("serialPorts", ports);

    util::FileLoader &file = util::FileLoader::instance();
    engine.rootContext()->setContextProperty("file", &file);

    engine.rootContext()->setContextProperty("avlog", &log);
    engine.rootContext()->setContextProperty("settings", jObj);
    engine.rootContext()->setContextProperty("AppPath", appPath);
    engine.rootContext()->setContextProperty("AppConfPath", appConfPath);

    label::LabelPrinterClient label;
    engine.rootContext()->setContextProperty("label", &label);

    scan::AvScannerClient scanner;
    engine.rootContext()->setContextProperty("scanner", &scanner);

//    engine.load(QUrl(qmlPath));
    engine.load(qmlPath);
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
