#include "conntcp.h"

#include <QDebug>

namespace power
{

ConnTcp::ConnTcp(const QString uri, int port, QObject *parent)
    : m_uri(uri), m_port(port), m_errorStr(""), m_state(false), m_connecting(false)
{
    Q_UNUSED(parent)

    QObject::connect(&m_socket, &QTcpSocket::connected, this, &ConnTcp::onConnected);
    QObject::connect(&m_socket, &QTcpSocket::disconnected, this, &ConnTcp::onDisconnected);
    QObject::connect(&m_socket, &QTcpSocket::readyRead, this, &ConnTcp::onReadyRead);
    QObject::connect(&m_socket, &QTcpSocket::stateChanged, this, &ConnTcp::onStateChanged);
    connect(&m_socket, QOverload<QAbstractSocket::SocketError>::of(&QAbstractSocket::error), this, &ConnTcp::onError);

    m_timer.setSingleShot(true);
    QObject::connect(&m_timer, &QTimer::timeout, this, &ConnTcp::onTimeout);

    qDebug() << "ConnTcp::ConnTcp: ctor";
}

ConnTcp::~ConnTcp()
{
    qDebug() << "ConnTcp::~ConnTcp: dtor";
    if (m_socket.isOpen()) m_socket.close();
}

//-----------------------------------------------------------------

void ConnTcp::onConnected()
{
    qDebug() << "ConnTcp::onConnected";

    m_timer.stop();
    m_state = true;
    m_connecting = false;
    m_errorStr = "";
    emit pwConnected();
    emit stateChanged();
    emit connectingChanged();
    emit errorStrChanged();
}

//-----------------------------------------------------------------

void ConnTcp::onDisconnected()
{
    qDebug() << "ConnTcp::onDisconnected";

    m_socket.close();
    m_state = false;
    m_connecting = false;
    m_errorStr = "";
    emit pwDisconnected();
    emit stateChanged();
    emit connectingChanged();
    emit errorStrChanged();
}

//-----------------------------------------------------------------

void ConnTcp::onStateChanged(QAbstractSocket::SocketState state)
{
    Q_UNUSED(state)
//    qDebug() << "ConnTcp::onStateChanged: ";
}

//-----------------------------------------------------------------

void ConnTcp::onReadyRead()
{
    QString data = m_socket.readAll();
//    qDebug() << "ConnectionTcp::onReadyRead: data: " << data;

    emit rcvData(data);
}

//-----------------------------------------------------------------

void ConnTcp::onError(QAbstractSocket::SocketError err)
{
    Q_UNUSED(err)
    m_timer.stop();
    m_socket.close();
    if (!m_connecting) return;

    m_state = false;
    m_connecting = false;
    m_errorStr = QString(m_socket.errorString());
    emit errorStrChanged();
    emit connectingChanged();
    emit stateChanged();

    qDebug() << "ConnTcp::onError: " << m_errorStr;
}

//-----------------------------------------------------------------

void ConnTcp::onTimeout()
{
    qDebug() << "ConnTcp::onTimeout";
    m_socket.disconnectFromHost();
    m_socket.close();
    m_connecting = false;
    emit connectingChanged();
}

//-----------------------------------------------------------------

void ConnTcp::connectTcp(const QString &uri, int port)
{
    if (m_socket.isOpen()) return;

    m_socket.connectToHost(uri, static_cast<quint16>(port));
    m_connecting = true;
    m_errorStr = "";
    emit connectingChanged();
    emit errorStrChanged();

    m_uri = uri;
    m_port = port;
    m_timer.setInterval(3000);
    m_timer.start();
}

//-----------------------------------------------------------------

void ConnTcp::connectTcp()
{
    connectTcp(m_uri, m_port);
}

//-----------------------------------------------------------------

void ConnTcp::disconnectTcp()
{
    m_socket.disconnectFromHost();
}

//-----------------------------------------------------------------

void ConnTcp::sendData(const QString &data)
{
    if (!m_state) return;
//    qDebug() << "ConnTcp::sendData: " << data;
    m_socket.write(data.toLocal8Bit());
}

//-----------------------------------------------------------------

}    // namespace power

