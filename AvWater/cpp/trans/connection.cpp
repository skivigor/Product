#include "connection.h"

#include <QString>
#include <QDebug>

namespace trans
{

Connection::Connection(QObject *parent)
    : m_state(false), m_connecting(false), m_lvl2(0)
{
    Q_UNUSED(parent)

    QObject::connect(&m_socket, SIGNAL(connected()), SLOT(onConnected()));
    QObject::connect(&m_socket, SIGNAL(disconnected()), SLOT(onDisconnected()));
    QObject::connect(&m_socket, SIGNAL(readyRead()), SLOT(onReadyRead()));

    m_timer.setSingleShot(true);
    m_timer.setInterval(7000);
    QObject::connect(&m_timer, SIGNAL(timeout()), this, SLOT(onTimeout()), Qt::QueuedConnection);
}

Connection::~Connection()
{
}


//-----------------------------------------------------------------

void Connection::onConnected()
{
    m_timer.stop();
    m_connecting = false;
    connectingChanged();
    m_state = true;
    emit stateChanged();
}

//-----------------------------------------------------------------

void Connection::onDisconnected()
{
    qDebug() << "Connection::onDisconnected";
    m_socket.close();
    m_state = false;
    emit stateChanged();
}

//-----------------------------------------------------------------

void Connection::onReadyRead()
{
    QByteArray ba = m_socket.readAll();
    qDebug() << "Connection::onReadyRead: " << ba.toHex();
    if (m_lvl2 == 0) { emit rcvData(ba); return; }

    ILevel2 *ptr = m_mapLvl2.value(m_lvl2);
    if (!ptr) return;
    QByteArrayList list = ptr->unpackData(ba);
    for (int i = 0; i < list.size(); ++i) emit rcvData(list.at(i));
}

//-----------------------------------------------------------------

void Connection::onTimeout()
{
    m_socket.abort();
    m_socket.close();
    m_connecting = false;
    connectingChanged();
}

//-----------------------------------------------------------------

void Connection::addLevel2(int num, ILevel2 *lvl)
{
    m_mapLvl2.insert(num, lvl);
}

//-----------------------------------------------------------------

void Connection::setActiveLevel2(int id)
{
    m_lvl2 = id;
}

//-----------------------------------------------------------------

void Connection::connectTcp(const QString &uri, quint16 port)
{
    if (m_socket.isOpen()) return;
    m_socket.connectToHost(uri, port);

    m_connecting = true;
    connectingChanged();
    m_timer.start();
}

//-----------------------------------------------------------------

void Connection::disconnectTcp()
{
    m_socket.disconnectFromHost();
}

//-----------------------------------------------------------------

void Connection::sendData(const QByteArray &data)
{
    if (!m_socket.isOpen() || !m_socket.isValid()) return;
    if (data.isEmpty()) return;

    if (m_lvl2 == 0)
    {
        qDebug() << "Connection::sendData: " << data.toHex();
        m_socket.write(data);
        return;
    }

    ILevel2 *lvl = m_mapLvl2.value(m_lvl2);
    QByteArray ba = lvl->packData(data);
    qDebug() << "Connection::sendData: " << ba.toHex();

    m_socket.write(ba);
}

//-----------------------------------------------------------------

}    // namespace trans


