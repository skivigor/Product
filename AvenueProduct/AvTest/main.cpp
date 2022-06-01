#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QtQml>

#include "log/avlog.h"

#include "db/dbserviceclient.h"
#include "util/scripttool.h"

#include "power/powerfactory.h"
//#include "power/pwprotocol.h"

#include "avtestclass.h"

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);

    // AvLog
    qInstallMessageHandler(avlog::AvLog::messageHandler);
    avlog::AvLogConfig cfg("AvTool-", true, false, false);
    avlog::AvLog &log = avlog::AvLog::instance(cfg);

    QString appPath = QGuiApplication::applicationDirPath();
    QString projPath(appPath + "/app_data/test");
    QString qml(projPath + "/qml/AvTestWindow.qml");

    QQmlApplicationEngine engine;

    using namespace power;
//    qRegisterMetaType<PwProtocol::PwCmdMode>("PwProtocol::PwCmdMode");
//    qRegisterMetaType<PwProtocol::PwCmdType>("PwProtocol::PwCmdType");

    db::DbServiceClient dbClient;
    dbClient.connect("ws://192.168.0.90:65123");
    engine.rootContext()->setContextProperty("dbClient", &dbClient);

    util::ScriptTool scr;
    engine.rootContext()->setContextProperty("util", &scr);
    QJSValue scrObj = engine.newQObject(&scr);
    engine.globalObject().setProperty("scr", scrObj);
    engine.evaluate(
        "function wait(ms) {"
        "    scr.wait(ms)"
        "}");

    power::PowerFactory pwFact;
    QJSValue pwObj = engine.newQObject(&pwFact);
    engine.globalObject().setProperty("pwfact", pwObj);
    engine.evaluate(
                "function PowerSupplyWithTcp(uri, port) {"
                "    return pwfact.createPowerSupplyWithTcp(uri, port)"
                "}");

    avtest::AvTestClass avtest;
    engine.rootContext()->setContextProperty("avtest", &avtest);

    engine.rootContext()->setContextProperty("avlog", &log);

    engine.load(qml);
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
