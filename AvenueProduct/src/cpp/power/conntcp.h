#ifndef CONNTCP_H
#define CONNTCP_H

#include <QObject>
#include <QTcpSocket>
#include <QTimer>

namespace power
{

class ConnTcp : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool state READ isConnected NOTIFY stateChanged)
    Q_PROPERTY(bool connecting READ isConnecting NOTIFY connectingChanged)
    Q_PROPERTY(QString errorStr READ getErrorStr NOTIFY errorStrChanged)

private:
    QTcpSocket   m_socket;
    QString      m_uri;
    int          m_port;
    QString      m_errorStr;
    bool         m_state;         // connected or disconnected
    bool         m_connecting;

    QTimer       m_timer;

private:
    ConnTcp(const ConnTcp&);
    ConnTcp& operator=(const ConnTcp&);

private slots:
    void onConnected();
    void onDisconnected();
    void onStateChanged(QAbstractSocket::SocketState state);
    void onReadyRead();
    void onError(QAbstractSocket::SocketError err);

    void onTimeout();

public:
    explicit ConnTcp(const QString uri = "192.168.0.248", int port = 30000, QObject *parent = nullptr);
    ~ConnTcp();

signals:
    void rcvData(const QString &data);
    void pwConnected();
    void pwDisconnected();
    void stateChanged();
    void connectingChanged();
    void errorStrChanged();

public slots:
    void connectTcp(const QString &uri, int port);
    void connectTcp();
    void disconnectTcp();
    void sendData(const QString &data);

    bool isConnected() const     { return m_state; }
    bool isConnecting() const    { return m_connecting; }
    QString getErrorStr() const  { return m_errorStr; }
    QString getUri() const       { return m_uri; }
    int getPort() const          { return m_port; }


};


}    // namespace power


#endif // CONNTCP_H
