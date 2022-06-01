#ifndef CMDQUEUE_H
#define CMDQUEUE_H

#include <QObject>
#include <QPair>
#include <QSharedPointer>
#include <QQueue>

#include "icmdowner.h"
#include "standcmd.h"
#include "trans/serialclient.h"


namespace stand
{

class CmdQueue : public QObject
{
    Q_OBJECT

    typedef QSharedPointer<StandCmd>  CmdPtr;
    typedef QPair<ICmdOwner*, CmdPtr> CmdPair;

private:
    QQueue<CmdPair>  m_queue;
    CmdPair          m_cmd;
    bool             m_executing;
    trans::SerialClient *m_pLink;

private:
    CmdQueue(const CmdQueue&);
    CmdQueue& operator=(const CmdQueue&);

    void eraseCmd();

private slots:
    void onRcvData(const QByteArray &data);
    void processQueue();
    void onExecuted();
    void onExecError(StandCmd::ErrorType type);
    void onCmdSendData(const QByteArray &data);

public:
    explicit CmdQueue(QObject *parent = nullptr);
    ~CmdQueue();

signals:

public slots:
    void setLink(trans::SerialClient *ptr);

    void add(CmdPair cmd);
    void execute();
    void clear();
    int  size() const      { return m_queue.size(); }
    bool isEmpty() const   { return m_queue.isEmpty(); }

};


}    // namespace stand


#endif // CMDQUEUE_H
