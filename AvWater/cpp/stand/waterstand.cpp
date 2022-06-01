#include "waterstand.h"
#include "trans/serialclient.h"
#include <QSerialPortInfo>

#include <QDebug>

namespace
{
const quint8  FnStandCode        = 0x7A;
const quint8  FnGetPulseCfg      = 0x01;
const quint8  FnSetPulseCfg      = 0x02;
const quint8  FnResetPulseCfg    = 0x03;
const quint8  FnStartTest        = 0x04;
const quint8  FnStopTest         = 0x05;
const quint8  FnGetResult        = 0x06;
const quint8  FnGetScaleWeight   = 0x07;
const quint8  FnGetScaleSpeed    = 0x08;
const quint8  FnGetMeterVolume   = 0x0A;
const quint8  FnGetMeterSpeed    = 0x0B;

QString CmdSearh("047A0101");
QString CmdGetPulseCfg("047A0101047A0102047A0103047A0104");
QString CmdResetPulseCfg("047A0301047A0302047A0303047A0304");
QString CmdGetData("037a07037a08047a0a01047a0a02047a0a03047a0a04047a0b01047a0b02047a0b03047a0b04");
//QString CmdGetResult("037A06");
QString CmdGetResult("037a07037a08047a0a01047a0a02047a0a03047a0a04047a0b01047a0b02047a0b03047a0b04037A06");
QString CmdStopTest("037A05");
}    // namespace

namespace stand
{

WaterStand::WaterStand(trans::SerialClient &serial, int baud, QObject *parent)
    : m_serial(serial),
      m_baud(baud)
{
    Q_UNUSED(parent)

    QObject::connect(&m_serial, &trans::SerialClient::rcvData, this, &WaterStand::onRcvData);
    QObject::connect(&m_serial, &trans::SerialClient::sdnConnected, this, &WaterStand::onSdnConnected);
    QObject::connect(&m_serial, &trans::SerialClient::sdnDisconnected, this, &WaterStand::onSdnDisconnected);

    m_timer.setSingleShot(true);
    QObject::connect(&m_timer, &QTimer::timeout, this, &WaterStand::onTimeout);
}

WaterStand::~WaterStand()
{
    //
}

//-----------------------------------------------------------------

void WaterStand::setVendorList(const QList<int> &list)
{
    m_vendorList = list;
}

//-----------------------------------------------------------------

void WaterStand::onRcvData(const QByteArray &data)
{
//    qDebug() << "WaterStand::onRcvData: " << data.toHex();

    // Search stand
    if (m_mode == STAND_SEARCH && data.at(1) == FnStandCode && data.at(2) == FnGetPulseCfg)
    {
        m_timer.stop();
        m_mode = STAND_WORK;
        qDebug() << "WaterStand::onRcvData: stand finded at port: " << m_port;

        m_state = true;
        emit stateChanged();
        emit portChanged();

        return;
    }

    // Get Pulse config
    if (m_mode == STAND_WORK && data.size() == 8 && data.at(1) == FnStandCode && data.at(2) == FnGetPulseCfg)
    {
        QJsonObject obj;
        quint8 id = static_cast<quint8>(data.at(3));
        quint16 weight = static_cast<quint16>((static_cast<quint8>(data.at(5)) << 8) + static_cast<quint8>(data.at(4)));
        obj["id"] = id;
        obj["weight"] = weight;
        obj["enable"] = data.at(6);
        obj["master"] = data.at(7);

        m_pulseCfg.append(obj);
        if (id == 4) emit pulseCfgChanged();
        return;
    }

    // Set/Reset pulse config
    if (m_mode == STAND_WORK && data.size() == 4 && data.at(1) == FnStandCode && (data.at(2) == FnSetPulseCfg || data.at(2) == FnResetPulseCfg) && data.at(3) == 4)
    {
        readPulseConfig();
        return;
    }

    // Get Scale weight
    if (m_mode == STAND_WORK && data.size() == 6 && data.at(1) == FnStandCode && data.at(2) == FnGetScaleWeight)
    {
        qint16 weight = static_cast<qint16>((static_cast<quint8>(data.at(4)) << 8) + static_cast<quint8>(data.at(3)));
        quint8 status = static_cast<quint8>(data.at(5));

        QJsonObject scale;
        if (m_standData.value("scale").isObject()) scale = m_standData.value("scale").toObject();
        scale["weight"] = weight;
        scale["status"] = status;

        m_standData["scale"] = scale;
        return;
    }

    // Get Scale speed
    if (m_mode == STAND_WORK && data.size() == 5 && data.at(1) == FnStandCode && data.at(2) == FnGetScaleSpeed)
    {
        qint16 speed = static_cast<qint16>((static_cast<quint8>(data.at(4)) << 8) + static_cast<quint8>(data.at(3)));

        QJsonObject scale;
        if (m_standData.value("scale").isObject()) scale = m_standData.value("scale").toObject();
        scale["speed"] = speed;

        m_standData["scale"] = scale;
        return;
    }

    // Get Meter volume
    if (m_mode == STAND_WORK && data.size() == 8 && data.at(1) == FnStandCode && data.at(2) == FnGetMeterVolume)
    {
        quint8 id = static_cast<quint8>(data.at(3));
        quint32 volume = static_cast<quint32>((static_cast<quint8>(data.at(7)) << 24) + (static_cast<quint8>(data.at(6)) << 16)
                                              + (static_cast<quint8>(data.at(5)) << 8) + static_cast<quint8>(data.at(4)));
        QVariant vol = volume;

        QJsonArray arr;
        if (m_standData.value("meter").isArray()) arr = m_standData.value("meter").toArray();

        QJsonObject obj;
        if (arr.at(id - 1).isObject()) obj = arr.at(id - 1).toObject();
        obj.insert("volume", QJsonValue::fromVariant(vol));
        if (arr.at(id - 1).isObject()) arr.replace(id - 1, obj);
        else arr.append(obj);

        m_standData["meter"] = arr;
        return;
    }

    // Get Meter speed
    if (m_mode == STAND_WORK && data.size() == 6 && data.at(1) == FnStandCode && data.at(2) == FnGetMeterSpeed)
    {
        quint8 id = static_cast<quint8>(data.at(3));
        quint16 speed = static_cast<quint16>((static_cast<quint8>(data.at(5)) << 8) + static_cast<quint8>(data.at(4)));

        QJsonArray arr;
        if (m_standData.value("meter").isArray()) arr = m_standData.value("meter").toArray();

        QJsonObject obj;
        if (arr.at(id - 1).isObject()) obj = arr.at(id - 1).toObject();
        obj["speed"] = speed;
        if (arr.at(id - 1).isObject()) arr.replace(id - 1, obj);
        else arr.append(obj);

        m_standData["meter"] = arr;
        if (id == 4) emit standDataChanged();
        return;
    }

    // Get Result
    if (m_mode == STAND_WORK && data.size() == 0x14 && data.at(1) == FnStandCode && data.at(2) == FnGetResult)
    {
        quint8 state = static_cast<quint8>(data.at(3));
        quint16 val1 = static_cast<quint16>((static_cast<quint8>(data.at(5)) << 8) + static_cast<quint8>(data.at(4)));
        quint16 val2 = static_cast<quint16>((static_cast<quint8>(data.at(7)) << 8) + static_cast<quint8>(data.at(6)));
        quint16 val3 = static_cast<quint16>((static_cast<quint8>(data.at(9)) << 8) + static_cast<quint8>(data.at(8)));
        quint16 val4 = static_cast<quint16>((static_cast<quint8>(data.at(11)) << 8) + static_cast<quint8>(data.at(10)));
        quint16 meterVolume1 = static_cast<quint16>((static_cast<quint8>(data.at(13)) << 8) + static_cast<quint8>(data.at(12)));
        quint16 meterVolume2 = static_cast<quint16>((static_cast<quint8>(data.at(15)) << 8) + static_cast<quint8>(data.at(14)));
        quint16 meterVolume3 = static_cast<quint16>((static_cast<quint8>(data.at(17)) << 8) + static_cast<quint8>(data.at(16)));
        quint16 meterVolume4 = static_cast<quint16>((static_cast<quint8>(data.at(19)) << 8) + static_cast<quint8>(data.at(18)));

        m_result["state"] = state;
        m_result["val1"] = val1;
        m_result["val2"] = val2;
        m_result["val3"] = val3;
        m_result["val4"] = val4;
        m_result["meterVolume1"] = meterVolume1;
        m_result["meterVolume2"] = meterVolume2;
        m_result["meterVolume3"] = meterVolume3;
        m_result["meterVolume4"] = meterVolume4;

        emit resultChanged();
        return;
    }

    // Start test
    if (m_mode == STAND_WORK && data.size() == 3 && data.at(1) == FnStandCode && data.at(2) == FnStartTest)
    {
        m_testStarted = true;
        emit testStartedChanged();
        return;
    }

    // Stop test
    if (m_mode == STAND_WORK && data.size() == 3 && data.at(1) == FnStandCode && data.at(2) == FnStopTest)
    {
        m_testStarted = false;
        emit testStartedChanged();
        return;
    }
}

//-----------------------------------------------------------------

void WaterStand::onSdnConnected()
{
    qDebug() << "WaterStand::onSdnConnected";
}

//-----------------------------------------------------------------

void WaterStand::onSdnDisconnected()
{
    qDebug() << "WaterStand::onSdnDisconnected";
}

//-----------------------------------------------------------------

void WaterStand::onTimeout()
{
//    qDebug() << "WaterStand::onTimeout";
    if (m_mode == STAND_SEARCH && !m_portList.isEmpty())
    {
        m_serial.disconnectSerial();
        search();
        return;
    }
}

//-----------------------------------------------------------------

void WaterStand::search()
{
    qDebug() << "WaterStand::search";
    if (m_mode != STAND_SEARCH) m_mode = STAND_SEARCH;

    if (m_portList.isEmpty())
    {
        const auto infos = QSerialPortInfo::availablePorts();
        for (const QSerialPortInfo &info : infos)
        {
            if (info.portName().contains("USB") || info.portName().contains("COM"))
            {
                if (m_vendorList.isEmpty()) { m_portList << info.portName(); continue; }
                if (!m_vendorList.isEmpty() && m_vendorList.contains(info.vendorIdentifier())) m_portList << info.portName();
            }
            qDebug() << "WaterStand::search: Port info: " << info.vendorIdentifier() << " : " << info.portName() << " : " << info.manufacturer() << " : " << info.description();
        }
        if (m_portList.isEmpty()) return;
    }
    qDebug() << "WaterStand::search: port list: " << m_portList;

    for (int i = 0; i < m_portList.size(); ++i)
    {
        m_port = m_portList.first();
        m_portList.removeFirst();

        bool ret = m_serial.connectSerial(m_port, m_baud);
        if (ret == true) break;
    }

    if (m_serial.isConnected() == false) return;
    m_serial.sendData(CmdSearh);
    m_timer.start(500);
}

//-----------------------------------------------------------------

void WaterStand::readPulseConfig()
{
    qDebug() << "WaterStand::readPulseConfig";

    if (m_state == false) return;

    m_pulseCfg = QJsonArray();
    m_serial.sendData(CmdGetPulseCfg);

}

//-----------------------------------------------------------------

void WaterStand::writePulseConfig(const QJsonArray &cfg)
{
    qDebug() << "WaterStand::writePulseConfig: cfg: " << cfg;

    QByteArray ba;
    for (int i = 0; i < cfg.size(); ++i)
    {
        quint8 id = static_cast<quint8>(cfg.at(i)["id"].toInt());
        quint8 enable = static_cast<quint8>(cfg.at(i)["enable"].toInt());
        quint8 master = static_cast<quint8>(cfg.at(i)["master"].toInt());
        quint16 weight = static_cast<quint16>(cfg.at(i)["weight"].toInt());

        ba.append(8);  // len
        ba.append(FnStandCode);
        ba.append(FnSetPulseCfg);
        ba.append(static_cast<char>(id));
//        ba.append((const char *)&weight, sizeof(weight));
        ba.append(reinterpret_cast<const char *>(&weight), sizeof(weight));
        ba.append(static_cast<char>(enable));
        ba.append(static_cast<char>(master));
    }

    m_serial.sendData(ba);
}

//-----------------------------------------------------------------

void WaterStand::resetPulseConfig()
{
    qDebug() << "WaterStand::resetPulseConfig";

    if (m_state == false) return;
    m_serial.sendData(CmdResetPulseCfg);
}

//-----------------------------------------------------------------

void WaterStand::startTest(const QJsonObject &cfg)
{
    qDebug() << "WaterStand::startTest: " << cfg;
    quint8 mode = static_cast<quint8>(cfg["mode"].toInt());
    quint16 volume = static_cast<quint16>(cfg["volume"].toInt());

    QByteArray ba;
    ba.append(6);
    ba.append(FnStandCode);
    ba.append(FnStartTest);
    ba.append(static_cast<char>(mode));
    ba.append(reinterpret_cast<const char *>(&volume), sizeof(volume));

    m_serial.sendData(ba);
}

//-----------------------------------------------------------------

void WaterStand::stopTest()
{
    qDebug() << "WaterStand::stopTest";

    if (m_state == false) return;
    m_serial.sendData(CmdStopTest);
}

//-----------------------------------------------------------------

void WaterStand::readData()
{
    qDebug() << "WaterStand::readData";
    if (m_state == false) return;

    m_standData = QJsonObject();
    m_serial.sendData(CmdGetData);
}

//-----------------------------------------------------------------

void WaterStand::readResult()
{
    qDebug() << "WaterStand::readResult";
    if (m_state == false) return;

    m_result = QJsonObject();
    m_serial.sendData(CmdGetResult);
}

//-----------------------------------------------------------------

}    // namespace stand

