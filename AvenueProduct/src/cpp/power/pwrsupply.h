#ifndef PWRSUPPLY_H
#define PWRSUPPLY_H

#include <QObject>
#include <QTimer>

namespace power
{

class ConnTcp;

struct PwrSupplyConfig
{
    double   MinVoltage;
    double   MaxVoltage;
    double   MinFreq;
    double   MaxFreq;
    double   CurrRmsProtect;
    QString CurrRmsProtectMode;
    double   CurrPeakProtect;
    QString CurrPeakProtectMode;
    double   Voltage;
    double   Frequency;

    PwrSupplyConfig()
        : MinVoltage(0), MaxVoltage(300),
          MinFreq(45), MaxFreq(100),
          CurrRmsProtect(3), CurrRmsProtectMode("IMM"),
          CurrPeakProtect(9), CurrPeakProtectMode("IMM"),
          Voltage(220), Frequency(50)
    {
    }
};

enum PwrSupplyState
{
    PWR_STATE_IDLE,
    PWR_STATE_RESETING,
    PWR_STATE_MEAS
};

class PwrSupply : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString pwDescr READ getPwDescr NOTIFY pwDescrChanged)
    Q_PROPERTY(bool connected READ isConnected NOTIFY connectStateChanged)
    Q_PROPERTY(bool loaded READ isLoaded NOTIFY loadStateChanged)
    Q_PROPERTY(bool loadError READ isLoadError NOTIFY loadErrorChanged)
    Q_PROPERTY(double measVoltage READ getMeasVoltage NOTIFY measVoltageChanged)
    Q_PROPERTY(double measCurrent READ getMeasCurrent NOTIFY measCurrentChanged)
    Q_PROPERTY(double measPower READ getMeasPower NOTIFY measPowerChanged)
    Q_PROPERTY(double measPFactor READ getMeasPFactor NOTIFY measPFactorChanged)
    Q_PROPERTY(double measPeak READ getMeasPeak NOTIFY measPeakChanged)

private:
    ConnTcp  &m_conn;
    PwrSupplyConfig m_cfg;
    PwrSupplyState  m_state;
    bool      m_connected;
    bool      m_loaded;
    bool      m_loadError;
    QString   m_pwDescr;

    // Measure
    double    m_measVoltage;
    double    m_measCurrent;
    double    m_measPower;
    double    m_measPFactor;
    double    m_measPeak;

    QString   m_resp;
    QTimer    m_timer;

private:
    PwrSupply(const PwrSupply&);
    PwrSupply& operator=(const PwrSupply&);

    void init();
    void clear();

private slots:
    void onPwConnected();
    void onPwDisconnected();
    void onRcvData(const QString &data);
    void measure();

public:
    explicit PwrSupply(ConnTcp &conn, QObject *parent = nullptr);
    explicit PwrSupply(ConnTcp &conn, PwrSupplyConfig cfg, QObject *parent = nullptr);
    ~PwrSupply();

signals:
    void pwDescrChanged();
    void connectStateChanged();
    void loadStateChanged();
    void loadErrorChanged();
    void measVoltageChanged();
    void measCurrentChanged();
    void measPowerChanged();
    void measPFactorChanged();
    void measPeakChanged();


public slots:
    void pwConnect();
    void pwDisconnect();
    bool isConnected() const         { return m_connected; }
    QString getPwDescr() const       { return m_pwDescr; }
    bool isLoaded() const            { return m_loaded; }
    bool isLoadError() const         { return m_loadError; }
    double getMeasVoltage() const    { return m_measVoltage; }
    double getMeasCurrent() const    { return m_measCurrent; }
    double getMeasPower() const      { return m_measPower; }
    double getMeasPFactor() const    { return m_measPFactor; }
    double getMeasPeak() const       { return m_measPeak; }

    void setVoltage(double val);
    void loadOn();
    void loadOff();

    void reset();
};


}    // namespace power


#endif // PWRSUPPLY_H
