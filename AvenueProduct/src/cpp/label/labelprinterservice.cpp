#include "labelprinterservice.h"
#include "labelprinter.h"
#include "util/fileloader.h"
#include <QWebSocketServer>
#include <QWebSocket>
#include <QSslCertificate>
#include <QSslKey>
#include <QFile>

#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>

#include <QDebug>
#include "assert.h"


namespace
{

QString jsonToString(const QJsonObject &json)
{
    QJsonDocument doc(json);
    QString str(doc.toJson(QJsonDocument::Compact));
    return str;
}

void sendError(QWebSocket *ptr, const QString &mes)
{
    qWarning() << mes;

    QJsonObject obj;
    obj.insert("error", true);
    obj.insert("errorString", mes);
    ptr->sendTextMessage(jsonToString(obj));
}

void sendError(QWebSocket *ptr, const QString &mes, const QString &uuid)
{
    qWarning() << mes;

    QJsonObject obj;
    obj.insert("error", true);
    obj.insert("errorString", mes);
    obj.insert("uuid", uuid);
    ptr->sendTextMessage(jsonToString(obj));
}

}    // namespace


namespace label
{

LabelPrinterService::LabelPrinterService(LabelPrinter &printer, const QString &cfgPath, QObject *parent)
    : m_printer(printer),
      m_pServer(nullptr)
{
    Q_UNUSED(parent)

    QJsonDocument doc = util::FileLoader::instance().getFileAsJsonDoc(cfgPath);
    assert(!doc.isEmpty());

    QJsonObject jObj = doc.object();
    assert(jObj["printerServer"].isObject());
    QJsonObject cfg = jObj["printerServer"].toObject();
    quint16 port = static_cast<quint16>(cfg["port"].toInt());
    bool secured = cfg["secured"].toBool();
    setConfig(port, secured);
}

LabelPrinterService::LabelPrinterService(LabelPrinter &printer, const QJsonObject &cfg, QObject *parent)
    : m_printer(printer)
{
    Q_UNUSED(parent)
    quint16 port = static_cast<quint16>(cfg["port"].toInt());
    bool secured = cfg["secured"].toBool();
    setConfig(port, secured);
}

LabelPrinterService::~LabelPrinterService()
{
    m_pServer->close();
}

//----------------------------------------------------------------------------

void LabelPrinterService::setConfig(quint16 port, bool secured)
{
    // Starting web socket server
    if (!secured)
    {
        m_pServer = new QWebSocketServer(QStringLiteral("LabelPrinter Service: Non secured"), QWebSocketServer::NonSecureMode, this);
        assert(m_pServer);
    } else
    {
        m_pServer = new QWebSocketServer(QStringLiteral("LabelPrinter Service: Secured"), QWebSocketServer::SecureMode, this);
        assert(m_pServer);

        QFile certFile(QStringLiteral(":/localhost.cert"));
        QFile keyFile(QStringLiteral(":/localhost.key"));
        certFile.open(QIODevice::ReadOnly);
        keyFile.open(QIODevice::ReadOnly);
        QSslCertificate certificate(&certFile, QSsl::Pem);
        QSslKey sslKey(&keyFile, QSsl::Rsa, QSsl::Pem);
        certFile.close();
        keyFile.close();

        QSslConfiguration sslConfiguration;
        sslConfiguration.setPeerVerifyMode(QSslSocket::VerifyNone);
        sslConfiguration.setLocalCertificate(certificate);
        sslConfiguration.setPrivateKey(sslKey);
        sslConfiguration.setProtocol(QSsl::TlsV1SslV3);

        m_pServer->setSslConfiguration(sslConfiguration);
    }

    assert(m_pServer->listen(QHostAddress::Any, port));
    QObject::connect(m_pServer, &QWebSocketServer::newConnection, this, &LabelPrinterService::onNewConnection);
    QObject::connect(m_pServer, &QWebSocketServer::sslErrors, this, &LabelPrinterService::onSslErrors);

    qDebug() << "LabelPrinterService::setConfig: Started in " << (secured ? "Secured mode" : "Non secured mode");
}

//----------------------------------------------------------------------------

void LabelPrinterService::onNewConnection()
{
    qDebug() << "LabelPrinterService::onNewConnection: create";
    QWebSocket *pSocket = m_pServer->nextPendingConnection();
    assert(pSocket);
    qDebug() << "LabelPrinterService::onNewConnection: peer: " << pSocket->peerAddress() << ":" << pSocket->peerPort();

    QObject::connect(pSocket, &QWebSocket::textMessageReceived, this, &LabelPrinterService::onTextMessageReceived);
    QObject::connect(pSocket, &QWebSocket::binaryMessageReceived, this, &LabelPrinterService::onBinaryMessageReceived);
    QObject::connect(pSocket, &QWebSocket::disconnected, this, &LabelPrinterService::onDisconnected);
}

//----------------------------------------------------------------------------

void LabelPrinterService::onDisconnected()
{
    qDebug() << "LabelPrinterService::onDisconnected: processing";
    QWebSocket *pClient = qobject_cast<QWebSocket *>(sender());
    if (pClient)
    {
        qDebug() << "LabelPrinterService::onDisconnected: peer: " << pClient->peerAddress() << ":" << pClient->peerPort();
        pClient->deleteLater();
    }
}

//----------------------------------------------------------------------------

void LabelPrinterService::onTextMessageReceived(const QString &message)
{
    QWebSocket *pClient = qobject_cast<QWebSocket *>(sender());
    if (!pClient) return;
    qDebug() << "LabelPrinterService::onTextMessageReceived: peer: " << pClient->peerAddress() << ":" << pClient->peerPort();

    // Check JSON format
    QJsonDocument doc = QJsonDocument::fromJson(message.toUtf8());
    if (!doc.isObject())
    {
        QString warn = "LabelPrinterService::onTextMessageReceived: message: " + message + " is NOT json object";
        sendError(pClient, warn);
        return;
    }

    // Check request
    QJsonObject obj = doc.object();
    if (!obj["req"].isString())
    {
        QString warn = "LabelPrinterService::onTextMessageReceived: message: " + message + " NOT contains request";
        if (obj["uuid"].isString()) sendError(pClient, warn, obj["uuid"].toString());
            else sendError(pClient, warn);
        return;
    }
    QString method = obj["req"].toString();
    if (method != "print")
    {
        QString warn = "LabelPrinterService::onTextMessageReceived: method: " + method + " unsupported";
        if (obj["uuid"].isString()) sendError(pClient, warn, obj["uuid"].toString());
            else sendError(pClient, warn);
        return;
    }

    // Check args
    // TODO
    QJsonArray arr = obj["args"].toArray();
    // TODO

    // Print profile
    QString profile = arr.at(0).toString();
    // Print args
    QJsonArray args = arr.at(1).toArray();
    QStringList list;
    for (auto x : args) list << x.toString();
    // Print num
    int num = arr.size() > 2 ? arr.at(2).toInt() : 0;

    bool res = false;
    if (num > 0) res = m_printer.print(profile, list, num);
    else res = m_printer.print(profile, list);
    if (res == false) { sendError(pClient, "Print error"); return; }

    QJsonObject result;
    result.insert("ack", method);
    result.insert("error", false);
    if (obj["uuid"].isString()) result.insert("uuid", obj["uuid"].toString());
    pClient->sendTextMessage(jsonToString(result));
}

//----------------------------------------------------------------------------

void LabelPrinterService::onBinaryMessageReceived(const QByteArray &message)
{
    QWebSocket *pClient = qobject_cast<QWebSocket *>(sender());
    if (!pClient) return;

    qDebug() << "LabelPrinterService::onBinaryMessageReceived: mes: " << message.toHex();
}

//----------------------------------------------------------------------------

void LabelPrinterService::onSslErrors(const QList<QSslError> &errors)
{
    Q_UNUSED(errors)

    qDebug() << "LabelPrinterService::onSslErrors: Ssl errors";
}

//----------------------------------------------------------------------------

}    // namespace label

