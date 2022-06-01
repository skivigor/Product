#include "serialclient.h"
#include "ilevel2.h"
#include <QSerialPortInfo>

#include <QDebug>

namespace
{
const QString separator("\n");

//const int maxCmdNum = 400;
//const int clearCmdNum = 200;
//int       cmdNum = 0;
}    // namespace


namespace trans
{

SerialClient::SerialClient(ILevel2 &lvl2, QObject *parent)
    : m_portName("ttyUSB0"),
      m_baudRate(115200),
      m_statusStr(""),
      m_state(false),
      m_lvl2(lvl2),
      m_logEnabled(false),
      m_retry(false)
{
    Q_UNUSED(parent)

    QObject::connect(&m_port, SIGNAL(readyRead()), SLOT(onReadyRead()), Qt::QueuedConnection);
    QObject::connect(&m_port, SIGNAL(error(QSerialPort::SerialPortError)), SLOT(onError(QSerialPort::SerialPortError)));
    qDebug() << "SerialClient::SerialClient: ctor";
}

SerialClient::~SerialClient()
{
    qDebug() << "SerialClient::~SerialClient: dtor";
}

//-----------------------------------------------------------------

//void SerialClient::resizeOutput()
//{
//    QStringList list = m_log.split(separator);
//    QStringList::iterator iter = list.begin();
//    list.erase(iter, iter + clearCmdNum);

//    m_log = list.join(separator);
//    emit logChanged();
//    cmdNum = list.size() - 1;
//}

//-----------------------------------------------------------------

void SerialClient::onReadyRead()
{
//    if (cmdNum >= maxCmdNum) resizeOutput();

    QByteArray ba = m_port.readAll();
    if (ba.size() <= 128)
    {
        qDebug() << "SerialClient::onReadyRead: " << ba.toHex();
    } else
    {
        QByteArray temp = ba.mid(0, 128);
        qDebug() << "SerialClient::onReadyRead: " << temp.toHex() << " ...";
        qDebug() << "SerialClient::onReadyRead: data size: " << ba.size();
    }

    QByteArrayList list = m_lvl2.unpackData(ba);
    if (list.size() > 0) m_lastResp.clear();
    for (int i = 0; i < list.size(); ++i)
    {
//        m_lastRespList << QVariant(list.at(i));
////        qDebug() << "SerialClient::onReadyRead: unpack: " << list.at(i).toHex();
//        m_lastResp.append(list.at(i));
//        if (m_logEnabled)
//        {
//            m_log += list.at(i).toHex() + "\n";
//            cmdNum++;
//            emit logChanged();
//        }
        emit rcvData(list.at(i));
    }
}

//-----------------------------------------------------------------

void SerialClient::onError(QSerialPort::SerialPortError error)
{
    qDebug() << "SerialClient::onError: error: " << error;

    m_statusStr = "Port error";
    emit statusStrChanged();

    if (error == QSerialPort::DeviceNotFoundError)
    {
        m_statusStr = "Device Not Found";
        emit statusStrChanged();
        return;
    }

    if (error == QSerialPort::PermissionError)
    {
        m_statusStr = "Permission Error";
        emit statusStrChanged();
        return;
    }

    if (error == QSerialPort::OpenError)
    {
        m_statusStr = "Open Error";
        emit statusStrChanged();
        return;
    }

    if (error == QSerialPort::NotOpenError)
    {
        m_statusStr = "Not Open Error";
        emit statusStrChanged();
        return;
    }

    if (error == QSerialPort::ParityError)
    {
        m_statusStr = "Parity Error";
        emit statusStrChanged();
        return;
    }

    if (error == QSerialPort::FramingError)
    {
        m_statusStr = "Framing Error";
        emit statusStrChanged();
        return;
    }

    if (error == QSerialPort::BreakConditionError)
    {
        m_statusStr = "Break Condition";
        emit statusStrChanged();
        return;
    }

    if (error == QSerialPort::WriteError)
    {
        m_statusStr = "Write Error";
        emit statusStrChanged();
        return;
    }

    if (error == QSerialPort::ReadError)
    {
        m_statusStr = "Read Error";
        emit statusStrChanged();
        return;
    }

    if (error == QSerialPort::ResourceError)
    {
        m_statusStr = "Resource Error";
        emit statusStrChanged();
        m_port.close();
        m_state = false;
        emit stateChanged();
        return;
    }

    if (error == QSerialPort::UnsupportedOperationError)
    {
        m_statusStr = "Unsupported Operation";
        emit statusStrChanged();
        return;
    }

    if (error == QSerialPort::TimeoutError)
    {
        m_statusStr = "Timeout Error";
        emit statusStrChanged();
        return;
    }

    if (error == QSerialPort::UnknownError)
    {
        m_statusStr = "Unknown Error";
        emit statusStrChanged();
        return;
    }

//    if (m_retry) { m_retry = false; return; }
//    m_retry = true;

//    connectSerial();
}

//-----------------------------------------------------------------

bool SerialClient::connectSerial(const QString &portName, int baudRate, const QString &parity, const QString &stopBits, const QString &flowCtrl)
{
    m_portName = portName;
    m_baudRate = baudRate;

    qDebug() << "SerialClient::connectSerial";
    if (m_port.isOpen()) return true;
    qDebug() << "SerialClient::connectSerial: is free";

    QSerialPortInfo portInfo(portName);
    if (portInfo.isBusy())
    {
        m_statusStr = "Port busy";
        emit statusStrChanged();
        return false;
    }

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


    if (m_port.open(QIODevice::ReadWrite))
    {
        m_state = true;
        emit stateChanged();
        m_statusStr = "";
        emit statusStrChanged();
        emit sdnConnected();

        m_port.clear();
        return true;
//        m_port.flush();
    } else
    {
        m_state = false;
        emit stateChanged();
        m_statusStr = "Port error";
        emit statusStrChanged();
        return false;
    }

}

//-----------------------------------------------------------------

bool SerialClient::connectSerial(const QString &portName, int baudRate)
{
    m_portName = portName;
    m_baudRate = baudRate;
    qDebug() << "SerialClient::connectSerial: " << portName;

    if (m_port.isOpen()) return true;
    return connectSerial(portName, baudRate, "no", "1", "no");
}

//-----------------------------------------------------------------

//void SerialClient::connectSerial()
//{
////    if (m_port.isOpen()) return;
//    connectSerial(m_portName, m_baudRate, "no", "1", "no");
//}

//-----------------------------------------------------------------

void SerialClient::disconnectSerial()
{
    qDebug() << "SerialClient::disconnectSerial";
//    m_port.flush();
    m_port.clear();
    m_port.close();
    m_state = false;
    emit stateChanged();
    m_statusStr = "";
    emit statusStrChanged();
    emit sdnDisconnected();
}


//-----------------------------------------------------------------

void SerialClient::sendData(const QByteArray &data)
{
//    qDebug() << "SerialClient::sendData: as ARRAY: " << data.toHex();
    if (!m_port.isOpen() || data.isEmpty()) return;
    QByteArray ba = m_lvl2.packData(data);
    qDebug() << "SerialClient::sendData: " << ba.toHex();
    m_lastResp.clear();
    m_port.flush();
    m_port.write(ba);
//    m_port.waitForBytesWritten(20);
}

//-----------------------------------------------------------------

void SerialClient::sendData(const QString &data)
{
//    qDebug() << "SerialClient::sendData: as STRING: " << data;

    if (data.isEmpty()) return;
    QByteArray ba = m_lvl2.packData(QByteArray::fromHex(data.toLatin1()));
    qDebug() << "SerialClient::sendData: " << ba.toHex();
    m_lastResp.clear();
    m_port.flush();
    m_port.write(ba);
//    m_port.waitForBytesWritten(20);
}

//-----------------------------------------------------------------

void SerialClient::sendDataTest(const QByteArray &data)
{
    qDebug() << "SerialClient::sendDataTest: data: " << data.toHex();

}

//-----------------------------------------------------------------

void SerialClient::logEnable(bool en)
{
    qDebug() << "SerialClient::logEnable: " << en;
    m_logEnabled = en;
    emit logEnabledChanged();
}

//-----------------------------------------------------------------

QString SerialClient::getRespAsHexString()
{
    QString resp = m_lastResp.toHex();
    m_lastResp.clear();
    return resp;
}

//-----------------------------------------------------------------

std::vector<int> SerialClient::getRespAsBin()
{
    std::vector<int> vec(m_lastResp.begin(), m_lastResp.end());
    m_lastResp.clear();
    m_lastRespList.clear();
    return vec;
}

//-----------------------------------------------------------------

QVariantList SerialClient::getTestList()
{
    qDebug() << "SerialClient::getTestList";

    QByteArray ba1;
    ba1.append(0x03);
    ba1.append(0x7A);
    ba1.append(0x08);
    QByteArray ba2("Test ba2");
    QByteArray ba3("Test sfdjhgsjh sgdfgj ba3");
    QByteArray ba4("Test hgjhgdsjhf ba4");
    QByteArray ba5("Test bla fgr ba5");

    QVariantList list;
    list << QVariant(ba1) << QVariant(ba2) << QVariant(ba3) << QVariant(ba4) << QVariant(ba5);
//    list.append(QVariant(ba1));

    return list;
}

//-----------------------------------------------------------------

QVariantList SerialClient::getRespAsList()
{
    QVariantList resp = m_lastRespList;
    m_lastRespList.clear();

    return resp;
}

//-----------------------------------------------------------------

}    // namespace trans

