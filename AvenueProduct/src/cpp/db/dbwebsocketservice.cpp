#include "dbwebsocketservice.h"
#include "sqldatabase.h"
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


namespace db
{

DbWebsocketService::DbWebsocketService(SqlDatabase &db, const QString &jsPath, quint16 port, bool secured, QObject *parent)
    : m_db(db),
      m_pServer(nullptr)
{
    Q_UNUSED(parent)
    setConfig(jsPath, port, secured);
}

DbWebsocketService::DbWebsocketService(SqlDatabase &db, const QString &jsPath, const QString &cfgPath, QObject *parent)
    : m_db(db),
      m_pServer(nullptr)
{
    Q_UNUSED(parent)

    QJsonDocument doc = util::FileLoader::instance().getFileAsJsonDoc(cfgPath);
    assert(!doc.isEmpty());

    QJsonObject jObj = doc.object();
    assert(jObj["wsServer"].isObject());
    QJsonObject cfg = jObj["wsServer"].toObject();
    quint16 port = static_cast<quint16>(cfg["port"].toInt());
    bool secured = cfg["secured"].toBool();
    setConfig(jsPath, port, secured);
}

DbWebsocketService::~DbWebsocketService()
{
    m_pServer->close();
    qDeleteAll(m_clients.keys());
    m_clients.clear();
}

//----------------------------------------------------------------------------

void DbWebsocketService::setConfig(const QString &jsPath, quint16 port, bool secured)
{
    m_db.init();
//    assert(m_db.init());
    m_engine.installExtensions(QJSEngine::ConsoleExtension);

    QJSValue m_jsObj = m_engine.newQObject(&m_db);
    m_engine.globalObject().setProperty("db", m_jsObj);

    m_jsModule = m_engine.importModule(jsPath);
    assert(!m_jsModule.isError());

    // Starting web socket server
    if (!secured)
    {
        m_pServer = new QWebSocketServer(QStringLiteral("AvDatabase Service: Non secured"), QWebSocketServer::NonSecureMode, this);
        assert(m_pServer);
    } else
    {
        // TODO
    }

    assert(m_pServer->listen(QHostAddress::Any, port));
    QObject::connect(m_pServer, &QWebSocketServer::newConnection, this, &DbWebsocketService::onNewConnection);
    QObject::connect(m_pServer, &QWebSocketServer::sslErrors, this, &DbWebsocketService::onSslErrors);

    qDebug() << "DbWebsocketService::setConfig: Started in " << (secured ? "Secured mode" : "Non secured mode");
}

//----------------------------------------------------------------------------

void DbWebsocketService::onNewConnection()
{
    qDebug() << "DbWebsocketService::onNewConnection: create";
    QWebSocket *pSocket = m_pServer->nextPendingConnection();
    assert(pSocket);
    qDebug() << "DbWebsocketService::onNewConnection: peer: " << pSocket->peerAddress() << ":" << pSocket->peerPort();

    QObject::connect(pSocket, &QWebSocket::textMessageReceived, this, &DbWebsocketService::onTextMessageReceived);
    QObject::connect(pSocket, &QWebSocket::binaryMessageReceived, this, &DbWebsocketService::onBinaryMessageReceived);
    QObject::connect(pSocket, &QWebSocket::disconnected, this, &DbWebsocketService::onDisconnected);

    m_clients.insert(pSocket, false);
}

//----------------------------------------------------------------------------

void DbWebsocketService::onDisconnected()
{
    qDebug() << "DbWebsocketService::onDisconnected: processing";
    QWebSocket *pClient = qobject_cast<QWebSocket *>(sender());
    if (pClient)
    {
        qDebug() << "DbWebsocketService::onDisconnected: peer: " << pClient->peerAddress() << ":" << pClient->peerPort();
        m_clients.remove(pClient);
        pClient->deleteLater();
    }
}

//----------------------------------------------------------------------------

void DbWebsocketService::onTextMessageReceived(const QString &message)
{
    QWebSocket *pClient = qobject_cast<QWebSocket *>(sender());
    if (!pClient) return;
    qDebug() << "DbWebsocketService::onTextMessageReceived: peer: " << pClient->peerAddress() << ":" << pClient->peerPort();

    // Check JSON format
    QJsonDocument doc = QJsonDocument::fromJson(message.toUtf8());
    // TODO

    // Check database connection
    QJsonObject obj = doc.object();
    // TODO

    // Check request
    // TODO

    QJsonArray arr;
    QJSValueList args;
    if (obj["args"].isArray()) arr = obj["args"].toArray();
    for (int i = 0; i < arr.size(); ++i) args << m_engine.toScriptValue(arr.at(i));

    // Check function name
    QString funcName = obj["req"].toString();
    QJSValue function = m_jsModule.property(funcName);
    if (function.isUndefined())
    {
        QString warn = "DbWebsocketService::onTextMessageReceived: Error: \"" + funcName + "\" is not function name";
        if (obj["uuid"].isString()) sendError(pClient, warn, obj["uuid"].toString());
            else sendError(pClient, warn);
        return;
    }

    // Check auth
    bool waitAuth = false;
    if (m_clients.value(pClient) != true)
    {
        // checkUser
        if (obj["req"].toString() != "checkUser")
        {
            QString warn = "Authorization required";
            if (obj["uuid"].isString()) sendError(pClient, warn, obj["uuid"].toString());
                else sendError(pClient, warn);
            return;
        }
        waitAuth = true;
    }

    // Run function
    QJSValue ret = function.call(args);
    if (ret.isError())
    {
        int line = ret.property("lineNumber").toInt();
        QString err = ret.toString();
        QString warn = "DbWebsocketService::onTextMessageReceived: Exception at line " + QString::number(line) + " : " + err;
        if (obj["uuid"].isString()) sendError(pClient, warn, obj["uuid"].toString());
            else sendError(pClient, warn);
        return;
    }

    QJsonObject result = ret.toVariant().toJsonObject();
    result.insert("ack", funcName);
    // TODO
    pClient->sendTextMessage(jsonToString(result));

    if (waitAuth && !result["error"].toBool()) m_clients.insert(pClient, true);
}

//----------------------------------------------------------------------------

void DbWebsocketService::onBinaryMessageReceived(const QByteArray &message)
{
    QWebSocket *pClient = qobject_cast<QWebSocket *>(sender());
    if (!pClient) return;

    qDebug() << "DbWebsocketService::onBinaryMessageReceived: mes: " << message.toHex();
}

//----------------------------------------------------------------------------

void DbWebsocketService::onSslErrors(const QList<QSslError> &errors)
{
    Q_UNUSED(errors)

    qDebug() << "DbWebsocketService::onSslErrors: Ssl errors";
}

//----------------------------------------------------------------------------

}    // namespace db

