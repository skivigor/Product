#include "dbserviceclient.h"

#include <QDebug>

namespace
{
const QString defResp("undefined");
}    // namespace

namespace db
{

DbServiceClient::DbServiceClient(QObject *parent)
    : m_connected(false),
      m_resp(defResp)
{
    Q_UNUSED(parent)

    QObject::connect(&m_socket, &QWebSocket::connected, this, &DbServiceClient::onConnected);
    QObject::connect(&m_socket, &QWebSocket::sslErrors, this, &DbServiceClient::onSslErrors);
    QObject::connect(&m_socket, &QWebSocket::textMessageReceived, this, &DbServiceClient::onTextMessageReceived);
//    qDebug() << "DbServiceClient::DbServiceClient: ctor";
}

DbServiceClient::~DbServiceClient()
{
//    qDebug() << "DbServiceClient::~DbServiceClient: dtor";
    m_socket.close();
}


//----------------------------------------------------------------------------

void DbServiceClient::onConnected()
{
    qDebug() << "DbServiceClient::onConnected";
    m_connected = true;
    emit connectChanged();
}

//----------------------------------------------------------------------------

void DbServiceClient::onDisconnected()
{
    qDebug() << "DbServiceClient::onDisconnected";
    m_connected = false;
    emit connectChanged();
}

//----------------------------------------------------------------------------

void DbServiceClient::onTextMessageReceived(const QString &message)
{
//    qDebug() << "DbServiceClient::onTextMessageReceived: " << message;
    m_resp = message;
    emit respChanged();
}

//----------------------------------------------------------------------------

void DbServiceClient::onSslErrors(const QList<QSslError> &errors)
{
    Q_UNUSED(errors)
    qDebug() << "DbServiceClient::onSslErrors";
}

//----------------------------------------------------------------------------

void DbServiceClient::clearResponse()
{
    m_resp = defResp;
    emit respChanged();
}

//----------------------------------------------------------------------------

void DbServiceClient::connect(const QString &url)
{
    qDebug() << "DbServiceClient::connect: " << url;
    m_socket.open(QUrl(url));
}

//----------------------------------------------------------------------------

void DbServiceClient::send(const QString &mes)
{
//    qDebug() << "DbServiceClient::send: mes: " << mes;
    m_socket.sendTextMessage(mes);
}

//----------------------------------------------------------------------------


}    // namespace db

