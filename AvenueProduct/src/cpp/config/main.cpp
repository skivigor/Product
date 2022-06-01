#include <QCoreApplication>

#include "iconfigloader.h"
#include "jsonconfigloader.h"
#include "testconfigloader.h"

#include "imedialoader.h"
#include "filemedialoader.h"
#include "testmedialoader.h"

#include <QDebug>

int main(int argc, char *argv[])
{
    QCoreApplication a(argc, argv);
    qDebug() << "Config test project";

    config::JsonConfigLoader cfg(QCoreApplication::applicationDirPath() + "/conf/addr.json");
    config::TestConfigLoader cfg_test(cfg);

    config::FileMediaLoader mda;
    config::TestMediaLoader mda_test(mda);

    QString fileName("garnitura1.jpg");
    QByteArray ba = mda.getElement(fileName);
    qDebug() << "BA SIZE: " << ba.size();
    mda.saveElement(fileName, ba);

    cfg_test.start();
    mda_test.start();

    return a.exec();
}
