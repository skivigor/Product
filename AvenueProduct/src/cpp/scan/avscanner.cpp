#include "avscanner.h"
#include <QSerialPortInfo>

#include <QDebug>

namespace scan
{

AvScanner::AvScanner(QObject *parent)
    : m_data("")
{
    Q_UNUSED(parent)

    QObject::connect(&m_port, SIGNAL(readyRead()), SLOT(onReadyRead()), Qt::QueuedConnection);
    QObject::connect(&m_port, SIGNAL(error(QSerialPort::SerialPortError)), SLOT(onError(QSerialPort::SerialPortError)));
}

AvScanner::~AvScanner()
{
//    qDebug() << "AvScanner::~AvScanner: dtor";
    m_port.close();
}

//-----------------------------------------------------------------

QString AvScanner::getData()
{
    QString scan = m_data;
    clearData();
    return scan;
}

//-----------------------------------------------------------------

void AvScanner::clearData()
{
    m_data = "";
    emit dataChanged();
}

//-----------------------------------------------------------------

void AvScanner::onReadyRead()
{
    QByteArray ba = m_port.readAll();
    m_data = QString(ba);
    emit dataChanged();

    qDebug() << "scandata: " << m_data;
}

//-----------------------------------------------------------------

void AvScanner::onError(QSerialPort::SerialPortError error)
{
    qDebug() << "AvScanner::onError";
    Q_UNUSED(error)
}

//-----------------------------------------------------------------


void AvScanner::close()
{
    m_port.clear();
    m_port.close();
    m_data = "";
    emit dataChanged();
}

//-----------------------------------------------------------------

bool AvScanner::open(const QString &portName, int baudRate, const QString &parity, const QString &stopBits, const QString &flowCtrl)
{
    if (m_port.isOpen()) return false;

    QSerialPortInfo portInfo(portName);
    if (portInfo.isBusy()) return false;

    // Open SERIAL port
    m_port.setPortName(portName);
    m_port.setBaudRate(baudRate);
    m_port.setDataBits(QSerialPort::Data8);

    // set PARITY
    if (parity == "no")
    {
        m_port.setParity(QSerialPort::NoParity);
    } else
    {
        m_port.setParity(QSerialPort::EvenParity);
    }

    // set STOP BITS
    if (stopBits == "2")
    {
        m_port.setStopBits(QSerialPort::TwoStop);
    } else if (stopBits == "1.5")
    {
        m_port.setStopBits(QSerialPort::OneAndHalfStop);
    } else
    {
        m_port.setStopBits(QSerialPort::OneStop);
    }

    //set FLOW CONTROL
    if (flowCtrl == "hardware")
    {
        m_port.setFlowControl(QSerialPort::HardwareControl);
    } else
    {
        m_port.setFlowControl(QSerialPort::NoFlowControl);
    }


    if (m_port.open(QIODevice::ReadOnly))
    {
        m_port.clear();
        return true;
    }

    return false;
}

//-----------------------------------------------------------------

bool AvScanner::open(const QString &portName, int baudRate)
{
    return open(portName, baudRate, "no", "1", "no");
}

//-----------------------------------------------------------------

}    // namespace scan

