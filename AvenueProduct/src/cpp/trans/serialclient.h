#ifndef SERIALCLIENT_H
#define SERIALCLIENT_H

#include <QObject>
#include <QSerialPort>
#include <QVariantList>

#include <vector>

namespace trans
{

class ILevel2;

class SerialClient : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool state READ isConnected NOTIFY stateChanged)
    Q_PROPERTY(QString statusStr READ getStatusStr NOTIFY statusStrChanged)
    Q_PROPERTY(QString log READ getLog NOTIFY logChanged)
    Q_PROPERTY(bool logEnabled WRITE logEnable READ isLogEnabled NOTIFY logEnabledChanged)

private:
    QSerialPort    m_port;
    QString        m_portName;
    int            m_baudRate;
    QString        m_statusStr;
    bool           m_state;
    ILevel2       &m_lvl2;
    QString        m_log;
    bool           m_logEnabled;
    QByteArray     m_lastResp;
    QVariantList   m_lastRespList;

    bool           m_retry;

private:
    SerialClient(const SerialClient&);
    SerialClient& operator=(const SerialClient&);

    void resizeOutput();

private slots:
    void onReadyRead();
    void onError(QSerialPort::SerialPortError error);

public:
    explicit SerialClient(ILevel2 &lvl2, QObject *parent = nullptr);
    ~SerialClient();



signals:
    // IPort implementation
    void rcvData(const QByteArray &data);
    void sdnConnected();
    void sdnDisconnected();

    void stateChanged();
    void statusStrChanged();

    void logChanged();
    void logEnabledChanged();

public slots:
    void connectSerial(const QString &portName, int baudRate, const QString &parity,
                 const QString &stopBits, const QString &flowCtrl);
    void connectSerial(const QString &portName, int baudRate);
    void connectSerial();
    void disconnectSerial();
    bool isConnected() const          { return m_state; }
    QString getStatusStr() const      { return m_statusStr; }

    void sendData(const QByteArray &data);
    void sendData(const QString &data);
    void sendDataTest(const QByteArray &data);

    QString getLog() const     { return m_log; }
    bool isLogEnabled() const  { return m_logEnabled; }
    void logEnable(bool en);

    QString getRespAsHexString();
    std::vector<int> getRespAsBin();

    QVariantList getTestList();
    QVariantList getRespAsList();
};


}    // namespace trans


#endif // SERIALCLIENT_H
