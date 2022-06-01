#include <QCoreApplication>
#include <QHostInfo>

#include "log/avlog.h"

#include "util/fileloader.h"
#include "label/labelprinter.h"
#include "label/labelprinterservice.h"

#include <QDebug>

int main(int argc, char *argv[])
{
    QCoreApplication a(argc, argv);

    // Host name
    QString host = QHostInfo::localHostName();
    host = host.left(10);

    // AvLog
    qInstallMessageHandler(avlog::AvLog::messageHandler);
    avlog::AvLogConfig cfg("LogLbl_" + host + "-", true, false, false);
    avlog::AvLog &log = avlog::AvLog::instance(cfg);

    QString appPath(QCoreApplication::applicationDirPath() + "/");
    QJsonDocument doc = util::FileLoader::instance().getFileAsJsonDoc(appPath + "/app_data/conf/conf.json");
    assert(!doc.isEmpty());
    QJsonObject jObj = doc.object();
    assert(jObj["printerServer"].isObject());
    QJsonObject srvCfg = jObj["printerServer"].toObject();

//    QString profilePath = appPath + "app_data/conf/" + jObj["printerServer"].toObject().value("profile").toString();
    QString devicePath = jObj["printerServer"].toObject().value("device").toString();
    qDebug() << "devicePath: " << devicePath;

//    QFile file(profilePath);
//    file.open(QIODevice::ReadOnly | QIODevice::Text);
//    QString profile = file.readAll();
//    file.close();

    label::LabelPrinter printer(devicePath);
    label::LabelPrinterService srv(printer, srvCfg);

    return a.exec();
}
