#ifndef WATERSTAND_H
#define WATERSTAND_H

#include <QObject>
#include <QTimer>

#include <QJsonObject>
#include <QJsonArray>

namespace trans
{
class SerialClient;
}    // namespace trans

namespace stand
{

class WaterStand : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool state READ isConnected NOTIFY stateChanged)
    Q_PROPERTY(QString statusStr READ getStatusStr NOTIFY statusStrChanged)
    Q_PROPERTY(QString port READ getPort NOTIFY portChanged)
    Q_PROPERTY(bool testStarted READ isTestStarted WRITE setTestStarted NOTIFY testStartedChanged)

    Q_PROPERTY(QJsonArray pulseCfg READ getPulseCfg NOTIFY pulseCfgChanged)
    Q_PROPERTY(QJsonObject standData READ getStandData NOTIFY standDataChanged)
    Q_PROPERTY(QJsonObject result READ getResult NOTIFY resultChanged)

private:
    enum StandMode
    {
        STAND_IDLE,
        STAND_SEARCH,
        STAND_WORK
    };

private:
    trans::SerialClient &m_serial;
    QList<int>   m_vendorList;
    int          m_baud;
    bool         m_state        = false;
    QString      m_statusStr    = "";
    bool         m_testStarted  = false;
    StandMode    m_mode         = STAND_IDLE;
    QString      m_port         = "";
    QStringList  m_portList;

    QTimer    m_timer;

    QJsonArray   m_pulseCfg;
    QJsonObject  m_standData;
    QJsonObject  m_result;


private slots:
    void onRcvData(const QByteArray &data);
    void onSdnConnected();
    void onSdnDisconnected();
    void onTimeout();

public:
    explicit WaterStand(trans::SerialClient &serial, int baud, QObject *parent = nullptr);
    ~WaterStand();

signals:
    void stateChanged();
    void statusStrChanged();
    void portChanged();
    void testStartedChanged();

    void pulseCfgChanged();
    void standDataChanged();
    void resultChanged();

public slots:
    bool isConnected() const       { return m_state; }
    QString getStatusStr() const   { return m_statusStr; }
    QString getPort() const        { return m_port; }
    bool isTestStarted() const     { return m_testStarted; }
    void setTestStarted(bool val)  { m_testStarted = val; emit testStartedChanged(); }
    QJsonArray getPulseCfg() const { return m_pulseCfg; }
    QJsonObject getStandData() const    { return m_standData; }
    QJsonObject getResult() const  { return m_result; }

    void setVendorList(const QList<int> &list);

    void search();
    void readPulseConfig();
    void writePulseConfig(const QJsonArray &cfg);
    void resetPulseConfig();

    void startTest(const QJsonObject &cfg);
    void stopTest();

    void readData();
    void readResult();
};


}    // namespace stand


#endif // WATERSTAND_H
