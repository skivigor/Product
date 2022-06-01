#ifndef DBSERVICECLIENT_H
#define DBSERVICECLIENT_H

#include <QObject>
#include <QWebSocket>
#include <QSslError>
#include <QList>
#include <QString>
#include <QUrl>

namespace db
{

class DbServiceClient : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool connected READ isConnected NOTIFY connectChanged)
    Q_PROPERTY(QString resp READ getResponse NOTIFY respChanged)

private:
    QWebSocket m_socket;
    bool       m_connected;
    QString    m_resp;

private:
    DbServiceClient(const DbServiceClient&);
    DbServiceClient& operator=(const DbServiceClient&);

private slots:
    void onConnected();
    void onDisconnected();
    void onTextMessageReceived(const QString &message);
    void onSslErrors(const QList<QSslError> &errors);

public:
    explicit DbServiceClient(QObject *parent = nullptr);
    ~DbServiceClient();

signals:
    void connectChanged();
    void respChanged();

public slots:
    bool isConnected() const     { return m_connected; }
    QString getResponse() const  { return m_resp; }
    void clearResponse();

    void connect(const QString &url);
    void send(const QString &mes);

};


}    // namespace db


#endif // DBSERVICECLIENT_H
