#include "labelprinterclient.h"
#include <QUrl>

#include <QDebug>

namespace label
{

LabelPrinterClient::LabelPrinterClient(QObject *parent)
    : m_connected(false),
      m_resp("undefined")
{
    Q_UNUSED(parent)

    QObject::connect(&m_socket, &QWebSocket::connected, this, &LabelPrinterClient::onConnected);
    QObject::connect(&m_socket, &QWebSocket::disconnected, this, &LabelPrinterClient::onDisconnected);
    QObject::connect(&m_socket, &QWebSocket::sslErrors, this, &LabelPrinterClient::onSslErrors);
    QObject::connect(&m_socket, &QWebSocket::textMessageReceived, this, &LabelPrinterClient::onTextMessageReceived);
}

LabelPrinterClient::~LabelPrinterClient()
{
    m_socket.close();
}

//----------------------------------------------------------------------------

void LabelPrinterClient::onConnected()
{
    qDebug() << "LabelPrinterClient::onConnected";
    m_connected = true;
    emit connectChanged();
}

//----------------------------------------------------------------------------

void LabelPrinterClient::onDisconnected()
{
    qDebug() << "LabelPrinterClient::onDisconnected";
    m_connected = false;
    emit connectChanged();
}

//----------------------------------------------------------------------------

void LabelPrinterClient::onTextMessageReceived(const QString &message)
{
        qDebug() << "LabelPrinterClient::onTextMessageReceived: " << message;
        m_resp = message;
        emit respChanged();
}

//----------------------------------------------------------------------------

void LabelPrinterClient::onSslErrors(const QList<QSslError> &errors)
{
    Q_UNUSED(errors)
    qDebug() << "LabelPrinterClient::onSslErrors";
}

//----------------------------------------------------------------------------

void LabelPrinterClient::clearResponse()
{
    m_resp = "undefined";
    emit respChanged();
}

//----------------------------------------------------------------------------

void LabelPrinterClient::connect(const QString &url)
{
    qDebug() << "LabelPrinterClient::connect: " << url;
    m_socket.open(QUrl(url));
}

//----------------------------------------------------------------------------

void LabelPrinterClient::disconnect()
{
    m_socket.close();
}

//----------------------------------------------------------------------------

void LabelPrinterClient::send(const QString &mes)
{
    m_socket.sendTextMessage(mes);
}

//----------------------------------------------------------------------------

}    // namespace label

