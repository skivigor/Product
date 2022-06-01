#include "pwrsupply.h"
#include "conntcp.h"

#include <QDebug>

namespace power
{

PwrSupply::PwrSupply(ConnTcp &conn, QObject *parent)
    : m_conn(conn),
      m_state(PWR_STATE_IDLE),
      m_connected(false),
      m_loaded(false),
      m_loadError(false),
      m_pwDescr("Unknown"),
      m_measVoltage(0),
      m_measCurrent(0),
      m_measPower(0),
      m_measPFactor(0),
      m_measPeak(0)
{
    Q_UNUSED(parent)

    init();
    qDebug() << "PwrSupply::PwrSupply: ctor";
}

PwrSupply::PwrSupply(ConnTcp &conn, PwrSupplyConfig cfg, QObject *parent)
    : m_conn(conn),
      m_cfg(cfg),
      m_state(PWR_STATE_IDLE),
      m_connected(false),
      m_loaded(false),
      m_loadError(false),
      m_pwDescr("Unknown"),
      m_measVoltage(0),
      m_measCurrent(0),
      m_measPower(0),
      m_measPFactor(0),
      m_measPeak(0)
{
    Q_UNUSED(parent)

    init();
    qDebug() << "PwrSupply::PwrSupply: ctor";
}

PwrSupply::~PwrSupply()
{
    qDebug() << "PwrSupply::~PwrSupply: dtor";
}

//-----------------------------------------------------------------

void PwrSupply::init()
{
    QObject::connect(&m_conn, &ConnTcp::pwConnected, this, &PwrSupply::onPwConnected);
    QObject::connect(&m_conn, &ConnTcp::pwDisconnected, this, &PwrSupply::onPwDisconnected);
    QObject::connect(&m_conn, &ConnTcp::rcvData, this, &PwrSupply::onRcvData);
    QObject::connect(&m_timer, &QTimer::timeout, this, &PwrSupply::measure);
    m_timer.setSingleShot(false);
    m_timer.setInterval(1000);
}

//-----------------------------------------------------------------

void PwrSupply::clear()
{
    m_state = PWR_STATE_IDLE;
    m_loaded = false;
    m_loadError = false;
    m_pwDescr = "Unknown";
    m_measVoltage = 0;
    m_measCurrent = 0;
    m_measPower = 0;
    m_measPFactor = 0;
    m_measPeak = 0;
    emit pwDescrChanged();
    emit loadStateChanged();
    emit loadErrorChanged();
    emit measVoltageChanged();
    emit measCurrentChanged();
    emit measPowerChanged();
    emit measPFactorChanged();
    emit measPeakChanged();
}

//-----------------------------------------------------------------

void PwrSupply::onPwConnected()
{
    qDebug() << "PwrSupply::onPwConnected";
    m_connected = true;
    emit connectStateChanged();

    reset();
}

//-----------------------------------------------------------------

void PwrSupply::onPwDisconnected()
{
    qDebug() << "PwrSupply::onPwDisconnected";
    clear();
    m_connected = false;
    emit connectStateChanged();
    m_timer.stop();
}

//-----------------------------------------------------------------

void PwrSupply::onRcvData(const QString &data)
{
//    qDebug() << "PwrSupply::onRcvData: data: " << data;

    if (m_state == PWR_STATE_RESETING)
    {
        m_resp += data;

        if (!data.contains('\n')) return;
        m_state = PWR_STATE_IDLE;
        m_pwDescr = m_resp;
        m_resp.clear();

        emit pwDescrChanged();
        return;
    }

    if (m_state == PWR_STATE_MEAS)
    {
        m_resp += data;
        QStringList list = m_resp.split('\n');
        if (list.size() < 6) return;

        m_loaded = list.at(0).toInt();
        if (!m_loaded)
        {
            m_timer.stop();
            emit loadStateChanged();
            return;
        }

        m_measVoltage = list.at(1).toDouble();
        m_measCurrent = list.at(2).toDouble();
        m_measPower = list.at(3).toDouble();
        m_measPFactor = list.at(4).toDouble();
        m_measPeak = list.at(5).toDouble();
        emit measVoltageChanged();
        emit measCurrentChanged();
        emit measPowerChanged();
        emit measPFactorChanged();
        emit measPeakChanged();
        return;
    }
}

//-----------------------------------------------------------------

void PwrSupply::measure()
{
    if (!m_connected) return;
    m_resp.clear();

//    qDebug() << "PwrSupply::measure";

    QString cmd = QString("OUTP?\nMEAS:VOLT?\nMEAS:CURR?\nMEAS:POW?\nMEAS:POW:PFAC?\nMEAS:CURR:PEAK?\n");
    m_conn.sendData(cmd);
}

//-----------------------------------------------------------------

void PwrSupply::pwConnect()
{
    m_conn.connectTcp();
}

//-----------------------------------------------------------------

void PwrSupply::pwDisconnect()
{
    loadOff();
    m_conn.disconnectTcp();
}

//-----------------------------------------------------------------

void PwrSupply::setVoltage(double val)
{
    if (!m_connected) return;

    QString cmd = QString("VOLT %1\n").arg(val);
    m_conn.sendData(cmd);
}

//-----------------------------------------------------------------

void PwrSupply::loadOn()
{
    if (!m_connected) return;

    QString cmd = QString("OUTP ON\n");
    m_conn.sendData(cmd);

    m_state = PWR_STATE_MEAS;
    m_loaded = true;
    emit loadStateChanged();
    m_timer.start();
}

//-----------------------------------------------------------------

void PwrSupply::loadOff()
{
    if (!m_connected) return;

    m_timer.stop();
    m_state = PWR_STATE_IDLE;
    m_loaded = false;
    emit loadStateChanged();

    QString cmd = QString("OUTP OFF\n");
    m_conn.sendData(cmd);
}

//-----------------------------------------------------------------

void PwrSupply::reset()
{
    if (!m_connected) return;
    m_resp.clear();

    QString cfgInit = QString("*CLS\nSYST:REM\nOUTP OFF\n");
    QString cfgVolt = QString("CONF:VOLT:MIN %1\nCONF:VOLT:MAX %2\n").arg(m_cfg.MinVoltage).arg(m_cfg.MaxVoltage);
    QString cfgFreq = QString("CONF:FREQ:MIN %1\nCONF:FREQ:MAX %2\n").arg(m_cfg.MinFreq).arg(m_cfg.MaxFreq);
    QString cfgRms = QString("CONF:PROT:CURR:RMS %1\nCONF:PROT:CURR:RMS:MOD %2\n").arg(m_cfg.CurrRmsProtect).arg(m_cfg.CurrRmsProtectMode);
    QString cfgPeak = QString("CONF:PROT:CURR:PEAK %1\nCONF:PROT:CURR:PEAK:MOD %2\n").arg(m_cfg.CurrPeakProtect).arg(m_cfg.CurrPeakProtectMode);
    QString cfgOut = QString("VOLT %1\nFREQ %2\n").arg(m_cfg.Voltage).arg(m_cfg.Frequency);
    QString idn = QString("*IDN?\n");

    QString cmd = cfgInit + cfgVolt + cfgFreq + cfgRms + cfgPeak + cfgOut + idn;
    m_conn.sendData(cmd);

    clear();
    m_state = PWR_STATE_RESETING;
}

//-----------------------------------------------------------------

}    // namespace power

