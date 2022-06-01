#ifndef FWCMD_H
#define FWCMD_H

#include <QObject>
#include <QByteArray>
#include <QTimer>

namespace load
{

class StandCmd : public QObject
{
    Q_OBJECT

private:
    quint8      m_id;
    QByteArray  m_cmd;
    QByteArray  m_validResp;
    int         m_retryCount;
    QString     m_descr;
    QByteArray  m_resp;
    bool        m_waitAns;
    QTimer      m_timer;
    static int  m_cmdNum;

private slots:
    void processing();
    void onTimeout();

public:
    enum ErrorType
    {
        TYPE_TIMEOUT,
        TYPE_RESP
    };

public:
    explicit StandCmd(quint8 id, const QByteArray &cmd, const QByteArray &validResp, int retry, const QString &descr, QObject *parent = nullptr);
    ~StandCmd();

signals:
    void sendData(const QByteArray &cmd);
    void executed();
    void execError(StandCmd::ErrorType type);

public slots:
    quint8 getId() const  { return m_id; }
    void execute();
    void rcvData(const QByteArray &data);
    QByteArray getResponse() const  { return m_resp; }
    QString getDescription() const  { return m_descr; }
};


}    // namespace load


#endif // FWCMD_H
