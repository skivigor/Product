#ifndef DBWEBSOCKETSERVICE_H
#define DBWEBSOCKETSERVICE_H

#include <QObject>
#include <QJSEngine>
#include <QList>
#include <QMap>
#include <QByteArray>
#include <QSslError>

class QWebSocketServer;
class QWebSocket;

namespace db
{

class SqlDatabase;

class DbWebsocketService : public QObject
{
    Q_OBJECT

private:
    SqlDatabase         &m_db;
    QWebSocketServer    *m_pServer;
    QMap<QWebSocket *, bool>  m_clients;
    QJSEngine            m_engine;
    QJSValue             m_jsObj;
    QJSValue             m_jsModule;

private:
    DbWebsocketService(const DbWebsocketService&);
    DbWebsocketService& operator=(const DbWebsocketService&);

    void setConfig(const QString &jsPath, quint16 port, bool secured);

private slots:
    void onNewConnection();
    void onDisconnected();
    void onTextMessageReceived(const QString &message);
    void onBinaryMessageReceived(const QByteArray &message);
    void onSslErrors(const QList<QSslError> &errors);

public:
    explicit DbWebsocketService(SqlDatabase &db, const QString &jsPath, quint16 port, bool secured, QObject *parent = nullptr);
    explicit DbWebsocketService(SqlDatabase &db, const QString &jsPath, const QString &cfgPath, QObject *parent = nullptr);
    ~DbWebsocketService();

signals:

public slots:
};


}    // namespace db


#endif // DBWEBSOCKETSERVICE_H
