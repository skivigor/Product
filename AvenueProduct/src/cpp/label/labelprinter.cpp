#include "labelprinter.h"
#include <QRegularExpression>
#include <QDataStream>
#include <QFile>

#include <QDebug>

#include <QCoreApplication>
#include "util/fileloader.h"


namespace label
{

LabelPrinter::LabelPrinter(const QString &devicePath, QObject *parent)
    : m_devicePath(devicePath)
{
    Q_UNUSED(parent)
}

LabelPrinter::~LabelPrinter()
{
}

//-----------------------------------------------------------------

bool LabelPrinter::print(const QString &profile, const QStringList &args, int num)
{
    qDebug() << "LabelPrinter::print: " << args << " : " << num;

    QString prof = profile;
    prof.replace("$Num", QString::number(num));

    for (int i = 1; i <= args.size(); ++i)
    {
        // TODO
    }
    prof += "\n";

    // TODO delete
    QString appPath(QCoreApplication::applicationDirPath() + "/");
    util::FileLoader::instance().saveFile(appPath + "/app_data/conf/prof.txt", prof);

    QFile file(m_devicePath);
    if (!file.open(QIODevice::WriteOnly))
    {
        qDebug() << "LabelPrinter::print: " << m_devicePath << " CAN NOT OPEN";
        file.close();
        return false;
    }
    qDebug() << "LabelPrinter::print: " << m_devicePath << " OPENNED";
    QTextStream out(&file);
    out << prof;
    file.close();

    return true;
}

//-----------------------------------------------------------------

}    // namespace label

