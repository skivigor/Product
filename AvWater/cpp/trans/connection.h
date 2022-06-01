#ifndef CONNECTION_H
#define CONNECTION_H

#include <QObject>

#include "ilevel2.h"
#include <QMap>
#include <QTimer>
#include <QTcpSocket>


namespace trans
{

class Connection : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool state READ isConnected NOTIFY stateChanged)
    Q_PROPERTY(bool connecting READ isConnecting NOTIFY connectingChanged)

private:
    QTcpSocket  m_socket;
    bool        m_state;        // connected or disconnected state
    bool        m_connecting;   // in the process of connection
    QTimer      m_timer;

    QMap<int, ILevel2 *>  m_mapLvl2;
    int                  m_lvl2;

private:
    Connection(const Connection&);
    Connection& operator=(const Connection&);

private slots:
    void onConnected();
    void onDisconnected();
    void onReadyRead();

    void onTimeout();

public:
    explicit Connection(QObject *parent = nullptr);
    ~Connection();

    void addLevel2(int id, ILevel2 *lvl);
    void setActiveLevel2(int id);

signals:
    void stateChanged();
    void connectingChanged();
    void rcvData(const QByteArray &data);

public slots:
    void connectTcp(const QString &uri, quint16 port);
    void disconnectTcp();
    bool isConnected() const      { return m_state; }
    bool isConnecting() const     { return m_connecting; }

    void sendData(const QByteArray &data);
};


}    // namespace trans


#endif // CONNECTION_H
