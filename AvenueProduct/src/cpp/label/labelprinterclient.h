#ifndef LABELPRINTERCLIENT_H
#define LABELPRINTERCLIENT_H

#include <QObject>
#include <QWebSocket>
#include <QSslError>

namespace label
{

class LabelPrinterClient : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool connected READ isConnected NOTIFY connectChanged)
    Q_PROPERTY(QString resp READ getResponse NOTIFY respChanged)

private:
    QWebSocket m_socket;
    bool       m_connected;
    QString    m_resp;

private:
    LabelPrinterClient(const LabelPrinterClient&);
    LabelPrinterClient& operator=(const LabelPrinterClient&);

private slots:
    void onConnected();
    void onDisconnected();
    void onTextMessageReceived(const QString &message);
    void onSslErrors(const QList<QSslError> &errors);

public:
    explicit LabelPrinterClient(QObject *parent = nullptr);
    ~LabelPrinterClient();

signals:
    void connectChanged();
    void respChanged();

public slots:
    bool isConnected() const     { return m_connected; }
    QString getResponse() const  { return m_resp; }
    void clearResponse();

    void connect(const QString &url);
    void disconnect();
    void send(const QString &mes);
};


}    // namespace label


#endif // LABELPRINTERCLIENT_H
