#include "scanner.h"

#include <QDebug>

namespace stand
{

Scanner::Scanner(QObject *parent)
    : m_data(""),
      m_port(m_lvl2)
{
    Q_UNUSED(parent)
    QObject::connect(&m_port, SIGNAL(rcvData(QByteArray)), SLOT(onRcvData(QByteArray)));
    qDebug() << "Scanner::Scanner: ctor";
}

Scanner::~Scanner()
{
    qDebug() << "Scanner::~Scanner: dtor";
}

//-----------------------------------------------------------------

QString Scanner::getData()
{
    QString scan = m_data;
    clearData();
    return scan;
}

//-----------------------------------------------------------------

void Scanner::clearData()
{
    m_data = "";
    emit dataChanged();
}

//-----------------------------------------------------------------

void Scanner::onRcvData(const QByteArray &data)
{
    qDebug() << "Scanner::onRcvData: data: " << data.toHex();

    m_data = QString(data);
//    m_data.remove(QRegExp("[\r\n]"));
    emit dataChanged();
}

//-----------------------------------------------------------------

bool Scanner::open(const QString &port, int speed)
{
    qDebug() << "Scanner::open";

    m_port.connectSerial(port, speed);
    return  true;
}

//-----------------------------------------------------------------


void Scanner::close()
{
    qDebug() << "Scanner::close";

    m_port.disconnectSerial();
    m_data = "";
    emit dataChanged();
}

//-----------------------------------------------------------------

}    // namespace stand

