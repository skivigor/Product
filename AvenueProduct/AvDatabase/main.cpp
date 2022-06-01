#include <QCoreApplication>

#include "log/avlog.h"
#include "db/sqldatabase.h"
#include "db/dbwebsocketservice.h"

int main(int argc, char *argv[])
{
    QCoreApplication a(argc, argv);

    qInstallMessageHandler(avlog::AvLog::messageHandler);
    avlog::AvLogConfig cfg("AvDb-", true, true, true, false);
    avlog::AvLog &log = avlog::AvLog::instance(cfg);

    QString appPath(QCoreApplication::applicationDirPath() + "/app_data");
    db::SqlDatabase db(appPath + "/conf/conf.json", "test");
    db::DbWebsocketService srv(db, appPath + "/db/sql_constructor.mjs", appPath + "/conf/conf.json");

    return a.exec();
}
